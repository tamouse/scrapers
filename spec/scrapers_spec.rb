require 'spec_helper'
require 'scrapers'

module Scrapers
  
  describe Scrapers do
    it{ expect(Scrapers).to respond_to(:agent) }
  end
  
end
