#temp file, pls remove
class Screen
  def present

  end
  def unavailable?

  end
end
login_screen = Screen.new
$user_session = Screen.new
resturant = Screen.new







login_screen.present()
if resturant.unavailable?
  $user_session.display_message("Sorry, this store is unavailable due to high load.")
end
=begin
Entirety of order taking code and payment screens
=end