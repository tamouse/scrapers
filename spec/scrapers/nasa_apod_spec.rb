
require 'spec_helper'


module Scrapers
  
  describe NasaApod do
    it {Scrapers::NasaApod.should respond_to :scrape}

    context "scrape" do
      let(:url){"http://apod.nasa.gov/apod/astropix.html"}
      let(:apod_hash){
        VCR.use_cassette("#{example.description.gsub(/[^-[:alnum:]]/,'')}.cassette", :record => :new_episodes) do
          Scrapers::NasaApod.scrape(url)
        end}
      it {apod_hash.should be_a(Hash)}
      %w{title link description pubDate guid content_encoded}.map(&:to_sym).each do |attr|
        it "should include #{attr}" do
          apod_hash.keys.should include attr
        end
        it {apod_hash[attr].should_not be_nil}
        it {apod_hash[attr].should be_a(String)}

      end

    end

  end

end
