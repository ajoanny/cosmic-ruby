class Session
  def initialize
    @objects_to_persist = []
  end

  def add orm, model
    @objects_to_persist << [orm, model]
  end

  def commit
    @objects_to_persist.each do |orm, model|
      orm._save(model)
    end
    @objects_to_persist = []
  end

  def dispatch_events
    @objects_to_persist
      .map { |_, model| model.try(:events) }
      .flatten
      .each { |event| MessageBus.handle event }
  end
end