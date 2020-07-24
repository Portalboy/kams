require 'lib/gameobject'

class Universe < Container

  def initialize(*args)
    super
    @locations = {}
  end

  def self.locations
    Locations
  end
end

Locations = {:earth => "1234"}