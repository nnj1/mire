extends CharacterBody2D

@export var speed = 50
var run_modifier = 1

var mouse_in_window = false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	# Check if this instance is controlled by the current local peer
	if is_multiplayer_authority():
		# Enable the Camera2D for the local player instance
		get_node("Camera2D").make_current()
	else:
		# Optionally, disable or ensure the camera is not current for remote players
		get_node("Camera2D").enabled = false

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_pressed("run"):
		run_modifier = 2
	else:
		run_modifier = 1
	var front_direction = (get_global_mouse_position() - self.position).normalized()
	velocity = front_direction * input_direction.dot(Vector2.UP)  * speed * run_modifier
		
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport().get_visible_rect()

	if viewport_rect.has_point(mouse_position):
		#print("Mouse is inside the game window.")
		mouse_in_window = true
	else:
		#print("Mouse is outside the game window.")
		mouse_in_window = false
	
	if Input.is_action_just_released("flashlight"):
		get_node('PointLight2D').enabled = !get_node('PointLight2D').enabled
		
	# Get the global position of the mouse cursor
	var look_mouse_position = get_global_mouse_position()

	# Rotate the node to face the mouse position if mouse is in window
	if mouse_in_window:
		look_at(look_mouse_position)
	
	# adjust animation
	if velocity != Vector2.ZERO:
		# The player is moving
		if not get_node('walkingSound').playing:
			get_node('walkingSound').play()
		get_node("AnimatedSprite2D").play('flashlight_move')
	else:
		get_node('walkingSound').stop()
		get_node("AnimatedSprite2D").play('flashlight_idle')
		

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	get_input()
	move_and_slide()
	
