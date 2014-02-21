module Scrapers
  module ManningDashboard

    def self.scrape(url)
      results = Hash.new

      Mechanize.start(url) do |m|

      end

      results
    end

  end
end
