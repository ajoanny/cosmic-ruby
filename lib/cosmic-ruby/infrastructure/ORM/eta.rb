class Eta
  def self.to_date string
    if string.nil?
      return nil
    end
    date = string.split('-').map { |e| Integer(e) }
    Custom::Date.new date[2], date[1], date[0]
  end
end