extends Node2D


func _on_button_pressed() -> void:
	Networking.start_server()
	get_tree().change_scene_to_file("res://game.tscn")
	
func _on_button_2_pressed() -> void:
	var outcome = Networking.start_client()
	if outcome:
		get_tree().change_scene_to_file("res://game.tscn")


func _on_text_edit_text_changed() -> void:
	Networking.ADDRESS = get_node('VBoxContainer/HBoxContainer/TextEdit').text
	Networking.PORT = get_node('VBoxContainer/HBoxContainer/TextEdit').text


func _on_text_edit_2_text_changed() -> void:
	pass # Replace with function body.
