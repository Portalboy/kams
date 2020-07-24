#A module to allow things like heavy storage canisters to be dragged.

module Draggable

  def initialize(*args)
    super

    @draggable
  end

  def drag(player, room, event)
    player.output "Temporary: You heave will all your might!"
    player.balance = false
  end

  def stop_drag(player, room, event)
    player.output "You let go of the #{@generic = 'item'} and exhale loudly."
    player.balance = true
  end

  def draggable?
    true
  end

  def draggable=(value)
    @draggable = value
  end

end