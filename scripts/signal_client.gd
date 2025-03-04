extends Node

class_name SignalClient

signal peer_connected(pid: int)
signal offer_received(pid: int, sdp: String)
signal answer_received(pid: int, sdp: String)
signal candidate_received(pid: int, mid: String, index: int, sdp: String)

const SERVER_IP = '127.0.0.1'
const SERVER_PORT = 9000

var udp = PacketPeerUDP.new()


func _process(_delta: float) -> void:
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = JSON.parse_string(packet.get_string_from_utf8())

		match message.type:
			"peer_connected":
				peer_connected.emit(message.source_id)
			"offer":
				offer_received.emit(message.source_id, message.sdp)
			"answer":
				answer_received.emit(message.source_id, message.sdp)
			"candidate":
				candidate_received.emit(message.source_id, message.mid, message.index, message.sdp)



func send_data(data: Dictionary):
	udp.set_dest_address(SERVER_IP, SERVER_PORT)
	udp.put_packet(JSON.stringify(data).to_utf8_buffer())