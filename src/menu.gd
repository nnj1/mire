extends Node2D

func _on_button_pressed() -> void:
	Networking.start_server()
	#await fade_out_menu()
	get_tree().change_scene_to_file("res://game.tscn")
	#Transition.transition_to_scene("res://game.tscn")

	
func _on_button_2_pressed() -> void:
	Networking.start_client()
	#await fade_out_menu()
	get_tree().change_scene_to_file("res://game.tscn")
	#Transition.transition_to_scene("res://game.tscn")
	
	
func _on_text_edit_text_changed() -> void:
	Networking.ADDRESS = get_node('VBoxContainer/HBoxContainer/TextEdit').text
	Networking.PORT = get_node('VBoxContainer/HBoxContainer/TextEdit').text

func fade_out_menu():
	# CREATE the TWEEN LOCALLY
	var current_tween = create_tween()
	
	# Configure and add the tweener. It starts automatically.
	current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.tween_property(get_node('CanvasLayer/ColorRect'), "color:a", 1.0,  0.5)
	
	# Wait for the animation to finish.
	await current_tween.finished
	
	return true

func _on_text_edit_2_text_changed() -> void:
	pass # Replace with function body.
