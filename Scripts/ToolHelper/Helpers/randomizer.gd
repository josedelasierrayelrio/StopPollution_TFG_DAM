class_name RandomHelper

static func get_random_string_in_array(options: Array) -> String:
	#return options[randi() % options.size()]
	return options.pick_random()

static func get_random_enum(options: Dictionary) -> int:
	var keys = options.keys()
	var random_index = randi() % keys.size()
	return options[keys[random_index]]

static func get_random_int_in_range(min: int, max: int):
	var random = RandomNumberGenerator.new()
	return random.randi_range(min, max)

static func get_random_float_in_range(min: float, max: float):
	var random = RandomNumberGenerator.new()
	return random.randf_range(min, max)
