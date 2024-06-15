extends CanvasLayer

# 👇 Emitted when the play button is pressed.
signal start_game
# 👇 Emitted to delete the level before new level is created.
signal delete_level
# 👇 Emits when player is trying to purchase new skin
signal purchase_skin
# 👇 ONLY FOR TESTING PURPOSE, creating signal to reset purchases
signal reset_purchases

@onready var console = $Debug/ConsoleLog

# 👇 Creating references to the scenes so that they can be later used in the script
@onready var title_screen = $TitleScreen
@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen
@onready var game_over_score_label = $GameOverScreen/Box/ScoreLabel
@onready var game_over_high_score_label = $GameOverScreen/Box/HighScoreLabel
@onready var shop_screen = $ShopScreen

var current_screen = null

# 👇 Called when the node enters the scene tree for the first time.
func _ready() -> void:
	console.visible = false
	
	register_buttons()
	change_screen(title_screen)
	
# 👇 To handle pressed signal from various buttons
func register_buttons():
	
	var buttons = get_tree().get_nodes_in_group("buttons")
	
	if buttons.size() > 0:
		for button in buttons:
			if button is ScreenButton:
				# 👇 This "clicked" signal has been created inside "screen_buttons.gd"
				button.clicked.connect(_on_button_pressed)

# 👇 One function to control what happens from any button click
func _on_button_pressed(button):
	SoundFX.play("Click")
	match button.name:
		"TitlePlay":
			# print("Play button is pressed.")
			# 👇 To hide the current scene
			change_screen(null)
			await(get_tree().create_timer(0.5).timeout)
			start_game.emit()
		"TitleShop":
			change_screen(shop_screen)
		"PauseRetry":
			# 👇 Close the pause screen
			change_screen(null)
			# 👇 Wait for pause screen to disappear totally
			await(get_tree().create_timer(0.75).timeout)
			# 👇 Resume the game
			get_tree().paused = false
			# 👇 Emit signal to start a new game
			start_game.emit() 
		"PauseBack":
			change_screen(title_screen)
			# 👇 Resume the game
			get_tree().paused = false
			# 👇 Emit signal to delete the level
			delete_level.emit()
		"PauseClose":
			# 👇 Close the pause screen
			change_screen(null)
			# 👇 Wait for pause screen to disappear totally
			await(get_tree().create_timer(0.75).timeout)
			# 👇 Resume the game
			get_tree().paused = false
		"GameOverRestart":
			# 👇 No need to create new signal to for retry.
			# 👇 We can use the same "start_game" signal.
			change_screen(null)
			# 👇 Wait for the screen to fade out
			await(get_tree().create_timer(0.5).timeout)
			# 👇 Emit signal to start a new game
			start_game.emit()
		"GameOverMenu":
			# 👇 This is where we need to delete the old level
			# 👇 and old camera.
			change_screen(title_screen)
			delete_level.emit()
		"ShopBack":
			print("Go back")
			change_screen(title_screen)
		"ShopPurchaseSkin":
			# 👇 Emits when player clicks on new skin
			purchase_skin.emit()
		"ShopResetPurchases":
			reset_purchases.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_toggle_console_pressed() -> void:
	console.visible = !console.visible	
	# 👇 "utility.gd" is accessible to all the scripts using the name "MyUtility".
	# MyUtility.add_log_msg()
	# ☝️ MyUtility is a name for singleton of "utility.gd" script assigned in "Project Settings" -> "Autoload"

func change_screen(new_screen):
	# 👇👇👇 Hiding the current scene
	# 👇 if current scene is present and not null
	if current_screen != null:
		# 👇 stores the "Tween" object. 
		var disappear_tween = current_screen.disappear()
		# ☝️ Once the animations is finished, it will emit a "finished" signal.
		# 👇 This will stop this function until "finished" signal is emitted from this tween.
		await(disappear_tween.finished) # In this 👈 case, it will wait for 0.5 seconds
		# 👇 If ".visible" (which does not show up in auto-complete) is not set to false, the buttons will still work.
		current_screen.visible = false
		
	# 👇👇👇 Changing current scene to new scene
	current_screen = new_screen
	if current_screen != null:
		var appear_tween = current_screen.appear()
		await(appear_tween.finished)
		# 👇 To enable button clicks after the screens come on the screen completely.
		get_tree().call_group("buttons", "set_disabled", false)

# 👇 Sets the label of Score and Highscore and changes 
# 👇 current_screen to game_over screen. 
func game_over(score, highscore):
	# 👇 updates text of score label
	game_over_score_label.text = "Score:" + str(score)
	# 👇 updates text of high score label
	game_over_high_score_label.text = "Best:" + str(highscore)
	# 👇 changes current_screen to game_over screen.
	change_screen(game_over_screen)

# 👇 Sets the current scene to pause screen when pause button is pressed
func pause_game():
	change_screen(pause_screen)
