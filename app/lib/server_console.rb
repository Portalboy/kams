#Meant to handle input from the server so that admin commands can be executed without being logged in.
#This is WIP! Have not tested!

class ServerInput
  def initialize

    input_thread = Thread.new {
      input = STDIN::gets.chomp
      command = CommandParser.parse(self, input)

      if event.nil?
        if input
          doc = Syntax.find(input.strip.split[0].downcase)
          if doc
            output doc
          else
            output 'Not sure what you mean by that.'
          end
        end
      else
        changed
        notify_observers(event)
      end
    }
    input_thread.join
  end
end