extends Node

const SERVER_PORT := 9000

var signal_ws_server: SignalWsServer

func _ready() -> void:
	signal_ws_server = SignalWsServer.new()
	signal_ws_server.listen(SERVER_PORT)

	# Testing
	# var raw = 'x|x'
	# var msg = SignalWsMsg.parse(raw)
	# if msg != null:
	# 	print('msg.type:', msg.type)
	# 	print('msg.id:', msg.id)
	# 	print('msg.data:', msg.data)

func _process(_delta: float) -> void:
	signal_ws_server.poll()
