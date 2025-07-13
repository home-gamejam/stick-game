class_name DebugOverlay extends RichTextLabel

# static Signal to notify when the text is updated
static var text_updated: Signal = (func():
	(DebugOverlay as Object).add_user_signal("text_updated", [
		{"name": "text", "type": TYPE_STRING}
	])
	return Signal(DebugOverlay, "text_updated")
	).call()

static func show_text(text_: String) -> void:
	DebugOverlay.text_updated.emit(text_)


func _ready() -> void:
	text_updated.connect(func(text_: String) -> void:
		self.text = text_)
