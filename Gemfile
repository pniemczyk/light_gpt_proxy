# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in light_gpt_proxy.gemspec
gemspec

ruby '3.2.0'

gem 'rake', '~> 13.2'
group :development, :test do
  gem 'guard-rspec', '~> 4.7'
  gem 'guard-rubocop', '~> 1.5'
  gem 'pry', '~> 0.14'
  gem 'rspec', '~> 3.0'
  gem 'rubocop', '~> 1.21'
end

group :test do
  gem 'rack-test'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'
end
