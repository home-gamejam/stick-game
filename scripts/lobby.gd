extends Node

const PORT = 12345
const HOST = "127.0.0.1"
const MAX_CLIENTS = 8


signal player_added()


func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		_on_host_pressed()

	%Host.connect("pressed", _on_host_pressed)
	%Join.connect("pressed", _on_join_pressed)


func _on_host_pressed():
	print("_on_host_pressed")

	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	#var peer = WebSocketMultiplayerPeer.new() # ENetMultiplayerPeer.new()
	#peer.create_server(PORT)
	#multiplayer.set_multiplayer_peer(peer)

	multiplayer.peer_connected.connect(
		func _on_peer_connected(pid: int):
			print("_on_peer_connected", pid)
			# Client
			player_added.emit(pid)
	)

	# Server
	player_added.emit(multiplayer.get_unique_id())


func _on_join_pressed():
	print("_on_join_pressed")

	var peer = ENetMultiplayerPeer.new()
	var remote = %Remote.text
	peer.create_client(remote, PORT)
	#var peer = WebSocketMultiplayerPeer.new() # ENetMultiplayerPeer.new()
	#peer.create_client("ws://" + host + ":" + str(PORT))
	multiplayer.set_multiplayer_peer(peer)
