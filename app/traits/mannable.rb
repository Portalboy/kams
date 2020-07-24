require 'set'

#Another outdated module. This should probably be replaced at some point.
module Mannable

  def initialize(*args)
    super
    @manning_me = Set.new
    @mannable_occupancy = 1
  end

  def mannable?
    true
  end

  def occupied?
    not @manning_me.empty?
  end

  def has_room?
    @manning_me.length < @mannable_occupancy
  end

  def manned_by object
    @manning_me << object.goid
  end

  def occupants
    @manning_me
  end

  def evacuated_by object
    @manning_me.delete object.goid
  end

  def occupied_by? object
    @manning_me.include? object.goid
  end
end
