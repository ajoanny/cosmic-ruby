require 'active_record'

class UnitOfWorkActiveRecord
  def initialize session
    @commit = false
    @session = session
    @batches = BatchRepositorySql.new session
    @products = ProductRepositorySql.new session
  end

  def commit
    @commit = true
  end

  def rollback
    raise ActiveRecord::Rollback
  end

  def persists
    ActiveRecord::Base.transaction do
      yield
      if committed?
        @session.commit()
      else
        rollback
      end
    end
  end

  def batches
    @batches
  end

  def products
    @products
  end

  def events
    events = @session.new_events
    @session.event_seen
    events
  end

  private

  def committed?
    @commit
  end


end