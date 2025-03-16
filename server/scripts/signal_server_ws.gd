extends Node

var signal_server_ws: SignalServerWs

func _ready() -> void:
	signal_server_ws = SignalServerWs.new()

	# Testing
	var msg = Msg.parse('x|x')
	print(MsgType.HOST, ", ", MsgType.JOIN)
	print('msg.type:', msg.type)
	print('msg.id:', msg.id)
	print('msg.data:', msg.data)

func _process(_delta: float) -> void:
	signal_server_ws.poll()


# Generate unique IDs for peers and lobbies
class ID:
	# This conveniently allow producing an easy to share 6-digit code
	# that can be used when inviting friends to join a lobby
	const MAX_RAND_ID = 999999

	static func gen(cache: Dictionary[int, Variant]) -> int:
		var id := randi() % MAX_RAND_ID + 1

		# In the unlikely event that the random ID is already taken, just
		# get another one. I don't really expect this will ever happen, just
		# being cautious.
		while cache.has(id):
			id = randi() % MAX_RAND_ID + 1

		return id


# Message types for WebSocket messages
enum MsgType {
	INVALID = 0,
	HOST,
	JOIN,
	PEER_CONNECT,
	PEER_DISCONNECT,
	SEAL
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
	func _init(id_: int, type_: MsgType, data_: String = "") -> void:
		id = id_
		type = type_
		data = data_

	# Parse a message string in the form of "type|pid|data" to a Msg object
	static func parse(msg_str: String) -> Msg:
		var tokens: PackedStringArray = msg_str.split("|")

		var type_ := tokens[0].to_int()
		var id_ := tokens[1].to_int()
		var data_ := tokens[2] if tokens.size() > 2 else ""

		if type_ == MsgType.INVALID or id_ == 0:
			print("Could not parse message: ", msg_str)
			return null

		return Msg.new(id_, type_, data_)

	# Convert this message to a string in the form of "type|pid|data"
	func stringify() -> String:
		return str(type) + "|" + str(id) + "|" + data


# Lobby that clients can join
class Lobby extends RefCounted:
	var lobby_id: int
	var host_id: int
	var peers: Dictionary[int, Peer] = {}
	var sealed_at: int

	func _init(id: int, host_id_: int):
		lobby_id = id
		host_id = host_id_

	# Call with peer wanting to join the lobby
	func join(new_peer: Peer) -> bool:
		if sealed_at > 0:
			print("Lobby ", lobby_id, " is sealed.")
			return false

		if peers.has(new_peer.peer_id):
			print("Peer ", new_peer.peer_id, " is already in the lobby.")
			return false

		if not new_peer.is_open():
			return false

		for peer in peers.values():
			if not peer.is_open():
				continue

			# Tell the new peer about the existing peer and vice versa
			new_peer.send_msg(Msg.new(peer.peer_id, MsgType.PEER_CONNECT))
			peer.send_msg(Msg.new(new_peer.peer_id, MsgType.PEER_CONNECT))

		peers[new_peer.peer_id] = new_peer

		return true

	# Call with peer wanting to leave the lobby. Returns true if lobby was
	# closed.
	func leave(peer_id: int) -> bool:
		if not peers.has(peer_id):
			print("Peer ", peer_id, " is not in the lobby.")
			return false

		peers.erase(peer_id)

		var is_host := peer_id == host_id

		# If the lobby is sealed, there shouldn't be any valid peers left, so
		# just return whether the lobby is considered closed or not.
		if sealed_at > 0:
			return is_host

		for peer2 in peers.values():
			if not peer2.is_open():
				continue

			# If host is closing, close all peer connections
			if is_host:
				peer2.ws.close()
			else:
				peer2.send_msg(Msg.new(peer_id, MsgType.PEER_DISCONNECT))

		return is_host

	# Seal the room so that no one else can join
	func seal() -> bool:
		# Only allow sealing 1x
		if sealed_at > 0:
			return false

		# Seal after a bit of cushion time
		sealed_at = Time.get_ticks_msec()

		for peer in peers.values():
			if not peer.is_open():
				continue

			peer.send_msg(Msg.new(lobby_id, MsgType.SEAL))

		return true

# Represent client peer connecting to server
class Peer extends RefCounted:
	const TIMEOUT_MS = 1_000

	var peer_id: int
	var lobby_id: int
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


# WebSocket based signaling server
class SignalServerWs:
	const LOBBY_SEAL_GRACE_PERIOD_MS = 10_000

	var tcp_server := TCPServer.new()
	var peers_all: Dictionary[int, Peer] = {}
	var lobbies: Dictionary[int, Lobby] = {}

	# Create a lobby for hosting a new game hosted by the given peer
	func host_game(peer: Peer) -> bool:
		if peer.lobby_id > 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return false

		var lobby_id := ID.gen(lobbies)

		peer.lobby_id = lobby_id

		var lobby := Lobby.new(lobby_id, peer.peer_id)
		lobby.join(peer)

		lobbies[lobby_id] = lobby

		return true

	# Join a lobby with the given ID
	func join_game(peer: Peer, lobby_id: int) -> bool:
		if peer.lobby_id > 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return false

		if not lobbies.has(lobby_id):
			print("Lobby ", lobby_id, " does not exist.")
			return false

		lobbies[lobby_id].join(peer)
		peer.lobby_id = lobby_id
		peer.send_msg(Msg.new(lobby_id, MsgType.JOIN))

		return true

	# Handle current peer message
	func handle_peer_msg(peer: Peer) -> bool:
		var msg = Msg.parse(peer.get_msg())
		if msg == null:
			return false

		match msg.type:
			MsgType.HOST:
				return host_game(peer)

			MsgType.JOIN:
				return join_game(peer, msg.id)

			MsgType.SEAL:
				var lobby = lobbies[peer.lobby_id]

				# Only the host can seal the lobby
				if lobby.host_id == peer.peer_id:
					return lobby.seal()

				return false

		return false

	func poll() -> void:
		if not tcp_server.is_listening():
			return

		# Whenever a new client connects to the server,
		# represent it with a new Peer object
		if tcp_server.is_connection_available():
			var peer_id := ID.gen(peers_all)
			var stream = tcp_server.take_connection()
			peers_all[peer_id] = Peer.new(peer_id, stream)

		var closed_peers: Array[Peer] = []

		for peer in peers_all.values() as Array[Peer]:
			# If peer doesn't join a lobby before TIMEOUT_MS expires, close the
			# connection. This assumes that clients create connections and join
			# lobbies as part of the same action, so the time between connection
			# and the join message should be short.
			if peer.lobby_id == 0 and Time.get_ticks_msec() - peer.created_at > Peer.TIMEOUT_MS:
				peer.ws.close()

			peer.ws.poll()

			while peer.is_open() and peer.has_msg():
				if not handle_peer_msg(peer):
					peer.ws.close()
					break

			if peer.ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
				closed_peers.append(peer)

				if lobbies.has(peer.lobby_id) and lobbies[peer.lobby_id].leave(peer.peer_id):
					# If the host left the lobby, remove the lobby
					lobbies.erase(peer.lobby_id)

			# Clean up peers for any lobbies that have been sealed after the
			# grace period has past
			for lobby in lobbies.values():
				# Not sealed
				if lobby.sealed_at == 0:
					continue

				if Time.get_ticks_msec() - lobby.sealed_at > LOBBY_SEAL_GRACE_PERIOD_MS:
					for lobby_peer in lobby.peers.values():
						lobby_peer.ws.close()
						closed_peers.append(lobby_peer)

		# Remove closed peers from the list
		for peer in closed_peers:
			peers_all.erase(peer.peer_id)