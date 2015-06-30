require 'netrc'
require 'mechanize'

module Scrapers
  module RubyTapas

    # DpdCart is a remote service gateway object (Gateway Pattern)
    # that provides a connection to rubytapas.dpdcart.com where the
    # RubyTapas episodes and download files are available, as well as
    # the episode feed.
    class DpdCart

      RUBYTAPAS_HOST = 'rubytapas.dpdcart.com'
      ENV_RUBYTAPAS_USER = 'RUBYTAPAS_USER'
      ENV_RUBYTAPAS_PASSWORD = 'RUBYTAPAS_PASSWORD'
      LOGIN_PATH = '/subscriber/login'
      LOGIN_URL = "https://#{RUBYTAPAS_HOST}#{LOGIN_PATH}"
      FEED_PATH = '/feed'
      FEED_URL = "https://#{RUBYTAPAS_HOST}#{FEED_PATH}"
      CONTENT_PATH = "/subscriber/content"
      CONTENT_URL = "https://#{RUBYTAPAS_HOST}#{CONTENT_PATH}"

      # User name for dpdcart account
      attr_accessor :user

      # Password for dpdcart acount
      attr_accessor :password

      attr_accessor :dry_run, :debug

      # Create a new instance of the DpdCart gateway.
      #
      # @param user [String] - the DpdCart account name, typically an
      # email address.
      # @param password [String] - password associated with the
      # account.
      #
      # If the user and password are empty, the information will be
      # obtained in the following order:
      #
      # - reading the environment variables `RUBYTAPAS_USER` and
      # `RUBYTAPAS_PASSWORD`
      #
      # - reading the user's `$HOME/.netrc` file and pulling the
      # credentials that match the host name for the rubytapas
      # account.
      #
      # If no credentials can be found, it will raise and error:
      # `NoCredentialsError`.
      def initialize(user=nil, password=nil, options={})
        self.dry_run = options[:dry_run]
        self.debug = options[:debug]
        if user && password
          @user = user
          @password = password
        else
          @user, @password = get_credentials_from_environment
          unless user && password
            @user, @password = get_credentials_from_netrc
          end
        end
        self.agent = Mechanize.new
      end

      # Return the episode feed from dpdcart
      def feed!
        uri = URI(FEED_URL)
        request = Net::HTTP::Get.new(uri)
        request.basic_auth user, password
        Net::HTTP.start(uri.host, uri.port, {:use_ssl => true}) {|http| http.request(request)}.body
      end

      # Login to dpdcart before downloading
      def login!
        page = agent.get LOGIN_URL
        page.form.field_with(name: "username").value = user
        page.form.field_with(name: "password").value = password
        page.form.submit
        unless agent.page.title.match(/Subscription Content/)
          raise "Could not log in"
        end
        agent
      end

      # Download the file from dpdcart
      def download!(file)
        warn "DEBUG: downloading #{file}" if debug
        if dry_run
          warn "DEBUG: download skipped for dry run" if dry_run
          filename = file
          body = "no body"
        else
          page = agent.get(file) unless dry_run
          filename = page.filename
          body = page.body
        end
        [ filename, body ]
      end

      private

      attr_accessor :options, :agent

      def get_credentials_from_environment
        [ ENV[ENV_RUBYTAPAS_USER], ENV[ENV_RUBYTAPAS_PASSWORD] ]
      end

      def get_credentials_from_netrc
        creds = Netrc.read[RUBYTAPAS_HOST]
        [ creds.login, creds.password ]
      end

    end
  end
end
