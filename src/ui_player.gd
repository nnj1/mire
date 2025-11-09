extends AudioStreamPlayer

func _ready():
	# Connect signals for all existing buttons in the tree when the AutoLoad is ready
	_connect_all_existing_buttons(get_tree().root)
	
	# Connect to the SceneTree signal for nodes added later
	get_tree().node_added.connect(_on_SceneTree_node_added)

# Recursively check the entire tree for existing buttons
func _connect_all_existing_buttons(root: Node):
	for child in root.get_children():
		_connect_button_signals(child)
		_connect_all_existing_buttons(child) # Recurse into children
	
func play_button_hover():
	self.stream = load('res://assets/Be Not Afraid UI/--Unholy/Be Not Afraid UI/BNA_UI11.wav')
	self.play()
	
func play_button_click():
	if not playing:
		self.stream = load('res://assets/Be Not Afraid UI/--Unholy/Be Not Afraid UI/BNA_UI12.wav')
		self.play()
	
# Called when a node is added to the SceneTree
func _on_SceneTree_node_added(node: Node):
	_connect_button_signals(node)

# Function to connect the signal for a given node
func _connect_button_signals(node: Node):
	# BaseButton is the class that Button inherits from
	if node is BaseButton:
		# Connect the mouse_entered signal to our sound playing function
		node.mouse_entered.connect(play_button_hover)
		# Connect the mouse_entered signal to our sound playing function
		node.pressed.connect(play_button_click)
