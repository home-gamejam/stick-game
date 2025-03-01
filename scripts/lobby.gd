extends Node

const SERVER_PORT = 8888
# const HOST = "192.168.68.64"
# const HOST = "127.0.0.1"
# const HOST = "local.emeraldwalk.com"
const HOST = "pi44g.local"
const MAX_CLIENTS = 8
const CERT_NAME = HOST

const IS_WEBSOCKETS = true

signal player_added()


func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		_on_server_start()

	%Remote.text = HOST
	%Host.connect("pressed", _on_server_start)
	%Join.connect("pressed", _on_client_connect)


func _on_server_start():
	print("Starting server on port:", SERVER_PORT, "...")
	print("IPs:", IP.get_local_addresses())

	var peer

	if IS_WEBSOCKETS:
		peer = WebSocketMultiplayerPeer.new()
		var server_certs = load("res://certs/" + CERT_NAME + ".crt")
		var server_key = load("res://certs/" + CERT_NAME + ".key")
		var server_tls_options = TLSOptions.server(server_key, server_certs)
		peer.create_server(SERVER_PORT, "*", server_tls_options)
	else:
		peer = ENetMultiplayerPeer.new()
		peer.create_server(SERVER_PORT, MAX_CLIENTS)

	multiplayer.set_multiplayer_peer(peer)

	multiplayer.peer_connected.connect(
		func _on_peer_connected(pid: int):
			print("_on_peer_connected", pid)
			# Client
			player_added.emit(pid)
	)

	# Add server play if not dedicated server
	if !OS.has_feature("dedicated_server"):
		player_added.emit(multiplayer.get_unique_id())


func _on_client_connect():
	var remote = %Remote.text
	print("Client connecting to ", remote, ":", SERVER_PORT, "...")

	var peer

	if IS_WEBSOCKETS:
		peer = WebSocketMultiplayerPeer.new()
		var client_trusted_cas = load("res://certs/rootCA.crt")
		var client_tls_options = TLSOptions.client(client_trusted_cas)
		peer.create_client("wss://" + remote + ":" + str(SERVER_PORT), client_tls_options)
	else:
		peer = ENetMultiplayerPeer.new()
		peer.create_client(remote, SERVER_PORT)

	multiplayer.set_multiplayer_peer(peer)
