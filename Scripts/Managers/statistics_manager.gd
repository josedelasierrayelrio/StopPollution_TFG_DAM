class_name StatisticsManager
extends Node

@export var wait_year: float = 3 ## Los segundos equivalentes a un año
@export var max_pollution: float = 100 ## Polución máxima
@export var is_debug_invert_pollution: bool = false ## Invertir la polución
@export var pollution_change_rate: float = 0.1 ## Tasa de cambio por frame
@export var rich_pollution: float = 0.067 ## Cantidad de pollution generada por año por un rico
@export var poor_pollution: float = 0.033 ## Cantidad de pollution generada por año por un rico
@export var polluted_according_to_the_type_rich: Dictionary = {
	"negative": 0.0,
	"low": 0.06,
	"medium": 0.10,
	"advanced": 0.25,
	"hardcore": 0.50
}
@export var polluted_according_to_the_type_poor: Dictionary = {
	"negative": -0.50,
	"low": -0.06,
	"medium": -0.10,
	"advanced": -0.25,
	"hardcore": -0.50
}
var year: int = 0:
	get:
		return year
var total_rich_pufs: int = 0
var total_poor_pufs: int = 0
var total_buildings: int = 0
var total_rich_buildings: Array[int]
var total_poor_buildings: Array[int]

var previous_pollution: float
var actual_pollution: float
var target_pollution: float
var building_rich_pollution: float = rich_pollution * 0.3
var building_poor_pollution: float = poor_pollution * 0.3
var slow_increment: float = wait_year / 100
var next_spawn_in: float

var buildings: Array

@onready var total_pufs: Array
@onready var ui_labels = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_LABELS_RESULT)
@onready var ui_years_label = PathsHelper.get_node_by_name(ui_labels, "YResult")
@onready var ui_pollution_label =  PathsHelper.get_node_by_name(ui_labels, "PResult")
@onready var ui_poblation_label =  PathsHelper.get_node_by_name(ui_labels, "PoResult")
@onready var ui_poblation_poor_label =  PathsHelper.get_node_by_name(ui_labels, "WResult")
@onready var ui_poblation_rich_label =  PathsHelper.get_node_by_name(ui_labels, "BResult")
@onready var ui_new_puf_time_label =  PathsHelper.get_node_by_name(ui_labels, "NPResult")
@onready var ui_new_puf_label = PathsHelper.get_node_by_name(ui_labels, "NewPuf")

@onready var ui_sprites = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_STATISTICS_ANIMATIONS)
@onready var ui_year_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "YearSprite")
@onready var ui_pollution_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "PollutionSprite")
@onready var ui_poblation_sprite: Sprite2D = PathsHelper.get_node_by_name(ui_sprites, "PoblationSprite")
@onready var ui_year_animation_player: AnimationPlayer = ui_year_sprite.get_child(0)
@onready var ui_poblation_animation_player: AnimationPlayer = ui_poblation_sprite.get_child(0)
@onready var ui_pollution_sprite_player: AnimationPlayer = ui_pollution_sprite.get_child(0)
@onready var year_timer: Timer = $YearsTimer

@onready var debugs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_DEBUG) 
@onready var debug_invert_pollution_button: Button =  PathsHelper.get_node_by_name(debugs, "IPButton")

func _ready():
	year_timer.wait_time = wait_year
	year_timer.start()
	ui_new_puf_label.text = DefinitionsHelper.UI_LABEL_STATISTICS_INITIAL_TIME
	debug_invert_pollution_button.connect("pressed", Callable(self, "_on_button_debug_invert_pollution_toggled"))

func _process(delta):
	ui_pollution_label.text = String.num(actual_pollution, 2)
	_change_time_to_spawn_label(delta)
	_update_poblation()
	_update_pollution(delta)
	buildings = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_BUILDING) 
	connect_to_buildings()

func _update_poblation():
	var global_puf: int = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS).size()
	var animation_to_play: String = ""
	if total_pufs.size() != global_puf:
		if global_puf > total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_PLUS_UI
		elif global_puf < total_pufs.size():
			animation_to_play = DefinitionsHelper.ANIMATION_MINUM_UI
		total_pufs = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_PUFS)
		ui_poblation_label.text = str(total_pufs.size())
		ui_poblation_poor_label.text = str(total_poor_pufs)
		ui_poblation_rich_label.text = str(total_rich_pufs)
		_reproduce_animation(ui_poblation_sprite, ui_poblation_animation_player, animation_to_play, true)

func _change_visibility_sprite(sprite: Sprite2D, visibility: bool):
	sprite.visible = visibility

func _update_pollution(delta): 
	var slow_delta: float = delta * slow_increment
	previous_pollution = actual_pollution
	if actual_pollution < target_pollution:
		actual_pollution += pollution_change_rate * slow_delta
		if actual_pollution > target_pollution:
			actual_pollution = target_pollution
		_shake_node(ui_pollution_label, delta, actual_pollution, slow_delta)
	elif actual_pollution > target_pollution:
		actual_pollution -= pollution_change_rate * slow_delta
		_shake_node(ui_pollution_label, delta, actual_pollution, slow_delta)
		if actual_pollution < target_pollution:
			actual_pollution = target_pollution
	if actual_pollution != 0:
		_change_visibility_sprite(ui_pollution_sprite, true)
	else:
		_change_visibility_sprite(ui_pollution_sprite, false)

