# -*- ruby -*-
require 'spec_helper'
require 'scrapers/manning_books'
require 'ostruct'

RSpec.describe Scrapers::ManningBooks::Scraper do
  describe "verify Class method signatures" do
    it "responds to :new" do
      expect(Scrapers::ManningBooks::Scraper).to respond_to(:new)
    end
  end
  describe "verify instance method signatures" do
    subject { Scrapers::ManningBooks::Scraper.new }
    it { is_expected.to respond_to :scrape }
    it { is_expected.to respond_to :login }
    it { is_expected.to respond_to :wait_a_bit }
    it { is_expected.to respond_to :download_books }
  end
  describe "#login" do
    let(:scraper) { Scrapers::ManningBooks::Scraper.new } 
    let(:agent) { double('agent') }

    before do
      allow(Scrapers::NetrcReader).to receive(:new) do
        OpenStruct.new(user: "joe@example.com", pw: "password")
      end
    end

    it "verify user" do
      expect(scraper.user).to eq("joe@example.com")
    end
    it "verify pw" do
      expect(scraper.pw).to eq("password")
    end

    context "when login is passed a block" do
      it "logs in and yields the block" do
        expect(agent).to receive(:get).and_return(agent)
        expect(agent).to receive(:current_page).at_least(5).times.and_return(agent)
        expect(agent).to receive(:uri)
        expect(agent).to receive(:form).exactly(3).times.and_return(agent)
        expect(agent).to receive(:field_with).exactly(2).times.and_return(agent)
        expect(agent).to receive(:value=).exactly(2).times.and_return(agent)
        expect(agent).to receive(:submit).and_return(agent)
        expect(agent).to receive(:uri).and_return(Scrapers::ManningBooks::DASHBOARD_URL)
        scraper.login(agent) { |m| @result = "in yield" }
        expect(@result).to eq("in yield")
      end
      
    end

    context "when login is not passed a block" do
      it "raises an exception" do
        expect{ scraper.login(agent) }.to raise_error("Must provide a block to execute after logged in to site")
      end
    end

  end

  describe "#download_books" do
    let(:scraper) {Scrapers::ManningBooks::Scraper.new}
    let(:agent) {double('agent')}
    let(:books) do
      3.times.map do |i|
        OpenStruct.new(href: "http://#{Scrapers::ManningBooks::DASHBOARD_URL}/#{i}")
      end
    end


    before do
      allow(Scrapers::NetrcReader).to receive(:new) do
        OpenStruct.new(user: "joe@example.com", pw: "password")
      end

      allow(scraper).to receive(:wait_a_bit).at_least(:once)
    end

    it "downloads the books" do
      save_stdout = $stdout
      $stdout = double('output').as_null_object
      expect(agent).to receive(:get).exactly(3).times
      expect(agent).to receive(:current_page).exactly(3*4).times.and_return(agent)
      expect(agent).to receive(:filename).exactly(3*2).times.and_return("FILENAME")
      expect(agent).to receive(:save!).exactly(3).times
      expect(agent).to receive(:uri).exactly(3).times
      results = scraper.download_books(agent, books)
      $stdout = save_stdout
      expect(results.size).to eq(3)
    end

  end

  # Saving the best for last
  describe "#scrape" do
    let(:scraper) {Scrapers::ManningBooks::Scraper.new}
    let(:agent) {double('agent').as_null_object}
    let(:netrc_reader) {double('netrc_reader').as_null_object}
    let(:book_list) {[['book1','url1'],['book2','url2']]}

    before do
      allow(Scrapers::NetrcReader).to receive(:new).and_return(netrc_reader)
      allow(scraper).to receive(:wait_a_bit).at_least(:once)
      allow(scraper).to receive(:login).and_yield(agent)
    end

    it "scrapes the dashboard" do
      expect(Mechanize).to receive(:start).and_yield(agent)
      expect(scraper).to receive(:download_books).and_return(book_list)
      scraper.scrape
    end

  end
end
