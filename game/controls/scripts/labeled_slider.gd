@tool
extends HBoxContainer

signal value_changed(v: float)

@export var label = "Placeholder":
	get:
		return $Left/Label.text
	set(v):
		$Left/Label.text = v

@export var value = 0.:
	get:
		return $Slider.value
	set(v):
		$Slider.value = v
		$Left/Value.text = str(v)
		value_changed.emit(v)

func _on_slider_value_changed(v:float):
	value = v
