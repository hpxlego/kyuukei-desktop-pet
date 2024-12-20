extends Control

var RESIZE = 0.1
var BASE_WIDTH = ProjectSettings.get("display/window/size/viewport_width")
var BASE_HEIGTH = ProjectSettings.get("display/window/size/viewport_height")

var prev_text: String

@onready var kyukei = $"%Kyukei"
@onready var speech_box = $"%SpeechBox"
@onready var speech_label = $"%SpeechLabel"

@export_multiline var kyuukei_speech: Array[String]


func _ready() -> void:
	randomize()
	change_mouse_passthrought_size()
	get_viewport().size_changed.connect(change_mouse_passthrought_size)
	await get_random_kyuukei_speech()
	start_random_kyuukei_speech()


func scale_points(points: Array, base_resolution: Vector2, new_resolution: Vector2) -> PackedVector2Array:
	# Calculate the scaling factors
	var scale_x = new_resolution.x / base_resolution.x
	var scale_y = new_resolution.y / base_resolution.y

	# Create a new array to store the scaled points
	var scaled_points = []
	for point in points:
		var scaled_point = Vector2i(point.x * scale_x, point.y * scale_y)
		scaled_points.append(scaled_point)
	
	return PackedVector2Array(scaled_points)


func get_random_kyuukei_speech():
	var new_speech = kyuukei_speech.duplicate()
	new_speech.erase(prev_text)
	var text = new_speech.pick_random()
	prev_text = text
	speech_box.show()
	change_mouse_passthrought_size()
	speech_label.text = text
	await get_tree().create_timer(5.0).timeout
	speech_box.hide()
	change_mouse_passthrought_size()


func start_random_kyuukei_speech():
	var rand_timer = randf_range(3.0, 30.0)
	await get_tree().create_timer(rand_timer).timeout
	await get_random_kyuukei_speech()
	start_random_kyuukei_speech()


func change_mouse_passthrought_size():
	var passthrough_polygon = scale_points(orthogonal_convex_hull(), Vector2(BASE_WIDTH, BASE_HEIGTH), get_viewport().size)
	get_window().mouse_passthrough_polygon = passthrough_polygon
	print(get_window().mouse_passthrough_polygon)


func get_control_points(rect: Control) -> Array:
	# Get the global position and size of the control
	var rect_position = rect.get_global_rect().position
	var rect_size = rect.get_global_rect().size

	# Calculate the four corners
	var top_left = rect_position
	var top_right = rect_position + Vector2(rect_size.x, 0)
	var bottom_left = rect_position + Vector2(0, rect_size.y)
	var bottom_right = rect_position + rect_size

	# Return the points as an array
	return [top_left, top_right, bottom_left, bottom_right]


func flatten_array(nested_array: Array) -> Array:
	var flat_array = []
	for element in nested_array:
		for y in element:
			flat_array.append(y)
	return flat_array


## orthogonal convex hull in godot because i'm a fucking hack  
func orthogonal_convex_hull():
	var kyukei_point = Geometry2D.convex_hull(get_control_points(kyukei))
	var speech_box_point = Geometry2D.convex_hull(get_control_points(speech_box))
	if not speech_box.visible: speech_box_point = []
	
	return flatten_array(Geometry2D.merge_polygons(kyukei_point, speech_box_point))


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("resize_plus"):
		change_size(RESIZE)
		change_mouse_passthrought_size()
	elif Input.is_action_just_pressed("resize_minus"):
		change_size(-RESIZE)
		change_mouse_passthrought_size()

func change_size(new_size) -> void:
	get_viewport().size += Vector2i(get_viewport().size * new_size)
