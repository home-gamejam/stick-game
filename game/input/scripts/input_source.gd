extends Node

# Base class for input sources. Should be converted to an
# abstract class when Godot supports it.
class_name InputSource

func get_input() -> InputData:
	return null