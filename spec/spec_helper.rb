# frozen_string_literal: true

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"


  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end