extends Node

const DEFAULT_SERVER_IP = '127.0.0.1'
const DEFAULT_SERVER_PORT = 9000

signal player_added()

var peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var signal_ws_client: SignalWsClient = SignalWsClient.new()
var mesh_initialized := false

@onready var Host: Button = %Host
@onready var Join: Button = %Join
@onready var LobbyID: LineEdit = %LobbyID

func _ready():
	Host.pressed.connect(_on_host_pressed)
	Join.pressed.connect(_on_join_pressed)

	signal_ws_client.connected.connect(_on_connected)
	signal_ws_client.lobby_hosted.connect(_on_lobby_hosted)
	signal_ws_client.lobby_joined.connect(_on_lobby_joined)
	signal_ws_client.peer_connected.connect(_on_peer_connected)

	signal_ws_client.answer_received.connect(_on_remote_description_received.bind("answer"))
	signal_ws_client.offer_received.connect(_on_remote_description_received.bind("offer"))
	signal_ws_client.candidate_received.connect(_on_candidate_received)

func _get_server_url() -> String:
	return "ws://" + DEFAULT_SERVER_IP + ":" + str(DEFAULT_SERVER_PORT)

func _on_host_pressed():
	signal_ws_client.connect_to_server(_get_server_url())

func _on_join_pressed():
	var lobby_id = LobbyID.text.to_int()
	signal_ws_client.connect_to_server(_get_server_url(), lobby_id)

func _on_connected(pid: int):
	print("connected: ", pid)
	peer.create_mesh(pid)
	multiplayer.set_multiplayer_peer(peer)
	mesh_initialized = true

	player_added.emit(pid)

func _on_lobby_hosted(pid: int, lobby_id: int):
	print("lobby hosted: ", pid, ", ", lobby_id)

func _on_lobby_joined(pid: int, lobby_id: int):
	print("lobby joined: ", pid, ", ", lobby_id)

func _on_remote_description_received(pid: int, sdp: String, type: String):
	if peer.has_peer(pid):
		print("Setting remote description: ", type, ", ", pid)
		var peer_cn = peer.get_peer(pid).connection
		peer_cn.set_remote_description(type, sdp)

func _on_candidate_received(pid: int, mid: String, index: int, sdp: String):
	if peer.has_peer(pid):
		print("Adding ice candidate: ", pid, ", ", mid, ", ", index, ", ", sdp)
		var peer_cn = peer.get_peer(pid).connection
		peer_cn.add_ice_candidate(mid, index, sdp)

func _on_peer_connected(pid: int):
	print("peer connected: ", pid)

	var peer_cn: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer_cn.initialize()

	# Not needed for LAN only gaming. TBD whether I'll add WAN support.
	# peer_cn.initialize({
	# 	"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	# })

	peer_cn.session_description_created.connect(
		func _on_session_description_created(type: String, sdp: String):
			if not peer.has_peer(pid):
				return

			peer_cn.set_local_description(type, sdp)

			match type:
				"offer":
					signal_ws_client.send_offer(pid, sdp)
				"answer":
					signal_ws_client.send_answer(pid, sdp)
				_:
					print("Unknown session description type: ", type)
	)

	peer_cn.ice_candidate_created.connect(
		func _on_ice_candidate_created(mid: String, index: int, sdp: String):
			signal_ws_client.send_candidate(pid, mid, index, sdp)
	)
