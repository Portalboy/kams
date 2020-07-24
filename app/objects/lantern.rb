require 'lib/gameobject'
require 'traits/emitslight'

#A simple object for seeing in dark rooms.
#
#===Info
# None yet
class Lantern < GameObject
  include EmitsLight

  def initialize(*args)
    super(*args)

    @generic = "lantern"
    @movable = true
    @short_desc = "A metal lantern."
    @fuel = 200
    @long_desc = "A metal lantern with about #{fuel} seconds of fuel."
    info.texture = "Its surface is cold to the touch."
  end

  def fuel_level
    "A metal lantern with about #{@fuel} seconds of fuel"
  end

  def room
    if @container.nil?
      nil
    else
      $manager.find(@container).room
    end
  end
end