extends Node

const PORT = 8080
const HOST = "192.168.68.64"
# const HOST = "127.0.0.1"
const MAX_CLIENTS = 8


signal player_added()


func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		_on_server_start()

	%Remote.text = HOST
	%Host.connect("pressed", _on_server_start)
	%Join.connect("pressed", _on_client_connect)


func _on_server_start():
	print("Starting server on port:", PORT, "...")
	print("IPs:", IP.get_local_addresses())
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	#var peer = WebSocketMultiplayerPeer.new() # ENetMultiplayerPeer.new()
	#peer.create_server(PORT)

	multiplayer.set_multiplayer_peer(peer)

	multiplayer.peer_connected.connect(
		func _on_peer_connected(pid: int):
			print("_on_peer_connected", pid)
			# Client
			player_added.emit(pid)
	)

	# Server
	player_added.emit(multiplayer.get_unique_id())


func _on_client_connect():
	var remote = %Remote.text
	print("Client connecting to ", remote, ":", PORT, "...")

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(remote, PORT)

	#var peer = WebSocketMultiplayerPeer.new() # ENetMultiplayerPeer.new()
	#peer.create_client("ws://" + host + ":" + str(PORT))
	multiplayer.set_multiplayer_peer(peer)
