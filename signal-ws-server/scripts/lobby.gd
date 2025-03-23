class_name SignalWsLobby

extends RefCounted

var lobby_id: int
var host_id: int
var peers: Dictionary[int, SignalWsPeer] = {}
var sealed_at: int

func _init(id: int, host_id_: int):
	lobby_id = id
	host_id = host_id_

# Call with peer wanting to join the lobby
func join(new_peer: SignalWsPeer) -> bool:
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

		# Tell the new peer about the existing peer and vice versa. Note that
		# this only happens as non-host peers join since the peer gets added
		# after this loop, but it results in every peer knowing about every other
		# peer (including the host).
		new_peer.send_msg(SignalWsMsg.new(peer.peer_id, SignalWsMsg.Type.PEER_CONNECT))
		peer.send_msg(SignalWsMsg.new(new_peer.peer_id, SignalWsMsg.Type.PEER_CONNECT))

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
			peer2.send_msg(SignalWsMsg.new(peer_id, SignalWsMsg.Type.PEER_DISCONNECT))

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

		peer.send_msg(SignalWsMsg.new(lobby_id, SignalWsMsg.Type.SEAL))

	return true
