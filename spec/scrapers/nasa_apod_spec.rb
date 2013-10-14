
require 'spec_helper'


module Scrapers
  
  describe NasaApod do
    it {Scrapers::NasaApod.should respond_to :scrape}

    context "scrape" do

      before(:all) do
        pending "until apod back up"
        # @url = "http://apod.nasa.gov/apod/astropix.html"
        # VCR.use_cassette("nasa-apod", :record => :new_episodes) do
        #   @apod_hash = Scrapers::NasaApod.scrape(@url)
        # end
      end
      
      xit "should be a Hash" do
        @apod_hash.should be_a(Hash)
      end
      
      %w{title link description pubDate guid content_encoded}.map(&:to_sym).each do |attr|
        it "should include #{attr}" do
          @apod_hash.keys.should include attr
        end
        xit "#{attr} should not be nil" do
          @apod_hash[attr].should_not be_nil
        end
        
        xit "#{attr} should be a Sring" do
          @apod_hash[attr].should be_a(String)
        end

      end
    end
  end
end
