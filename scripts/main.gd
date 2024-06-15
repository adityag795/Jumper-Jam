extends Node

@onready var game = $Game
@onready var screens = $Screens
@onready var iap_manager = $IAPManager

# 👇 To check weather any game is in progress or not
var game_in_progress = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 👇 To know when the game looses focus (minimized or any other app screen overlays the game)
	# 👇 and when it gains focus (user coming back to the game window)
	# 👇 To know this we use "WindowEvent"s from "DisplayServer" as shown below
	DisplayServer.window_set_window_event_callback(_on_window_event)
	# ☝️ Everytime any changes occur to game window, this ☝️ function will be called.
	
	# 👇 catches "start_game" signal from "screens.gd" 
	# 👇 and runs "_on_screen_start_game" function which starts new game.
	screens.start_game.connect(_on_screen_start_game)
	# 👇 catches "player_died" signal emitted from "game.gd"
	# 👇 and runs "_on_game_player_died" function which takes "score" and "high score" as a parameter
	game.player_died.connect(_on_game_player_died)
	# 👇 catches "delete_level" signal from "screens.gd" 
	# 👇 and runs " " function which will delete the old level.
	screens.delete_level.connect(_on_screen_delete_level)
	# 👇 Catches the signal from "game" script
	game.pause_game.connect(_on_game_pause_game)
	# 👇 In APP purchase signal
	iap_manager.unlock_new_skin.connect(_iap_manager_unlock_new_skin)
	screens.purchase_skin.connect(_on_screens_purchase_skin)
	# 👇 ONLY FOR TESTING, catches to reset the purchase while testing
	screens.reset_purchases.connect(_on_screen_reset_purchases)


# 👇 Function recognises when the game window looses focus 
# 👇 and when it gains focus.
func _on_window_event(event):
	# print("New window event " + str(event))
	match event:
		# 👇 If window is maximized/ brought back to focus.
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("Focus in")
			MyUtility.add_log_msg("Focus in")
		# 👇 If window is minimized/ another app opened.
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			print("Focus out")
			MyUtility.add_log_msg("Focus out")
			# 👇 To pause the game only when there is a game in
			# 👇 progress and the game is not already paused
			if game_in_progress == true && !get_tree().paused:
				_on_game_pause_game()
				print("Window minimized, pausing the game!")
				MyUtility.add_log_msg("Focus out")
		# 👇 To make sure that the close button still works
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()
#
#func _process(delta: float) -> void:
	#print(game_in_progress)

# 👇 This function starts a new game when called.
func _on_screen_start_game():
	# 👇 The new game has started 
	game_in_progress = true
	# 👇 Starts a new game
	game.new_game()


# 👇 This function is called when "player_died" signal is received above
# 👇 and changes the screen to game_over screen. It takes "score" and "high score" as a parameter.
func _on_game_player_died(score, highscore):
	# 👇 The game is done for sure so..
	game_in_progress = false
	# 👇 Delays gameover screen by 750 miliseconds so that player 
	# 👇 gets enough time to register that the game is over.
	await(get_tree().create_timer(0.75).timeout)
	# 👇 This calls "screen.gd"'s game_over() function.
	screens.game_over(score, highscore)

# 👇 This function will delete the level when the player dies.
func _on_screen_delete_level():
	# 👇 Since the level is being deleted, the game will also stop.
	game_in_progress = false
	# 👇 This function in "game.gd" script will reset the game.
	game.reset_game()

# 👇 This will pause the whole game
func _on_game_pause_game():
	# 👇 Pauses the whole scene tree. Physics, Collison detection,UI, etc. all stops. Even the buttons won't work.
	get_tree().paused = true
	# 👇 Changing current scene through "screens.gd"'s pause_game function
	screens.pause_game()

###### IAP Signals ######

func _iap_manager_unlock_new_skin():
	if game.new_skin_unlocked == false:
		game.new_skin_unlocked = true
		print("Unlocking the new skin...")

func _on_screens_purchase_skin():
	iap_manager.purchase_skin()

func _on_screen_reset_purchases():
	iap_manager.reset_purchases()
