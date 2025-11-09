# CanvasModulate Day/Night Cycle Script (GDScript for Godot 4)
extends CanvasModulate

## --- Configuration ---
@export var day_length_in_seconds: float = 120.0 # Real-world seconds for one full in-game day
var time_speed_multiplier: float = 24.0 / day_length_in_seconds 
# Time speed is calculated based on desired day length.

@export_range(0.0, 24.0, 0.1) var current_time_hour: float = 6.0 # Start at 6:00 AM (Sunrise)

## --- Color Definitions (Adjust these to fit your game's aesthetic) ---
const COLOR_NIGHT = Color(0.1, 0.1, 0.3, 1.0)        # Dark Blue/Purple
const COLOR_SUNRISE = Color(0.8, 0.5, 0.2, 1.0)      # Warm Orange/Red
const COLOR_DAY = Color(1.0, 1.0, 1.0, 1.0)          # Full Brightness (White)
const COLOR_SUNSET = Color(1.0, 0.4, 0.15, 1.0)      # Deep Orange/Red

## --- Time Markers (The hour when the phase begins) ---
const SUNRISE_START_HOUR: float = 5.0 # 5:00 AM
const DAY_START_HOUR: float = 7.0     # 7:00 AM
const SUNSET_START_HOUR: float = 18.0 # 6:00 PM
const NIGHT_START_HOUR: float = 20.0  # 8:00 PM (Transition to Night begins)
const MIDNIGHT_START_HOUR: float = 22.0 # 10:00 PM (Transition to Sunrise begins)

# Time duration for smooth transitions in hours
const TRANSITION_DURATION: float = 2.0 


func _ready():
	# Set the authority to the server (peer ID 1)
	set_multiplayer_authority(1)
	# Ensure the speed multiplier is calculated at start
	time_speed_multiplier = 24.0 / day_length_in_seconds

func _process(delta: float):
	if not is_multiplayer_authority(): return
	# 1. Update In-Game Time
	current_time_hour += delta * time_speed_multiplier
	# Wrap time around to 24 hours
	current_time_hour = fmod(current_time_hour, 24.0)
	
	# Variables for color interpolation
	var from_color: Color
	var to_color: Color
	var transition_start: float = 0.0
	var transition_end: float = 0.0
	var lerp_weight: float = 0.0

	# 2. Determine Current Time Phase and Set Colors/Times

	# --- PHASE 1: Night to Sunrise Transition (e.g., 3:00 to 5:00) ---
	# This phase handles the tail end of the night leading into sunrise.
	if current_time_hour < SUNRISE_START_HOUR:
		from_color = COLOR_NIGHT
		to_color = COLOR_SUNRISE
		# Calculate transition that logically occurs before SUNRISE_START_HOUR
		transition_start = SUNRISE_START_HOUR - TRANSITION_DURATION 
		transition_end = SUNRISE_START_HOUR

	# --- PHASE 2: Sunrise to Day Transition (5:00 to 7:00) ---
	elif current_time_hour < DAY_START_HOUR:
		from_color = COLOR_SUNRISE
		to_color = COLOR_DAY
		transition_start = SUNRISE_START_HOUR
		transition_end = DAY_START_HOUR
		
	# --- PHASE 3: Full Day (7:00 to 18:00) ---
	elif current_time_hour < SUNSET_START_HOUR:
		self.color = COLOR_DAY
		return # Exit early when no transition is needed
		
	# --- PHASE 4: Day to Sunset Transition (18:00 to 20:00) ---
	elif current_time_hour < NIGHT_START_HOUR:
		from_color = COLOR_DAY
		to_color = COLOR_SUNSET
		transition_start = SUNSET_START_HOUR
		transition_end = NIGHT_START_HOUR
		
	# --- PHASE 5: Sunset to Night Transition (20:00 to 22:00) ---
	elif current_time_hour < MIDNIGHT_START_HOUR:
		from_color = COLOR_SUNSET
		to_color = COLOR_NIGHT
		transition_start = NIGHT_START_HOUR
		transition_end = MIDNIGHT_START_HOUR
		
	# --- PHASE 6: Full Night (22:00 to 3:00) ---
	else: # current_time_hour >= MIDNIGHT_START_HOUR (or the end of the day)
		self.color = COLOR_NIGHT
		return # Exit early when no transition is needed

	# 3. Calculate Interpolation Weight (t)
	# Ensure transition times are valid for a duration check
	var current_duration: float = transition_end - transition_start
	if current_duration <= 0.0: # Should not happen with current setup, but a safeguard
		current_duration = TRANSITION_DURATION

	# Calculate time into the transition window
	var time_in_transition: float = current_time_hour - transition_start
	
	# Calculate lerp weight (t value) and clamp it between 0.0 and 1.0
	lerp_weight = clamp(time_in_transition / current_duration, 0.0, 1.0)

	# 4. Apply New Color
	self.color = from_color.lerp(to_color, lerp_weight)
