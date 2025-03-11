extends Node


signal player_added()

var peer_id = randi() % 100
var peer = WebRTCMultiplayerPeer.new()
var signal_client = SignalClient.new()
var mesh_initialized = false


func _ready():
	%Host.connect("pressed", _on_server_start)
	%Join.connect("pressed", _on_client_connect)

	signal_client.peer_connected.connect(
		func(pid: int):
			_log_message("peer_connected", pid)

			if not mesh_initialized:
				_log_message("Initializing mesh")
				peer.create_mesh(peer_id)
				multiplayer.set_multiplayer_peer(peer)
				mesh_initialized = true
				player_added.emit(peer_id)

			_on_peer_connected(pid)
	)

	signal_client.offer_received.connect(
		func _on_offer_received(pid: int, sdp: String):
			_log_message("offer_received", [pid, sdp])

			if peer.has_peer(pid):
				_log_message("Setting remote description", ["offer", pid])
				var peer_cn = peer.get_peer(pid).connection
				peer_cn.set_remote_description("offer", sdp)
	)

	signal_client.answer_received.connect(
		func _on_answer_received(pid: int, sdp: String):
			_log_message("answer_received", [pid, sdp])

			if peer.has_peer(pid):
				_log_message("Setting remote description", ["answer", pid])
				var peer_cn = peer.get_peer(pid).connection
				peer_cn.set_remote_description("answer", sdp)
	)

	signal_client.candidate_received.connect(
		func _on_candidate_received(pid: int, mid: String, index: int, sdp: String):
			_log_message("candidate_received", [pid, mid, index, sdp])

			if peer.has_peer(pid):
				_log_message("Adding ice candidate", [pid, mid, index, sdp])
				var peer_cn = peer.get_peer(pid).connection
				peer_cn.add_ice_candidate(mid, index, sdp)
	)


func _process(delta):
	signal_client._process(delta)


# This will need to be triggered by the server when a new peer connects. Demo
# project uses websockets to do this.
func _on_peer_connected(id: int):
	_log_message("_on_peer_connected", id)

	var peer_cn = WebRTCPeerConnection.new()
	peer_cn.initialize()
	# peer_cn.initialize({
	# 	"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	# })

	peer_cn.session_description_created.connect(
		func _session_description_created(type: String, sdp: String):
			if not peer.has_peer(id):
				return

			_log_message("session_description_created", [id, type, sdp])
			peer_cn.set_local_description(type,  sdp)

			signal_client.send_data({
				"source_id": peer_id,
				"target_id": id,
				"type": type,
				"sdp": sdp
			})
	)

	peer_cn.ice_candidate_created.connect(
		func _on_ice_candidate_created(mid: String, index: int, sdp: String):
			_log_message("ice_candidate_created", [id, mid, index,  sdp])

			signal_client.send_data({
				"source_id": peer_id,
				"target_id": id,
				"type": "candidate",
				"mid": mid,
				"index": index,
				"sdp": sdp
			})
	)

	_log_message("Adding peer", id)
	peer.add_peer(peer_cn, id)

	player_added.emit(id)

	if id < peer.get_unique_id():
		_log_message("creating offer", id)
		peer_cn.create_offer()
	else:
		_log_message("not creating offer", id)


func _log_message(label: String, args = []):
	if typeof(args) != TYPE_ARRAY:
		args = [args]

	var message = ", ".join(args).substr(0, 50).replace('\n', ' ')
	print(peer_id, ": [", label, "] ", message)

func _on_server_start():
	_log_message("server_start")


	# Testing, Need to figure out how this should work
	# _on_connected(1)
	# _on_peer_connected(2)


func _on_client_connect():
	_log_message("client_connect")

	signal_client.server_ip = %IP.text
	print("Setting signal server to: ", signal_client.server_ip)

	signal_client.send_data({"source_id": peer_id, "type": "register"})
	# _on_connected(2)
	# _on_peer_connected(1)
