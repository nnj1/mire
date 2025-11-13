extends RigidBody2D

var item_data

func prepare(given_item_data = {
		'name': 'default item',
		'description': 'some default shit',
		'equippable': false,
		'consumable': false,
		'shoot': false,
		'melee': false,
		'active': false,
		'damage': 1,
		'icon': 'will generate random'
	}):
	item_data = given_item_data
	var random_icons = Networking.dir_contents('res://assets/FreePixelSurvivalItemsPack/Items/')
	item_data.icon = 'res://assets/FreePixelSurvivalItemsPack/Items/' + random_icons.pick_random()
	
	get_node('TextureRect').texture = load(self.item_data.icon)
	get_node('TextureRect').tooltip_text = self.item_data.name
	get_node("TextureRect").material.set_shader_parameter("speed", 0)

	
func _ready() -> void:
	self.set_multiplayer_authority(1)
	
	
func _on_texture_rect_mouse_entered() -> void:
	get_node("TextureRect").scale = Vector2(1.2, 1.2)
	get_node("TextureRect").material.set_shader_parameter("speed", 1)

func _on_texture_rect_mouse_exited() -> void:
	get_node("TextureRect").scale = Vector2(1, 1)
	get_node("TextureRect").material.set_shader_parameter("speed", 0)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed('shoot'):
		print('Clicked')
	
