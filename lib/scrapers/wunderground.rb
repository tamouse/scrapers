# -*- ruby -*-
require 'mechanize'
# require 'pry'

module Scrapers
  module Wunderground

    def self.scrape(url)
      results = Hash.new

      Mechanize.start do |m|
        m.get(url)
        results["title"] = m.page.title
        results["url"] = m.page.uri.to_s
        snippet = m.page.search('#weather-snippet')
        results["snippet"] = snippet.to_html.gsub(/[\n\t]+/,'')
        results["location"] = snippet.at_css('h1').text.strip
        results["image"] = snippet.at_css('#condition-img div img')['src']
        results["temp"] = snippet.at_css('#temp').text.gsub(/[[:space:]]+/,' ').strip
        results["condition"] = snippet.at_css('#condition').text.strip
        results["feel"] = snippet.at_css('#feel').text.gsub(/[[:space:]]+/,' ').strip
        results["high"] = snippet.at_css('.high').text.gsub(/[[:space:]]+/,' ').strip
        results["low"] = snippet.at_css('.low').text.gsub(/[[:space:]]+/,' ').strip
      end

      results
    end

  end
end
