class FakeUnitOfWork
  attr_reader :commit, :rollback

  def initialize batches, products = Set[]
    @commit = false
    @rollback = false
    @batches = batches
    @products = products
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

  def products
    @products
  end

  def committed?
    @commit
  end

  def rollbacked?
    @rollback
  end
end