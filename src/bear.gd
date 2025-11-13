extends CharacterBody2D

const is_player:bool = false

var main_game_node: Node2D

var growl_sounds = [
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (1).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (2).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (3).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (4).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (5).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (6).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (7).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (8).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (9).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (10).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (11).mp3'),
	preload('res://assets/horror_sfx_vol_1/Monster Growl/Monster Growl (12).mp3')
]
				
var hurt_sounds = [
	preload('res://assets/Beasts/Beasts/Beast_Grunt.wav'),
	preload('res://assets/Beasts/Beasts/Beast_Grunt2.wav'),
	preload('res://assets/Beasts/Beasts/Beast_Grunt3.wav'),
	preload('res://assets/Beasts/Beasts/Beast_Grunt4.wav'),
	preload('res://assets/Beasts/Beasts/Beast_Grunt5.wav')
]

# --- Configuration ---
const SPEED = 50.0       # Movement speed in pixels/second
const ROTATION_SPEED = 1.0 # Speed of rotation (higher = faster turn)
const MIN_CHANGE_TIME = 5  # Minimum seconds before changing direction
const MAX_CHANGE_TIME = 10  # Maximum seconds before changing direction

# --- Speed Configuration ---
var MIN_SPEED = SPEED - 40       # Minimum movement speed in pixels/second
var MAX_SPEED = SPEED + 25     # Maximum movement speed in pixels/second

# --- State Variables ---
var current_speed: float = 0.0 # The speed currently being used for movement
var time_until_change: float = 0.0
var target_direction: Vector2 = Vector2.ZERO
var aggro: bool = false
var dead: bool = false
var health = 100

var last_attacker = null

# function for taking damage	

@rpc("authority", "reliable")
func take_damage(damage_amount: int, source_peer_id: int) -> void:
	if not dead:
		print(str(name) + ' just took ' + str(damage_amount) + ' damage from ' + str(source_peer_id))
		last_attacker = main_game_node.get_node(str(source_peer_id))
		# do other server side game state shit here
		health = health - damage_amount
		if health <= 0:
			dead = true
			get_node('hurtSound').stream = preload('res://assets/Beasts/Beasts/Beast_Defeated.wav')
			get_node('AnimatedSprite2D').play('dying')
			
		# will always be called from server and will modify things that will be synced with multiplayersynchronizer
		play_hit_animation.rpc()
		
@rpc("any_peer", "call_local")
func play_hit_animation():
	aggro = true
	_set_new_target_direction() # reorient direction
	get_node("bloodParticles").emitting = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.25)
	tween.tween_property(self, "modulate", Color(1,1,1), 0.25)
	if not get_node('hurtSound').playing:
		get_node('hurtSound').stream = hurt_sounds.pick_random()
		get_node('hurtSound').play()
			
func _ready():
	
	self.set_multiplayer_authority(1)
	
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	# Initialize the randomizer for unique paths each run
	randomize()
	
	# Set the initial random direction, time, and speed
	_set_new_target_direction()

# All movement and timing logic goes here for physics stability
func _physics_process(delta: float):
	
	# Only the server runs the game logic
	if not is_multiplayer_authority():
		return
		
	if not dead:
		# 1. Countdown the timer
		time_until_change -= delta
		
		# 2. Check if it's time to pick a new direction and speed
		if time_until_change <= 0:
			_set_new_target_direction()
			
		# 3. Apply Movement
		# The velocity is directly tied to the target direction and the current_speed
			# if bear is aggro, he goes twice as fast

		velocity = target_direction * (current_speed + 50 * int(aggro))
		move_and_slide()
		
		# 4. Smooth Rotation (LERP)
		_smooth_rotate(delta)
		
		# play animation
		if velocity:
			if not get_node('AnimatedSprite2D').is_playing():
				get_node('AnimatedSprite2D').play('walk')

# Function to calculate a new random direction, speed, and reset the timer
func _set_new_target_direction():
	# Set a new random time until the next direction change
	if not aggro:
		time_until_change = randf_range(MIN_CHANGE_TIME, MAX_CHANGE_TIME)
	elif aggro:
		# changes orietntation more frequently
		time_until_change = randf_range(0, 1)
	
	# NEW: Set a new random speed
	current_speed = randf_range(MIN_SPEED, MAX_SPEED)
		
	# adjust rate of walking animation to correspond to this speed
	get_node('AnimatedSprite2D').speed_scale = current_speed / SPEED
	
	# idle directions
	if not aggro:
		# Generate a random angle from 0 to 45 degrees 
		var random_angle = randf_range(-PI/2, PI/2)
		
		# Convert the angle into a normalized direction vector
		target_direction = Vector2.from_angle(random_angle)
	elif aggro:
		# directed directions towards player
		target_direction = (last_attacker.global_position - self.position).normalized()
	
	#print("New speed: ", current_speed, ". Next change in: ", time_until_change, "s")

# Function to smoothly turn the character to face the direction of movement
func _smooth_rotate(delta: float):
	# Only rotate if the character is actually moving
	if target_direction.length_squared() > 0.0: 
		
		# Calculate the angle (in radians) of the target_direction vector
		var target_rotation = target_direction.angle()
		
		# Use lerp_angle() for the shortest and smoothest rotation
		# delta * ROTATION_SPEED controls the interpolation factor, making it time-based
		rotation = lerp_angle(rotation, target_rotation, delta * ROTATION_SPEED)

# periodic growl
func _on_timer_timeout() -> void:
	# Only the server runs the game logic
	if not is_multiplayer_authority():
		return
	
	if not dead:
		get_node('growlSound').stream = growl_sounds.pick_random()
		get_node('growlSound').play()
		get_node('growlTimer').wait_time = randf_range(3, 8)
