#Representor room. Basically acts as the entry/exit point for starships for a given planet,
#so you WARP TO Earth and end up placed in Earth's representor.

require 'objects/room'

class Representor < Room

  def initialize(*args)
    super
    @represented_world = '{INCORRECTLY MADE REPRESENTOR}'
  end

  def represented_world
    @represented_world
  end

  def represented_world=(value)
    @represented_world = value
  end

end