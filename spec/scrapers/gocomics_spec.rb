require 'spec_helper'
require "scrapers/gocomics"

module Scrapers

  describe GoComics do
    it{should respond_to :scrape}
    context "scraping" do
      before(:all) do
        @comic_strip = 'nonsequitur'
        @comic = VCR.use_cassette('gocomics.nonsequitur') do
          Scrapers::GoComics.scrape(@comic_strip)
        end
      end

      it "retrieves a comic" do
        @comic.should_not be_nil
      end
      it "should be a Hash" do
        @comic.should be_a(Hash)
      end
      %w{title url pubdate img_src}.map(&:to_sym).each do |key|
        it "should have key #{key}" do
          @comic.should have_key(key)
        end
      end
      context "title" do
        it{@comic[:title].should_not be_empty}
        it{@comic[:title].should match /Non Sequitur Comic Strip on GoComics.com/}
      end
      context "url" do
        it{@comic[:url].should_not be_empty}
        it{@comic[:url].should match /www\.gocomics\.com\/nonsequitur/}
      end
      context "pubdate" do
        it{@comic[:pubdate].should_not be_empty}
        it{Date.parse(@comic[:pubdate]).should be_a(Date)}
      end
      context "img_src" do
        it{@comic[:img_src].should_not be_empty}
        it{URI.parse(@comic[:img_src]).should be_a(URI::HTTP)}
      end

    end
  end
end
