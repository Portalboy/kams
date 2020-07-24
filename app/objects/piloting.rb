require 'objects/subsystem'
require 'traits/mannable'

class Helm < Subsystem
  include Mannable


  def initialize(*args)
    super(nil, *args)
    @module_type = :piloting
    @article = 'the'
    @generic = 'piloting station'
    @long_desc = "Piloting controls"
    @alt_names = @alt_names + ["piloting", "pilot", "helm"]
    @mannable = true
  end

  def use(event, player, room)
    player.output "You take the controls."
  end

  def man(event, player, room)
    player.output "You take the helm controls."
    player.output "@manning_me: #{@manning_me}"
  end

  def ship_alert(event, alert_station = :piloting)
    if alert_station == :piloting
      @manning_me.each do |o|
        $manager.find(o).out_event(event)
      end
    end
  end

  #Probably no reason for this to be here, oh well! kept it just in case I'd need it later.
=begin
  def handle_input(input)
    if input.nil? or input.chomp.strip == ""
      @player.print(prompt) unless @player.closed?
      return
    end

    if not alive
      self.output "You are dead. You can't do much of anything."
      return
    end

    event = CommandParser.parse(self, input)

    @prompt_shown = false

    if event.nil?
      if input
        doc = Syntax.find(input.strip.split[0].downcase)
        if doc
          output doc
        else
          output 'Not sure what you mean by that.'
        end
      end
    elsif @asleep and event[:action] != 'wake'
      output 'You cannot do that when you are asleep!'
    else
      changed
      notify_observers(event)
    end
  end
=end

end