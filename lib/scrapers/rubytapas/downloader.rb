require 'netrc_reader'
require 'mechanize'

module Scrapers
  module RubyTapas
    
    # Download the files for a given RubyTapas episode to
    # the intended destination.
    #
    class Downloader 

      attr_accessor :episode, :destination, :options, :download_directory
      
      # Create a downloader instance, with *episode* containing
      # the current Episode object, *destination* containing the
      # directory where the episode files will go. Specify *options*
      # as follows:
      #
      # - `:user`: the user name to log into the RubyTapas site
      # - `:pw`: the password to log into the RubyTapas site
      def initialize(episode, destination, options={})
        self.episode = episode
        self.destination = destination
        self.options = options
      end

      def login
        uri = URI.parse("https://#{RUBYTAPAS_HOST}")
        uri.path = "/subscriber/login"

        remote_client.get(uri)
        remote_client.current_page.tap do |page|
          page.form.field_with(:name => "username").value = options[:user]
          page.form.field_with(:name => "password").value = options[:pw]
          page.form.submit
        end

        uri.path = "/subscriber/content"
        raise "unable to log into #{RUBYTAPAS_HOST}" unless @remote_client.current_page.uri == uri
      end

      # Perform the download operation for the current Downloader object.
      def download!
        self.download_directory = make_directory
        puts "Downloading #{episode.title} to #{download_directory}"
        Dir.chdir(download_directory) do |dir|
          with_remote_client do |agent|
            episode.file_list.each do |download|
              download_file(download, agent)
            end
          end
        end
      end

      # Create the directory for the download from the destination
      # and the episode's slug.
      #
      # Raises `Errno::NOENTRY` if destination does not exist.
      # Raises `Errno::EEXIST` if destination + slug already exists.
      def make_directory
        FileUtils.mkdir(File.join(File.realpath(destination), episode.slug)).first
      end

      private

      def remote_client
        @remote_client ||= Mechanize.new
      end
      
      def with_remote_client
        yield remote_client
      end
      
      def download_file(download, agent)
        file = agent.get(download.href)
        file.filename = download.filename
        puts "Saving #{file.filename}"
        file.save!
      end

    end

  end
end
