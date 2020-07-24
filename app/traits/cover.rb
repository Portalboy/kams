module Cover
  def initialize(*args)
    super

    @cover = true
    @cover_capacity = 1
    @covering = Set.new
  end

  def cover?
    true
  end

  def is_cover?
    cover?
  end

  def capacity
    @cover_capacity
  end

  def has_cover?
    @covering.length < @cover_capacity
  end

  def covering
    @covering
  end
end