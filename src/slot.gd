extends ColorRect

# the JSON document containing item data
var item = null

func prepare(item) -> void:
	self.item = item
	self.tooltip_text = item.name
	get_node('button').texture = load(item.icon)
	if item.active:
		self.color = Color(0.573,0.573,0.573, 0.63)
	
func _ready() -> void:
	# Crucial: Setting this property to a non-empty string triggers 
	# the engine to call _make_custom_tooltip(). Use a space to prevent 
	# the default tooltip from showing.
	#get_node('TextureRect').tooltip_text = 'yeet'
	
	pass

func _on_button_gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().get_root().get_node('Node2D').show_item_view(self.item)
