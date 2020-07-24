#Contains all the movement commands
module Movement
  class << self

    #Typical moving.
    def move(event, player, room)
      case player.manning?
        when true
        #if player.manning? #Event is different if player is manning a station
          station = $manager.find(player.manning, room)
          if station.module_type == :piloting
            if $manager.find(station.container).can?(:starship)
              starship = $manager.find(station.container).starship #The starship the console is located in
              fly_ship(event, player, room)
            else
              player.output "This console appears to be disconnected."
            end
            #player.output("The ship would have flown #{event[:direction]}")
          else
            player.output "You are manning a console. Try STAND."
          end
        else
          dir_exit = room.exit(event[:direction])

          if dir_exit.nil?
            player.output("You cannot go #{event[:direction]}.")
            return
          elsif dir_exit.is_a? Portal
            player.output "You cannot simply go that way."
            return
          elsif dir_exit.can? :open and not dir_exit.open?
            player.output("That exit is closed. Perhaps you should open it?")
            return
          elsif player.prone?
            player.output('You must stand up first.')
            return
          elsif not player.balance
            player.output "You must be balanced to move."
            return
          elsif player.info.in_combat
            Combat.flee(event, player, room)
            return
          end

          new_room = $manager.find dir_exit.exit_room
          event[:exit_room] = dir_exit.exit_room

          if new_room.nil?
            player.output('You start to move in that direction, then stop when you realize that exit leads into the void.')
            return
          end

          if new_room.dark? and not player.perma_blind? and not room.dark? and not player.has_light? #TODO: Change from 'lantern' to inheritent of light once the light class is made.
            #object = object || player.search_inv(event[:at]) || room.find(event[:at])
            #if response = player.equipment.worn_or_wielded?(event[:object])
            player.blind = true
            player.output "Woah, it's pitch black in here!"
          end



          if not new_room.always_dark? and not player.perma_blind? and player.blind?
            player.blind = false
            player.output("The light floods back into your view, restoring your vision.",true)
          end

          if not new_room.dark? and not player.perma_blind? and player.blind?
            player.blind = false
            player.output("A small light nearby allows you to see again.",true)
          end

          if event[:pre]
            in_message = "#{event[:pre]}, !name comes in from the !direction."
            out_message = "#{event[:pre]}, !name leaves to the !direction."
          else
            in_message = nil
            out_message = nil
          end

          old_room = room

          if player.has_light?
            event[:to_other] = "#{player.name.capitalize} enters from #{opposite_dir(event[:direction])} carrying a small light."
            event[:to_deaf_other] = event[:to_other]
            event[:to_blind_other] = "You hear the sound of footsteps drawing nearer, as the feint hiss of a gas lantern grows louder."
          else
            event[:to_other] = player.entrance_message(opposite_dir(event[:direction]), in_message)
            event[:to_deaf_other] = event[:to_other]
            event[:to_blind_other] = "You sense someone nearing you."
          end
          room.remove(player)
          new_room.add(player)
          new_room.calculate_light if new_room.always_dark?
          new_room.out_event(event)
          player.container = new_room.game_object_id
          event_other = event.dup
          if player.has_light? and !room.light_source?
            event_other[:to_other] = "#{player.name.capitalize} exits to #{event[:direction]}, carrying the light away with him."
            event_other[:to_blind_other] = "You hear the sounds of someone leaving."
            event_other[:to_deaf_other] = event[:to_other]
          else
            event_other[:to_other] = player.exit_message(event_other[:direction], out_message)
            event_other[:to_blind_other] = "You hear the sounds of someone leaving."
            event_other[:to_deaf_other] = event[:to_other]
          end
          room.out_event(event_other)

          if old_room.always_dark?
            old_room.calculate_light
          end

          if player.info.followers
            player.info.followers.each do |f|
              follower = $manager.find f
              room.remove follower
              new_room.add follower

              room.output "#{follower.name.capitalize} follows #{player.name} #{event[:direction]}."
          end
        end
      end
    end

    def fly_ship(event, player, room)
      case player.manning?
        when true
          #if player.manning? #Event is different if player is manning a station
          station = $manager.find(player.manning, room)
          if station.module_type == :piloting
            if $manager.find(station.container).can?(:starship)
              starship = $manager.find(station.container).starship #The starship the console is located in
              dir_exit = starship.room.exit(event[:direction])
              if starship.flying?
              if dir_exit.nil?
                player.output("You cannot go #{event[:direction]}.")
                return
              elsif dir_exit.is_a? Portal
                player.output "You cannot simply go that way."
                return
              elsif dir_exit.can? :open and not dir_exit.open?
                player.output("That exit is closed. Perhaps you should open it?")
                return
              #elsif not player.balance
              #  player.output "You must be balanced to move."
              #  return
              #elsif player.info.in_combat #This should be uncommented and adjusted when ship combat is added. TODO: Implement ship combat.
              #  Combat.flee(event, player, room)
              #  return
              end

              new_room = $manager.find dir_exit.exit_room
              event[:exit_room] = dir_exit.exit_room

              if new_room.nil?
                player.output('You start to move in that direction, then stop when you realize that exit leads into the void.')
                return
              end

              if new_room.indoors?
                player.output('Flight over indoor areas not yet implemented.') #TODO: Implement flight over indoor rooms
                return
              end

              if event[:pre]
                in_message = "#{event[:pre]}, #{starship.full_name} comes in from the !direction."
                out_message = "#{event[:pre]}, #{!name}{starship.full_name leaves to the !direction."
              else
                in_message = nil
                out_message = nil
              end

              event[:to_other] = player.entrance_message(opposite_dir(event[:direction]), in_message)
              event[:to_deaf_other] = "You see a massive starship fly in from the #{opposite_dir(event[:direction])}"
              event[:to_blind_other] = "You hear the deafening roar of a starship's massive engine overhead."
              starship.room.remove(starship)
              new_room.add(starship)
              new_room.out_event(event)
              starship.container = new_room.game_object_id
              event_other = event.dup
              event_other[:to_other] = player.exit_message(event_other[:direction], out_message)
              event_other[:to_blind_other] = "You hear a deafening roar as a starship's engine drones off to the #{event[:direction]}."
              starship.room.out_event(event_other)
              #player.output "You have flown #{event[:direction]}"

              if starship.info.followers
                starship.info.followers.each do |f|
                  follower = $manager.find f
                  starship.room.remove follower
                  new_room.add follower

                  starship.room.output "#{follower.name.capitalize} follows #{player.name} #{event[:direction]}."
                end
              end
              else
                player.output "You must takeoff before flying."
              end
            else
              player.output "This console appears to be disconnected."
            end
            #player.output("The ship would have flown #{event[:direction]}")
          else
            player.output "You are manning a console. Try STAND."
          end
        else
          player.output "You cannot do this unless manning a helm." #Temporary, more debuggy message. TODO: Change to something friendlier
      end
    end

    def flee(event, player, room)
      Combat.delete_event event
      player.balance = true
      player.info.in_combat = false
      if event.target.info.fleeing
        event.target.info.fleeing = false
        event.target.balance = true
        event.target.info.in_combat = false
        event.player = event.target
        event.target = nil
        event.to_target = event.to_player = event.to_other = nil
        event.pre = "Eyes wide with fear"
        Movement.move(event, event.player, room)
      else
        #target already fled
      end
    end

    def gait(event, player, room)
      if event[:phrase].nil?
        if player.info.entrance_message
          player.output "When you move, it looks something like:", true
          player.output player.exit_message("north")
        else
          player.output "You are walking normally."
        end
      elsif event[:phrase].downcase == "none"
        player.info.entrance_message = nil
        player.info.exit_message = nil
        player.output "You will now walk normally."
      else
        player.info.entrance_message = "#{event[:phrase]}, !name comes in from !direction."
        player.info.exit_message = "#{event[:phrase]}, !name leaves to !direction."

        player.output "When you move, it will now look something like:", true
        player.output player.exit_message("north")
      end
    end

    #Enter a portal
    def enter(event, player, room)
      portal = $manager.find(event[:object], room)
      if not player.balance
        player.output "You cannot use a portal while unbalanced."
        return
      elsif portal.nil?
        player.output "What are you trying to #{event[:portal_action]}?"
        return
      elsif not portal.is_a? Portal
        player.output "You cannot #{event[:portal_action]} #{portal.name}."
        return
      elsif portal.info.portal_action and portal.info.portal_action != event[:portal_action].to_sym
        player.output "You cannot #{event[:portal_action]} #{portal.name}."
        return
      elsif portal.info.portal_action.nil? and event[:portal_action] != "enter"
        player.output "You cannot #{event[:portal_action]} #{portal.name}."
        return
      end

      new_room = $manager.find portal.exit_room
      event[:exit_room] = portal.exit_room

      if new_room.nil?
        player.output('You start to move in that direction, then stop when you realize that way leads into the void.')
        return
      end

      event[:to_other] = portal.entrance_message(player, event[:portal_action])
      event[:to_deaf_other] = event[:to_other]
      event[:to_blind_other] = "You sense someone nearing you."
      room.remove(player)
      player.output portal.portal_message(player, event[:portal_action])
      new_room.add(player)
      new_room.out_event(event)
      player.container = new_room.game_object_id
      event_other = event.dup
      event_other[:to_other] = portal.exit_message(player, event_other[:portal_action])
      event_other[:to_blind_other] = "You hear the sounds of someone leaving."
      room.out_event(event_other)

      if player.info.followers
        player.info.followers.each do |f|
          follower = $manager.find f
          room.remove follower
          new_room.add follower

          room.output "#{follower.name.capitalize} follows #{player.name} #{event[:direction]}."
        end
      end
    end

    #Sit down.
    def sit(event, player, room)
      if not player.balance
        player.output "You cannot sit properly while unbalanced."
        return
      elsif event[:object].nil?
        if player.sitting?
          player.output('You are already sitting down.')
        elsif player.manning?
          player.output('You are already sitting at a station.')
        elsif player.prone? and player.sit
          event[:to_player] = 'You stand up then sit on the ground.'
          event[:to_other] = "#{player.name} stands up then sits down on the ground."
          event[:to_deaf_other] = event[:to_other]
          room.output(event)
        elsif player.sit
          event[:to_player] = 'You sit down on the ground.'
          event[:to_other] = "#{player.name} sits down on the ground."
          event[:to_deaf_other] = event[:to_other]
          room.out_event(event)
        else
          player.output('You are unable to sit down.')
        end
      else
        object = $manager.find(event[:object], player.room)

        if object.nil?
          player.output('What do you want to sit on?')
        elsif not object.can? :sittable?
          player.output("You cannot sit on #{object.name}.")
        elsif object.occupied_by? player
          player.output("You are already sitting there!")
        elsif not object.has_room?
          player.output("The #{object.generic} #{object.plural? ? "are" : "is"} already occupied.")
        elsif player.sit(object)
          object.sat_on_by(player)
          event[:to_player] = "You sit down on #{object.name}."
          event[:to_other] = "#{player.name} sits down on #{object.name}."
          event[:to_deaf_other] = event[:to_other]
          room.out_event(event)
        else
          player.output('You are unable to sit down.')
        end
      end
    end

    #Stand up.
    def stand(event, player, room)
      if not player.prone?
        player.output('You are already on your feet.')
        return
      elsif not player.balance
        player.output "You cannot stand while unbalanced."
        return
      end

      if player.sitting?
        object = $manager.find(player.sitting_on, room)
      elsif player.manning?
        object = $manager.find(player.manning, room)
      else
        object = $manager.find(player.lying_on, room)
      end

      if player.stand
        event[:to_player] = 'You rise to your feet.'
        event[:to_other] = "#{player.name} stands up."
        event[:to_deaf_other] = event[:to_other]
        room.out_event(event)
        object.evacuated_by(player) unless object.nil?
      else
        player.output('You are unable to stand up.')
      end
    end

    def takeoff(event, player, room)
      if player.manning?
        station = $manager.find(player.manning)
        if station.module_type == :piloting
          #TAKEOFF STUFF HERE
          starship = room.starship
          starship_room = nil
          container = nil
          if starship.landed_in
            #If starship is landed in a room (in logic, not physically)
            if $manager.find(starship.landed_in)
              starship_room = $manager.find(starship.landed_in)
              container = starship_room
            end
            if $manager.find(starship.container)
              container = $manager.find(starship.container)
            end

            if not starship.container.nil?
              current_container = $manager.find starship.container
              current_container.inventory.remove(starship) if current_container
            end

            if container.is_a? Container
              container.add starship
            else
              starship_room.inventory.add(starship)
              starship.container = container.goid
            end
            starship.landed_in = nil
            starship.show_in_look = false
            starship
            if starship.linked_exits
              starship.linked_exits.each do |e|
                ship_landing_exit = $manager.find(e)
                $manager.delete_object(ship_landing_exit)
                starship.linked_exits - [e]
              end
            end

            starship.linked_exits
            player.output "#{starship.full_name}'s engine roars as it spools up, emitting a piercing electromagnetic squeal and rising into #{$manager.find(starship.container).name}'s sky."
          else
            player.output "#{starship.full_name} is already flying."
          end
          #TAKEOFF STUFF ABOVE
        else
          player.output "You are not at the helm."
        end
      else
        #Player not manning
        player.output "You are not using a starship."
      end
    end

    def land(event, player, room)
      if player.manning?
        station = $manager.find(player.manning)
        if station.module_type == :piloting
          #LANDING STUFF HERE
          starship = room.starship
          room_landed_in = nil
          room_landed_in = $manager.find(starship.landed_in) if starship.landed_in
          if not starship.landed_in
            unless starship.room.inventory.find_all('class', StarshipExit).empty? #Why does this use ::empty?
              player.output "There is already a starship landed here, so there is no room for #{starship.full_name}. DEBUG: #{starship.room.inventory.find_all('class', StarshipExit).empty?}"
              return #TODO: Reformat some of my Methods to make use of the simple `return` call to remove nested ifs in ifs in ifs in ifs.
            end
            starship.landed_in = starship.room.goid
            room_landed_in = $manager.find(starship.landed_in)
            boarding_room = $manager.find(starship.boarding_room)
            out_exit = $manager.create_object(StarshipExit, starship.room, boarding_room.goid, {:@note => "Landing zone to #{starship.name}", :@alt_names => ["embark"], :@landing_exit => true, :@linked_ship => starship.name})
            in_exit = $manager.create_object(StarshipExit, boarding_room, starship.room.goid, {:@note => "#{starship.name} to Landing zone", :@alt_names => ["disembark"], :@landing_exit => true, :@linked_ship => starship.name})
            starship.linked_exits = [out_exit.goid, in_exit.goid]
            starship.show_in_look = "#{starship.full_name} is landed here." #Temporary-ish. Eventually should be set to a CASE Lookup so the INROOM description fits the room it's landed in.
            player.output "#{starship.name} landed in #{room_landed_in.name}."
          else
            player.output "#{starship.name} is already landed in #{room_landed_in.name}."
          end
        else
          player.output "You are not at the helm."
        end
      else
        #Player not manning
        player.output "You are not using a starship."
      end
    end

