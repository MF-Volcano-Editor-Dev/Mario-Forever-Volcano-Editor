class_name ExtensiveMath

## Static library class to provide useful sublibraries and subclasses about mathematics
##
##


## Static library subclass to provide a branch of useful methods of calculus calculations
##
## [b]Notes:[/b][br]
## 1. It's NOT RECOMMENDED to use these methods in GDScript because of the bad performance
## when calculation is soaring, including over-high samples and over-amount calculation calls[br]
## If you do want to do so, please consider C# and translate these codes into it.[br]
## 2. All [param function]s are required to be and can ONLY be:
## [codeblock]
## func(x: float) -> float: return <expression with x>
## [/codeblock]
## Of course, you can replace x to any identifier you want, such as a, b, y, th, etc.
## @tutorial(Calling C# Methods in GDScript): https://docs.godotengine.org/en/4.0/tutorials/scripting/cross_language_scripting.html#calling-methods
class Calculus:
	## Default sampling amount of intergral calculation
	const INTERGRAL_SAMPLE: int = 2400
	## Default sampling amount of derivative calculation, often being the reciprocal of [const INTERGRAL_SAMPLE]
	const DERIVATIVE_SAMPLE: float = 1.0 / float(INTERGRAL_SAMPLE)
	
	## Returns derivative of a [param function] at [param x0]. 
	## The lower [param sample] is, the more accuracy the result will present with
	static func derivative_at(function: Callable, x0: float, sample: float = DERIVATIVE_SAMPLE) -> float:
		assert(sample >= INTERGRAL_SAMPLE, "Sample amount (%s) is higher than %s, derivative calculation failed!" % [sample, DERIVATIVE_SAMPLE])
		return (function.call(x0 + sample) - function.call(x0)) / sample
	
	## Returns integral of a [param function] between/from [param bottom] and/to [param top]. 
	## The higher [param sample] is, the more accurate the result will be
	static func integral_finite(function: Callable, bottom: float, top: float, sample: int = INTERGRAL_SAMPLE) -> float:
		assert(sample >= INTERGRAL_SAMPLE, "Sample amount (%s) is lower than %s, integral calculation failed!" % [sample, INTERGRAL_SAMPLE])
		
		var ret: float = 0
		
		var l: float = bottom
		var r: float = l
		for i in sample + 1:
			# Moves the right edge
			r = lerpf(bottom, top, float(i) / float(sample))
			# Calculates the average height
			var aveH: float = function.call((l + r) / 2)
			# Gets the "size" of rectangle
			ret += (r - l) * aveH
			# Moves the left edge to the right one
			l = r
		
		return ret
	
	
	## Returns the result of a Legender Ellipse Integral II [E(x)], with [param top] and [param k] input[br]
	## E(x) = ∫[0, top]√(1 - k * sin(t)^2)dt, in which k is often a square-powered value
	static func legender_ellipse_ii(top: float, k: float, sample: int = INTERGRAL_SAMPLE) -> float:
		return integral_finite(
			func(t: float) -> float:
				return sqrt(1 - k * (sin(t) ** 2)),
			0, top, sample
		)


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
	const _MIN_SAMPLES: int = 1024
	
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
	
	
	## Returns the short axis of the ellipse
	func get_short_axis() -> float:
		return amplitude[amplitude.min_axis_index()]
	
	
	## Returns thelong axis of the ellipse
	func get_long_axis() -> float:
		return amplitude[amplitude.max_axis_index()]
	
	
	## Returns the focal length of the ellipse
	func get_focal_length() -> float:
		return 2 * sqrt(get_long_axis() ** 2 - get_short_axis() ** 2)
	
	
	## Returns the eccentricity of the ellipse
	func get_eccentricity() -> float:
		return get_focal_length() / 2 / get_long_axis()
	
	
	## Returns the area of the ellipse
	func get_area() -> float:
		return PI * amplitude.x * amplitude.y
	
	
	## Returns length of the ellipse[b]
	## [br]
	## [b]Note:[/b] Due to the speciality of ellipse, you need to input the samples to provide calculation accuracy.
	## With minimum of 256, and if lower, an error will be thrown
	func get_length(sample: int = Calculus.INTERGRAL_SAMPLE) -> float:
		var ret: float = 0
		
		# If the ellipse is a circle, then C = 2πr
		if amplitude.x == amplitude.y:
			return 2 * PI * amplitude.x
		# If not a circle, then use ellipse integral
		else:
			var a: float = get_long_axis()
			var e: float = get_eccentricity()
			ret = 4 * a * Calculus.legender_ellipse_ii(PI/2, e ** 2)
		
		return ret
