class_name ManagerEntities
extends Node2D

signal ocuppied_cells_array(ocuppied_cells: Array[Vector2i])
signal update_current_total_pufs(pufs: Array[Node2D])
signal total_draggin_pufs(pufs: int)
signal time_to_birth(time: float)
signal mouse_over_puf(text: String)
signal time_to_rich()
signal born_puf()
signal born_a_rich()
signal born_a_poor()
signal dead_a_rich()
signal dead_a_poor()
signal celebration_all_pufs()

@export_range(0, 100) var limit_initial_spawn_puf: int = RandomHelper.get_random_int_in_range(15, 20) ## 0 es equivalente a un número aleatorio entre 15 y 20
@export var spawn_time: float = 3 ## Tiempo entre spawn y spawn
@export var spawn_time_to_rich: float = 13  ## Cuando se pone a false, comienzan a spawnear únicamente ricos
@export var is_time_to_spawn_rich: bool = false ## ¿Es tiempo de que solo spawneen ricos?

var spawn_cells: Array[Vector2i] 
var ocuppied_cells: Array[Vector2i] 
var rich_pufs: Array[Node2D] 
var poor_pufs: Array[Node2D] 
var current_pufs: Array[Node2D]
var selected_puf: Array[Node2D]
var dragging_pufs: Array[Node2D]
var total_time_of_spawn: float 

var is_finished_initial_spawn: bool = false
var is_picked_up: bool = false
var is_first_puf: bool = true

# Variables para el sistema de selección de pufs
@onready var parent: Node2D = get_tree().get_first_node_in_group("game")
@onready var puf: PackedScene = preload(PathsHelper.PATH_SCENE_PUF)
@onready var blood_stain_sprite: PackedScene = preload(PathsHelper.PATH_SCENE_BLOOD_STAIN)
@onready var building: PackedScene = preload(PathsHelper.PATH_SCENE_BUILDING)
@onready var tilemap: TileMap = get_tree().get_first_node_in_group(DefinitionsHelper.GROUP_TILEMAP)
@onready var timer_spawn: Timer = $TimerSpawn
@onready var debugs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_DEBUG) 
@onready var debug_toogle_spawn_button: Button = PathsHelper.get_node_by_name(debugs, "TSButton")

func _ready():
	timer_spawn.wait_time = spawn_time
	timer_spawn.start()
	emit_signal("time_to_birth", timer_spawn.time_left)
	if not debugs.is_empty():
		debug_toogle_spawn_button.connect("pressed", Callable(self, "_on_button_debug_toogle_spawn_button_toggled"))

func _process(delta):
	pass

func _born_a_puf():
	var new_puf: Node2D
	var random_position = spawn_cells[RandomHelper.get_random_int_in_range(0, spawn_cells.size()-1)]
	var flip: int = RandomHelper.get_random_int_in_range(0, 1)
	var random_global_position = tilemap.astar_grid.get_point_position(Vector2(random_position.x, random_position.y)) # Transforma las coordenadas locales del grid en globales
	new_puf = puf.instantiate()
	if not is_time_to_spawn_rich:
		new_puf.social_class = DefinitionsHelper.RICH_SOCIAL_CLASS
	new_puf.position = random_global_position
	new_puf.get_node("SpritePuf").flip_h = flip # Cambia la dirección hacia la que mira el puf al instanciarse
	_emit_signal_according_born_social_class_puf(new_puf)
	_save_puf_in_array(new_puf, current_pufs)
	
	new_puf.connect("puf_dragging", Callable(self, "_on_puf_dragging"))
	new_puf.connect("puf_undragging", Callable(self, "_on_puf_undragging"))
	new_puf.connect("cell_ocuppied", Callable(self, "_on_ocupied_cell"))
	new_puf.connect("cell_unocuppied", Callable(self, "_on_unocupied_cell"))
	new_puf.connect("puf_smashed", Callable(self, "_on_puf_smashed"))
	new_puf.connect("enter_mouse_above_me", Callable(self, "_on_mouse_enter_above_puf"))
	new_puf.connect("exit_mouse_above_me", Callable(self, "_on_mouse_exit_above_puf"))
	parent.add_child(new_puf)

