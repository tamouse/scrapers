require "bundler/gem_tasks"
require "highline/import"
require "active_support/core_ext/string/inflections"

desc "Create the basis for a new scraper"
task :new, [:module_name] do |t, args|
  if args.module_name
    module_name = args.module_name
  else
    module_name = ask("<%= color('What is the name of your new scraper module?', YELLOW) %>") {|q| q.default = "NewScraper" }
  end

  file_name = module_name.underscore + ".rb"
  dir_name = File.join(File.dirname(__FILE__),'lib','scrapers')

  new_scraper_path = File.join(dir_name, file_name)

  template = <<-EOT
module Scrapers
  module #{module_name}

    def self.scrape(url)
      results = Hash.new

      Mechanize.start(url) do |m|

      end

      results
    end

  end
end
EOT
  
  if File.exist?(new_scraper_path)
    if agree("<%= color('#{file_name}', BLUE); color('already exists. Do you want to overwrite it?', YELLOW) %>", true)
      File.unlink(new_scraper_path)
    else
      exit 0
    end
  end
  
  File.write(new_scraper_path, template)
  say("<%= color('New scraper in', YELLOW) %> <%= color('#{new_scraper_path}', BLUE) %>")
  
end
