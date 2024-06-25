class_name BehaviourBuildings
extends StaticBody2D

signal cell_ocuppied(cood_cell: Vector2i)
signal cell_unocuppied(cood_cell: Vector2i)
signal building_construction(type: String, is_rich_building: bool)

enum Type_building {
	negative,
	low,
	medium,
	advanced,
	hardcore
}

const NUMBER_OF_BUILDING_RICH: int = 8
const NUMBER_OF_BUILDING_POOR: int = 7
const _POLLUTION_OF_BUILDING_RICH: Array[Type_building] = [Type_building.negative, Type_building.low,
Type_building.medium, Type_building.advanced, Type_building.hardcore]
const _POLLUTION_OF_BUILDING_RICH_FULL: Array[Type_building] = []
const ANIMATED_TIME_POLLUTION: float = 2

var owners_puf: Array:
	get: 
		return owners_puf
	set(_owners_puf):
		owners_puf = _owners_puf
var is_rich_building: bool:
	get:
		return is_rich_building
	set(_is_rich_building):
		is_rich_building = _is_rich_building
var myself: Building: 
	get: return myself
	set(_myself):
		myself = _myself

var _my_type_of_building: Type_building = Type_building.low 
var is_save_pufs: bool = false
var saved_pufs: Array[Node2D]

@onready var sprite_building: Sprite2D = $SpriteBuilding
@onready var tilemap: TileMap = get_tree().get_first_node_in_group("tilemap")
@onready var statistics = get_tree().get_nodes_in_group(DefinitionsHelper.GROUP_UI_DEBUG) 
@onready var year_timer: Timer =  PathsHelper.get_node_by_name(statistics, "YearTimer")
@onready var animated_pollution: AnimatedSprite2D = $AnimatedPollution
@onready var animated_explosion: AnimatedSprite2D = $ExplosionEffect
@onready var animated_effects: AnimatedSprite2D = $AnimatedEffects
@onready var animated_building: AnimatedSprite2D = $AnimatedBuilding

func _init(_owners_puf: Array):
	owners_puf = _owners_puf

func _ready():
	myself = Building.new(owners_puf.front())
	
	if owners_puf.front().is_my_rich:
		randomize()
		_POLLUTION_OF_BUILDING_RICH_FULL.append_array(_POLLUTION_OF_BUILDING_RICH)
		_POLLUTION_OF_BUILDING_RICH.shuffle()
		print(_POLLUTION_OF_BUILDING_RICH_FULL)
		_my_type_of_building = _get_type_if_rich()
		_change_sprite_according_group_rich()
	else: 
		_my_type_of_building = Type_building.low
		_load_building_according_poor(owners_puf.size())
	year_timer.connect("timeout", Callable(self, "_on_year_timer_pollution_out"))
	var initial_grid_cell: Vector2i = tilemap.local_to_map(self.position)
	emit_signal("cell_ocuppied", initial_grid_cell)
	emit_signal("building_construction", _my_type_of_building, is_rich_building)

func _load_building_according_poor(count_group: int):
	var texture_frame: int
	match(count_group):
		3: 
			sprite_building.frame = RandomHelper.get_random_int_in_range(DefinitionsHelper.TEXTURE_BUILDING_POOR_SHACK_001, DefinitionsHelper.TEXTURE_BUILDING_POOR_SHACK_003)
			_my_type_of_building = Type_building.medium
		4: 
			sprite_building.frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_WINDMILL
			_my_type_of_building = Type_building.low
		5: 
			sprite_building.frame = RandomHelper.get_random_int_in_range(DefinitionsHelper.TEXTURE_BUILDING_POOR_LITTLE_HOUSE_001, DefinitionsHelper.TEXTURE_BUILDING_POOR_LITTLE_HOUSE_012)
			_my_type_of_building = Type_building.medium
		6: 
			sprite_building.frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_CROP
			_my_type_of_building = Type_building.negative
		7: 
			sprite_building.frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_WAREHOUSES_001
			_my_type_of_building = Type_building.medium
		8: 
			sprite_building.frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_WAREHOUSES_002
			_my_type_of_building = Type_building.advanced
		9: 
			sprite_building.frame = DefinitionsHelper.TEXTURE_BUILDING_POOR_WAREHOUSES_003
			_my_type_of_building = Type_building.hardcore

func _change_sprite_according_group_rich():
		var index_texture_frame: int = RandomHelper.get_random_int_in_range(1, NUMBER_OF_BUILDING_RICH)
		sprite_building.frame = index_texture_frame

func _get_type_if_rich() -> Type_building:
	if _POLLUTION_OF_BUILDING_RICH_FULL.is_empty():
		_POLLUTION_OF_BUILDING_RICH_FULL.append_array(_POLLUTION_OF_BUILDING_RICH.slice(0))
		_POLLUTION_OF_BUILDING_RICH.shuffle()
	
	var random_type = _POLLUTION_OF_BUILDING_RICH.pop_front()
	return random_type

func _destroy():
	animated_explosion.play("default")
	_destroy_after_time(2)

func _destroy_after_time(time: float):
	await get_tree().create_timer(time).timeout
	emit_signal("cell_unocuppied", tilemap.local_to_map(self.position))
	self.queue_free()

func _on_year_timer_pollution_out(time: float):
	animated_pollution.play("default")
	await get_tree().create_timer(ANIMATED_TIME_POLLUTION).timeout
	animated_pollution.stop()
