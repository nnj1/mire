extends MultiplayerSpawner


# In your Server-side Spawner script (e.g., a MobSpawner node's script)
@export var ground_item_scene: PackedScene = load("res://ground_item.tscn")

func _ready() -> void:
	# spawn 3 items
	spawn_new_item('medicine', Vector2(0,0))
	spawn_new_item('food', Vector2(0,0))
	spawn_new_item('needle', Vector2(0,0))
	
func spawn_new_item(item_name: String, spawn_position: Vector2):
	# This check is crucial: Only the server can instantiate and add_child
	if not is_server(): 
		return
		
	# TODO: based on item name, look up item data from JSON structure and create an item
	
	var new_item = ground_item_scene.instantiate()
	new_item.position = spawn_position + Vector2.from_angle(randf_range(0, TAU)) * 200
	new_item.rotation = randf_range(0, TAU)
	new_item.prepare()

	# The Spawner watches its 'Spawn Path' (e.g., EnemyContainer) for new children.
	# When the server adds a new child here, the Spawner automatically replicates the spawn 
	# (and the linked MultiplayerSynchronizer) to all connected clients.
	get_node(spawn_path).call_deferred("add_child", new_item, true)
	

func is_server():
	return multiplayer.is_server()
