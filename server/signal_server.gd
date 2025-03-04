extends Node

var udp = PacketPeerUDP.new()
var SERVER_PORT = 9000
var peers = {}
var peer_timeout = 30.0

func _ready():
	var err = udp.bind(SERVER_PORT, "0.0.0.0")
	if err != OK:
		print("Failed to start UDP signaling server on port ", SERVER_PORT, ": ", err)
	else:
		print("UDP signaling server started on port ", SERVER_PORT)

func _process(_delta: float) -> void:
	# Remove peers that have timed out
	for peer_id in peers.keys():
		var peer = peers[peer_id]
		if Time.get_unix_time_from_system() - peer.last_seen > peer_timeout:
			print("Peer ", peer_id, " timed out")
			peers.erase(peer_id)

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()

		var message = JSON.parse_string(packet.get_string_from_utf8())

		var addr = udp.get_packet_ip()
		var port = udp.get_packet_port()

		print("message: ", message, ", ", addr, ":", port)

		# Get all peer keys that are not this one
		var peer_ids = []
		for peer_id in peers.keys():
			if message.source_id != peer_id:
				peer_ids.append(peer_id)

		if message.type == "register":
			peers[message.source_id] = {
				"addr": addr,
				"port": port,
				"last_seen": Time.get_unix_time_from_system()
			}
			for peer_id in peer_ids:
				_send_peer_connected(message.source_id, peer_id)
				_send_peer_connected(peer_id, message.source_id)

		else:
			var peer = peers[message.target_id]
			print("Sending ", message.type, " to ", message.target_id, ", ", peer.addr, ":", peer.port)
			udp.set_dest_address(peer.addr, peer.port)
			udp.put_packet(JSON.stringify(message).to_utf8_buffer())

			# for peer_id in peer_ids:
			# 	var peer = peers[peer_id]
			# 	print("Sending ", message.type, " to ", peer_id, ", ", peer.addr, ":", peer.port)
			# 	udp.set_dest_address(peer.addr, peer.port)
			# 	udp.put_packet(JSON.stringify(message).to_utf8_buffer())

func _send_peer_connected(connected_id, to_id):
	print("Sending peer_connected ", connected_id, " to ", to_id)
	var peer = peers[to_id]
	udp.set_dest_address(peer.addr, peer.port)
	udp.put_packet(JSON.stringify({"source_id": connected_id, "type":"peer_connected"}).to_utf8_buffer())
