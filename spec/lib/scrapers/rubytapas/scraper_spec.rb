require 'spec_helper'
require 'scrapers/rubytapas'

describe Scrapers::RubyTapas::Scraper do

  let(:feed) do
    File.read(File.expand_path("../test_data/feed.xml", __FILE__))
  end

  let(:scraper) { Scrapers::RubyTapas::Scraper.new(episode_number, options)}
  let(:episode_number) { "001" }
  let(:episode_title ) { "001 Binary Literals" }
  let(:options) do
    {
      "destination" => '.',
      "subscription" => 'rubytapas'
    }
  end
  let(:cart) {instance_spy("Scrapers::RubyTapas::DpdCart",
                           :feed! => feed,
                           :download! => [ 'filename',
                                           'body' ]
                          )}
  before do
    allow(Scrapers::RubyTapas::DpdCart).to receive(:new).and_return(cart)
  end

  describe "#episodes" do
    it "gets a collection of episodes" do
      expect(scraper.episodes.size).to eq(267)
    end
  end

  describe "#find_by_episode" do
    subject { scraper.find_by_episode(episode_number) }
    it "returns episode 001" do
      expect(subject.number).to eq(episode_number)
    end
    it "returns episode title" do
      expect(subject.title).to eq(episode_title)
    end
  end

  describe "#scrape!" do
    before do
      allow(scraper).to receive(:friendly_pause)
      allow(FileUtils).to receive(:mkdir).and_return(["download_dir"])
      allow(File).to receive(:binwrite)
    end

    context "when scraping one episode" do
      it "scrapes one episode" do
        expect(scraper).to receive(:find_by_episode).with(episode_number).and_call_original
        scraper.scrape!
      end

    end

    context "when scraping all episodes" do
      let(:scraper) { Scrapers::RubyTapas::Scraper.new(:all, options) }

      it "scrapes all the episodes" do
        scraper.scrape!
      end
    end

  end

  describe "#list!" do
    let(:output) { spy("standard output") }

    it "prints a list of episodes" do
      expect(scraper).to receive(:with_pager).and_yield(output)
      expect(output).to receive(:puts).with(/001 *\t001 Binary Literals *\t2012-Sep-24/)
      scraper.list!
    end
  end

end
