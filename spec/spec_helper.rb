# frozen_string_literal: true
require 'yaml'
require 'active_record'

db_config       = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"


  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end