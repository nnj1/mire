extends Camera2D

# Settings for the shake effect
var trauma: float = 0.0 # Current shake intensity (0.0 to 1.0)
@export var trauma_decay: float = 1.0 # How fast trauma fades per second
@export var max_offset: float = 400.0 # Max pixel/unit offset for the shake

# Store the camera's original position/offset
var original_position: Vector2

# Optional: Add a smooth animation when the shake stops
var trauma_tween: Tween

# --- Configuration ---
@export var zoom_speed := 2.0 # How quickly the zoom adjusts (Higher = Faster, Less smooth)
@export var zoom_factor := 0.1 # How much to change the zoom level per scroll click
@export var min_zoom := Vector2(0.75, 0.75) # Closest zoom-in limit
@export var max_zoom := Vector2(2, 2) # Farthest zoom-out limit

var target_zoom := Vector2(1.0, 1.0) # Start at default zoom

func _ready():
	# Store the initial camera offset, which is usually (0, 0)
	original_position = position

# --- Input Handling (Detect Mouse Wheel) ---
func _input(event):
	if event is InputEvent:
		# Zoom In (Closer)
		if Input.is_action_pressed('zoom_in'):
			target_zoom -= Vector2(zoom_factor, zoom_factor)
		
		# Zoom Out (Farther)
		elif Input.is_action_pressed('zoom_out'):
			target_zoom += Vector2(zoom_factor, zoom_factor)
		
		# Clamp the target zoom to stay within defined limits
		target_zoom.x = clampf(target_zoom.x, min_zoom.x, max_zoom.x)
		target_zoom.y = clampf(target_zoom.y, min_zoom.y, max_zoom.y)

# --- Smoothing Loop ---
func _process(delta):
	# Smoothly move the actual 'zoom' towards the 'target_zoom'
	# By multiplying 'zoom_speed' by 'delta', the zoom rate is consistent across all frame rates.
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	
	if trauma > 0:
		# 1. Decay the trauma over time
		trauma -= trauma_decay * delta
		trauma = max(trauma, 0) # Ensure trauma doesn't go below 0
		
		# 2. Calculate the shake intensity
		# The shake factor is the square of trauma. Squaring gives a faster fade-out 
		# for a more dramatic, snappy stop.
		var shake_factor = trauma * trauma 
		
		# 3. Apply a randomized offset
		# The shake uses a high-frequency noise (or simple randf) for erratic movement.
		var x_offset = randf_range(-1.0, 1.0) * max_offset * shake_factor
		var y_offset = randf_range(-1.0, 1.0) * max_offset * shake_factor
		
		# Apply the final position offset
		position = original_position + Vector2(x_offset, y_offset)
	else:
		# When trauma hits zero, ensure the camera snaps back to its intended position
		position = original_position

# --- Public API for Other Scripts to Call ---

# Call this from any other script (e.g., player hit, explosion)
# The trauma parameter should be between 0.0 and 1.0.
func add_trauma(amount: float):
	# Clamping ensures the trauma never exceeds 1.0
	trauma = min(trauma + amount, 1.0)
