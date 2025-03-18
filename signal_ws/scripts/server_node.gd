extends Node

var signal_ws_server: SignalWsServer

func _ready() -> void:
	signal_ws_server = SignalWsServer.new()

	# Testing
	var raw = 'x|x'
	var msg = SignalWsMsg.parse(raw)
	if msg != null:
		print('msg.type:', msg.type)
		print('msg.id:', msg.id)
		print('msg.data:', msg.data)

func _process(_delta: float) -> void:
	signal_ws_server.poll()


# WebSocket based signaling server
class SignalWsServer:
	# This conveniently allow producing an easy to share 6-digit code
	# that can be used when inviting friends to join a lobby
	const MAX_RAND_ID = 999_999
	const LOBBY_SEAL_GRACE_PERIOD_MS = 10_000

	var tcp_server := TCPServer.new()
	var peers_all: Dictionary[int, SignalWsPeer] = {}
	var lobbies: Dictionary[int, SignalWsLobby] = {}

	# Generate a random ID for a peer or lobby
	func _gen_id() -> int:
		var id := randi() % MAX_RAND_ID + 1

		# In the unlikely event that the random ID is already taken, just
		# get another one. I don't really expect this will ever happen, just
		# being overly cautious.
		while peers_all.has(id) or lobbies.has(id):
			id = randi() % MAX_RAND_ID + 1

		return id

	# Create a lobby for hosting a new game hosted by the given peer
	func host_game(peer: SignalWsPeer) -> bool:
		if peer.lobby_id > 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return false

		peer.lobby_id = _gen_id()

		var lobby := SignalWsLobby.new(peer.lobby_id, peer.peer_id)
		lobbies[peer.lobby_id] = lobby

		lobby.join(peer)

		# Pass newly created lobby id back to host client peer
		peer.send_msg(SignalWsMsg.new(peer.lobby_id, SignalWsMsg.Type.HOST))

		return true

	# Join a lobby with the given ID
	func join_game(peer: SignalWsPeer, lobby_id: int) -> bool:
		if peer.lobby_id > 0:
			print("Peer ", peer.peer_id, " is already in a lobby.")
			return false

		if not lobbies.has(lobby_id):
			print("Lobby ", lobby_id, " does not exist.")
			return false

		lobbies[lobby_id].join(peer)
		peer.lobby_id = lobby_id

		# Pass joined lobby_id back to client peer
		peer.send_msg(SignalWsMsg.new(lobby_id, SignalWsMsg.Type.JOIN))

		return true

	# Handle current peer message
	func handle_peer_msg(peer: SignalWsPeer) -> bool:
		var msg = SignalWsMsg.parse(peer.get_msg())
		if msg == null:
			return false

		match msg.type:
			SignalWsMsg.Type.HOST:
				return host_game(peer)

			SignalWsMsg.Type.JOIN:
				return join_game(peer, msg.id)

			SignalWsMsg.Type.SEAL:
				var lobby = lobbies[peer.lobby_id]

				# Only the host can seal the lobby
				if lobby.host_id == peer.peer_id:
					return lobby.seal()

				return false

			[SignalWsMsg.Type.OFFER, SignalWsMsg.Type.ANSWER, SignalWsMsg.Type.CANDIDATE]:
				# These message types have id as the target peer id but result
				# in outgoing messages with id set to source id
				var source_id = peer.peer_id
				var target_id = msg.id

				peers_all[target_id].send_msg(
					SignalWsMsg.new(source_id, msg.type, msg.data)
				)

				return true
			_:
				return false

	func poll() -> void:
		if not tcp_server.is_listening():
			return

		# Whenever a new client connects to the server,
		# represent it with a new Peer object
		if tcp_server.is_connection_available():
			var peer_id := _gen_id()
			var stream = tcp_server.take_connection()
			var peer = SignalWsPeer.new(peer_id).as_server(stream)
			peers_all[peer_id] = peer

			# Tell client peer what its ID is
			peer.send_msg(SignalWsMsg.new(peer_id, SignalWsMsg.Type.CONNECTED))

		var closed_peers: Array[SignalWsPeer] = []

		for peer in peers_all.values() as Array[SignalWsPeer]:
			# If peer doesn't join a lobby before TIMEOUT_MS expires, close the
			# connection. This assumes that clients create connections and join
			# lobbies as part of the same action, so the time between connection
			# and the join message should be short.
			if peer.lobby_id == 0 and Time.get_ticks_msec() - peer.created_at > SignalWsPeer.TIMEOUT_MS:
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
