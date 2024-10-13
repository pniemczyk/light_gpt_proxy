# frozen_string_literal: true

require 'light_gpt_proxy'
require 'pry'
require 'vcr'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  VCR.configure do |vcr_config|
    vcr_config.cassette_library_dir = 'spec/vcr_cassettes'
    vcr_config.hook_into :webmock
    vcr_config.configure_rspec_metadata!
    vcr_config.allow_http_connections_when_no_cassette = true

    # vcr_config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
  end

  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description]
                  .split(/\s+/, 2).join('/')
                  .gsub(/::/, '/')
                  .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                  .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                  .tr("-", "_")
                  .downcase
                  .tr('.', '/').gsub(/[^\w\/]+/, '_')
    VCR.use_cassette(name) { example.call }
  end
end
