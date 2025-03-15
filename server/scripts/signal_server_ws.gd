extends Node

var signal_server_ws: SignalServerWs

func _ready() -> void:
	signal_server_ws = SignalServerWs.new()

	# Testing
	var msg = Msg.parse('1|1')
	print('msg:', msg.data)

func _process(_delta: float) -> void:
	signal_server_ws.poll()


# Generate unique IDs for peers and lobbies
class UniqueID:
	# This conveniently allow producing an easy to share 6-digit code
	# that can be used when inviting friends to join a lobby
	const MAX_RAND_ID = 999999

	static func gen() -> int:
		return randi() % MAX_RAND_ID + 1


# Message types for WebSocket messages
enum MsgType {
	HOST,
	JOIN
}


# Messages passed over WebSocket connections
class Msg:
	# Primary message payload. This could be a peer id or a
	# lobby id depending on the message type
	var id: int

	# Message type
	var type: MsgType

	# Additional payload that some messages carry
	var data: String

	# Construct a new Msg objects (gets called by Msg.new())
	func _init(id_: int, type_: MsgType, data_: String) -> void:
		id = id_
		type = type_
		data = data_

	# Parse a message string in the form of "type|pid|data" to a Msg object
	static func parse(msg_str: String) -> Msg:
		var tokens: PackedStringArray = msg_str.split("|")

		var type_ := tokens[0].to_int()
		var id_ := tokens[1].to_int()
		var data_ := tokens[2] if tokens.size() > 2 else ""

		return Msg.new(id_, type_, data_)

	# Convert this message to a string in the form of "type|pid|data"
	func stringify() -> String:
		return str(type) + "|" + str(id) + "|" + data


# WebSocket based signaling server
class SignalServerWs:
	var tcp_server := TCPServer.new()
	var peers_pending_lobby: Dictionary[int, Peer] = {}
	var lobbies: Dictionary[int, Lobby] = {}

	# Create a lobby for hosting a new game hosted by the given peer
	func host_game(peer: Peer) -> void:
		if peer.lobby_id >= 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return

		var lobby_id := UniqueID.gen()
		# In the unlikely event that the random ID is already taken, just get
		# another one
		while (lobbies.has(lobby_id)):
			lobby_id = UniqueID.gen()

		peer.lobby_id = lobby_id

		lobbies[lobby_id] = Lobby.new(lobby_id, peer.peer_id)

	# Join a lobby with the given ID
	func join_game(peer: Peer, lobby_id: int) -> void:
		if peer.lobby_id >= 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return

		if not lobbies.has(lobby_id):
			print("Lobby ", lobby_id, " does not exist.")
			return

		peer.lobby_id = lobby_id
		lobbies[lobby_id].peers[peer.id] = peer

	func poll():
		if not tcp_server.is_listening():
			return

		# Whenever a new client connects to the server,
		# represent it with a new Peer object
		if tcp_server.is_connection_available():
			var peer_id := UniqueID.gen()
			# In the unlikely event that the random ID is already taken, just get
			# another one
			while (peers_pending_lobby.has(peer_id)):
				peer_id = UniqueID.gen()

			var stream = tcp_server.take_connection()
			var peer = Peer.new(peer_id, stream)
			peers_pending_lobby[peer_id] = peer

		for peer in peers_pending_lobby.values() as Array[Peer]:
			# If peer doesn't join a lobby before TIMEOUT_MS expires, close the
			# connection. This assumes that clients create connections and join
			# lobbies as part of the same action.
			if peer.lobby_id < 0 and Time.get_ticks_msec() - peer.created_at > Peer.TIMEOUT_MS:
				peer.ws.close()

			peer.ws.poll()

			while peer.is_open() and peer.has_msg():
				var msg = Msg.parse(peer.get_msg())

				match msg.type:
					MsgType.HOST:
						host_game(peer)

					MsgType.JOIN:
						join_game(peer, msg.id)


# Lobby that clients can join
class Lobby extends RefCounted:
	var lobby_id := -1
	var host_id := -1
	var peers: Dictionary[int, Peer] = {}

	func _init(id: int, host_id_: int):
		lobby_id = id
		host_id = host_id_


# Represent client peer connecting to server
class Peer extends RefCounted:
	const TIMEOUT_MS = 1000

	var peer_id := -1
	var lobby_id := -1
	var created_at := Time.get_ticks_msec()
	var ws := WebSocketPeer.new()

	func _init(id: int, stream: StreamPeerTCP):
		peer_id = id
		ws.accept_stream(stream)

	func is_open() -> bool:
		return ws.get_ready_state() == WebSocketPeer.STATE_OPEN

	func has_msg() -> bool:
		return ws.get_available_packet_count() > 0

	func get_msg() -> String:
		return ws.get_packet().get_string_from_utf8()

	func send_msg(msg: Msg) -> void:
		ws.send_text(msg.stringify())