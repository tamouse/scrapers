require 'spec_helper'
require "scrapers/sinfest"

module Scrapers

  describe Sinfest do
    it{should respond_to :scrape}
    context "scraping" do
      before(:all) do
        @comic = VCR.use_cassette('sinfest') do
          Scrapers::Sinfest.scrape
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
        it{@comic[:title].should match /Nails/}
      end
      context "url" do
        it{@comic[:url].should_not be_empty}
        it{@comic[:url].should match /http:\/\/sinfest.net/}
      end
      context "pubdate" do
        it{@comic[:pubdate].should_not be_empty}
        it{Date.parse(@comic[:pubdate]).should be_a(Date)}
      end
      context "img_src" do
        it{@comic[:img_src].should_not be_empty}
        it{URI.parse(@comic[:img_src]).should be_a(URI::HTTP)}
        it{@comic[:img_src].should eq 'http://sinfest.net/comikaze/comics/2013-10-19.gif'}
      end

    end
  end
end
