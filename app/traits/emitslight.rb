#Makes it possible to see in the dark while holding (and lit).
#
#Not finished, WIP
#Defaults to needing fuel, can be disabled.
module EmitsLight


  def initialize(*args)
    super

    @fuel = 0
#    @actions << "light"
    @uses_fuel = true
    @lit = false
  end

  def light
    @lit = true
    info.texture = "Its surface is warm to the touch from the flame flickering inside it."
    #room = $manager.find(self.room)
    room = self.room
    if room.is_a? String
      room = $manager.find(room)
    end
    room.light
  end

  def lit?
    @lit
  end

  def extinguish
    @lit = false
    info.texture = "Its surface is cold to the touch."
    #room = $manager.find(self.room)
    room = self.room
    if room.is_a? String
      room = $manager.find(room)
    end
    room.darken
  end

  def uses_fuel?
    @uses_fuel
  end

  def fuel?
    return false if @fuel.nil?
    @fuel > 0
  end

  def fuel
    @fuel
  end
end
