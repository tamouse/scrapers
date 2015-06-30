require 'nokogiri'
require 'fileutils'
require 'scrapers/rubytapas/config'
require 'scrapers/rubytapas/episode'
require 'scrapers/rubytapas/dpdcart'

module Scrapers
  module RubyTapas

    # Scraper provides the methods to download, extract and build a collection
    # of RubyTapas episodes from the RubyTapas RSS feed.
    class Scraper

      attr_accessor :user, :pw, :destination, :episode_number, :netrc_reader, :dry_run, :debug
      attr_reader :dpdcart

      # *episode_number* is the RubyTapas episode number (note! not the post id!) of the
      # episode to download. If the episode number is the symbol :all, then all episodes
      # will be retrieved. Note that if any of the episodes have been previously retrieved
      # to the destination, i.e., the associated directory already exists, that episode
      # download will be skipped.
      #
      # *options* contains the options from the cli, which include:
      #
      # - "user": the username of the RubyTapas account
      # - "pw": the password of the RubyTapas account
      # - "destination": the root destination of the episode downloads
      def initialize(episode_number, options)
        self.episode_number = episode_number
        self.user = options["user"]
        self.pw = options["pw"]
        self.destination = options.fetch("destination", Dir.pwd)
        self.dry_run = options["dry_run"]
        self.debug = options["debug"]
        @dpdcart = Scrapers::RubyTapas::DpdCart.
                   new(user, pw, {dry_run: dry_run, debug: debug})
        warn "DEBUG: episode_number: #{episode_number}, options: #{options.inspect}" if debug
      end

      # Perform the scraping operation
      def scrape!
        dpdcart.login!
        if all_episodes?
          episodes.each do |episode|

            begin
              download(episode)
              friendly_pause unless dry_run
            rescue Errno::EEXIST
              warn "Episode previously downloaded. Skipping."
            end

          end
        else
          episode = find_by_episode(episode_number)
          if episode.nil?
            raise "Unknown episode for #{episode_number}"
          else
            download(episode)
          end
        end
      end

      # Print a list of episodes
      def list!
        with_pager do |pager|
          episodes.each do |episode|
            pager.puts format_episode(episode)
          end
        end
      end

      # Returns the collection of episodes.
      def episodes
        @episodes ||= fetch_episodes
      end

      # Retrieves the episode associated with *episode number*.
      def find_by_episode(episode_number)
        episodes.detect {|e| e.number == episode_number}
      end

      private

      def all_episodes?
        episode_number.to_s.downcase.to_sym == :all
      end

      # Builds a collection of all the episodes listed in the feed
      def fetch_episodes
        feed = Nokogiri::XML.parse(dpdcart.feed!)
        feed.xpath("//item").map do |item|
          Episode.new(item)
        end
      end

      def download(episode)
        download_directory = make_download_directory(episode.slug)
        episode.file_list.each do |file|
          download_file(download_directory, file.href)
        end
      end

      def download_file(dir, url)
        warn "fetching #{url}" if debug
        name, body = dpdcart.download!(url)
        File.binwrite(File.join(dir,name), body) unless dry_run
        warn "saved #{name} to #{dir}" if debug
      end


      def make_download_directory(slug)
        dir = File.join(File.realpath(destination), slug)
        warn "Downloading to #{dir}" if debug
        if dry_run
          "no dir for dry run"
        else
          FileUtils.mkdir(dir).first
        end
      end

      def friendly_pause(delay=5)
        puts
        print "Sleeping #{delay} seconds"
        delay.downto(1) { sleep 1; print "." }
        puts "\n"
      end

      def with_pager(&block)
        raise "Must be called with block" unless block_given?
        pager = open("|more","w")
        yield pager
        pager.close
      end

      def format_episode(episode)
        "%-5s\t%-40s\t%-15s" % [episode.number, episode.title, episode.pub_date.strftime("%Y-%b-%d")]
      end

    end
  end
end
