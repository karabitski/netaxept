source "http://rubygems.org"

# Specify your gem's dependencies in netaxept.gemspec
gemspec

gem 'rake'

group :development do
  gem 'awesome_print', require: 'ap'
  gem 'pry'
end

group :test do
  gem 'coveralls', :require => false
  gem 'rb-fsevent', '~> 0.9'
  gem 'rspec', '~> 2.14.0'
  gem 'simplecov', require: false
  gem 'test-queue', '~> 0.1.3'
  gem 'mechanize'
  gem 'vcr', '~> 2.6.0'
  gem 'webmock', '~> 1.14.0'
end
