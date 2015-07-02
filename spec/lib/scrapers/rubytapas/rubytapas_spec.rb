require 'spec_helper'
require 'support/use_vcr'

require 'scrapers/rubytapas/cli'

RSpec.describe "RubyTapas Thor Script", :type => :integration do

  let(:output) {double('stdout').as_null_object}
  let(:feed) do
    File.read(File.expand_path("../test_data/feed.xml", __FILE__))
  end
  let(:download) { ['filename', 'body'] }

  let(:cart) do
    instance_spy("Scrapers::RubyTapas::DpdCart",
                 :feed! => feed,
                 :download! => download
                )
  end

  before do
    allow_any_instance_of(Scrapers::RubyTapas::Scraper).
      to receive(:friendly_pause)
    allow(Scrapers::RubyTapas::DpdCart).
      to receive(:new).and_return(cart)
    allow(FileUtils).to receive(:mkdir).and_return(["download-dir"])
    allow(File).to receive(:binwrite)
  end

  describe "download command" do

    context "when scraping one episode" do

      it "retrieves one episode" do
        expect_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:scrape!).once.and_call_original
        expect(cart).to receive(:download!).exactly(3).times

        VCR.use_cassette('rubytapas-download-1', :match_requests_on => [:method, :host, :path, :query]) do
          Scrapers::RubyTapas::CLI.start(%w[download 001 --destination=. --user=joan@example.com --pw=password])
        end
      end

    end

    context "when scraping all episodes" do

      it "retrieves all episodes" do
        expect_any_instance_of(Scrapers::RubyTapas::Scraper).to receive(:scrape!).once.and_call_original
        expect(cart).to receive(:download!).exactly(933).times

        VCR.use_cassette('rubytapas-download-all', :match_requests_on => [:method, :host, :path, :query]) do
          save_stdout = $stdout
          # $stdout = output
          Scrapers::RubyTapas::CLI.start(%w[download all --destination=. --user=joan@example.com --pw=password])
          $stdout = save_stdout
        end
      end

    end

  end

  describe "list command" do
    let(:feed) { File.read(File.join(File.expand_path("../", __FILE__), "test_data/feed.xml")) }
    before do
      allow(Scrapers::RubyTapas::DpdCart).
        to receive(:new).and_return(cart)
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
