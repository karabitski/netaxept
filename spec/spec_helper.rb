require 'rubygems'
require 'bundler/setup'

require 'netaxept' # and any other gems you need
require "netaxept_credentials"

require "mechanize"
require "pry"

Dir.glob(File.join(File.dirname(__FILE__),"support/matchers/*_matcher.rb")) do |file|
  require file
end

Netaxept.configure do |config|
  config.merchant_id      = NETAXEPT_TEST_MERCHANT_ID
  config.netaxept_token   = NETAXEPT_TEST_TOKEN
  config.default_currency = "SEK"
  config.environment      = :test
  config.debug            = false
end