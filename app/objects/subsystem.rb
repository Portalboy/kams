require 'lib/gameobject'
require 'traits/readable'

#A simple object for testing Readable module.
#
#===Info
# writable (Boolean)
class Subsystem < GameObject
  include Readable

  attr_accessor :module_type

  def initialize(*args)
    super(*args)

    @generic = "subsystem"
    @movable = false
    @short_desc = "a ship subsystem"
    @long_desc = "A console covered in blinky lights. Fancy!"
    @alt_names = @alt_names + ["console","subsystem"]
  end
end
