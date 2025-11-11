extends ColorRect

# the JSON document containing item data
var item: Dictionary

func prepare(item_given) -> void:
	self.item = item_given
	get_node('button').tooltip_text = item.name
	get_node('button').icon = load(item.icon)
	if item.active:
		self.color = Color(0.573,0.573,0.573, 0.63)
	
func _ready() -> void:
	# Crucial: Setting this property to a non-empty string triggers 
	# the engine to call _make_custom_tooltip(). Use a space to prevent 
	# the default tooltip from showing.
	#get_node('TextureRect').tooltip_text = 'yeet'
	
	pass

func _on_button_pressed() -> void:
	get_tree().get_root().get_node('Node2D').show_item_view(self.item)
