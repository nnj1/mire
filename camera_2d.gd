extends Camera2D

# --- Configuration ---
@export var zoom_speed := 2.0 # How quickly the zoom adjusts (Higher = Faster, Less smooth)
@export var zoom_factor := 0.1 # How much to change the zoom level per scroll click
@export var min_zoom := Vector2(0.75, 0.75) # Closest zoom-in limit
@export var max_zoom := Vector2(2, 2) # Farthest zoom-out limit

var target_zoom := Vector2(1.0, 1.0) # Start at default zoom

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
