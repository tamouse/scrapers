require 'spec_helper'

module Scrapers

  describe AllRecipes do
    it{should respond_to :scrape}
    context "scraping" do
      before(:all) do
        @url = "http://allrecipes.com/recipe/morning-glory-muffins-i/detail.aspx"
        @recipe = VCR.use_cassette('allrecipes.morning-glory-muffins-i') do
          Scrapers::AllRecipes.new.scrape(@url)
        end
      end
      
      it "retrieves a recipe" do
        @recipe.should_not be_nil
      end
      it "should be a Hash" do
        @recipe.should be_a(Hash)
      end
      %w{title url ingredients directions photo}.map(&:to_sym).each do |key|
        it "should have key #{key}" do
          @recipe.should have_key(key)
        end
      end
    end
  end
end

