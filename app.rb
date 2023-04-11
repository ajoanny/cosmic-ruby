require 'sinatra'
require 'ostruct'
require 'cosmic-ruby/entrypoints/allocate'

class App < Sinatra::Base
  include Allocate

  def initialize(app = nil, **_kwargs)
    super
  end

  def dependencies
    session = Session.new
    OpenStruct.new({
      batch_repositories: BatchRepositorySql.new(dependencies.session),
      session: session
    })
  end
end