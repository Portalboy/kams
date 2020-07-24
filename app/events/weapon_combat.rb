require 'events/combat'

module WeaponCombat

  class << self

    def slash(event, player, room)

      return if not Combat.ready? player

      weapon = get_weapon(player, :slash)
      if weapon.nil?
        player.output "You are not wielding a weapon you can slash with."
        return
      end

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_other] = "#{weapon.name} flashes as #{player.name} swings it at #{target.name}."
      event[:to_target] = "#{weapon.name} flashes as #{player.name} swings it towards you."
      event[:to_player] = "#{weapon.name} flashes as you swing it towards #{target.name}."
      event[:attack_weapon] = weapon
      event[:blockable] = true

      player.balance = false
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event

      event[:action] = :weapon_hit
      event[:combat_action] = :slash
      event[:to_other] = "#{player.name} slashes across #{target.name}'s torso with #{weapon.name}."
      event[:to_target] = "#{player.name} slashes across your torso with #{weapon.name}."
      event[:to_player] = "You slash across #{target.name}'s torso with #{weapon.name}."

      Combat.future_event event

    end

    def aim(event, player, room)

      return if not Combat.ready? player

      weapon = get_weapon(player, :aim)
      if weapon.nil?
        player.output "You are not wielding a weapon that requires aiming."
        return
      end

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_other] = "#{player.name} aims #{weapon.name} at #{target.name}."
      event[:to_target] = "#{player.name} aims #{weapon.name} at you."
      event[:to_player] = "You put your eye to #{weapon.name}'s sights, carefully aiming it at #{target.name}."
      event[:attack_weapon] = weapon
      event[:blockable] = false

      player.balance = false
      player.aiming = true
      player.aiming_at = target.goid
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event
      #Combat.future_event event

    end

    def reaim(event, player, room) #Like aim, but for just after shooting (doesn't check for balance)

      weapon = get_weapon(player, :aim)
      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_player] = "You stabilize #{weapon.name}, aiming it at #{target.name}."
      event[:attack_weapon] = weapon
      event[:blockable] = false

      player.balance = false
      player.aiming = true
      player.aiming_at = target.goid
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event
      #Combat.future_event event

    end

    def shoot(event, player, room)
      target = (event.target && room.find(event.target)) || room.find(player.last_target)
      weapon = get_weapon(player, :aim)
      if Combat.aiming? player
        return unless Combat.can_shoot_at? player, target
        event[:action] = :shoot
        number_of_guns = get_weapons(player, :shoot).size
        event[:attacks] = number_of_guns
        #event[:to_player] = "#{weapon.sound[:shoot]}! Your shot hits #{target.name}'s torso." #TODO: Fix shooting while aimed
        #event[:to_other] = "#You hear a #{weapon.sound[:shoot]}! #{player.name} shoots #{target.name}'s torso."
        event[:to_player] = "Pew! Your shot hits #{target.name}'s torso." #TODO: Fix shooting while aimed
        event[:to_other] = "#{target.name} is hit in the torso by #{player.name}'s #{weapon.name}."
        player.aiming = false
        event[:attacks].times do
          room.out_event event
        end



        event[:action] = :reaim
        event[:to_player] = "You restabilize your aim at #{target.name}."
        event[:to_other] = nil
        Combat.future_event(event)
      else
      if Combat.gun_ready? player #Shooting without aiming
      return unless Combat.gun_ready? player

      weapon = get_weapon(player, :shoot)
      if weapon.nil?
        player.output "You are not wielding a weapon you can shoot with."
        return
      end



      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_other] = "#{weapon.name} cracks loudly as #{player.name} haphazardly fires it at #{target.name}."
      event[:to_target] = "#{weapon.name} cracks loudly as #{player.name} haphazardly fires it at you."
      event[:to_player] = "#{weapon.name} cracks loudly as you haphazardly fire it at #{target.name}."
      event[:attack_weapon] = weapon
      event[:blockable] = false #Todo: Make this blockable by those with fantastic sword reflexes
      event[:dodgable] = true

      player.balance = false
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event

      number_of_guns = get_weapons(player, :shoot).size

      event[:action] = :weapon_hit
      event[:attacks] = number_of_guns
      event[:to_other] = "#{player.name}'s #{weapon.name} hits #{target.name}'s torso."
      event[:to_target] = "#{player.name} hits you in the chest with #{weapon.name}."
      event[:to_player] = "You hit #{target.name}'s torso with #{weapon.name}."

      #if number_of_guns > 1
      #  event2 = event
      #  room.out_event event
      #end

      event[:attacks].times do
        Combat.future_event event
      end

      Combat.future_event event
      else #Shooting without aiming?
        #if Combat.aiming? player
          #TODO: Make aiming provide benefits
          #TODO: Fix aiming
        #end
      end
      end
    end

    def unaim(event, player, room)
      target = (event.target && room.find(event.target)) || room.find(player.last_target)
      event[:to_other] = "#{player.name} stops aiming at #{target.name}, dropping #{player.pronoun(:possessive)} weapon to #{player.pronoun(:possessive)} hip."
      event[:to_player] = "You stop aiming at #{target.name}, dropping your weapon to your hip."
      event[:to_target] = "#{player.name} lowers #{player.pronoun(:possessive)} weapon away from you."
      player.aiming = false
      player.aiming_at = nil
      player.balance = true
      player.info.in_combat = false
      target.info.in_combat = false
      room.out_event event
    end

    def simple_block(event, player, room)

      return if not Combat.ready? player

      weapon = get_weapon(player, :block)
      if weapon.nil?
        player.output "You are not wielding a weapon you can block with."
        return
      end

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target == player
        player.output "You cannot block yourself."
        return
      elsif target
        events = Combat.find_events(:player => target, :target => player, :blockable => true)
      else
        events = Combat.find_events(:target => player, :blockable => true)
      end

      if events.empty?
        player.output "What are you trying to block?"
        return
      end

      if target.nil?
        target = events[0].player
      end

      player.last_target = target.goid

      b_event = events[0]
      if rand > 0.5
        b_event[:action] = :weapon_block
        b_event[:type] = :WeaponCombat
        b_event[:to_other] = "#{player.name} deftly blocks #{target.name}'s attack with #{weapon.name}."
        b_event[:to_player] = "#{player.name} deftly blocks your attack with #{weapon.name}."
        b_event[:to_target] = "You deftly block #{target.name}'s attack with #{weapon.name}."
      end

      event[:target] = target
      event[:to_other] = "#{player.name} raises #{player.pronoun(:possessive)} #{weapon.generic} to block #{target.name}'s attack."
      event[:to_target] = "#{player.name} raises #{player.pronoun(:possessive)} #{weapon.generic} to block your attack."
      event[:to_player] = "You raise your #{weapon.generic} to block #{target.name}'s attack."

      player.balance = false
      room.out_event event
    end


    #Wield a weapon.
    def wield(event, player, room)
      weapon = player.inventory.find(event[:weapon])
      if weapon.nil?
        weapon = player.equipment.find(event[:weapon])
        if weapon and player.equipment.get_all_wielded.include? weapon
          player.output "You are already wielding that."
        else
          player.output "What are you trying to wield?"
        end
        return
      end

      if not weapon.is_a? Weapon
        player.output "#{weapon.name} is not wieldable."
        return
      end

      if event[:side]
        side = event[:side]
        if side != "right" and side != "left"
          player.output "Which hand?"
          return
        end

        result = player.equipment.check_wield(weapon, "#{side} wield")
        if result
          player.output result
          return
        end

        result = player.equipment.wear(weapon, "#{side} wield")
        if result.nil?
          player.output "You are unable to wield that."
          return
        end
        event[:to_player] = "You grip #{weapon.name} firmly in your #{side} hand."
      else
        result = player.equipment.check_wield(weapon)

        if result
          player.output result
          return
        end

        result = player.equipment.wear(weapon)
        if result.nil?
          player.output "You are unable to wield that weapon."
          return
        end

        event[:to_player] = "You firmly grip #{weapon.name} and begin to wield it."
      end

      player.inventory.remove weapon
      event[:to_other] = "#{player.name} wields #{weapon.name}."
      room.out_event(event)
    end

    #Unwield a weapon.
    def unwield(event, player, room)

      if event[:weapon] == "right" || event[:weapon] == "left"
        weapon = player.equipment.get_wielded(event[:weapon])

        if weapon.nil?
          player.output "You are not wielding anything in your #{event[:weapon]} hand."
          return
        end
      elsif event[:weapon].nil?
        weapon = player.equipment.get_wielded
        if weapon.nil?
          player.output "You are not wielding anything."
          return
        end
      else
        weapon = player.equipment.find(event[:weapon])

        if weapon.nil?
          player.output "What are you trying to unwield?"
          return
        end

        if not [:left_wield, :right_wield, :dual_wield].include? player.equipment.position_of(weapon)
          player.output "You are not wielding #{weapon.name}."
          return
        end

      end

      if player.equipment.remove(weapon)
        player.inventory << weapon
        event[:to_player] = "You unwield #{weapon.name}."
        event[:to_other] = "#{player.name} unwields #{weapon.name}."
        room.out_event(event)
      else
        player.output "Could not unwield #{weapon.name}."
      end
    end

    def weapon_hit(event, player, room)
      Combat.delete_event event
      player.balance = true
      event.target.balance = true
      player.info.in_combat = false
      event.target.info.in_combat = false
      Combat.inflict_damage event, player, room, 10 #temporary set amount of damage for now
    end

    def weapon_block(event, player, room)
      Combat.delete_event event
      player.balance = true
      event.target.balance = true
      player.info.in_combat = false
      event.target.info.in_combat = false
      room.out_event event
    end

    private

    WeaponTypes = {
      :sword => [:charge, :thrust, :sweep, :circle_sweep, :slash, :circle_slash, :hilt_slam, :cleave, :behead, :pin, :block],
      :hammer => [:charge, :sweep, :cicle_sweep, :bash, :swing, :circle_swing, :crush, :ground_slam, :block],
      :axe => [:charge, :thrust, :feint_thrust, :throw, :sweep, :circle_sweep, :bash, :slash, :cleave, :behead, :block],
      :dagger => [:charge, :thrust, :feint_thrust, :stab, :gouge, :throw, :slash, :circle_slash, :backstab, :pin, :block],
      :pole => [:charge, :thrust, :feint_thrust, :lunge, :throw, :sweep, :circle_sweep, :pin, :block],
      :pistol => [:shoot, :spray, :blast, :whip, :aim],
      :rifle => [:shoot, :blast, :butt, :snipe, :aim]
    }

    def weapon_can? type, attack
      WeaponTypes[type.to_sym].include? attack.to_sym
    end

    def get_weapon player, attack
      weapon = nil
      player.equipment.get_all_wielded.each do |w|
        if w.is_a? Weapon and w.info.weapon_type and weapon_can?(w.info.weapon_type, attack)
          weapon = w
          break
        end
      end

      weapon

    end

    def get_weapons player, attack
      weapons = []
      player.equipment.get_all_wielded.each do |w|
        if w.is_a? Weapon and w.info.weapon_type and weapon_can?(w.info.weapon_type, attack)
          weapons << w
          break
        end
      end

      weapons

    end
  end
end
