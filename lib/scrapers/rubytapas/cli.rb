require 'thor'
require 'scrapers/version'
require 'scrapers/rubytapas'

module Scrapers
  module RubyTapas
    
    # Thor script that handles things with Avdi Grimm's RubyTapas
    class CLI < Thor

      # Download an episode, or all episodes.
      desc "download EPISODE", "Downloads the listed episode's files into a new directory with the episode tag in the given directory. Specifying ALL for the episode number downloads all episodes."
      method_option :debug, type: :boolean
      method_option :dry_run, type: :boolean
      method_option :destination, :aliases => %w{-d}, :desc => "Destination to store the downloads. Default is the current working directory.", :default => "."
      method_option :user, :aliases => %w{-u}, :desc => "dpdcart user. Default is read from $HOME/.netrc"
      method_option :pw, :aliases => %w{-p}, :desc => "dpdcart password. Default is read from $HOME/.netrc"
      def download(episode)
        Scrapers::RubyTapas::Scraper.new(episode, options).scrape!
      end

      # Get a list of available episodes
      desc "list", "Show a list of the available episodes"
      method_option :user, :aliases => %w{-u}, :desc => "dpdcart user. Default is read from $HOME/.netrc"
      method_option :pw, :aliases => %w{-p}, :desc => "dpdcart password. Default is read from $HOME/.netrc"
      def list()
        Scrapers::RubyTapas::Scraper.new(nil, options).list!
      end

      # Version Info
      desc "version", "Show the rubytapas and scrapers library version info"
      def version
        say "rubytapas version: #{Scrapers::RubyTapas::VERSION}. scrapers version: #{Scrapers::VERSION}."
      end

    end

  end
end
