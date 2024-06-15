extends Camera2D

@onready var destroyer = $Destroyer
@onready var destroyer_shape = $Destroyer/CollisionShape2D

# 👇 Make sure that this variable can only hold a player type
var player: Player = null
# 👇 Global variable 
var viewport_size

func _ready() -> void:
	# 👇 The camera should adjust just after it is created OR else there is a delay and creates a glitch while creating a new game
	if player:
		global_position.y = player.global_position.y
	
	# 👇 To store reference of viewport_size()
	viewport_size = get_viewport_rect().size
	# 👇 To find centre point of screen
	global_position.x = viewport_size.x/2
	# ☝️ Will calculate for device of every screen
	
	# 👇 To stop camera from going below the ground or outside the window
	limit_bottom = viewport_size.y
	limit_left = 0
	limit_right = viewport_size.x
	# 👇 Placing the destroyer at the bottom edge of the camera
	destroyer.position.y = viewport_size.y
	# 👇 Storing the desired available shape for CollisionShape2D in "rect_shape"
	var rect_shape = RectangleShape2D.new()
	# 👇 Deciding the size of the shape. "X" part has to catch platforms hence kept at viewport size. "Y" not that important so kept 200.
	var rect_shape_size = Vector2(viewport_size.x, 200)
	# 👇 Setting size of the rect_shape."set_size()" function does not come up in suggestions.
	rect_shape.set_size(rect_shape_size)
	# 👇 Assigning that shape to collisonshape2D's shape
	destroyer_shape.shape = rect_shape
	
func _process(_delta: float) -> void:
	if player:
		# 👇 This is a margin distance below player. You can play with this value.
		var limit_distance = 520
		# 👇 if camera's lowest bound > player's y position with jump height + limit distance
		if limit_bottom > player.global_position.y + limit_distance:
			limit_bottom = int (player.global_position.y + limit_distance)
	
	# 👇 We will call count the number of areas that are overlapping
	var overlapping_areas = destroyer.get_overlapping_areas()
	# 👇 if there are no overlapping areas, than skip
	# 👇 else, delete them one by one
	if overlapping_areas.size() > 0:
		for area in overlapping_areas:
			if area is Platform:
				area.queue_free()
				# print(" Deleting " + area.name)
	
	#if player and player.global_position.y < limit_bottom - viewport_size.y/2:
		#limit_bottom = player.global_position.y + viewport_size.y/2

func _physics_process(_delta: float) -> void:
	if player:
		global_position.y = player.global_position.y

# 👇 This function can only accept as Player as an argument
func setup_camera(_player: Player):
	if _player:
		player = _player
