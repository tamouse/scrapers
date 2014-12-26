require 'netrc_reader'
require 'uri'
require 'nokogiri'
require 'scrapers/rubytapas/config'
require 'scrapers/rubytapas/episode'
require 'scrapers/rubytapas/downloader'

module Scrapers
  module RubyTapas

    # Scraper provides the methods to download, extract and build a collection
    # of RubyTapas episodes from the RubyTapas RSS feed.
    class Scraper 

      attr_accessor :user, :pw, :destination, :episode_number, :netrc_reader, :dry_run, :debug
      # This will normally be calculated, but this allows injection
      attr_writer :feed_url

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
        self.netrc_reader = options.fetch("netrc_reader") { NetrcReader.new(RUBYTAPAS_HOST)}
        self.user = options.fetch("user") { netrc_reader.user }
        self.pw = options.fetch("pw") { netrc_reader.pw }
        self.destination = options.fetch("destination", Dir.pwd)
        self.feed_url = options.fetch("feed_url", feed_url)
        self.dry_run = options["dry_run"]
        self.debug = options["debug"]
        warn "DEBUG: episode_number: #{episode_number}, options: #{options.inspect}" if debug
      end

      # Perform the scraping operation
      def scrape!
        downloader = Downloader.new(nil, destination, {user: user, pw: pw, debug: debug, dry_run: dry_run})
        downloader.login unless dry_run
        if all_episodes?
          episodes.each do |episode|
            downloader.episode = episode

            warn "Skipping episde #{episode.title}" if dry_run

            begin
              downloader.download! unless dry_run
            rescue Errno::EEXIST
              warn "Episode previously downloaded. Skipping."
            end

            friendly_pause unless dry_run
          end
        else
          episode = find_by_episode(episode_number)
          raise "Unknown episode for #{episode_number}" if episode.nil?
          downloader.episode = episode
          warn "Skipping episode #{episode.title}" if dry_run
          downloader.download! unless dry_run
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

      def feed_url
        @feed_url ||= URI.parse("https://#{RUBYTAPAS_HOST}#{FEED_PATH}")
      end

      # Builds a collection of all the episodes listed in the feed
      def fetch_episodes
        feed = Nokogiri::XML.parse(fetch_feed)
        feed.xpath("//item").map do |item|
          Episode.new(item)
        end
      end

      # Fetches the feed.xml
      # Returns the feed contents.
      def fetch_feed
        warn "DEBUG: fetching feed..." if debug
        start_time = Time.now
        uri = URI(feed_url)
        request = Net::HTTP::Get.new(uri)
        request.basic_auth user, pw
        response = Net::HTTP.start(uri.host, uri.port, {:use_ssl => true}) do |http|
          http.request(request)
        end
        stop_time = Time.now
        warn "DEBUG: feed retreived in #{"%-03.3f" % (stop_time.to_f - start_time.to_f)} seconds" if debug
        response.body
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
