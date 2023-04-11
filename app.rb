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
    uow = UnitOfWorkActiveRecord.new session
    OpenStruct.new({ uow: uow })
  end
end