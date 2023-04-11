class Session
  def initialize
    @objects_to_persist = []
  end

  def add orm_class, method, object
    @objects_to_persist << [orm_class, method, object]
  end

  def commit
    @objects_to_persist.each do |orm_class, method, object|
      orm_class.send(:from,object)
               .send(method)
    end
    @objects_to_persist = []
  end
end