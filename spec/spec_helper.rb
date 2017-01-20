unless ENV["CODECLIMATE_REPO_TOKEN"].nil?
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require "rubygems"
require "bundler"
require "dotenv"
require "vcr"

Dotenv.load

Bundler.require(:default, :development)

require "rule1"

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.filter_sensitive_data("<TESSITURA_IP>") {
    ENV.fetch("TESSITURA_IP", "tessitura-ip")
  }
end
