class_name Utils

# Frame rate independent linear interpolation based on
# https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
static func damp(source: Variant, target: Variant, smoothing: float, dt: float):
	return lerp(source, target, 1 - pow(smoothing, dt))
