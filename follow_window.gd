extends Control


var following = false
var dragging_start_position = Vector2.ONE


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("grab"):
		following = true
		dragging_start_position = DisplayServer.mouse_get_position() - get_window().position
	elif Input.is_action_just_released("grab"):
		following = false


func scale_point(point: Vector2) -> Vector2i:
	# Calculate the scaling factors
	var scale_x = get_viewport().size.x / ProjectSettings.get_setting("display/window/size/viewport_width")
	var scale_y = get_viewport().size.y / ProjectSettings.get_setting("display/window/size/viewport_height")

	# Create a new array to store the scaled points
	
	var scaled_point = Vector2i(point.x * scale_x, point.y * scale_y)
	
	return Vector2i(scaled_point)


func _process(delta: float) -> void:
	if following:
		var glob_mouse = Vector2i(DisplayServer.mouse_get_position() - get_window().position)
		var start_drag = Vector2i(dragging_start_position)
		
		print(glob_mouse - start_drag)
		
		get_window().position = get_window().position + (glob_mouse - start_drag)