func _calculate_total_pollution() -> float:
	var total_rich_pollution: float = 0.0
	var total_poor_pollution: float = 0.0
	for i in range(total_rich_buildings.size()):
		var building_count = total_rich_buildings[i]
		var pollution_multiplier = 0.0
		match i:
			0: pollution_multiplier = polluted_according_to_the_type_rich["negative"]
			1: pollution_multiplier = polluted_according_to_the_type_rich["low"]
			2: pollution_multiplier = polluted_according_to_the_type_rich["medium"]
			3: pollution_multiplier = polluted_according_to_the_type_rich["advanced"]
			4: pollution_multiplier = polluted_according_to_the_type_rich["hardcore"]
		total_rich_pollution += building_count * pollution_multiplier
	for i in range(total_poor_buildings.size()):
		var building_count = total_poor_buildings[i]
		var pollution_multiplier = 0.0
		match i:
			0: pollution_multiplier = polluted_according_to_the_type_poor["negative"]
			1: pollution_multiplier = polluted_according_to_the_type_poor["low"]
			2: pollution_multiplier = polluted_according_to_the_type_poor["medium"]
			3: pollution_multiplier = polluted_according_to_the_type_poor["advanced"]
			4: pollution_multiplier = polluted_according_to_the_type_poor["hardcore"]
		total_poor_pollution += building_count * pollution_multiplier
	total_rich_pollution += total_rich_pufs * rich_pollution 
	total_poor_pollution += total_poor_pufs * poor_pollution
	var total_pollution = total_rich_pollution + total_poor_pollution
	if is_debug_invert_pollution:
		total_pollution *= -1
	return total_pollution

func _update_animations_to_pollution(animation_to_play: String):
	ui_pollution_sprite_player.stop()
	ui_pollution_sprite_player.play(animation_to_play)

func _reproduce_animation(animation_sprite: Sprite2D, animation_player: AnimationPlayer, animation: String, cut_animation: bool):
	_change_visibility_sprite(animation_sprite, true)
	if cut_animation:
		animation_player.stop()
		animation_player.play(animation)
		return
	if animation_player.is_playing():
		animation_player.queue(animation)
	elif animation_player.get_queue().is_empty(): 
		animation_player.play(animation)

func _shake_node(node: Node, delta: float, shake_intensity: float, shake_duration: float):
	var shake_timer = shake_duration
	while shake_timer > 0:
		var shake_offset: float = randf_range(-shake_intensity, shake_intensity)
		node.position.x += shake_offset
		shake_timer -= delta
		await get_tree().create_timer(delta).timeout
	node.position.x = 0

func _change_time_to_spawn_label(delta):
	if next_spawn_in > 0:
		next_spawn_in -= delta
		if next_spawn_in < 0:
			next_spawn_in = 0
	ui_new_puf_time_label.text = String.num(next_spawn_in, 2)

func connect_to_buildings():
	if not buildings.is_empty(): 
		for building in buildings:
			building.connect("building_construction", Callable(self, "_on_building_construction"))

func _on_manager_pufs_born_a_rich():
	total_rich_pufs += 1

func _on_manager_pufs_born_a_poor():
	total_poor_pufs += 1

func _on_manager_pufs_dead_a_rich():
	total_rich_pufs -= 1
	
func _on_manager_pufs_dead_a_poor():
	total_poor_pufs -= 1

func _on_years_timer_timeout():
	year += 1
	ui_years_label.text = str(year)
	_reproduce_animation(ui_year_sprite, ui_year_animation_player, DefinitionsHelper.ANIMATION_PLUS_UI, false)
	var animation_to_play = DefinitionsHelper.ANIMATION_DOWN_UI if actual_pollution > target_pollution else DefinitionsHelper.ANIMATION_UP_UI
	_update_animations_to_pollution(animation_to_play)
	target_pollution += _calculate_total_pollution()

func _on_manager_pufs_time_to_rich():
	ui_new_puf_label.text = DefinitionsHelper.UI_LABEL_STATISTICS_TIME_TO_RICH

func _on_manager_pufs_time_to_birth(time):
	next_spawn_in = time

func _on_button_debug_invert_pollution_toggled():
	is_debug_invert_pollution = !is_debug_invert_pollution

func _on_building_construction(type: String, is_rich_building: bool):
	match type:
		"negative":
			if is_rich_building: total_rich_buildings[0] += 1
			else: total_poor_buildings[0] += 1 
		"low": 
			if is_rich_building: total_rich_buildings[0] += 1
			else: total_poor_buildings[0] += 1 
		"medium": 
			if is_rich_building: total_rich_buildings[0] += 1
			else: total_poor_buildings[0] += 1 
		"advanced": 
			if is_rich_building: total_rich_buildings[0] += 1
			else: total_poor_buildings[0] += 1 
		"hardcore":
			if is_rich_building: total_rich_buildings[0] += 1
			else: total_poor_buildings[0] += 1 
