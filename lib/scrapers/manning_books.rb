# -*- ruby -*-
require 'mechanize'
# require 'pry'

module Scrapers
  module ManningBooks

    DASHBOARD_URL = "https://account.manning.com/dashboard"
    
    def self.scrape(dest=".", user=nil, pw=nil)
      results = Array.new

      Mechanize.start do |m|
        m.get DASHBOARD_URL
        unless m.current_page.uri == DASHBOARD_URL
          # log in
          m.current_page.form.field_with(:type => 'email').value= user
          m.current_page.form.field_with(:type => 'password').value= pw
          m.current_page.form.submit
          sleep 2
          raise "could not log in" unless m.current_page.uri.to_s == DASHBOARD_URL
        end

        book_downloads = m.current_page.links_with(:href => %r{/account/bookProduct/download})

        Dir.chdir(dest) do |dir|
          book_downloads.each do |book|
            puts "Downloading #{book.href}"
            m.get book.href
            results << [m.current_page.filename, m.current_page.uri.to_s]
            puts "Saving #{m.current_page.filename}"
            m.current_page.save! # overwrite!

            wait_a_bit 5
          end

        end

      end

      Hash[results]
    end

    def self.wait_a_bit(delay)
      puts "delaying for #{delay} second(s)"
      %w[- \ | /].cycle(delay) do |c|
        print "\r#{c}"
        sleep 1
      end
      print "\r"
    end


  end
end
