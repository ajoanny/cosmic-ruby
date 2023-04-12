class FakeSession
  def initialize
    @commit = false
    @objects = []
  end

  def add _, model
    @objects << model
  end

  def commit
    @commit = true
  end

  def objects
    @objects
  end
end