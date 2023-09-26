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
	const _MIN_SAMPLES: int = 256

	## Origin of the ellipse
	var origin: Vector2
	## Amplitude of the ellipse
	var amplitude: Vector2:
		set(value): amplitude = value.abs()
	## Rotation of the ellipse
	var rotation: float


	func _init(p_origin: Vector2 = Vector2.ZERO, p_amplitude: Vector2 = Vector2(8, 8), p_rotation: float = 0) -> void:
		origin = p_origin
		amplitude = p_amplitude
		rotation = p_rotation
	
	## Returns the point's position on the ellipse with given [param phase]
	func get_point_on_ellipse(phase: float) -> Vector2:
		return origin + Vector2(amplitude.x * cos(phase), amplitude.y * sin(phase)).rotated(rotation)
	
	
	## Returns the focal length of the ellipse
	func get_focal_length() -> float:
		var ret: float = 0

		if amplitude.x > amplitude.y:
			ret = 2 * sqrt(amplitude.x ** 2 - amplitude.y ** 2)
		elif amplitude.y > amplitude.x:
			ret = 2 * sqrt(amplitude.y ** 2 - amplitude.x ** 2)
		
		return ret


	## Returns the eccentricity of the ellipse
	func get_eccentricity() -> float:
		var long_axis: float = \
			amplitude.x if amplitude.x > amplitude.y \
			else amplitude.y if amplitude.x != amplitude.y \
			else 0.0

		return get_focal_length() / 2 / long_axis
	

	## Returns the area of the ellipse
	func get_area() -> float:
		return PI * amplitude.x * amplitude.y
	

	## Returns length of the ellipse[b]
	## [br]
	## [b]Note:[/b] Due to the speciality of ellipse, you need to input the samples to provide calculation accuracy.
	## With minimum of 256, and if lower, an error will be thrown
	func get_length(samples: int = _MIN_SAMPLES) -> float:
		var ret: float = 0
		
		# If the ellipse is a circle, then C = 2πr
		if amplitude.x == amplitude.y:
			return 2 * PI * amplitude.x
		# If not a circle, then use iteration calculation
		else:
			var phase: float = 0
			var point: Vector2 = Vector2.ZERO
			
			if samples < _MIN_SAMPLES:
				printerr("Sample time is lower than %s and the result will be inaccurate!" % [_MIN_SAMPLES])

			for i in samples:
				phase += TAU * float(i) / float(samples)

				var _point: Vector2 = get_point_on_ellipse(phase)
				ret += _point.distance_to(point)
		
		return ret


	