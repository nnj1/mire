extends Node2D

const INVENTORY_SLOT = preload("res://slot.tscn")
var typing_chat: bool = false
var in_pause_menu:bool = false
var over_inventory:bool = false
var viewing_itemview:bool = false

func _ready() -> void:
	get_node('UI/role').text = Networking.ROLE
	get_node('UI/id').text = str(get_tree().get_multiplayer().get_unique_id())

func update_inventory(inventory) -> void:
	# clear current inventory
	for child in get_node('UI/inventory').get_children():
		child.queue_free()
	# populate clear current inventory
	for item in inventory:
		var slot = INVENTORY_SLOT.instantiate()
		slot.prepare(item)
		get_node('UI/inventory').add_child(slot)
		
func _input(_event: InputEvent):
	if Input.is_action_just_released("chat"):
		get_node('UI/VBoxContainer/chatinput').grab_focus()
		typing_chat = true
		
	if Input.is_action_just_pressed('ui_cancel'):
		get_node('PauseUI').visible = !get_node('PauseUI').visible
		if get_node('PauseUI').visible:
			in_pause_menu = true
		else:
			in_pause_menu = false
	
func _process(_delta: float) -> void:
	# show FPS on UI
	get_node("UI/fps").text = "FPS: " + str(Engine.get_frames_per_second())
	
	# TODO: fuck with the fog shader
	var _shader_material : ShaderMaterial = get_node('Fog layer/Fog').material
	#shader_material.set_shader_parameter("smoke_color", Color(1.0, 0.0, 0.0))
	
	
# code for chat functionality
func _on_chatinput_focus_entered() -> void:
	# When TextEdit gains focus, disable player input handling
	typing_chat = true

func _on_chatinput_focus_exited() -> void:
	# When TextEdit loses focus, re-enable player input handling
	typing_chat = false

func _on_chatinput_text_submitted(new_text: String) -> void:
	if new_text != '':
		if not is_multiplayer_authority():
			send_chat.rpc_id(1, new_text, multiplayer.get_unique_id())
		else:
			send_chat(new_text, multiplayer.get_unique_id())
		get_node('UI/VBoxContainer/chatinput').text = ''
	get_node('UI/VBoxContainer/chatinput').release_focus()
	typing_chat = false

func _on_chatbox_ready() -> void:
	get_node('UI/VBoxContainer/chatbox').set_multiplayer_authority(1)

@rpc('any_peer', 'unreliable_ordered')
func send_chat(new_text, id):
	# APPEND THE MESSAGE TO CHAT HISTORY
	get_node('UI/VBoxContainer/chatbox').text += '\n' + str(id) + ':  '+ new_text
	# if the message contains a server code send it to server TODO: only allow the authority to do this!
	if multiplayer.is_server():
		if new_text == '/spawnbear':
			get_node('enemies/EnemyMultiplayerSpawner').spawn_new_enemy(Vector2(0,0))

func _on_h_slider_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), value)

func _on_h_slider_3_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Sound'), value)

func _on_button_pressed() -> void:
	get_node('UI/itemview').visible = false
	viewing_itemview = false
	
func show_item_view(item: Dictionary):
	get_node('UI/itemview').visible = true
	get_node('UI/itemview/Panel/VBoxContainer/Label').text = item.name
	get_node('UI/itemview/Panel/VBoxContainer/HBoxContainer/RichTextLabel').text = item.description
	get_node('UI/itemview/Panel/VBoxContainer/HBoxContainer/TextureRect').texture = load(item.icon)
	viewing_itemview = true

func _on_inventory_mouse_entered() -> void:
	self.over_inventory = true
	#print('entered inventory')

func _on_inventory_mouse_exited() -> void:
	self.over_inventory = false
	#print('exited inventory')

# server side code that any peer can connect to to request the server to do shit
@rpc("any_peer", 'reliable')
func request_damage(target_path, damage_amount: int, source_peer_id: int):
	if not multiplayer.is_server():
		return
	var target_node = get_node(target_path)
	print('Server got request from ' + str(source_peer_id) + ' to do damage to ' + target_node.name)
	# do the damage and shit
	target_node.take_damage(damage_amount, source_peer_id)

func _on_button_4_pressed() -> void:
	get_tree().quit()
