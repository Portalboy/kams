require 'objects/subsystem'

#An object for recording, and most importantly redistributing, events that a starship receives.
#Primary purpose is to iterate over each manned subsystem that monitors that event and duplicate
#that event to each one. This is so that players manning a subsystem like Piloting can still see
#things happening in the ship's room.

class Blackbox < Subsystem

  def initialize(*args)
    super(*args)

    @generic = "black box"
    @movable = false
    @short_desc = "the ship's black box"
    @long_desc = "A console outputting all kinds of logging information!"
    @alt_names = ["box"]
  end

  def out_event event
    super
    if info.redirect_output_to
      if event[:target] == self and event[:player] != self
        self.output event[:to_target]
      elsif event[:player] == self
        self.output event[:to_player]
      else
        #Could also log to array or something
        self.output event[:to_other]
        container = $manager.find(self.container)
        starship = container.starship
        #starship.alert(event)
      end
    end
  end

end