# Base class for input sources. Should be converted to an
# abstract class when Godot supports it.
class_name InputSource extends Node

func get_input() -> InputData:
	return null