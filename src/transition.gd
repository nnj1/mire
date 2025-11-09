extends CanvasLayer

const FADE_TIME = 0.5 

# Only reference the ColorRect, which is the object being animated.
@onready var fader: ColorRect = $Fader 

func _ready():
	# Start fully transparent.
	fader.color.a = 0.0

# ------------------------------------
# FADE-OUT: Hides the current scene
# ------------------------------------
func fade_out():
	# CREATE the TWEEN LOCALLY
	var current_tween = create_tween()
	
	# Configure and add the tweener. It starts automatically.
	current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.tween_property(fader, "color:a", 1.0, FADE_TIME)
	
	# Wait for the animation to finish.
	await current_tween.finished
	
	return true

# ------------------------------------
# FADE-IN: Reveals the new scene
# ------------------------------------
func fade_in():
	# CREATE the TWEEN LOCALLY
	var current_tween = create_tween()
	
	# Configure and add the tweener. It starts automatically.
	current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	current_tween.tween_property(fader, "color:a", 0.0, FADE_TIME)
	
	# Wait for the animation to finish.
	await current_tween.finished
	
	return true

# ------------------------------------
# Unified Transition Function (Updated)
# ------------------------------------
func transition_to_scene(path: String):
	# 1. Fade out the current scene
	await fade_out()
	
	# 2. Change the scene while the screen is black
	var error = get_tree().change_scene_to_file(path)
	
	if error != OK:
		print("ERROR: Could not load scene at path: ", path)
		await fade_in() 
		return

	# 3. CRITICAL STEP: Wait for the scene tree change to finalize.
	# This fires AFTER the new root has been set and the new scene's _ready() 
	# functions have executed, meaning all nodes (including MultiplayerSpawner) 
	# should be attached and ready for processing.
	await get_tree().tree_changed
	
	# Optional but often helpful for networking: wait one more frame
	# to ensure all initial network processing has a chance to run.
	await get_tree().process_frame
	
	# 4. Fade in to reveal the new scene
	await fade_in()
	
	print("Transition complete and new scene is fully loaded.")
