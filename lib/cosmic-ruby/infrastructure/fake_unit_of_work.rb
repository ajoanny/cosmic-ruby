class FakeUnitOfWork
  attr_reader :commit, :rollback

  def initialize batches
    @commit = false
    @rollback = false
    @batches = batches
  end

  def commit
    @commit = true
  end

  def rollback
    @rollback = true
  end

  def persists
    begin
      yield
    rescue Exception => e
      rollback
      raise e
    end

  end

  def batches
    @batches
  end

  def committed?
    @commit
  end

  def rollbacked?
    @rollback
  end
end