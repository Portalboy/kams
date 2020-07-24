require "objects/weapon"

class RangedWeapon < Weapon
  include Wearable

  def initialize(*args)
    super
    info.weapon_type = :pistol
    info.defense = 0
    @sound[:shoot] = "bang"
  end
end