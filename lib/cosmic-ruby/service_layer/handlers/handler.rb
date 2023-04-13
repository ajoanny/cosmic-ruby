class Handler
  def initialize uow
    @uow = uow
  end

  def perform event
    raise Exception('Not Implemented')
  end
end