extends CanvasLayer

# The duration of the fade animation in seconds.
const FADE_TIME = 0.5 

@onready var fader: ColorRect = $Fader
@onready var tween: Tween

# Called to instantly hide the fade overlay (set its alpha to 0).
func _ready():
	tween = get_tree().create_tween()
	# Start fully transparent so the scene is visible immediately
	fader.color.a = 0.0

# ------------------------------------
# FADE-OUT: Hides the current scene
# ------------------------------------
func fade_out():
	# Ensure the Tween is ready to go
	if tween:
		tween.kill() # Stop any previous tween operation
		
	# Start at the current alpha and tween it to fully opaque (alpha 1.0)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 1. Animate the ColorRect's alpha from 0.0 to 1.0 (fully black)
	tween.tween_property(fader, "color:a", 1.0, FADE_TIME)
	
	# 2. Wait for the fade out to complete
	await tween.finished
	
	# The scene is now completely blacked out.
	return true # Signal that the fade-out is complete

# ------------------------------------
# FADE-IN: Reveals the new scene
# ------------------------------------
func fade_in():
	# Ensure the Tween is ready to go
	if tween:
		tween.kill() 
		
	# Start fully opaque and tween it to transparent (alpha 0.0)
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# 1. Animate the ColorRect's alpha from 1.0 to 0.0 (fully transparent)
	tween.tween_property(fader, "color:a", 0.0, FADE_TIME)
	
	# 2. Wait for the fade in to complete
	await tween.finished
	
	# The new scene is now visible.
	return true # Signal that the fade-in is complete
