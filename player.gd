extends CharacterBody2D

# variables for walking and running and turning direction with mouse
@export var speed = 50
var input_direction: Vector2
var front_direction: Vector2
var target_angle
var run_modifier = 1
var mouse_in_window = false

# variables for inventory management
var inventory_items = ['flashlight', 'handgun', 'knife', 'rifle', 'shotgun']
var current_inventory_item_index = 0

# variables for state machine and animations, note that these states can never occur together
# (whereas shooting will be handled independently, since you can technically shoot and melee while idle, walking, or running, but not reloading or interacting)
enum States {IDLE, WALKING, RUNNING, RELOADING, INTERACTING}
var state: States = States.IDLE
var body_animation_player: Node2D
var feet_animation_player: Node2D

# state machine for shooting and melee
enum CombatStates {NONE, SHOOTING, MELEE}
var combat_state: CombatStates = CombatStates.NONE

func set_combat_state(new_combat_state: int, force: bool = false) -> void:
	var previous_combat_state := combat_state
	# do state checks here to see if we actually want to change states
	# you can only shoot or melee if you're not reloading or interacting
	if new_combat_state != CombatStates.NONE and (state == States.RELOADING or state == States.INTERACTING):
		new_combat_state = previous_combat_state
	combat_state = new_combat_state as CombatStates
	
	if previous_combat_state != new_combat_state or not force:
		if combat_state == CombatStates.SHOOTING:
			body_animation_player.play(inventory_items[current_inventory_item_index] + '_shoot')
		elif combat_state == CombatStates.MELEE:
			get_node('gruntSound').play()
			
func set_state(new_state: int, force: bool = false) -> void:
	var previous_state := state
	# do state checks here to see if we actually want to change states
	# can't reload unless you're in an idle state 
	if new_state == States.RELOADING and previous_state != States.IDLE:
		new_state = previous_state
	state = new_state as States
	
	# only do animation stuff if the state has changed to a different one
	if previous_state != new_state or not force:
		if state == States.IDLE:
			body_animation_player.play(inventory_items[current_inventory_item_index] + '_idle')
			feet_animation_player.play('idle')
			get_node('walkingSound').stop()
			get_node('reloadSound').stop()
		elif state == States.WALKING:
			run_modifier = 1
			body_animation_player.play(inventory_items[current_inventory_item_index] + '_move')
			if abs(input_direction.dot(Vector2.LEFT)) > abs(input_direction.dot(Vector2.UP)):
				feet_animation_player.play('strafe_left')
			elif abs(input_direction.dot(Vector2.RIGHT)) > abs(input_direction.dot(Vector2.UP)):
				feet_animation_player.play('strafe_right')
			else:
				feet_animation_player.play('walk')
			get_node('walkingSound').volume_db = 2
			get_node('walkingSound').pitch_scale = 1
			if not get_node('walkingSound').playing:
				get_node('walkingSound').play()
		elif state == States.RUNNING:
			run_modifier = 2
			body_animation_player.play(inventory_items[current_inventory_item_index] + '_move')
			#TODO: find a way to dynamically adjust the strafe animation to be faster
			if abs(input_direction.dot(Vector2.LEFT)) > abs(input_direction.dot(Vector2.UP)):
				feet_animation_player.play('strafe_left')
			elif abs(input_direction.dot(Vector2.RIGHT)) > abs(input_direction.dot(Vector2.UP)):
				feet_animation_player.play('strafe_right')
			else:
				feet_animation_player.play('run')
			get_node('walkingSound').volume_db = 3
			get_node('walkingSound').pitch_scale = 1.2
			if not get_node('walkingSound').playing:
				get_node('walkingSound').play()
		elif state == States.RELOADING:
			if body_animation_player.get_animation() != inventory_items[current_inventory_item_index] + '_reload':
				if body_animation_player.sprite_frames.has_animation(inventory_items[current_inventory_item_index] + '_reload'):
					body_animation_player.play(inventory_items[current_inventory_item_index] + '_reload')
					if not get_node('reloadSound').playing:
						get_node('reloadSound').play()
			feet_animation_player.play('idle')

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	# fill up global variables
	body_animation_player = get_node("AnimatedSprite2D")
	feet_animation_player = get_node("AnimatedSprite2D2")
	# Check if this instance is controlled by the current local peer
	if is_multiplayer_authority():
		# Enable the Camera2D for the local player instance
		get_node("Camera2D").make_current()
	else:
		# Optionally, disable or ensure the camera is not current for remote players
		get_node("Camera2D").enabled = false

# for processing input events not related to animation
func _input(event: InputEvent) -> void:	
	if Input.is_action_just_released("scroll_up") and not event.ctrl_pressed:
		current_inventory_item_index += 1
		if current_inventory_item_index > len(inventory_items) - 1:
			current_inventory_item_index = 0
		# OPTIONAL: auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index] == 'flashlight':
			get_node('PointLight2D').enabled = true
		# call set state with the same state to get the animations to be consistent with flashlight
		set_state(state, true)
	if Input.is_action_just_released("scroll_down") and not event.ctrl_pressed:
		current_inventory_item_index -= 1
		if current_inventory_item_index < 0:
			current_inventory_item_index = len(inventory_items) - 1
		# auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index] == 'flashlight':
			get_node('PointLight2D').enabled = true
		# call set state with the same state to get the animations to be consistent with flashlight
		set_state(state, true)
	
# for state and animation dependeing things
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# detect if the mouse is in the window
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport().get_visible_rect()
	if viewport_rect.has_point(mouse_position):
		#print("Mouse is inside the game window.")
		mouse_in_window = true
	else:
		#print("Mouse is outside the game window.")
		mouse_in_window = false
	
	# if item is not flashlight, turn it off
	if inventory_items[current_inventory_item_index] != 'flashlight':
		get_node('PointLight2D').enabled = false
	# if user is on flashlight, handle toggling it when flashlight key is pressed
	if Input.is_action_just_released("flashlight") and inventory_items[current_inventory_item_index] == 'flashlight':
		get_node('PointLight2D').enabled = !get_node('PointLight2D').enabled
	
	# Handle rotation of the user based on mouse cursor position
	# Get the global position of the mouse cursor
	var _look_mouse_position = get_global_mouse_position()
	# Rotate the node to face the mouse position if mouse is in window
	if mouse_in_window:
		var direction_to_target = get_global_mouse_position() - self.global_position
		# 1. Calculate the target angle (in radians)
		target_angle = direction_to_target.angle() 
		# 2. Lerp the current rotation angle toward the target angle
		rotation = lerp_angle(rotation, target_angle, 6 * delta)
		#look_at(look_mouse_position)		


func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	get_input()
	move_and_slide()
	
	
# for dealing with movement input
func get_input():
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	front_direction = (get_global_mouse_position() - self.position).normalized()
	
	# TODO: some complex shit with mouse look i'm still working on
	#velocity = front_direction * input_direction.dot(Vector2.UP)  * speed * run_modifier
	#velocity += Vector2.LEFT * input_direction.dot(Vector2.LEFT) * speed / 2 
	#velocity += Vector2.RIGHT * input_direction.dot(Vector2.RIGHT) * speed / 2
	
	#if not Input.is_action_pressed("reload"):
	velocity = input_direction * speed * run_modifier
	#else:
		#velocity = Vector2.ZERO
	#	pass
	
	if velocity != Vector2.ZERO:
		if Input.is_action_pressed("run"):
			set_state(States.RUNNING)
		else:
			set_state(States.WALKING)
	else:
		if Input.is_action_pressed("reload"):
			set_state(States.RELOADING)
		else:
			set_state(States.IDLE)
	
