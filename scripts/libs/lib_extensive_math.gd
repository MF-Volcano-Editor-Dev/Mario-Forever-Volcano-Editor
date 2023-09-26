class_name ExtensiveMath

## Static library class to provide useful sublibraries and subclasses about mathematics
##
##


## Static sublibrary class to provide extra methods for [Vector2D]'s operations
##
##
class Vector2D:
	static func projection_limit(vector: Vector2, onto: Vector2, length: float) -> Vector2:
		# Get projection on the vector "onto"
		var v: Vector2 = vector.project(onto)
		# Get delta of overlengthened section
		var d: Vector2 = v - v.limit_length(length)

		# If the "vector" doesn't overlengthen over "length", then the function returns "vector2"; otherwise, the result
		# will be the "vector" minus the delta
		return vector - d if v.length_squared() > length ** 2 else vector


## Class that provides an ellipse with methods to use
##
##
class Ellipse:
	var origin: Vector2
	var amplitude: Vector2:
		set(value): amplitude = value.abs()
	var rotation: float


	func _init(p_origin: Vector2 = Vector2.ZERO, p_amplitude: Vector2 = Vector2(8, 8), p_rotation: float = 0) -> void:
		origin = p_origin
		amplitude = p_amplitude
		rotation = p_rotation
	

	func get_point_on_ellipse(phase: float) -> Vector2:
		return origin + Vector2(amplitude.x * cos(phase), amplitude.y * sin(phase)).rotated(rotation)
	
	
	func get_focal_length() -> float:
		var ret: float = 0

		if amplitude.x > amplitude.y:
			ret = 2 * sqrt(amplitude.x ** 2 - amplitude.y ** 2)
		elif amplitude.y > amplitude.x:
			ret = 2 * sqrt(amplitude.y ** 2 - amplitude.x ** 2)
		
		return ret


	func get_eccentricity() -> float:
		var long_axis: float = \
			amplitude.x if amplitude.x > amplitude.y \
			else amplitude.y if amplitude.x != amplitude.y \
			else 0.0

		return get_focal_length() / 2 / long_axis
	

	func get_size() -> float:
		return PI * amplitude.x * amplitude.y
	

	func get_circle(sampling_times: int = 256) -> float:
		var ret: float = 0
		
		var phase: float = 0
		var point: Vector2 = Vector2.ZERO
		for i in sampling_times:
			phase += TAU * float(i) / float(sampling_times)

			var _point: Vector2 = get_point_on_ellipse(phase)
			ret += _point.distance_to(point)
		
		return ret


	