#Level 2 Martial Combat
=begin
require 'events/combat'

module MartialCombat2
  class << self

    def disarm(event, player, room)
      return if not Combat.ready? player

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_other] = "#{player.name} grabs #{target.pronoun}'s weapon in an attempt to disarm #{target.pronoun}."
      event[:to_target] = "#{player.name} thrusts out #{player.pronoun(:possessive)} hand and grabs your weapon."
      event[:to_player] = "You snap your hand at #{target.name}'s weapon."
      event[:blockable] = true

      player.balance = false
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event

      event[:action] = :martial_hit
      event[:combat_action] = :disarm
      event[:to_other] = "#{player.name} swiftly snaps #{target.name}'s weapon out of his hand."
      event[:to_target] = "#{player.name} snaps your weapon out of your hand, disarming you!"
      event[:to_player] = "You snap #{target.name}'s weapon out of #{target.pronoun(:possessive)} hand."

      Combat.future_event event
    end

    def trip(event, player, room)
      return unless Combat.ready? player

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target.nil?
        player.output "Who are you trying to attack?"
        return
      else
        return unless Combat.valid_target? player, target
      end

      player.last_target = target.goid

      event.target = target

      event[:to_other] = "#{player.name} sweeps #{player.pronoun(:possessive)} leg towards #{target.name}'s to trip #{target.pronoun}."
      event[:to_target] = "#{player.name} sweeps #{player.pronoun(:possessive)} leg towards yours, trying to knock you down!"
      event[:to_player] = "You sweep your foot at #{target.name}'s legs."
      event[:jump_blockable] = true ###change from Blockable to Jump-To-Block

      player.balance = false
      player.info.in_combat = true
      target.info.in_combat = true

      room.out_event event

      event[:action] = :martial_hit
      event[:combat_action] = :trip
      event[:to_other] = "#{player.name} sweeps #{target.name}'s legs out from under #{target.pronoun}!"
      event[:to_target] = "You fall on your side as #{player.name} sweeps your legs out from under you!"
      event[:to_player] = "#{target.name} is knocked off his feet, landing squarely on his side from your kick!"

      Combat.future_event event
    end

    def jump_dodge(event, player, room)
      return unless Combat.ready? player

      target = (event.target && room.find(event.target)) || room.find(player.last_target)

      if target == player
        player.output "You cannot block yourself."
        return
      elsif target
        events = Combat.find_events(:player => target, :target => player, :jump_blockable => true)
      else
        events = Combat.find_events(:target => player, :jump_blockable => true)
      end

      if events.empty?
        player.output "What are you trying to dodge?"
        return
      end

      if target.nil?
        target = events[0].player
      end

      player.last_target = target.goid

      b_event = events[0]
      if rand > 0.5
        b_event[:action] = :martial_miss
        b_event[:type] = :MartialCombat
        b_event[:to_other] = "#{player.name} jumps over #{target.name}'s attack."
        b_event[:to_player] = "#{player.name} jumps over your attack."
        b_event[:to_target] = "You time your jump carefully, smoothly avoiding #{target.name}'s attack."
      end

      event[:target] = target
      event[:to_other] = "#{player.name} tries to jump over #{target.name}'s attack."
      event[:to_target] = "#{player.name} tries to jump over your attack."
      event[:to_player] = "You watch #{target.name}'s movements, preparing to jump."

      player.balance = false
      room.out_event event
    end

    def martial_hit(event, player, room)
      Combat.delete_event event
      player.balance = true
      event.target.balance = true
      player.info.in_combat = false
      event.target.info.in_combat = false
      Combat.inflict_damage event, player, room, 8 #temporary set amount of damage for now
    end

    def martial_miss(event, player, room)
      Combat.delete_event event
      player.balance = true
      event.target.balance = true
      player.info.in_combat = false
      event.target.info.in_combat = false
      room.out_event event
    end

  end
end
=end