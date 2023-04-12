class FakeUnitOfWork
  attr_reader :commit, :rollback, :events

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
      puts @session.objects
      @events = @session.objects
              .map { |object| object.try(:events) || [] }
              .map { |events| events[-1] }
              .compact

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