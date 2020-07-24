

require 'objects/mobile'
require 'events/combat'


#Base class for all mobiles.
class Jenny < Mobile

  def initialize(*args)
    super(*args)
    @name = 'Jenny'
    @sex = 'f'
    @actions << "kiss"
  end

  def kiss(event, player, room)
    target = $manager.find event[:target]
    #event.to_player = "You lean over to give #{event[:target]} a kiss"
    #event.to_other = "#{event[:player]} leans over to kiss #{event[:target]}"
    event.to_player = "You lean over and give #{target.name} a kiss"
    event.to_other = "#{event[:player]} leans over and kisses #{target.name}"
    room.out_event event

    #event[:action] = :custom
    #event[:custom_action] = :kiss
    #event[:to_other] = "#{player.name} kisses #{event[:target]} affectionately."
    #event[:to_target] = "#{player.name} kisses you passionately."
    #event[:to_player] = "You kiss #{event[:target]} passionately."
    #Combat.future_event event
  end
end