=begin #unman command, currently unman is an alias for stand. TODO: Make the unman event so people can use UNMAN [STATION]
    def unman(event, player, room)
      if not player.manning?
        player.output("You aren't manning anything.")
        return
      elsif not player.balance
        player.output "You cannot stand while unbalanced."
        return
      end

      if player.sitting?
        object = $manager.find(player.sitting_on, room)
      elsif player.manning?
        object = $manager.find(player.manning, room)
      else
        object = $manager.find(player.lying_on, room)
      end

      if player.unman
        event[:to_player] = 'You rise to your feet.'
        event[:to_other] = "#{player.name} stands up."
        event[:to_deaf_other] = event[:to_other]
        room.out_event(event)
        object.evacuated_by(player) unless object.nil?
      else
        player.output('You are unable to stand up.')
      end
    end
=end

    #Strike a pose.
    def pose(event, player, room)
      if event[:pose].downcase == "none"
        player.pose = nil
        player.output "You are no longer posing."
      else
        player.pose = event[:pose]
        player.output "Your pose is now: #{event[:pose]}."
      end
    end

    def drag(event, player, room)
      object = $manager.find(event[:object], room)

      if object.nil?
        player.output("There is no #{event[:object]} to drag.")
        return
      elsif not object.draggable
        player.output("You cannot drag #{object.name}.")
        return
      elsif player.dragging?
        player.output("You are already dragging something else.")
        return
      end

      room.remove(object)
      object.container = player.goid
      player.inventory << object
      player.dragging = object.goid

      event[:to_player] = "You grab the #{object.name} and begin dragging it."
      event[:to_other] = "#{player.name} grabs onto #{object.name} and starts dragging it."
      room.out_event(event)
    end

    def undrag(event, player, room)
      player.output "not a real command yet"
    end

    def warp(event, player, room)
      if room.starship
       if room.starship.can_warp?
         player.output "WARPING AWAY! WHEEEEE!" #TODO: Warp logic goes here.
         return false
        else
          player.output "You are not in a warp-capable vessel."
         return false
        end
      end
    end

    def starmap(event, player, room)
      Universe.locations.each do |location,goid|
        player.output(location, true)
      end
      player.output "To access any of these locations, use WARP."
    end

  end
end
