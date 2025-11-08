extends Node2D


func _on_button_pressed() -> void:
	Networking.start_server()
	get_tree().change_scene_to_file("res://game.tscn")
	
func _on_button_2_pressed() -> void:
	Networking.start_client()
	get_tree().change_scene_to_file("res://game.tscn")
