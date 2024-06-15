extends Node2D

@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite

# 👇 Creating variables for parallax
@onready var parallax1 = $ParallaxBackground/ParallaxLayer
@onready var parallax2 = $ParallaxBackground/ParallaxLayer2
@onready var parallax3 = $ParallaxBackground/ParallaxLayer3
@onready var hud = $UILayer/HUD
# 👇 To store reference to the player scene
var player_scene = preload("res://scenes/player.tscn")
var player: Player = null
var player_spawn_pos: Vector2
# 👇 To store the score of the player
var score: int = 0
# 👇 To store reference to the game camera scene
var highscore: int = 0

var camera_scene = preload("res://scenes/game_camera.tscn")

var camera = null
var viewport_size: Vector2
# 👇 Picking a path for the save file
var save_file_path = "user://highscore.save"
# ☝️ "user://" is a special fi;le path that godot uses which is different on all operating systems
# ☝️ Godot is going to create a special folder in the player system to store the save file. 

# 👇 Creating a new signal so that it can reach "main.gd" script
signal player_died(score, highscore)
# 👇 To be emitted when HUD emits its own pause game signal
signal pause_game
# 👇 Weather the In-app purchase has been purchased or not
var new_skin_unlocked = false

# 👇 Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 👇 Calculating the position where player should be spawn
	viewport_size = get_viewport_rect().size
	var player_spawn_pos_y_offset = 135
	player_spawn_pos.x = viewport_size.x / 2
	player_spawn_pos.y = viewport_size.y - player_spawn_pos_y_offset
	# 👇 Calculating the position of ground sprite
	ground_sprite.global_position.x = viewport_size.x / 2
	ground_sprite.global_position.y = viewport_size.y
	
	setup_parallax_layer(parallax1)
	setup_parallax_layer(parallax2)
	setup_parallax_layer(parallax3)
	# 👇 Hiding the ground sprite in the begining
	hud.visible = false
	# 👇 Hiding the ground sprite in the begining
	ground_sprite.visible = false
	# 👇 Setting to 0 before starting of the game
	hud.set_score(0)
	# 👇 Score needs to be loaded in the start of the game
	load_score()
	# 👇 connecting "hud" script's pause game signal to a function which will emit "game" script's pause game signal
	hud.pause_game.connect(_on_hud_pause_game)
	
# 👇 This will give you the correct scale for the sprite of the parallax layer.
# 👇 This will be called from inside the setup_parallax_layer()
func get_parallax_sprite_scale(parallax_sprite: Sprite2D):
	# Let's get the texture out of the sprite
	var parallax_texture = parallax_sprite.get_texture()
	var parallax_texture_width = parallax_texture.get_width()
	# 👇 Calculating the correct sprite scale - 🚨 Formula/algo is imp. to note here
	var scale = viewport_size.x / parallax_texture_width
	var result = Vector2(scale, scale)
	return result
	
# 👇 This will set the correct sprite scale using the above function and then
# 👇 calculate the motion mirroring value for the layer as well
func setup_parallax_layer(parallax_layer: ParallaxLayer):
	# 👇 Get the layer and Find its child
	var parallax_sprite = parallax_layer.find_child("Sprite2D")
	# 👇 If it finds a child name "Sprite2D"
	if parallax_sprite != null:
		# 👇 It gets the scale from the above function
		parallax_sprite.scale = get_parallax_sprite_scale(parallax_sprite)
		# 👇 Motion mirroring value = "Scale of the sprite" X "Height of the sprite"
		var mirrorY = parallax_sprite.scale.y * parallax_sprite.get_texture().get_height()
		parallax_layer.motion_mirroring.y = mirrorY
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if player:
		# 👇 Making sure that the score does't reduces when
		# 👇 when the player goes down after the mid of the jump
		if score < (viewport_size.y - player.global_position.y):
			# 👇 Calculating player's score as per player's Y coordinate position
			score = (viewport_size.y - player.global_position.y)
			# 👇 Setting up the score using "set_score" function in "hud.gd" script
			hud.set_score(score)

func new_game():
	
	# 👇 Deleting any existing player or camera objects and level parts
	reset_game()
	# 👇 Instantiating player
	player = player_scene.instantiate()
	player.global_position = player_spawn_pos
	# 👇 catches "died" signal emitted from "player.gd" 
	# 👇 and runs the "_on_player_died" function
	player.died.connect(_on_player_died)
	add_child(player)
	# 👇 To instantiate the camera scene from within the code
	camera = camera_scene.instantiate()
	# 👇 This is a function in game_camera script
	camera.setup_camera(player)
	# 👇 This adds camera as a child of the root node
	add_child(camera)
	
	# 👇 Applying new skin
	if new_skin_unlocked:
		player.use_new_skin()
	# ☝️ Call this only after "add_child(player)" OR else player will be NULL.
	if player:
		level_generator.setup(player)
		level_generator.start_generation()
	
	# 👇 Making the HUD visible with new game
	hud.visible = true
	# 👇 Making ground sprite visible with new game
	ground_sprite.visible = true
	# 👇 Setting the score to 0 every time a new game starts
	score = 0

# 👇 This function is run when "died" signal is received
# 👇 This will then access the main script to access screen script to change to "GameOver" screen
func _on_player_died():
	# 👇 Updating Highscore
	if score > highscore:
		highscore = score
		print("New high score: " + str(highscore))
		# 👇 Saving score as soon as player dies
		save_score()
	# 👇 Disabling the HUD
	hud.visible = false
	# 👇 This emits along with score and high score
	player_died.emit(score, highscore)

# 👇 This function resets the level
func reset_game():
	# 👇 Hiding the ground sprite in the begining
	ground_sprite.visible = false
	# 👇 Setting to 0 before starting of the game
	hud.set_score(0)
	# 👇 Hiding the HUD
	hud.visible = false
	# 👇 First, We will delete the level, which will be 
	# 👇 done in level_generator script.
	level_generator.reset_level()
	# 👇 Deleting the player
	if player != null:
		player.queue_free()
		player = null
		# 👇 The game crashes if this is not set to null
		level_generator.player = null
	# 👇 Deleting the camera
	if camera != null:
		camera.queue_free()
		camera = null

# 👇 Function to save score
func save_score():
	# 👇 open the save file 👇( file path, file operation )
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	# ☝️ file handle creates the file if it doesn't exist
	file.store_var(highscore) # 👈 Store the variable "highscore" along with the value inside.
	# file.store_var("var_one")
	# file.store_var("var_two")
	print("Saving highscore to disk...")

# 👇 Function to load score
func load_score():
	if FileAccess.file_exists(save_file_path):
		# 👇 open the save file 👇( file path, file operation )
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		# 👇 "get_var()" returns the list of variables in the order in which you save them.
		highscore = file.get_var() # 👈 gives you "highscore"
		# file.get_var() # 👈 running it again gives you "var_one"
		# file.get_var() # 👈 running it again gives you "var_two"
		print("Loading highscore from file..." + str(highscore))
		file.close()
	else:
		print("Save file doesn't exist, setting highscore to 0.")
		highscore = 0

func _on_hud_pause_game():
	pause_game.emit()
