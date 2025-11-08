extends Node2D

func _ready() -> void:
	get_node('UI/role').text = Networking.ROLE
	get_node('UI/id').text = str(get_tree().get_multiplayer().get_unique_id())


func _process(delta: float) -> void:
	var shader_material : ShaderMaterial = get_node('Fog layer/Fog').material
	#shader_material.set_shader_parameter("smoke_color", Color(1.0, 0.0, 0.0))
