extends Camera2D

@export var multiplier_speed: float = 4
@export var zoom_speed: float = 10.0
@export var zoom_margin: float = 0.1
@export var zoom_min: float = 1.0
@export var zoom_max: float = 5.0
@export var edge_margin: int = 50  ## Distancia desde los bordes para empezar a mover la cámara

var speed: float = 50.0
var zoom_factor: float = 1.0
var zoom_pos: Vector2 = Vector2()
var zooming: bool = false

var mouse_pos: Vector2 = Vector2()
var mouse_pos_global: Vector2 = Vector2()
var start: Vector2 = Vector2()
var start_v: Vector2 = Vector2()
var end: Vector2 = Vector2()
var end_v: Vector2 = Vector2()
var is_dragging: bool = false
var is_mouse_move: bool = false
var current_global_
@onready var tilemap: TileMap = get_tree().get_first_node_in_group(DefinitionsHelper.GROUP_TILEMAP) 
@onready var debugs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_DEBUG) 
@onready var mouse_camera_button: Button =  PathsHelper.get_node_by_name(debugs, "MMButton")

func _ready():
	mouse_camera_button.connect("pressed", Callable(self, "_on_toogle_button_changes_mouse_move"))

func _process(delta):
	zoom_camera(delta)
	move_camera(delta)

func _on_toogle_button_changes_mouse_move():
	is_mouse_move = !is_mouse_move

func _mouse_move(direction: Vector2) -> Vector2:
	if is_mouse_move:
		if mouse_pos.x < edge_margin:
			direction.x = -1
		elif mouse_pos.x > get_viewport_rect().size.x - edge_margin:
			direction.x = 1
		if mouse_pos.y < edge_margin:
			direction.y = -1
		elif mouse_pos.y > get_viewport_rect().size.y - edge_margin:
			direction.y = 1
	return direction

func _awsd_move(direction: Vector2) -> Vector2:
	var inputX: int = get_input_x()
	var inputY: int = get_input_y()
	direction.x += inputX
	direction.y += inputY
	return direction

func _input(event: InputEvent) -> void:
	input_for_zoom(event)
	if event is InputEventMouse:
		mouse_pos = event.position
		mouse_pos_global = get_global_mouse_position()

func _zoom_out():
	zoom_factor -= 0.01 * zoom_speed
	zoom_pos = get_global_mouse_position()

func _zoom_in():
	zoom_factor += 0.01 * zoom_speed
	zoom_pos = get_global_mouse_position()

func get_input_x() -> int:
	return int(Input.is_action_pressed(InputsHelper.CAMERA_RIGHT)) - int(Input.is_action_pressed(InputsHelper.CAMERA_LEFT))

func get_input_y() -> int:
	return int(Input.is_action_pressed(InputsHelper.CAMERA_BACKWARD)) - int(Input.is_action_pressed(InputsHelper.CAMERA_FORWARD))

func zoom_camera(delta: float) -> void:
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, zoom_speed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, zoom_speed * delta)

	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	if not zooming:
		zoom_factor = 1.0

func move_camera(delta: float) -> void:
	if zoom.x == zoom_min and zoom.y == zoom_min:
		center_camera()
	var direction = Vector2()
	direction = _mouse_move(direction)
	direction = _awsd_move(direction)

	if direction != Vector2():
		position += direction.normalized() * (speed * multiplier_speed) * delta

func input_for_zoom(event: InputEvent) -> void:
	if abs(zoom_pos.x - get_global_mouse_position().x) > zoom_margin:
		zoom_factor = 1.0
	if abs(zoom_pos.y - get_global_mouse_position().y) > zoom_margin:
		zoom_factor = 1.0
	if event.is_pressed():
		zooming = true
		if event.is_action_pressed(InputsHelper.CAMERA_ZOOM_OUT):
			_zoom_out()
		if event.is_action_pressed(InputsHelper.CAMERA_ZOOM_IN):
			_zoom_in()
	else:
		zooming = true

func center_camera():
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
