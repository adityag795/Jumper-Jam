extends Node2D

@onready var platform_parent = $PlatformParent

var platform_scene = preload("res://scenes/platform.tscn")

# Level Generation variables
var start_platform_y
var y_distance_between_platform = 100
var level_size = 50
# 👇 To store the width and height of the game window
var viewport_size
# 👇 To store how many times did the platform generation loop has ran already
var generated_platform_count = 0
var player:Player = null

func setup(_player: Player):
	if _player:
		player = _player

func _ready() -> void:
	
	viewport_size = get_viewport_rect().size
	# 👇 Calculating the height in -y axis for placing 1st platform
	start_platform_y = viewport_size.y - (y_distance_between_platform * 2)
	# 👇 Setting it to 0 before the game begins
	# generated_platform_count = 0
	# ☝️ This line was resulting in generate_level() function running twice because
	# 🚨 generated_platform_count was getting set to 0 again.

# 👇 Creating a function to start generating level
func start_generation():
	# 👇 Called for the first time to generate level.
	generate_level(start_platform_y, true)

func _process(_delta: float) -> void:
	# 👇 We need to keep a track of player's Y position
	if player:
		# 👇 Stores the height at which player has reached
		var py = player.global_position.y
		# 👇 To calculate end of level position TOWARDS -y axis
		var end_of_level_pos = start_platform_y - (generated_platform_count * y_distance_between_platform)
		
		# 🚨🚨🚨 👇 The value of threshold is broken, which is leading to double generation as the game starts
		# 👉 Now resolved by commenting "generated_platform_count = 0" under "onready" method
		
		# 👇 Stores the height that which player touches, next 50 or so blocks will be generated
		var threshold = end_of_level_pos + (y_distance_between_platform * 6) 
		# ☝️ Reducing the level so that the player does not see new levels being generated
		# print("Player y coordinate: " + str(py) + ", Threshold:  " + str(threshold))
		# 👇 if player touches the threshold
		if py <= threshold and generated_platform_count != 0:
			# print("Player threshold reached " + str(py) + "  " + str(threshold))
			# 👇 Generate the next 50 levels but don't generate ground
			generate_level(end_of_level_pos, false)

# Start_y to take note of new height/ last platform that was generated in the last go.
func generate_level(start_y: float, generate_ground: bool):
	
	var platform_width = 136
	if generate_ground == true:
		# 👇👇👇👇 Generating Ground for any window width
		# 👇 Taking the size of the platform in consideration
		# 👇 Calculating no. of platforms needed to cover the whole width
		var ground_layer_platform_count = (viewport_size.x / platform_width) + 1
		# 👇 This is the HEIGHT of the platform
		var ground_layer_y_offset = 62 
		for i in range(ground_layer_platform_count):
			var ground_location = Vector2(i * platform_width, viewport_size.y - ground_layer_y_offset)
			create_platform(ground_location)
		
	# 👇👇👇👇 Generating the rest of the level
	# 👇 Creating a platform at different location / Level generation loop
	for i in range(level_size):

		var location: Vector2 = Vector2.ZERO
		# 👇 Calculate the x coordinate of the platform
		var max_x_position = viewport_size.x - platform_width
		var random_x = randf_range(0.0, max_x_position)
		location.x = random_x
		# 👇 Calculate the y coordinate of the platform
		location.y = start_y - (y_distance_between_platform * i)
		
		# print(location)
		create_platform(location)
		# 👇 Updating the number of platforms
		generated_platform_count += 1
		# print("generated_platform_count " + str(generated_platform_count))

# 👇 To instantiate a platform, set its location and add it as a child to parent node
func create_platform(location: Vector2):
	
	var platform = platform_scene.instantiate()
	# 👇😐 Whenever you instantiate another scene using variable, it wont't suggest its methods.
	# 👇 In below case, I had to write "global_position" myself. It wasn't suggested in auto-complete.
	platform.global_position = location
	platform_parent.add_child(platform)
	return platform

# 👇 To delete all the platforms created in the parent_platform
func reset_level():
	# 👇 Resetting the platform count back to 0
	generated_platform_count = 0
	# 👇 This returns an array to "platform". We will loop 
	# 👇 over all of them and delete them.
	for platform in platform_parent.get_children():
		platform.queue_free()
