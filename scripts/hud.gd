extends Control

@onready var topbar = $TopBar
@onready var topbar_bg = $TopBarBG
@onready var score_label = $TopBar/ScoreLabel

# 👇 signal to reach "main" scene which has access to "screens" scene
signal pause_game

func _ready() -> void:
	var os_name = OS.get_name()
	if os_name == "Android" || os_name == "iOS":
		# 👇 To learn what the safe area is (that includes onscreen camera, speaker grill, etc.)
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y # This value is the difference between top of the screen(0,0) and top of sage area(0.50)
		
		if os_name == "iOS":
			var screen_scale = DisplayServer.screen_get_scale()
			safe_area_top = (safe_area_top / screen_scale)
			MyUtility.add_log_msg("Screen scale: " + str(screen_scale))
		# 👇 We move TopBar into safe area so that score & other stats show below front-camera hole
		topbar.position.y += safe_area_top
		# 👇 The account for difference TopBar's top and bottom distance from TopBarBG's Top and Bottom.
		var margin = 10
		# 👇 We increase the size of the top bar's background
		topbar_bg.size.y += safe_area_top + margin

		MyUtility.add_log_msg("Safe area: " + str(safe_area))
		MyUtility.add_log_msg("Window size: " + str(DisplayServer.window_get_size()))
		MyUtility.add_log_msg("Safe_area_top: " + str(safe_area_top))
		MyUtility.add_log_msg("top bar pos: " + str(topbar.position))

# 👇 Gets called when the pause button in the HUD is pressed
func _on_pause_button_pressed() -> void:
	SoundFX.play("Click")
	# 👇 Pauses the whole scene tree. Physics, Collison detection,UI, etc. all stops. Even the buttons won't work.
	# get_tree().paused = !get_tree().paused
	# Since HUD is inside of the "game" scene, this can be caught and used to trigger other functions/signals inside "game" script
	pause_game.emit()

# 👇 To update the score on HUD
func set_score(new_score: int):
	# 👇 Keeps updating the "text" of "score_label"
	score_label.text = str(new_score)
