extends CharacterBody2D
class_name Player

@onready var animator = $AnimationPlayer
@onready var cshape = $CollisionShape2D

var speed = 300.0
var accelerometer_speed = 130.0

var gravity = 15.0
var max_fall_velocity = 1000.0
var jump_velocity = -800

var viewport_size
# 👇 for detecting the platform is either Mobile or PC
var use_accelerometer = false
# 👇 If true, the game will stop taking input for the player
var dead = false
# 👇 To signal to main script -> game script -> game over screen
signal died

# 👇 Turning animation names into variables so that they can
# 👇 be later inside use_new_skin() function
var fall_anim_name = "fall"
var jump_anim_name = "jump"

# 👇 Getting reference of Sprite2D node
@onready var sprite = $Sprite2D

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	
	var os_name = OS.get_name()
	if os_name == "Android" || os_name == "iOS":
		use_accelerometer = true

func _process(_delta: float) -> void:
	if velocity.y > 0:
		if animator.current_animation != fall_anim_name:
			animator.play(fall_anim_name)
	elif velocity.y < 0:
		if animator.current_animation != jump_anim_name:
			animator.play(jump_anim_name)

func _physics_process(_delta: float) -> void:
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity
	
	# 👇 If the player is still alive
	if !dead:
		if use_accelerometer:
			var mobile_input = Input.get_accelerometer()
			# print("Accelerometer: " + str(mobile_input))
			# 👇 The value of "mobile_input.x" swings bwetween -10 and +10 for left to right direction.
			# 👇 "accelerometer_speed" is multiplied to give a decent speed
			velocity.x = mobile_input.x * accelerometer_speed
		else:
		# 👇👇👇👇 Horizontal Movement for Keyboard Input 👇👇👇👇 #
			var direction = Input.get_axis("move_left", "move_right")
			# 👇 If direction is not = 0
			if direction:
				velocity.x = direction * speed
			else:
				# "speed/6" is the value of "delta"
				velocity.x = move_toward(velocity.x, 0, speed/6)
			# ☝️ This takes value of velocity.x and set it to be 0 over a small period of time
		
	# 👇 Add this to make the player move
	move_and_slide()
	
	var margin = 20
	# 👇 To check if the player has reached right end of screen
	if global_position.x > viewport_size.x + margin:
		# 👇 if so, then 
		global_position.x = -margin
	# 👇 To check if the player has reached left end of screen
	if global_position.x < 0 - margin:
		global_position.x = viewport_size.x + margin

func jump():
	velocity.y = jump_velocity
	SoundFX.play("Jump")

# 👇 To detect when the player goes off the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()

# 👇 To disable collision shape of the player when the player is dead
func die():
	# 👇 If the player is still alive
	if !dead:
		dead = true
		# 👇 Alternative to [cshape.disabled = true] to avoid errors
		cshape.set_deferred("disabled", true)
		# 👇 Emitting the signal when the player dies
		died.emit()
		SoundFX.play("Fall")

# 👇 To use new skins that player must buy
func use_new_skin():
	# 👇 Changing the variable name to use red character's animation
	fall_anim_name = "fall_red"
	jump_anim_name = "jump_red"
	# 👇 Changing the texture of "Sprite2D" node to avoid 
	# 👇 begining frames with player's old skin.
	if sprite:
		sprite.texture = preload("res://assets/textures/character/Skin2Idle.png")
