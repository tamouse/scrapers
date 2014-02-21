# -*- ruby -*-
require 'spec_helper'
require 'scrapers/manning_books'

module Scrapers

  describe ManningBooks do
    it{should respond_to :scrape}
    context "scraping" do
      before(:all) do
        @comic = VCR.use_cassette('manning_books') do
          @result = Scrapers::ManningBooks.scrape
        end
      end
      
      it {expect(@result).to_not be_nil}
      
    end
  end
end
