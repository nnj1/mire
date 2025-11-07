extends CharacterBody2D

@export var speed = 50
var run_modifier = 1


func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_pressed("run"):
		run_modifier = 2
	else:
		run_modifier = 1
	var front_direction = (get_global_mouse_position() - self.global_position).normalized()
	print(front_direction)
	velocity = front_direction * input_direction.dot(Vector2.UP)  * speed * run_modifier
		
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("flashlight"):
		get_node('PointLight2D').enabled = !get_node('PointLight2D').enabled
	# Get the global position of the mouse cursor
	var mouse_position = get_global_mouse_position()

	# Rotate the node to face the mouse position
	look_at(mouse_position)
	
	# adjust animation
	if velocity != Vector2.ZERO:
		# The object is moving
		get_node("AnimatedSprite2D").play('flashlight_move')
	else:
		get_node("AnimatedSprite2D").play('flashlight_idle')

func _physics_process(delta):
	get_input()
	move_and_slide()
	
