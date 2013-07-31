
require 'spec_helper'


module Scrapers
  
  describe NasaApod do
    it {Scrapers::NasaApod.should respond_to :new}
    it {Scrapers::NasaApod.new(nil).should respond_to :scrape}
    it {Scrapers::NasaApod.new(nil).scrape.should be_a(Hash)}
  end
  
end
