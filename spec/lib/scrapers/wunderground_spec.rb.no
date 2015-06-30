# -*- ruby -*-
require 'spec_helper'
require 'scrapers/wunderground'

module Scrapers

  describe Wunderground do
    it{should respond_to :scrape}
    context "scraping" do
      before(:all) do
        @scrape = VCR.use_cassette('wunderground') do
          @result = Scrapers::Wunderground.scrape
        end
      end
      
      it {expect(@result).to_not be_nil}
      
    end
  end
end
