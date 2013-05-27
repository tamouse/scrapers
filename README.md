# Scrapers

A library of web site scrapers utilizing mechanize and other goodies. Helpful in gathering images, moving things, saving things, etc.

LICENSE:: MIT
WEBSITE:: http://github.com/tamouse/scrapers

## Installation

Add this line to your application's Gemfile:

    gem 'scrapers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scrapers

## Usage

Scrapers is created as a module, either to mixin or call directly. See the various RDoc for explanation of each item.

### Getting the download image from an imgur.com page

    dir_path = File.join(APP.root,"downloads")
    image_url = Scrapers.imgur "http://imgur.com/IMGURCODE"
    local_path = Scrapers.download image_url, dir_path

### Getting a comic from gocomics.com

    dir_path = File.join(APP.root,"comics",comicname)
	image_url = Scrapers.gocomics "http://gocomics/#{comicname}"
	local_path = Scrapers.download image_url, dir_path

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
