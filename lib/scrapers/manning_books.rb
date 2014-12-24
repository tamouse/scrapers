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
        Mechanize.start do |m|
          login(m) do |m|
            book_downloads = m.current_page.links_with(:href => %r{/account/bookProduct/download})
            Dir.chdir(destination) do |dir|
              @results = download_books(m, book_downloads)
            end
          end
        end

        Hash[@results]
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


      def download_books(agent, books)
        books.map do |book|
          bookname = book.node.parent.parent.parent.parent.at_css('h1').text
          puts "Downloading #{bookname} from #{book.href}"
          if dry_run
            warn "dry run, not saving"
          else
            agent.get book.href
            puts "Saving #{agent.current_page.filename}"
            agent.current_page.save! # overwrite!
          end
          
          wait_a_bit delay_time
          [agent.current_page.filename, agent.current_page.uri.to_s]
        end
      end

    end
  end
end

