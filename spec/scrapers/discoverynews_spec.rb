require 'spec_helper'
require 'scrapers/discoverynews'


module Scrapers

  describe DiscoNews do
    it {should respond_to(:disco_downloads)}

    context "scraping" do
      let(:url) {"http://news.discovery.com/space/history-of-space/stunning-space-photos-week-june-9-14-pictures-130614.htm"}
      let(:images) do
        VCR.use_cassette('disconews.history-of-space') do
          Scrapers::DiscoNews.disco_downloads(url)
        end
      end

      it "retrieves an array of images" do
        images.should be_a(Array)
        images.each do |i|
          i.should =~ /^http:\/\/.*(jpe?g|png|gif)/
        end
      end
    end

  end

end
