require 'thor'
require 'scrapers/wunderground'
require 'awesome_print'

class Wunderground < Thor

  VERSION = '1.0.0'
  WUNDERGROUND_URL = "http://www.wunderground.com/"

  desc "current", "Show the current local weather conditions from #{WUNDERGROUND_URL}"
  def current
    current_conditions
  end

  desc "location", "Show location for current local weather"
  def location
    current_conditions["location"]
  end

  desc "image", "URL for current local weather conditions"
  def image
    current_conditions["image"]
  end

  desc "temp", "Current local temperature with units"
  def temp
    current_conditions["temp"]
  end

  desc "condition", "Current condition"
  def condition
    current_conditions["condition"]
  end

  desc "feel", "Feels like temperature"
  def feel
    current_conditions["feel"]
  end

  desc "high", "Forecast High Temperature"
  def high
    current_conditions["high"]
  end

  desc "low", "Forecast Low temperature"
  def low
    current_conditions["low"]
  end

  private

  def current_conditions
    @_current_conditions ||= Scrapers::Wunderground.scrape(WUNDERGROUND_URL)
  end

end
