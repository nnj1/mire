extends RigidBody2D

@export var item_data = {}

func prepare(given_item_data):
	item_data = given_item_data

	
func _ready() -> void:
	self.set_multiplayer_authority(1)
	get_node('TextureRect').texture = load(self.item_data.icon)
	get_node('TextureRect').tooltip_text = self.item_data.name
	get_node("TextureRect").material.set_shader_parameter("speed", 0)
	
	
func _on_texture_rect_mouse_entered() -> void:
	get_node("TextureRect").scale = Vector2(1.2, 1.2)
	get_node("TextureRect").material.set_shader_parameter("speed", 1)

func _on_texture_rect_mouse_exited() -> void:
	get_node("TextureRect").scale = Vector2(1, 1)
	get_node("TextureRect").material.set_shader_parameter("speed", 0)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed('shoot'):
		print('Clicked')
	
