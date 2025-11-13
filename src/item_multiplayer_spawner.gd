extends MultiplayerSpawner


# In your Server-side Spawner script (e.g., a MobSpawner node's script)
@export var ground_item_scene: PackedScene = load("res://ground_item.tscn")

# Example function signature:
func my_custom_spawn_logic(data: Variant) -> Node:	
		
	# TODO: based on item name, look up item data from JSON structure and create an item, right now we're just putting out some random shit
	var new_item = ground_item_scene.instantiate()
	new_item.position = data.spawn_position + Vector2.from_angle(randf_range(0, TAU)) * 200
	new_item.rotation = randf_range(0, TAU)
	var random_icons = Networking.dir_contents('res://assets/FreePixelSurvivalItemsPack/Items/')
	var item_data = data.item_data
	if item_data == null:
		item_data = {
			'name': 'default item',
			'description': 'some default shit',
			'equippable': false,
			'consumable': false,
			'shoot': false,
			'melee': false,
			'active': false,
			'damage': 1,
			'icon': 'res://assets/FreePixelSurvivalItemsPack/Items/' + random_icons.pick_random()
		}
	new_item.prepare(item_data)

	# 3. Return the *unparented* node instance
	return new_item

func _ready() -> void:
	
	self.spawn_function = my_custom_spawn_logic
	
	# spawn 3 items
	if multiplayer.is_server():
		self.call_deferred('spawn',{'item_data': null, 'spawn_position':Vector2(0,0)})
		self.call_deferred('spawn',{'item_data': null, 'spawn_position':Vector2(0,0)})
		self.call_deferred('spawn',{'item_data': null, 'spawn_position':Vector2(0,0)})

func is_server():
	return multiplayer.is_server()
