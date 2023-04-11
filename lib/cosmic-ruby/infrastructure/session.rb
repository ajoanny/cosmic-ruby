class Session
  def initialize
    @objects_to_persist = []
  end

  def add orm, model
    @objects_to_persist << [orm, model]
  end

  def commit
    @objects_to_persist.each do |orm, model|
      a = orm._save(model)
      p a
      p orm
    end
    @objects_to_persist = []
  end
end