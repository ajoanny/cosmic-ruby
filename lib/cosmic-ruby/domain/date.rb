module Custom
  class Date
    attr :day, :month, :year
    attr_reader :day, :month, :year
    alias_method :eql?, :==

    def initialize day, month, year
      @day = day
      @month = month
      @year = year
    end

    def == other
      other.class == self.class &&
        other.day == @day &&
        other.month == @month &&
        other.year == @year
    end

    def hash
      [self.class, day, month, year].hash
    end

    def <=> other
      if other.nil?
        return -1
      end
      other.to_s <=> to_s
    end

    def to_s
      "#{year}-#{month}-#{day}"
    end
  end
end