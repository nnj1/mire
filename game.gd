extends Node2D

func _ready() -> void:
	get_node('UI/role').text = Networking.ROLE
	get_node('UI/id').text = Networking.UniquePeerID
