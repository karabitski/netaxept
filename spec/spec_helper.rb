require 'rubygems'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'bundler/setup'

require 'netaxept' # and any other gems you need
require "netaxept_credentials"

require "mechanize"
require 'json'
require 'rspec'
require 'webmock/rspec'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

require 'vcr'
VCR.configure do |c|
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<MERCHANT_ID>') do
      ENV['MERCHANT_ID']
  end

  c.filter_sensitive_data('<NETAXEPT_TOKEN>') do
      ENV['NETAXEPT_TOKEN']
  end

  c.default_cassette_options = {
    serialize_with: :json,
    # TODO: Track down UTF-8 issue and remove
    preserve_exact_body_bytes: true,
    decode_compressed_response: true,
    record: ENV['TRAVIS'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

Dir.glob(File.join(File.dirname(__FILE__),"support/matchers/*_matcher.rb")) do |file|
  require file
end

def test_merchant_id
  ENV.fetch 'NETAXEPT_TEST_MERCHANT_ID'
end

def test_netaxept_token
  ENV.fetch 'NETAXEPT_TEST_TOKEN'
end

def netaxept_client
  Netaxept::Client.new({
    merchant_id: NETAXEPT_TEST_MERCHANT_ID,
    netaxept_token: NETAXEPT_TEST_TOKEN,
    default_currency: 'SEK',
    debug: false,
    environment: :test
  })
end