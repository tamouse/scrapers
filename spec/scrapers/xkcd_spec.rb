require 'spec_helper'
require "scrapers/xkcd"

describe Scrapers::Xkcd do
  it {should respond_to :scrape}
  context "scraping" do
    before(:all) do
      @comic = VCR.use_cassette("xkcd") do
        Scrapers::Xkcd.scrape 149
      end
      @expected = {
        :title      => "Sandwich",
        :url        => "http://xkcd.com/149/",
        :img_src    => "http://imgs.xkcd.com/comics/sandwich.png",
        :img_title  => "Proper User Policy apparently means Simon Says.",
        :img_alt    => "Sandwich",
        :pubdate    => "2010-02-01",
      }
    end
    it "should retrieve the comic" do
      @comic.should_not be_nil
    end
    it "should be a Hash" do
      @comic.should be_a(Hash)
    end
    it "should return expected" do
      @comic.should eq @expected
    end
  end
end
