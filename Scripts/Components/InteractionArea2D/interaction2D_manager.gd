extends Node2D

const BASE_TEXT: String = "none"

## Distancia entre el label y el objeto a interactuar en y
@export var distance_label_y = 36
## Distancia entre el label y el objeto a interactuar en x
@export var distance_label_x = 50
@export var active_areas: Array = []
var can_interact: bool = true
var mouse_pos
@onready var label = $Label

func add_area(area: InteractionArea2D):
	active_areas.push_back(area)

func remove_area(area: InteractionArea2D):
	var index_area: int = active_areas.find(area)
	if index_area != DefinitionsHelper.INDEX_NOT_EXIST:
		active_areas.remove_at(index_area)

func _process(delta):
	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = BASE_TEXT + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= distance_label_y
		label.global_position.x -= active_areas[0].global_position.x - distance_label_x 
		label.show()
	else: label.hide() 

## Este método devuelve el area más cercana al ratón
func _sort_by_distance_to_player(area1, area2) -> int:
	mouse_pos = get_global_mouse_position()
	var area1_to_mouse = mouse_pos.global_position.distadistance_squared_to	(area1.global.position)
	var area2_to_mouse = mouse_pos.global_position.distance_squared_to(area2.global.position)
	return area1_to_mouse < area2_to_mouse

func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
