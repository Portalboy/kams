require 'objects/exit'

#A generic exit. Add to Rooms to move between them. Don't forget to put an Exit in both rooms, if you want to move between them.
#
#It is best to put the direction in the alternate names of the exit. For example 'e' and 'east' should be included if the exit leads east. This
#also allows for exotic exit types, since the player can always do "go around" and an exit matching "around" would work.
class StarshipExit < Exit
  #GOID of room the exit leads to.
  attr_accessor :landing_exit, :linked_ship

  #Creates a new exit. Connects to exit_room if that is provided.
  def initialize(exit_room = nil, *args)
    super(*args)
    @exit_room = exit_room
    @generic = 'ship exit'
    @article = 'a'
    @landing_exit = false
    @player_only = false
    @ship_only = false
    @linked_ship = nil
  end

end
