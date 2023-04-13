class FakeSession
  def initialize
    @commit = false
    @objects = []
  end

  def add model
    @objects << model
  end

  def commit
    @commit = true
  end

  def objects
    @objects
  end

  def clear
    @objects = []
  end
end