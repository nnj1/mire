extends CharacterBody2D

# file paths for hurt sounds
var hurt_sounds = [preload('res://assets/Darkworld Audio - Survival Effects [Free .ogg]/Human/HumanInjured1.ogg'),
				 preload('res://assets/Darkworld Audio - Survival Effects [Free .ogg]/Human/HumanInjured2.ogg'),
				preload('res://assets/Darkworld Audio - Survival Effects [Free .ogg]/Human/HumanInjured3.ogg'),
				preload('res://assets/Darkworld Audio - Survival Effects [Free .ogg]/Human/HumanInjured4.ogg')]

# variables for walking and running and turning direction with mouse
@export var speed = 50
var input_direction: Vector2
var front_direction: Vector2
var target_angle
var run_modifier = 1
var mouse_in_window = false

#variables for combat
var MAX_HEALTH = 100
var health = 100
var MAX_STAMINA = 100
var stamina = 100
var dead = false

# variables for customizing the mouse cursor (crosshair)
var original_cursor_image: Image
var current_cursor_scale: float

# variables for inventory management
var inventory_items = [
	{
		'name': 'flashlight',
		'description': 'For lighting up the dark.',
		'equippable': true,
		'consumable': false,
		'shoot': false,
		'melee': true,
		'active': true,
		'damage': 1,
		'icon': 'res://assets/FreePixelSurvivalItemsPack/Items/3.png'
	},
	{
		'name': 'knife',
		'description': 'some shit',
		'equippable': true,
		'consumable': false,
		'shoot': false,
		'melee': true,
		'active': false,
		'damage': 5,
		'icon': 'res://assets/FreePixelMeleeWeaponPack/Weapons/13.png'	
	},
	{
		'name': 'handgun',
		'description': 'For lighting up the enemies.',
		'equippable': true,
		'consumable': false,
		'shoot': true,
		'melee': true,
		'active': false,
		'damage': 5,
		'icon': 'res://assets/FreePixelGunPack/Guns/1.png'	
	},
	{
		'name': 'rifle',
		'description': 'some shit',
		'equippable': true,
		'consumable': false,
		'shoot': true,
		'melee': true,
		'active': false,
		'damage': 10,
		'icon': 'res://assets/FreePixelGunPack/Guns/11.png'	
	},
	{
		'name': 'shotgun',
		'description': 'some shit',
		'equippable': true,
		'consumable': false,
		'shoot': true,
		'melee': true,
		'active': false,
		'damage': 25,
		'icon': 'res://assets/FreePixelGunPack/Guns/23.png'	
	}
]
var current_inventory_item_index = 0

# variables for state machine and animations, note that these states can never occur together
# (whereas shooting will be handled independently, since you can technically shoot and melee while idle, walking, or running, but not reloading or interacting)
enum States {IDLE, WALKING, RUNNING, RELOADING, INTERACTING}
var state: States = States.IDLE
var body_animation_player: Node2D
var feet_animation_player: Node2D
var advanced_animation_player: AnimationPlayer

