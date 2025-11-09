extends Node2D

const INVENTORY_SLOT = preload("res://slot.tscn")

func _ready() -> void:
	get_node('UI/role').text = Networking.ROLE
	get_node('UI/id').text = str(get_tree().get_multiplayer().get_unique_id())

func update_inventory(inventory) -> void:
	# clear current inventory
	for child in get_node('UI/inventory').get_children():
		child.queue_free()
	# populate clear current inventory TODO: make input object more complex
	for item in inventory:
		var slot = INVENTORY_SLOT.instantiate()
		slot.prepare(item)
		get_node('UI/inventory').add_child(slot)
	
func _process(_delta: float) -> void:
	# show FPS on UI
	get_node("UI/fps").text = "FPS: " + str(Engine.get_frames_per_second())
	
	# TODO: fuck with the fog shader
	var _shader_material : ShaderMaterial = get_node('Fog layer/Fog').material
	#shader_material.set_shader_parameter("smoke_color", Color(1.0, 0.0, 0.0))
	
	
	
