require "mechanize"
require "netrc"

module Scrapers
  module RubyTapas

    # DpdCart is a remote service gateway object (Gateway Pattern)
    # that provides a connection to rubytapas.dpdcart.com where the
    # RubyTapas episodes and download files are available, as well as
    # the episode feed.

    class DpdCart

      # NOTE: Updating this since now I have *two* subscriptions that
      # use DPD Cart, rubytapas and elixirsips. Generalizing this
      # accordingly. :)

      # The subscription name will be filled in depending on which
      # subscription I'm downloading from. This is a stock sprintf-type
      # fill in where you pass in the subscription parameter with a
      # value, thusly:
      #
      #     DPDCART_HOST % {subscription: "rubytapas"}
      #
      DPDCART_HOST_FORMAT         = "%{subscription}.dpdcart.com"
      ENV_DPDCART_USER_FORMAT     = "%{subscription}_USER"
      ENV_DPDCART_PASSWORD_FORMAT = "%{subscription}_USER"
      LOGIN_PATH                  = '/subscriber/login'
      FEED_PATH                   = '/feed'
      CONTENT_PATH                = "/subscriber/content"

      # Subscription at dbdcart
      attr_accessor :subscription

      # User name for dpdcart account
      attr_accessor :user

      # Password for dpdcart acount
      attr_accessor :password

      def dpdcart_host         ; @dpdcart_host         ||= DPDCART_HOST_FORMAT         % {subscription: subscription} ; end
      def env_dpdcart_user     ; @env_dpdcart_user     ||= ENV_DPDCART_PASSWORD_FORMAT % {subscription: subscription} ; end
      def env_dpdcart_password ; @env_dpdcart_password ||= ENV_DPDCART_PASSWORD_FORMAT % {subscription: subscription} ; end
      def debug                ; @debug                ||= options[:debug]                                            ; end
      def dry_run              ; @dry_run              ||= options[:dry_run]                                          ; end
      def feed_url             ; @feed_url             ||= URI("https://#{dpdcart_host}#{FEED_PATH}")                 ; end
      def login_url            ; @login_url            ||= URI("https://#{dpdcart_host}#{LOGIN_PATH}")                ; end

      # Create a new instance of the DpdCart gateway.
      #
      # @param user [String] - the DpdCart account name, typically an
      # email address.
      # @param password [String] - password associated with the
      # account.
      # @param subscription [String] - subscription name at DPD Cart
      # (e.g. 'rubytapas' or 'elixirsips')
      #
      # If the user and password are empty, the information will be
      # obtained in the following order:
      #
      # - reading the environment variables `<subscriptiion>_USER` and
      # `<subscription>_PASSWORD`
      #
      #   Note that <subscription> will be the subscription passed in
      #   above.
      #
      # - reading the user's `$HOME/.netrc` file and pulling the
      # credentials that match the host name for the subscription
      # account.
      #
      # If no credentials can be found, it will raise an error:
      # `NoCredentialsError`.
      #
      def initialize(user=nil, password=nil, subscription='rubytapas', options={})
        self.options = options
        self.subscription = subscription
        set_user_and_password(user, password)
        self.agent = Mechanize.new
      end

      # Retreive the episode feed from dpdcart
      def feed!
        http_fetch(feed_url)
      end

      # Download the file from dpdcart
      def download!(file)
        login
        warn "DEBUG: downloading #{file}" if debug
        if dry_run
          warn "DEBUG: download skipped for dry run" if dry_run
          filename = file
          body = "no body"
        else
          page = agent.get(file)
          filename = page.filename
          body = page.body
        end
        [ filename, body ]
      end

      private

      attr_accessor :options, :agent

      def set_user_and_password(user, password)
        if user && password
          @user = user
          @password = password
        else
          @user, @password = get_credentials_from_environment
          unless user && password
            @user, @password = get_credentials_from_netrc
          end
        end
      end

      def get_credentials_from_environment
        [ ENV[env_dpdcart_user], ENV[env_dpdcart_password] ]
      end

      def get_credentials_from_netrc
        creds = Netrc.read[dpdcart_host]
        if creds.nil?
          warn "Could not find credentials for #{dpdcart_host}"
          exit -1
        end
        [ creds.login, creds.password ]
      end

      # Login to dpdcart before downloading
      def login
        page = agent.get login_url
        page.form.field_with(name: "username").value = user
        page.form.field_with(name: "password").value = password
        page.form.submit
        unless agent.page.title.match(/Subscription Content/)
          raise "Could not log in"
        end
        agent
      end

      def http_fetch(uri)
        request = Net::HTTP::Get.new(uri)
        request.basic_auth user, password
        Net::HTTP.start(uri.host, uri.port, {:use_ssl => true}) {|http| http.request(request)}.body
      end

    end
  end
end
