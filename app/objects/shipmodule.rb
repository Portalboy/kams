require 'objects/room'

class Shipmodule < Room

  def initialize(*args)
    super(nil, *args)
    @generic = "ship module"
    info.terrain.indoors = true
    info.terrain.room_type = :starship
  end

  #TODO: Make ship module inherit Area from starship's area
  #TODO: Make power flow through adjacent rooms (using Exits to figure out which rooms are adjacent)
  def starship
    if @container.nil?
      nil
    else
      $manager.find(@container).starship
    end
  end

  def area
    if @container.nil?
      nil
    else
      $manager.find(@container).starship
    end
  end

  def ship_alert(event, alert_station = :piloting)
    @inventory.each do |o|
      if o.respond_to?(:ship_alert)
        o.ship_alert(event, alert_station)
      end
    end
  end

end