# variable to access main game node and functions
var main_game_node: Node2D

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
			if advanced_animation_player.has_animation(inventory_items[current_inventory_item_index].name + '_shoot'):
				if not advanced_animation_player.is_playing():
					advanced_animation_player.play(inventory_items[current_inventory_item_index].name + '_shoot')
					
					# do the actually shooting operation:
					var first_object = get_node('RayCast2D').get_collider()
					if first_object:
						if first_object.has_method('take_damage') and not first_object.dead:
							# do the actually shooting operation:
							
							# tween the cursor to register a hit
							var tween = create_tween()
							tween.tween_method(_set_scaled_cursor, 1, 1.5, .1)
							tween.tween_method(_set_scaled_cursor, 1.5, 1, .2)
							
							var damage = inventory_items[current_inventory_item_index].damage
							
							#if not multiplayer.is_server():
								#print('made it here')
								#first_object.take_damage.rpc_id(1, damage, int(name))
							#else:
								#first_object.take_damage(damage, int(name))
							if not multiplayer.is_server():
								main_game_node.request_damage.rpc_id(1, first_object.get_path(), damage, multiplayer.get_unique_id())
							else:
								main_game_node.request_damage(first_object.get_path(), damage, multiplayer.get_unique_id())
								
					# for single shot weapons, leave the state after firing (not the case for automatic)
					if inventory_items[current_inventory_item_index].name == 'handgun':
						set_state(CombatStates.NONE)
					if inventory_items[current_inventory_item_index].name == 'shotgun':
						set_state(CombatStates.NONE)
					
		elif combat_state == CombatStates.MELEE:
			if advanced_animation_player.has_animation(inventory_items[current_inventory_item_index].name + '_meleeattack'):
				if not advanced_animation_player.is_playing():
					advanced_animation_player.play(inventory_items[current_inventory_item_index].name + '_meleeattack')
		
		elif combat_state == CombatStates.NONE:
			_set_scaled_cursor(1.0)
			# stop any existing combat animation TODO: kinda janky
			advanced_animation_player.stop()
			
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
			get_node('Area2D').monitoring = false
			if combat_state == CombatStates.NONE:
				body_animation_player.play(inventory_items[current_inventory_item_index].name + '_idle')
			feet_animation_player.play('idle')
			get_node('walkingSound').stop()
			get_node('reloadSound').stop()
			if not get_node('breathingSlowSound').playing:
				get_node('breathingSlowSound').play()
		elif state == States.WALKING:
			get_node('Area2D').monitoring = false
			run_modifier = 1
			if combat_state == CombatStates.NONE:	
				body_animation_player.play(inventory_items[current_inventory_item_index].name + '_move')
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
			if not get_node('breathingFastSound').playing:
				get_node('breathingFastSound').play()
		elif state == States.RUNNING:
			get_node('Area2D').monitoring = false
			run_modifier = 2
			if combat_state == CombatStates.NONE:
				body_animation_player.play(inventory_items[current_inventory_item_index].name + '_move')
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
			get_node('breathingSound').pitch_scale = 0.5
			if not get_node('breathingSound').playing:
				get_node('breathingSound').play()
		elif state == States.RELOADING:
			get_node('Area2D').monitoring = false
			if body_animation_player.get_animation() != inventory_items[current_inventory_item_index].name + '_reload':
				if body_animation_player.sprite_frames.has_animation(inventory_items[current_inventory_item_index].name + '_reload'):
					body_animation_player.play(inventory_items[current_inventory_item_index].name + '_reload')
					if not get_node('reloadSound').playing:
						get_node('reloadSound').play()
			feet_animation_player.play('idle')
		elif state == States.INTERACTING:
			# maybe play some interacting animation here?
			get_node('Area2D').monitoring = true
			pass

# function for taking damage	
# This function can be called by any peer, but will execute on the authority (server)
@rpc("authority", "reliable")
func take_damage(damage_amount: int, source_peer_id: int) -> void:
	if multiplayer.is_server() and not dead:
		print(str(name) + ' just took ' + str(damage_amount) + ' damage from ' + str(source_peer_id))
		# do other server side game state shit here
		play_hit_animation.rpc() # other people can see the hit

@rpc("any_peer", "call_local")		
func play_hit_animation():
	if is_multiplayer_authority():
		get_node('Camera2D').add_trauma(0.5)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.25)
	tween.tween_property(self, "modulate", Color(1,1,1), 0.25)
	if not get_node('hurtSound').playing:
		get_node('hurtSound').stream = hurt_sounds.pick_random()
		get_node('hurtSound').play()
		
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _set_scaled_cursor(scale: float):
	if not original_cursor_image:
		return

	# Store the scale
	current_cursor_scale = scale

	# Calculate new dimensions
	var base_width = original_cursor_image.get_width()
	var base_height = original_cursor_image.get_height()

	var new_width = int(base_width * scale)
	var new_height = int(base_height * scale)

	# 2. Duplicate the original image and resize it
	var scaled_image = original_cursor_image.duplicate()
	# Use nearest-neighbor interpolation to keep pixel art crisp, or BILINEAR for smooth scaling
	scaled_image.resize(new_width, new_height, Image.INTERPOLATE_NEAREST)

	# 3. Convert the resized Image back to a Texture
	var scaled_texture = ImageTexture.create_from_image(scaled_image)

	# Calculate the new hotspot (center of the image)
	# The hotspot must be scaled by the same factor
	var new_hotspot = Vector2(new_width / 2.0, new_height / 2.0)

	# 4. Apply the custom mouse cursor
	Input.set_custom_mouse_cursor(
		scaled_texture,
		Input.CURSOR_ARROW, # Use ARROW or a custom type if desired
		new_hotspot
	)

func _ready() -> void:
	# fill up global variables
	body_animation_player = get_node("AnimatedSprite2D")
	feet_animation_player = get_node("AnimatedSprite2D2")
	advanced_animation_player = get_node("AnimationPlayer")
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	# 1. Load the base texture's Image data (to be resized later)
	original_cursor_image = preload('res://assets/new_crosshairs/c_dot.png').get_image()
	# Set the initial, default cursor
	_set_scaled_cursor(1.0)
	
	# Check if this instance is controlled by the current local peer
	if is_multiplayer_authority():
		# Enable the Camera2D for the local player instance
		get_node("Camera2D").make_current()
		# Jack into the GUI and update inventory
		main_game_node.update_inventory(inventory_items)
	else:
		# Optionally, disable or ensure the camera is not current for remote players
		get_node("Camera2D").enabled = false

