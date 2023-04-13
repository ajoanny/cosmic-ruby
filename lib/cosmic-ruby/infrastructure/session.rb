class Session
  def initialize
    @objects_to_persist = []
    @events = []
  end

  def add orm, model
    @objects_to_persist << [orm, model]
  end

  def commit
    @objects_to_persist.each do |orm, model|
      orm._save(model)
      @events << (model.try(:events) || [])
    end
    @objects_to_persist = []
  end

  def new_events
    @events.flatten
  end

  def event_seen
    @events = []
  end
end