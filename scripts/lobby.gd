extends Node

const SERVER_PORT = 8888
const HOST = "brianmac.local"
const MAX_CLIENTS = 8
const CERT_NAME = HOST

enum TransportType {
	Enet,
	Websocket
}

const transportType = TransportType.Websocket

signal player_added()


func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		_on_server_start()

	%Remote.text = HOST
	%Host.connect("pressed", _on_server_start)
	%Join.connect("pressed", _on_client_connect)


func _on_server_start():
	var peer

	if transportType == TransportType.Enet:
		print("Starting server on port:", SERVER_PORT, "...")
		print("IPs:", IP.get_local_addresses())

		peer = ENetMultiplayerPeer.new()
		peer.create_server(SERVER_PORT, MAX_CLIENTS)

	elif transportType == TransportType.Websocket:
		print("Starting server on port:", SERVER_PORT, "...")
		print("IPs:", IP.get_local_addresses())

		peer = WebSocketMultiplayerPeer.new()
		var server_certs = load("res://certs/" + CERT_NAME + ".crt")
		var server_key = load("res://certs/" + CERT_NAME + ".key")
		var server_tls_options = TLSOptions.server(server_key, server_certs)
		peer.create_server(SERVER_PORT, "*", server_tls_options)

	else:
		print("Unknown transport type")
		return

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

	var peer

	if transportType == TransportType.Enet:
		print("Client connecting to ", remote, ":", SERVER_PORT, "...")
		peer = ENetMultiplayerPeer.new()
		peer.create_client(remote, SERVER_PORT)

	elif transportType == TransportType.Websocket:
		print("Client connecting to ", remote, ":", SERVER_PORT, "...")
		peer = WebSocketMultiplayerPeer.new()
		var client_trusted_cas = load("res://certs/rootCA.crt")
		var client_tls_options = TLSOptions.client(client_trusted_cas)
		peer.create_client("wss://" + remote + ":" + str(SERVER_PORT), client_tls_options)


	else:
		print("Unknown transport type")
		return

	multiplayer.set_multiplayer_peer(peer)