# for processing input events not related to animation
func _input(event: InputEvent) -> void:	
	if Input.is_action_just_pressed("scroll_up") and not event.ctrl_pressed:
		inventory_items[current_inventory_item_index].active = false
		if current_inventory_item_index + 1 > len(inventory_items) - 1:
			current_inventory_item_index = 0
		else:
			current_inventory_item_index += 1
		inventory_items[current_inventory_item_index].active = true
		# OPTIONAL: auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index].name == 'flashlight':
			get_node('PointLight2D').enabled = true
			get_node("flashlightOnSound").play()
		
		# call set state with the same state to get the animations to be consistent with flashlight
		set_state(state, true)
		
		# Jack into the GUI and update inventory
		main_game_node.update_inventory(inventory_items)
		
	if Input.is_action_just_pressed("scroll_down") and not event.ctrl_pressed:
		inventory_items[current_inventory_item_index].active = false
		if current_inventory_item_index - 1 < 0:
			current_inventory_item_index = len(inventory_items) - 1
		else:
			current_inventory_item_index -= 1
		inventory_items[current_inventory_item_index].active = true
		# auto turn on flashlight if you switch to it
		if inventory_items[current_inventory_item_index].name == 'flashlight':
			get_node('PointLight2D').enabled = true
			get_node("flashlightOnSound").play()
		# call set state with the same state to get the animations to be consistent with flashlight
		set_state(state, true)
		
		# Jack into the GUI and update inventory
		main_game_node.update_inventory(inventory_items)
	
# for state and animation dependent things
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
	if inventory_items[current_inventory_item_index].name != 'flashlight':
		get_node('PointLight2D').enabled = false
	# if user is on flashlight, handle toggling it when flashlight key is pressed
	if not main_game_node.typing_chat and Input.is_action_just_released("flashlight") and inventory_items[current_inventory_item_index].name == 'flashlight':
		if get_node('PointLight2D').enabled:
			get_node("flashlightOffSound").play()
		else:
			get_node("flashlightOnSound").play()
		get_node('PointLight2D').enabled = !get_node('PointLight2D').enabled
		
	# play flashlight hum if flashlight is on
	if inventory_items[current_inventory_item_index].name == 'flashlight' and get_node('PointLight2D').enabled:
		if not get_node('flashlightHumSound').playing:
			get_node('flashlightHumSound').play()
	else:
		get_node('flashlightHumSound').stop()
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
		
	# draw the health and stamina bars
	main_game_node.get_node('UI/healthbar').value = self.health / self.MAX_HEALTH * 100
	main_game_node.get_node('UI/staminabar').value = self.stamina / self.MAX_STAMINA * 100

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	get_input()
	move_and_slide()
	
# for dealing with movement input
func get_input():
	if not main_game_node.typing_chat:
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
		
		# add recoil if shooting
		if combat_state == CombatStates.SHOOTING:
			if inventory_items[current_inventory_item_index].name == 'shotgun':
				velocity += front_direction * - 20
			if inventory_items[current_inventory_item_index].name == 'rifle':
				velocity += front_direction * - 15
		
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
		
		# since both these actions use the mouse click, we'll disable it when in pause menu:
		
		if not main_game_node.in_pause_menu and not main_game_node.over_inventory and not main_game_node.viewing_itemview:
			# TODO: shooting should only work if using a weapon that can shoot
			if Input.is_action_pressed("shoot") and inventory_items[current_inventory_item_index].shoot:
				set_combat_state(CombatStates.SHOOTING)
			if Input.is_action_just_released("shoot") and inventory_items[current_inventory_item_index].shoot:
				set_combat_state(CombatStates.NONE)
				
			# TODO: melee should only work if using a weapon that can melee
			if Input.is_action_pressed("melee") and inventory_items[current_inventory_item_index].melee:
				set_combat_state(CombatStates.MELEE)
			if Input.is_action_just_released("melee") and inventory_items[current_inventory_item_index].melee:
				set_combat_state(CombatStates.NONE)
				
			if Input.is_action_pressed('interact'):
				set_state(States.INTERACTING)
			if Input.is_action_just_released("interact"):
				set_state(States.IDLE)
				
	#print(combat_state)


# if interaction is active, this signal will go off if an item is in the area
func _on_area_2d_body_entered(body: Node2D) -> void:
	# if the body is an item, pick it up
	if 'item_data' in body:
		if not multiplayer.is_server():
			main_game_node.request_pick_up.rpc_id(1, body.get_path(), multiplayer.get_unique_id())
		else:
			main_game_node.request_pick_up(body.get_path(), multiplayer.get_unique_id())
