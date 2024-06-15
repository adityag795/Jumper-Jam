extends Control
# ☝️ since all the screens this script will be attached to have "control nodes" at the root

var fade_dur = 0.25

func _ready() -> void:
	visible = false
	# 👇 Controls alpha value to change visibility of a screen
	# 👇 The value is floating point 0.0 to 1.0 (o being 0 and 1.0 being 255)
	modulate.a = 0.0
	# 👇 This calls the "set_disabled" function of all the nodes belonging 
	# 👇 to "buttons" group to set their "diabled" property to true.
	get_tree().call_group("buttons", "set_disabled", true)
	
# 👇 To turn ON the scene visibility
func appear():
	visible = true
	# 👇 creating a tween object to animate "modulate.a" property
	var tween = get_tree().create_tween()
	# ☝️ Tween is light-weight object good for animsting numerical properties
	
	# 👇 Tweens also get disabled when the get_scene_tree() is paused.
	# 👇 So we changed the Screens's root node's Process mode to "Always"
	# 👇 After that we need to change tween's PAUSE MODE as shown below
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# 👇 Takes the modulate's alpha property to change to "1" from current value in duration of "0.5 seconds".
	tween.tween_property(self, "modulate:a", 1.0, fade_dur)
	# 👇 Returns the object so that it can be saved and triggered with some delay
	return tween
	
# 👇 To turn OFF the scene visibility	
func disappear():
	# 👇 As soon as screen starts disappearing, we diable all the buttons
	get_tree().call_group("buttons", "set_disabled", true)
	# ☝️ To disable button clicks while the screens are fading out.
	# visible = false 👈Set this in change_screen() after awaiting "finished" signal
	var tween = get_tree().create_tween()
	
	# 👇 Tweens also get disabled when the get_scene_tree() is paused.
	# 👇 So we changed the Screens's root node's Process mode to "Always"
	# 👇 After that we need to change tween's PAUSE MODE as shown below
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# 👇 Takes the modulate's alpha property to change to "0" from current value in duration of "0.5 seconds".
	tween.tween_property(self, "modulate:a", 0.0, fade_dur)
	return tween
