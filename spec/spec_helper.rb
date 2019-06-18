# frozen_string_literal: true

require 'bundler/setup'
require 'sequel/opentracing'
require 'opentracing_test_tracer'
require 'database_cleaner'

def test_db
  Sequel.sqlite('.spec.db')
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.before(:suite) do
    DatabaseCleaner[:sequel,
                    { :connection => test_db}].strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
