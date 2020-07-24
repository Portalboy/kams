### TAKEN FROM Area.rb ###
require 'objects/container'

#An Area contains rooms and can be used to manage the weather and other area-wide information.
#Right now they don't do much but hold rooms, though.
#
#==Info
# info.terrain = Info.new
# info.terrain.area_type = :urban
class Starship < Container

  attr_accessor :landed_in, :linked_exits, :boarding_room
  #Manual attr_reader on :full_name, with special hooks to ensure full_name is always updated when returned

  def initialize(*args)
    super
    info.terrain = Info.new
    info.terrain.starship_condition = :federation
    @article = "the"
    @generic = "starship"
    @alt_names = ["ship"]
    @landed_in = nil
    @flying = true
    @linked_exits = nil
    info.ship = Info.new
    info.ship.prefix = "U.S.S."
    info.ship.description = "#{full_name} is a starship."
    @ship_prefix = "U.S.S." #TODO: Figure out how to use info.starship.prefix in the resolve_full_name method
    @boarding_room = nil
    @blind = false
  end

  #Returns self.
  def starship
    self
  end

  def area
    if @container.nil?
      nil
    else
      $manager.find(@container).area
    end
  end

  def world
    if @container.nil?
      nil
    else
      $manager.find(@container).world
    end
  end

  def room
    if @container.nil?
      nil
    else
      $manager.find(@container).room
    end
  end

  def blind?
    @blind
  end

  def resolve_full_name

  end

  def full_name
    @full_name = "#{@generic}"
    @full_name = "#{@article} #{@ship_prefix} #{@name}" if @article and @ship_prefix and @name
    @full_name = "#{@article} #{@name}" if @article and @name
    @full_name = "#{@name}" if @name
  end

  #def fly(event, player, room) #Depricated, replaced by fly_ship command in events/movement
  #  station = $manager.find(player.manning, room)
  #  starship = $manager.find(station.container).starship #The starship the console is located in
  #  player.output "Ship travel not yet implemented. #{starship.name} would have flown #{event[:direction]} to #{}"
  #end

  def flying?
    if not @landed_in
      true
    else
      false
    end
  end
=begin #The below is borrowed from Objects/Player.
  def out_event(event) #For forwarding of room events to player while flying.
    if event[:target] == self and event[:player] != self
      if self.blind? and not self.deaf?
        self.output event[:to_blind_target]
      elsif self.deaf? and not self.blind?
        self.output event[:to_deaf_target]
      elsif self.deaf? and self.blind?
        self.output event[:to_deafandblind_target]
      else
        self.output event[:to_target]
      end
    elsif event[:player] == self
      self.output event[:to_player]
    else
      if self.blind? and not self.deaf?
        self.output event[:to_blind_other]
      elsif self.deaf? and not self.blind?
        self.output event[:to_deaf_other]
      elsif self.deaf? and self.blind?
        self.output event[:to_deafandblind_other]
      else
        self.output event[:to_other]
      end
    end
  end
=end
  def out_event event
    #super
    #if info.redirect_output_to
    #  if event[:target] == self and event[:player] != self
    #    self.output event[:to_target]
    #  elsif event[:player] == self
    #    self.output event[:to_player]
    #  else
    #    self.output event[:to_other]
    #  end
    #end
    ship_alert(event.dup)
  end

  def can_warp? #TODO: Implement Warp.
    false
  end

  #Propagates ship alert to all capable of receiving.
  def ship_alert(event, alert_station = :piloting)
    @inventory.each do |o|
      if o.respond_to?(:ship_alert)
        o.ship_alert(event, alert_station)
      end
    end
  end

end
