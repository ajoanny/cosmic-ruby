class FakeUnitOfWork
  attr_reader :commit, :rollback

  def initialize repositories, session = FakeSession.new
    @commit = false
    @rollback = false
    @batches = repositories[:batches]
    @products = repositories[:products]
    @session = session
    @events = []
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

  def events
    events = @session.objects.map(&:events).flatten
    @session.clear
    events
  end
end