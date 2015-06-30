require 'nokogiri'
require 'date'
require 'stringex_lite'

module Scrapers
  module RubyTapas

    class Episode 

      FileLink = Struct.new :filename, :href

      attr_accessor :number, :title, :link, :description, :guid, :pub_date, :file_list, :slug

      def initialize(*args)
        if args.size == 1
          case args[0]
          when String
            parse_item(Nokogiri::XML.parse(args[0]){|c| c.noblanks}.children.first)
          when Nokogiri::XML::Element
            parse_item(args[0])
          when Hash
            parse_options(args[0])
          else
          end
        elsif args.size > 1
          assign_from_args(*args)
        end
      end

      def number_from_title
        title.scan(/\w+/).first
      end

      def slug_from_title
        title.to_s.to_url
      end

      def file_list_from_description
        find_file_list(description)
      end
      
      private

      def parse_item(item)
        self.title = item.xpath("title").text
        self.number = number_from_title
        self.slug = slug_from_title
        self.link = item.xpath("link").text
        self.description = item.xpath("description").text
        self.guid = item.xpath("guid").text
        self.pub_date = DateTime.parse(item.xpath("pubDate").text)
        self.file_list = file_list_from_description
      end

      def parse_options(options)
        self.number = options[:number]
        self.title = options[:title]
        self.slug = options[:slug]
        self.link = options[:link]
        self.description = options[:description]
        self.guid = options[:guid]
        self.pub_date = options[:pub_date]
        self.file_list = options[:file_list]
      end

      def assign_from_args(*args)
        self.number,
        self.title,
        self.slug,
        self.link,
        self.description,
        self.guid,
        self.pub_date,
        self.file_list =
          *args
      end

      def find_file_list(content)
        Nokogiri::HTML.parse(content).css("a").
          select {|link| link['href'] =~ /download\?file_id=/ }.
          map { |link| FileLink.new(link.child.text, link['href']) }
      end
    end

  end
end
