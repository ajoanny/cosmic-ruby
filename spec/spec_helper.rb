# frozen_string_literal: true
require 'yaml'
require 'active_record'
require 'rack/test'
require 'sinatra'
require_relative '../app'


ENV['RACK_ENV'] = 'test'

class ServerTest < Sinatra::Base
  def self.inject dependencies
    @@dependencies = dependencies
  end
  def dependencies
    @@dependencies
  end
end


db_config       = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.after(:each) do
    ORM::Batch.destroy_all
    ORM::OrderLine.destroy_all
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end