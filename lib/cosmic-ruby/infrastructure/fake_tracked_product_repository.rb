
class FakeTrackedProductRepository < FakeProductRepository

  def initialize set, session
    super(set)
    @session = session
  end

  def get sku
    product = super sku
    @session.add nil, product
    product
  end

end