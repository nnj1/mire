extends Node2D

func _ready() -> void:
	get_node('UI/role').text = Networking.ROLE
	get_node('UI/id').text = str(get_tree().get_multiplayer().get_unique_id())
	
func _process(_delta: float) -> void:
	# show FPS on UI
	get_node("UI/fps").text = "FPS: " + str(Engine.get_frames_per_second())
	
	# TODO: fuck with the fog shader
	var _shader_material : ShaderMaterial = get_node('Fog layer/Fog').material
	#shader_material.set_shader_parameter("smoke_color", Color(1.0, 0.0, 0.0))
	
