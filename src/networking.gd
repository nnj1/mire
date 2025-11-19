extends Node

# useful function for searching through a list of json documents 
# and retrieving the value for a key for a document that has a certain id
func searchDocsInList(list, uniquekey: String, uniqueid: String, key: String):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			if key in doc.keys():
				return doc[key]
			else:
				return null
	return null

# useful function for searching through a list of json documents
# and retrieving doc where there is a certain value for a certain key
func returnDocInList(list, uniquekey, uniqueid):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			return doc
	return null
	
# useful function for making an array unique
func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

#useful function for picking a random value from a list
func choose_random_from_list(rand_list):
	return rand_list[randi() % rand_list.size()]


#useful function for returning a list of files in a directory
func dir_contents(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				pass
			else:
				if file_name.find('.import') == -1:
					#print("Found file: " + file_name)
					files.append(file_name)
			file_name = dir.get_next()
	else:
		#print("An error occurred when trying to access the path.")
		pass
	return files
	
var peer = ENetMultiplayerPeer
var PORT = 9999
var ADDRESS = "localhost"
var ROLE = null

var connected_peer_ids = []
var local_player_character
var UniquePeerID : String

func start_server() -> void:
	Networking.ROLE = 'Server'
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
func start_client():
	Networking.ROLE = 'Client'
	peer = ENetMultiplayerPeer.new()
	
	# TODO: get this working
	var error = peer.create_client(ADDRESS, PORT)
	if error != OK:
		# Handle immediate creation errors (e.g., ERR_ALREADY_IN_USE)
		print("Error setting up client peer: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	
	return true
