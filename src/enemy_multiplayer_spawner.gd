extends MultiplayerSpawner


# In your Server-side Spawner script (e.g., a MobSpawner node's script)
@export var bear_enemy_scene: PackedScene = load("res://bear.tscn")

func _ready() -> void:
	# spawn 3 bears
	spawn_new_enemy(Vector2(0,0))
	spawn_new_enemy(Vector2(0,0))
	spawn_new_enemy(Vector2(0,0))
	
func spawn_new_enemy(spawn_position: Vector2):
	# This check is crucial: Only the server can instantiate and add_child
	if not is_server(): 
		return

	var new_enemy = bear_enemy_scene.instantiate()
	new_enemy.position = spawn_position + Vector2.from_angle(randf_range(0, TAU)) * 200
	new_enemy.rotation = randf_range(0, TAU)

	# The Spawner watches its 'Spawn Path' (e.g., EnemyContainer) for new children.
	# When the server adds a new child here, the Spawner automatically replicates the spawn 
	# (and the linked MultiplayerSynchronizer) to all connected clients.
	get_node(spawn_path).call_deferred("add_child", new_enemy, true)

func is_server():
	return multiplayer.is_server()
