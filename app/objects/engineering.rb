require 'objects/subsystem'
require 'traits/mannable'

class Engineering < Subsystem
  include Mannable

  def initialize(*args)
    super(nil, *args)
    @module_type = :engineering
    @article = 'the'
    @generic = 'engineering station'
    @alt_names = @alt_names + ["engineering", "engineer"]
  end

  def use(event, player, room)
    player.output "You begin engineering."
  end

end