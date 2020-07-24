require 'objects/container'

#An Area contains rooms and can be used to manage the weather and other area-wide information.
#Right now they don't do much but hold rooms, though.
#
#==Info
# info.terrain = Info.new
# info.terrain.area_type = :urban
class World < Container

  def initialize(*args)
    super
    info.terrain = Info.new
    info.terrain.world_type = :terran
    info.terrain.air = :breathable
    @article = "a"
    @generic = "world"
  end

  #Returns self.
  def world
    self
  end

  def starship
    nil
  end
end