func _emit_signal_according_born_social_class_puf(new_puf):
	if new_puf.get_social_class() == DefinitionsHelper.RICH_SOCIAL_CLASS: 
		born_a_rich.emit()
		_save_puf_in_array(new_puf, rich_pufs)
	else: 
		born_a_poor.emit()
		_save_puf_in_array(new_puf, poor_pufs)

func _finished_spawn_initial_pufs():
	if is_finished_initial_spawn:
		return
	is_finished_initial_spawn = true
	
	if is_time_to_spawn_rich:
		timer_spawn.wait_time = spawn_time_to_rich
		timer_spawn.stop()
		await get_tree().create_timer(spawn_time_to_rich).timeout
		timer_spawn.start()
		time_to_rich.emit()

func _save_puf_in_array(puf: Node2D, array: Array):
	array.push_back(puf)

func _is_in_array(puf: Node2D, array: Array) -> bool:
	return array.has(puf)

func _remove_puf_in_array(puf: Node2D, array: Array):
	if not array.is_empty() and array.has(puf):
		array.erase(puf)

func _emit_signal_assemble():
	pass # TODO: Hacer que mande la señal de assemble

func _put_blood_stain(death_position: Vector2i):
	_emit_signal_to_update_total_pufs()
	await get_tree().create_timer(2).timeout
	var blood_stain = blood_stain_sprite.instantiate()
	blood_stain.stop()
	blood_stain.position = death_position
	blood_stain.visible = true
	blood_stain.play("default")
	parent.add_child(blood_stain)

func _create_groups_with_pufs() -> Group:
	return null

func _new_building():
	emit_signal("update_current_total_pufs", current_pufs.size())
	await get_tree().create_timer(0.5).timeout
	var new_building = building.instantiate()
	new_building.connect("building_construction", Callable(self, "_on_building_consruction"))

func _emit_signal_to_update_total_pufs():
	emit_signal("update_current_total_pufs", current_pufs.size())

func _on_timer_spawn_timeout():
	total_time_of_spawn += timer_spawn.wait_time
	_born_a_puf()
	if current_pufs.size() >= limit_initial_spawn_puf:
		is_time_to_spawn_rich = true
		_finished_spawn_initial_pufs()
	emit_signal("time_to_birth", timer_spawn.time_left)

func _on_ocupied_cell(cood_cell):
	ocuppied_cells.append(cood_cell)
	emit_signal("ocuppied_cells_array", ocuppied_cells)

func _on_unocupied_cell(cood_cell):
	if not ocuppied_cells.is_empty():
		if ocuppied_cells.has(cood_cell):
			ocuppied_cells.erase(cood_cell)
			emit_signal("ocuppied_cells_array", ocuppied_cells)

func _on_puf_dragging(puf):
	if not dragging_pufs.has(puf):
		dragging_pufs.append(puf)
	emit_signal("total_draggin_pufs", dragging_pufs.size())

func _on_puf_undragging(puf):
	if dragging_pufs.has(puf):
		dragging_pufs.erase(puf)
	emit_signal("total_draggin_pufs", dragging_pufs.size())

func _on_tile_map_ocuppied_coordinates(ocuppied_coordinates):
	ocuppied_cells = ocuppied_coordinates

func _on_tile_map_spawn_coordinates(spawn_coordinates):
	spawn_cells = spawn_coordinates

func _on_puf_smashed(death_puf: Node2D):
	_put_blood_stain(death_puf.position)
	emit_signal("celebration_all_pufs", DefinitionsHelper.TYPE_CELEBRATION_SMASH_PUF)
	dead_a_rich.emit()

func _on_button_debug_toogle_spawn_button_toggled():
	timer_spawn.start() if timer_spawn.is_stopped() else timer_spawn.stop()

func _on_mouse_manager_change_selected_pufs(pufs):
	selected_puf = pufs

func _on_mouse_enter_above_puf(puf: Node2D):
	var text: String = ""
	if puf.is_myself_rich():
		text = "[SPACE] to smash"
	else: text = "[Left Click] to drag"
	emit_signal("mouse_over_puf", text)

func _on_mouse_exit_above_puf(puf: Node2D):
	emit_signal("mouse_over_puf", "")
