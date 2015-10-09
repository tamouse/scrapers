# -*- ruby -*-
require 'mechanize'
require 'netrc_reader'

module Scrapers
  module ManningBooks

    NETRC_MANNING_ENTRY = 'manning'
    DASHBOARD_URL = "https://account.manning.com/dashboard"
    DELAY_TIME = 5 # seconds

    class Scraper
      attr_accessor :user, :pw, :delay_time, :destination, :dry_run

      def initialize(options={})
        netrc_reader = ::Scrapers::NetrcReader.new(NETRC_MANNING_ENTRY)
        @user = options.fetch("user", netrc_reader.user)
        @pw = options.fetch("pw", netrc_reader.pw)
        @delay_time = options.fetch("delay", DELAY_TIME)
        @destination = options.fetch("destination", ".")
        @dry_run = options.fetch("dry_run", false)
      end

      def scrape
        @results = nil
        Dir.chdir(destination) do |dir|

          Mechanize.start do |m|
            login(m) do |m|
              books = build_book_list(m.current_page)
              @results = download_books(m, books)
            end
          end

        end
        @results
      end

      def login(agent, &block)
        raise "Must provide a block to execute after logged in to site" unless block_given?

        agent.get DASHBOARD_URL
        unless agent.current_page.uri == DASHBOARD_URL
          # log in
          agent.current_page.form.field_with(:type => 'email').value= user
          agent.current_page.form.field_with(:type => 'password').value= pw
          agent.current_page.form.submit
          sleep 2
          raise "could not log in" unless agent.current_page.uri.to_s == DASHBOARD_URL
        end
        yield agent
      end

      def build_book_list(page)
        page.search('.book').map do |book|
          {
            title: book.at('[data-type=title]').children.first.text,
            downloads: book.at('.book_downloads').search('a').map do |link|
              type = link.children.first.text.downcase
              next unless type.match(/download/)
              type = type.split(" ").last
              [type.to_sym, link.attr(:href)]
            end.compact.to_h
          }
        end
      end

      def download_books(agent, books)
        books.map do |book|
          puts "Retrieving #{book[:title]}"
          downloads = book[:downloads].map do |type, href|
            next unless %i[pdf epub kindle].include?(type)
            print "  downloading #{type} ..."
            agent.get href unless dry_run
            agent.current_page.save! unless dry_run
            puts "saved #{agent.current_page.filename}"
            [agent.current_page.filename, href]
          end.compact.to_h
          wait_a_bit delay_time
          [book[:title], downloads]
        end.to_h
      end

      def wait_a_bit(delay)
        puts "delaying for #{delay} second(s)"
        %w[- * | +].cycle do |c|
          print "\r#{c}"
          sleep 1
          delay -= 1
          break if delay < 1
        end
        print "\r"
      end

    end
  end
end
