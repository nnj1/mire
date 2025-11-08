extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)
	
	spawn_player(1)

func spawn_player(id: int) -> void:
	if not multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player)
	
func despawn_player(player_node):
	print('need to find a way to despawn')
	
