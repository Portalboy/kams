require "objects/weapon"

class Sword < Weapon

  def initialize(*args)
    super
    @generic = "sword"
    info.weapon_type = :sword
    info.attack = 10
    info.defense = 5
  end

  def use(event, player, room)
    if self.respond_to? :magic
      player.output "Sword has a use method"
    else
      player.output "#{self.name} has no abilities."
    end
  end

end
