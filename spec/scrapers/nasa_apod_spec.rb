require 'spec_helper'
require "scrapers/nasa_apod"

module Scrapers

  describe NasaApod do
    it {Scrapers::NasaApod.should respond_to :scrape}

    context "scrape" do

      before(:all) do
        @url = "http://apod.nasa.gov/apod/astropix.html"
        VCR.use_cassette("nasa-apod", :record => :new_episodes) do
          @apod_hash = Scrapers::NasaApod.scrape(@url)
        end
      end

      it "should be a Hash" do
        @apod_hash.should be_a(Hash)
      end

      %w{title link description pubDate guid content_encoded}.map(&:to_sym).each do |attr|
        it "should include #{attr}" do
          @apod_hash.keys.should include attr
        end
        it "#{attr} should not be nil" do
          @apod_hash[attr].should_not be_nil
        end

        it "#{attr} should be a Sring" do
          @apod_hash[attr].should be_a(String)
        end

      end
    end
  end
end
