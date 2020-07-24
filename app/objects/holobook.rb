require 'lib/gameobject'
require 'traits/readable'

#A simple object for testing Readable module.
#
#===Info
# writable (Boolean)
class Holobook < GameObject
  include Readable

  def initialize(*args)
    super(*args)

    @generic = "holobook"
    @movable = true
    @short_desc = "a holographic book"
    @long_desc = "A holographic data storage and retrieval device for reading and writing."
    @alt_names = ["holographic book","book"]
    info.writable = true
  end
end
