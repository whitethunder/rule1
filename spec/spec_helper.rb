unless ENV["CODECLIMATE_REPO_TOKEN"].nil?
  require 'codeclimate-test-reporter'
  require "simplecov"
  SimpleCov.start
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

  if ENV["CODECLIMATE_REPO_TOKEN"]
    config.after(:suite) do
      puts
      `bundle exec codeclimate-test-reporter`
    end
  end
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_hosts "codeclimate.com"
end
