class UnitOfWork
  def persists
    raise Exception.new('Not Implemented')
  end
  def batches
    raise Exception.new('Not Implemented')
  end
end