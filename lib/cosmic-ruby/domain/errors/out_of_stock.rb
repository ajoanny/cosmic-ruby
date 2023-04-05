class OutOfStock < Exception
  def == other
    other.class == self .class
  end
end