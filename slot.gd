extends ColorRect

# Content to display in the tooltip
@export var tooltip_title: String = "default name"
@export var tooltip_description: String = "default description"

func prepare(item) -> void:
	tooltip_title = item.name
	tooltip_description = item.description
	get_node('TextureRect').texture = load(item.icon)
	if item.active:
		self.color = Color(0.573,0.573,0.573, 0.63)
	
func _ready() -> void:
	# Crucial: Setting this property to a non-empty string triggers 
	# the engine to call _make_custom_tooltip(). Use a space to prevent 
	# the default tooltip from showing.
	tooltip_text = "asdf"
	
# Virtual function called by the engine when hovering over this control.
#func _make_custom_tooltip(_for_text: String) -> Control:
	## --- 1. Create the Tooltip Root (Background/Panel) ---
	#var panel = PanelContainer.new()
	#panel.top_level = true
	#var style_box = StyleBoxFlat.new()
	#style_box.bg_color = Color("#333333")
	#style_box.set_corner_radius_all(5)
	#panel.add_theme_stylebox_override("panel", style_box)
	#
	## --- 2. Create the Layout (for padding) ---
	#var margin = MarginContainer.new()
	#margin.add_theme_constant_override("margin_left", 8)
	#margin.add_theme_constant_override("margin_top", 8)
	#margin.add_theme_constant_override("margin_right", 8)
	#margin.add_theme_constant_override("margin_bottom", 8)
	#panel.add_child(margin)
	#
	## --- 3. Create the Content (RichTextLabel for styling) ---
	#var label = RichTextLabel.new()
	#label.fit_content = true # Important for automatic sizing
	#margin.add_child(label)
	#
	## --- 4. Set Content (Using BBCode for formatting) ---
	#var content = "[center][b][color=#FFD700]" + tooltip_title + "[/color][/b][/center]\n"
	#content += "[i]" + tooltip_description + "[/i]"
	#label.text = content
	#
	## Return the root Control node. Godot handles adding it to the scene tree,
	## positioning it correctly, and destroying it when the mouse moves away.
	#return panel
