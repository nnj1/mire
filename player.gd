extends CharacterBody2D

@export var speed = 50
var run_modifier = 1
var inventory_items = ['flashlight', 'handgun', 'knife', 'rifle', 'shotgun']
var current_inventory_item_index = 0

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

func _input(event: InputEvent) -> void:
		
	if Input.is_action_just_released("scroll_up") and not event.ctrl_pressed:
		current_inventory_item_index += 1
		if current_inventory_item_index > len(inventory_items) - 1:
			current_inventory_item_index = 0
			# auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index] == 'flashlight':
			get_node('PointLight2D').enabled = true
	if Input.is_action_just_released("scroll_down") and not event.ctrl_pressed:
		current_inventory_item_index -= 1
		if current_inventory_item_index < 0:
			current_inventory_item_index = len(inventory_items) - 1
		# auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index] == 'flashlight':
			get_node('PointLight2D').enabled = true
	
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
	
	# if item is not flashlight, turn it off
	if inventory_items[current_inventory_item_index] != 'flashlight':
		get_node('PointLight2D').enabled = false

	if viewport_rect.has_point(mouse_position):
		#print("Mouse is inside the game window.")
		mouse_in_window = true
	else:
		#print("Mouse is outside the game window.")
		mouse_in_window = false
	
	if Input.is_action_just_released("flashlight") and inventory_items[current_inventory_item_index] == 'flashlight':
		get_node('PointLight2D').enabled = !get_node('PointLight2D').enabled
		
	# Get the global position of the mouse cursor
	var look_mouse_position = get_global_mouse_position()
	# Rotate the node to face the mouse position if mouse is in window
	if mouse_in_window:
		var direction_to_target = get_global_mouse_position() - self.global_position
		# 1. Calculate the target angle (in radians)
		var target_angle = direction_to_target.angle() 
		# 2. Lerp the current rotation angle toward the target angle
		rotation = lerp_angle(rotation, target_angle, 6 * delta)
		#look_at(look_mouse_position)
		
	
	# play animations shooting or melee
	if Input.is_action_pressed("melee"):
		get_node("AnimatedSprite2D").play(inventory_items[current_inventory_item_index] + '_meleeattack')
	elif Input.is_action_pressed("shoot"):
		get_node("AnimatedSprite2D").play(inventory_items[current_inventory_item_index] + '_shoot')
	# adjust animations for things that don't involve shooting or melee
	else:
		if velocity != Vector2.ZERO:
			# The player is moving
			if not get_node('walkingSound').playing:
				get_node('walkingSound').play()
			get_node("AnimatedSprite2D").play(inventory_items[current_inventory_item_index] + '_move')
		else:
			get_node('walkingSound').stop()
			get_node("AnimatedSprite2D").play(inventory_items[current_inventory_item_index] + '_idle')

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	get_input()
	move_and_slide()
	
