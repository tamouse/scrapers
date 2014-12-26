require 'spec_helper'
require 'support/dir_helpers'
require 'support/use_vcr'

require 'scrapers/rubytapas/cli'

RSpec.describe "RubyTapas Thor Script", :type => :integration do

  let(:output) {double('stdout').as_null_object}

  before do
    allow_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:friendly_pause)
    allow_any_instance_of(Scrapers::RubyTapas::Downloader).to receive(:download_file) do
      puts "dummy save"
    end
  end

  describe "download command" do

    context "when scraping one episode" do

      it "retrieves one episode" do
        expect_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:scrape!).and_call_original
        
        run_in_tmpdir do |d|
          VCR.use_cassette('rubytapas-download-1', :match_requests_on => [:method, :host, :path, :query]) do
            save_stdout = $stdout
            $stdout = output
            expect(output).to receive(:puts).with(%r"Downloading 001 Binary Literals to .*/001-binary-literals")
            Scrapers::RubyTapas::CLI.start(%w[download 001 --destination=. --user=joan@example.com --pw=password])
            $stdout = save_stdout
          end
        end
      end
      
    end

    context "when scraping all episodes" do

      it "retrieves all episodes" do
        expect_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:scrape!).once.and_call_original
        expect_any_instance_of(Scrapers::RubyTapas::Downloader).to receive(:download!).exactly(268).times.and_call_original
        
        run_in_tmpdir do |d|
          VCR.use_cassette('rubytapas-download-all', :match_requests_on => [:method, :host, :path, :query]) do
            save_stdout = $stdout
            $stdout = output
            Scrapers::RubyTapas::CLI.start(%w[download all --destination=. --user=joan@example.com --pw=password])
            $stdout = save_stdout
          end
        end
      end
      
    end
    
  end

  describe "list command" do
    let(:feed) { File.read(File.join(File.expand_path("../", __FILE__), "test_data/feed.xml")) }
    before do
      allow_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:fetch_feed).and_return(feed)
      allow_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:with_pager).and_yield(output)
    end
    it "provides a printout of the available feeds" do
      expect(output).to receive(:puts).with(%r"001 *\t001 Binary Literals *\t2012-Sep-24")
      Scrapers::RubyTapas::CLI.start(%w[list --user=joan@example.com --pw=password])
    end
  end
  
  describe "version command" do
    it "prints the version numbers for rubytapas and scrapers" do
      save_stdout = $stdout
      $stdout = output
      expect(output).to receive(:print).with("rubytapas version: #{Scrapers::RubyTapas::VERSION}. scrapers version: #{Scrapers::VERSION}.\n")
      Scrapers::RubyTapas::CLI.start(%w"version")
      $stdout = save_stdout
    end
  end

end
