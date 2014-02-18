require 'fileutils'
require 'ostruct'

module Scrapers
  
  module RubyTapas

    module_function

    # Save the post and attachments from an episode of RubyTapas
    # in a directory determined from the episode title.
    #
    # Example:
    #  episode url: "https://rubytapas.dpdcart.com/subscriber/post?id=443"
    #  title: "177 Aliasing | RubyTapas"
    #  subdirectory: /177-aliasing
    #
    # Parameters:
    #
    # * *url* - url of the episode to download
    # * *user* - username used to log into dpdcart
    # * *pw* - password used with username
    # * *dest* - destination directory to put episode subdirectory
    #
    def scrape(url=nil, user=nil, pw=nil, dest=".")
      raise "Must give user and password for RubyTapas downloads" if user.to_s.empty? or pw.to_s.empty?
      dest = File.realdirpath(dest)
      raise "Destination #{dest} must be a writeable directory" unless File.directory?(dest) and File.writable?(dest)

      Mechanize.start do |m|

        tapas = OpenStruct.new

        # First time, we will get redirected to the login page
        m.get url
        m.current_page.form.field_with(:name => "username").value = user
        m.current_page.form.field_with(:name => "password").value = pw
        m.current_page.form.submit

        # Second time, we should land on episode page
        m.get url
        raise "Not where I expected. #{m.current_page.uri} is not #{url}" unless m.current_page.uri != url

        m.current_page.tap do |page|
          tapas.title = page.title.strip
          tapas.episode_dir = File.join(dest,tapas.title.split("|").first.strip.downcase.gsub(%r{\s+},'-'))
          tapas.attachments = page.links_with(:href => %r{\bdownload\b})
          FileUtils.mkdir(tapas.episode_dir)
          Dir.chdir(tapas.episode_dir) do |dir|
            tapas.attachments.each do |att|
              puts "fetching #{att.text}"
              file = att.click
              puts "saving #{file.filename}"
              file.save
            end
          end
        end
        
        tapas
        
      end
    end
  end
  
end
