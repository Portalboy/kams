require 'objects/container'
require 'objects/exit'

#A room is where things live. Rooms themselves need to be in other rooms (kind of) and can certainly be nested as deeply as you would like.
#Especially since doors can be set up arbitrarily. A room should be placed within an Area.
#
#===Info
# terrain (Info)
# terrain.indoors (Boolean)
# terrain.water (Boolean)
# terrain.underwater (Boolean)
# terrain.room_type (Symbol)
class Room < Container
  #TODO: Make time-of-day method, relies on area's time-of-day descriptions, unless an instance variable is set with a time-of-day description.
  #That way, rooms will default to using their area's time-of-day descriptions (which will default to using their world's)
  #This allows areas and rooms to have customized messages. For instance, in a dense forest, you wouldn't want to say the sun is shining
  #brilliantly overhead, would you? Maybe completely omit the messages if you're in a cave?

  attr_reader :terrain

  #Create new room. Arguments same as GameObject.
  def initialize(*args)
    super(nil, *args)
    @generic = "room"
    info.terrain = Info.new
    info.terrain.indoors = false
    info.terrain.water = false
    info.terrain.underwater = false
    info.terrain.room_type = :urban
    info.terrain.dark = false
    info.terrain.always_dark = false
    @entry_point = false
  end

  #This returns the Area object this room resides within.
  #The reason it is someone recursive is for the case where rooms
  #might be inside something other than an area
  def area
    if @container.nil?
      nil
    else
      $manager.find(@container).area
    end
  end

  def dark?
    @info.terrain.dark
  end

  def room
    self
  end

  def starship
    if @container.nil?
      nil
    else
      $manager.find(@container).starship
    end
  end

  def world
    if @container.nil?
      nil
    else
      $manager.find(@container).area
    end
  end

  #Checks if a room is indoors.
  def indoors?
    @info.terrain.indoors
  end

  def light_sources #Searches the contents of the room for a light source.
    lights = @inventory.find_all('class', Lantern) #Temporary - Eventually it will need to check for inheritance from a root light object that all lights inherit from.
    lit_lights = []
    lights.each do |l|
      lit_lights << l if l.lit?
    end
    players = @inventory.find_all('class', :Player)
    players.each do |p|
      lit_lights << p if p.has_light?
    end
    lit_lights
  end

  def light #Makes the room temporarily not dark.
    @info.terrain.dark = false
    players = @inventory.find_all("class", :Player)
    players.each do |player|
      player.blind = false
      #player.output("A new source of light casts a warm glow, revealing the room you are standing in.")
    end
  end

  def darken #Makes the room dark again.
    @info.terrain.dark = true if @info.terrain.always_dark
    players = @inventory.find_all("class", :Player)
    players.each do |player|
      player.blind = true
    end
  end

  def always_dark?
    @info.terrain.always_dark
  end

  #Add an object to the room.
  def add(object)
    @inventory << object

    object.container = @game_object_id

    if object.is_a? Player or object.is_a? Mobile or object.is_a? Starship
      object.output(self.look(object)) unless object.blind?
    end
  end

  def light_source?
    light_sources.count > 0
  end

  def calculate_light
    if self.always_dark?
      #players = @inventory.find_all("class", :Player)
      if self.light_source?
       self.light
      else
        self.darken
      end
    end
  end

  #Returns an exit in the given direction. Direction is pretty
  #arbitrary, though.
  def exit(direction)
    @inventory.find(direction, Exit)
  end

  #Returns an array of all the exits in the room.
  def exits
    @inventory.find_all('class', Exit)
  end

  #Look around the room. Player is the player that is looking (so they don't see themselves).
  #Returns a description of the room including: name of the room, room short description, visible people in the room,
  #visible objects in the room. All pretty-like.
  def look(player)
    people = Array.new
    things = Array.new
    exits = Array.new
    add_to_desc = String.new

    @inventory.each do |item|

      if item.show_in_look
        add_to_desc << " " << item.show_in_look if item.show_in_look != ""
        next
      end

      if item.is_a?(Player) and item != player and item.visible
        if item.pose
          people << ("#{item.name}, #{item.pose},")
        else
          people << item.name
        end
      elsif item.is_a?(Exit) and item.visible
        if item.can? :open and item.closed?
          exits << "#{item.alt_names[0]} (closed)"
        elsif item.can? :open and item.open?
          exits << "#{item.alt_names[0]} (open)"
        else
          exits << (item.alt_names[0] || "[Improperly named exit]")
        end
      elsif item != player and item.visible
        if not item.quantity.nil? and item.quantity > 1
          quantity = item.quantity
        else
          quantity = item.article
        end

        if item.can? :pose and item.pose
          things << "#{item.name} (#{item.pose})"
        else
          things << "#{item.name}"
        end
      end
    end

    #What to show if there are no exits.
    if exits.empty?
      exits << "nowhere, apparently"
    else
      exits.sort!
    end

    if people.empty?
      people = ""
    else
      people = "<people>#{people.list} #{people.length > 1 ? 'are' : 'is'} here.</people>\n"
    end

    if things.empty?
      things = ""
    else
      things = "<objects>You see #{things.list(@inventory)} nearby.</objects>\n"
    end

    "<roomtitle>#{@name}</title>\n<roomdesc>#{(@short_desc || '') + add_to_desc}</desc>\n#{things}#{people}<exits>You can go #{exits.list}.</exits>"
  end
end

