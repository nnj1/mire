extends Node2D

func _on_button_pressed() -> void:
	Networking.start_server()
	
	# We use 'await' to pause the function until the animation is finished
	await Transition.fade_out() 
	# 2. Change the scene while the screen is black
	get_tree().change_scene_to_file("res://game.tscn")
	# 3. Start the fade-in to reveal the new scene
	await Transition.fade_in()
	
	print("New scene loaded and revealed!")
	
func _on_button_2_pressed() -> void:
	var outcome = Networking.start_client()
	if outcome:
		get_tree().change_scene_to_file("res://game.tscn")

	# We use 'await' to pause the function until the animation is finished
	await Transition.fade_out() 
	# 2. Change the scene while the screen is black
	get_tree().change_scene_to_file("res://game.tscn")
	# 3. Start the fade-in to reveal the new scene
	await Transition.fade_in()
	
	print("New scene loaded and revealed!")
	
func _on_text_edit_text_changed() -> void:
	Networking.ADDRESS = get_node('VBoxContainer/HBoxContainer/TextEdit').text
	Networking.PORT = get_node('VBoxContainer/HBoxContainer/TextEdit').text


func _on_text_edit_2_text_changed() -> void:
	pass # Replace with function body.
