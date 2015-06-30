require 'spec_helper'
require "scrapers/imgur"

module Scrapers

  describe "Imgur Scraping" do
    describe "Scrapers" do
      it {expect(Scrapers).to respond_to(:imgur)}
    end

    describe "Fetch the download link" do
      let(:url) {"http://imgur.com/v70StgA"}

      it "should return the download link from a given url" do
        expect(Scrapers.imgur(url)).to match(%r{http://imgur.com/download/v70StgA/})
      end
    end
  end
end
