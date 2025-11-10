@tool
extends SubViewport

var frame_counter = 0

@export_tool_button("Play Animation")
var play_animation = func():
	frame_counter = 0
	var animation_player = get_node('model/AnimationPlayer')
	animation_player.play('Armature|Unreal Take|baselayer')
	
func _ready() -> void:
	#var animation_player = get_node('model/AnimationPlayer')
	#animation_player.play('Armature|Unreal Take|baselayer')
	var animation_player = get_node('AnimationPlayer')
	animation_player.play('dying')

func save_screenshot():
	print('method called')
	get_texture().get_image().save_png('res://assets/bear_dying/bear' + str(frame_counter) + '.png')
	frame_counter += 1
