require "objects/ranged_weapon"

class Phaser < RangedWeapon

  def initialize(*args)
    super
    @generic = "phaser"
    info.weapon_type = :pistol
    info.attack = 15
    @sound = {:shoot => "pew",:whip => "clack"}
  end

  def use(event, player, room)
    player.output "#{self.name} has no abilities."
  end

end
