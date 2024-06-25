class_name BehaviourPuf
extends CharacterBody2D

signal cell_ocuppied(cood_cell: Vector2i)
signal cell_unocuppied(cood_cell: Vector2i)
signal puf_dead(puf: Vector2i)
signal puf_smashed(puf: Node2D)
signal puf_dragging(puf: Node2D)
signal puf_undragging(puf: Node2D)
signal enter_mouse_above_me(puf: Node2D)
signal exit_mouse_above_me(puf: Node2D)

@export var wait_time_move: float = 0.4 ## Tiempo de espera entre un movimiento y el siguiente
@export var wait_time_finish_celebration: float = 2 ## Tiempo de espera entre un movimiento y el siguiente
@export var wait_time_stop_rich: float = 0.5 ## Tiempo de espera hasta que el rico se para
@export var wait_time_disappear_name: float = 2 ## Tiempo de espera hasta que desaparece el nombre del puf
@export var move_grid_speed: float = 1 ## Velocidad a la que se desplaza el puf por el grid
@export var move_drag_speed: float = 80 ## Velocidad a la que se desplaza el puf al ser arrastrado
@export var degress_rotation: float = 90 ## Grados de rotación del sprite al arrastrarlo
@export var in_or_out_zoom: float = 0.5 ## Valor por el que se incrementa el texto a través del zoom de la cámara
@export var can_assemble: bool = false ## ¿Los Pufs se pueden unir?
@export var is_in_or_out_zoom: bool = false ## Booleana que controla si se incrementa o decrementa el zoom
@export var knockback_strength: float = 30 ## Fuerza del knockback
@export var is_selected: bool = false ## ¿Está el puf seleccionado?
@export var is_smashed_now: bool = false ## ¿Estoy aplastando ahora mismo?

var myself: Puf: 
	get: return myself
	set(_myself):
		myself = _myself
var is_baby: bool = false:
	get: return is_baby
	set(_is_baby):
		is_baby = _is_baby
var inside_the_birthroom_area: bool = false:
	get: return inside_the_birthroom_area
	set(_inside_area):
		inside_the_birthroom_area = _inside_area
var social_class: int = DefinitionsHelper.INDEX_RANDOM_SOCIAL_CLASS:
	set(_social_class):
		social_class = _social_class

var way_diying: String = DefinitionsHelper.WAY_DYING_NEEDS
var is_dragging: bool = false
var is_can_grid_move: bool = false
var is_your_moving: bool = false
var is_look_to_target_position: bool = false
var is_mouse_top: bool = false
var puf_rich_at_my_side: Array[Node2D]
var puf_poor_at_my_side: Array[Node2D]
var ocuppied_cells: Array[Vector2i]
var death_cells: Array[Vector2i]
var current_paths: Array[Vector2i]
var global_cursor_map_position_relative_local_tilemap: Vector2i
var local_cursor_map_position_relative_local_tilemap: Vector2i
var global_cursor_map_position_relative_global_tilemap: Vector2i
var current_position_relative_to_local_tilemap: Vector2i
var current_clic_position: Vector2
var target_grid_position: Vector2

@onready var wait_timer: Timer = $WaitTime
@onready var interact_label: Label = $InteractLabel
@onready var name_label: Label = $NameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var manager_puf: Node2D = get_tree().get_first_node_in_group("manager_pufs")
@onready var smash_sprite: Sprite2D = $SmashSprite
@onready var sprite_puf: Sprite2D = $SpritePuf
@onready var smash_animation_player: AnimationPlayer = smash_sprite.get_child(0)
@onready var selected_sprite: AnimatedSprite2D = $SelectedPuf
@onready var assemble_shape: CollisionShape2D = $InteractionAreas/AssembleArea/AssembleShape
@onready var repulsion_shape: CollisionShape2D = $InteractionAreas/RepulsionArea/RepulsionShape
@onready var mouse_shape: CollisionShape2D = $InteractionAreas/MouseArea/MouseShape
@onready var shape_puf: CollisionShape2D = $ShapePuf
@onready var tilemap: TileMap = get_tree().get_first_node_in_group(DefinitionsHelper.GROUP_TILEMAP)
@onready var astar_grid: AStarGrid2D = tilemap.astar_grid
@onready var camera: Camera2D = get_tree().get_first_node_in_group(DefinitionsHelper.GROUP_CAMERA)
@onready var birthroom: Node2D = get_tree().get_first_node_in_group(DefinitionsHelper.GROUP_BIRTHROOM)

func _init():
	myself = Puf.new(social_class, is_baby)

func _ready():
	social_class = myself.social_class
	_change_sprite_according_social_class()
	var initial_grid_cell: Vector2i = tilemap.local_to_map(self.position)
	
	shape_puf.shape = RectangleShape2D.new()
	shape_puf.shape.size = Vector2(16, 16)
	if is_myself_rich():
		assemble_shape.shape = RectangleShape2D.new()
		assemble_shape.shape.size = Vector2(32, 32)
		repulsion_shape.shape = RectangleShape2D.new()
		repulsion_shape.shape.size = Vector2(20, 20)
	
	emit_signal("cell_ocuppied", initial_grid_cell)
	manager_puf.connect("ocuppied_cells_array", Callable(self, "_on_ocuppied_cells"))
	manager_puf.connect("celebration_all_pufs", Callable(self, "_on_celebration_all_pufs"))
	tilemap.connect("death_coordinates", Callable(self, "_on_death_cells"))
	animation_player.play(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _change_sprite_according_social_class():
	var path_texture: String
	if social_class == DefinitionsHelper.INDEX_RICH_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_rich_pufs)
	elif social_class == DefinitionsHelper.INDEX_POOR_SOCIAL_CLASS:
		path_texture = RandomHelper.get_random_string_in_array(DefinitionsHelper.texture_poor_pufs)
	sprite_puf.texture = load(path_texture)

func _process(delta):
	selected_sprite.visible = true if is_selected else false
	_update_all_position_grid()
	if Input.is_action_pressed(InputsHelper.LEFT_CLICK):
		current_clic_position = get_global_mouse_position()
	
	if Input.is_action_just_released(InputsHelper.LEFT_CLICK):
		if is_dragging:
			is_dragging = false
			reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)
	if inside_the_birthroom_area:
		if Input.is_action_just_pressed("assemble_puf"):
			print("ESTOY DENTRO, SACRIFICAME")
	
	if is_mouse_top:
		if is_myself_rich():
			if Input.is_action_just_pressed(InputsHelper.SMASH_PUF):
				if not is_smashed_now:
					_smash_rich()
					_die(way_diying)
	_emit_signal_if_dragging()

func _physics_process(delta):
	if is_dragging:
		_animation_to_run_pufs()
		_move_to_clic_position(current_clic_position)
		if is_myself_rich():
			_look_to_mouse(-get_local_mouse_position())
			_stop_move_is_rich()

func _on_mouse_area_input_event(viewport, event, shape_idx):  #Cuando un evento interactua con el area
	if Input.is_action_pressed(InputsHelper.LEFT_CLICK):
		is_dragging = true

func _look_to_mouse(clic_position: Vector2):
	#var direction = (clic_position - self.global_position).normalized()
	sprite_puf.flip_h = clic_position.x < 0

func _move_to_clic_position(clic_position: Vector2):
	_look_to_mouse(get_local_mouse_position())
	var new_position_relative_to_map = tilemap.local_to_map(clic_position)
	var new_position = tilemap.map_to_local(new_position_relative_to_map)
	var direction = (new_position - self.position).normalized()
	_emit_signal_with_ocuppied_grid_position(tilemap.local_to_map(self.position), true)
	if _is_not_ocuppied_position(clic_position):
		if not is_myself_rich():
			if _is_wall_position(clic_position) or _is_death_position(clic_position):
				stop_immediately()
				return
	self.velocity = (direction * move_drag_speed)
	move_and_slide()
	_emit_signal_with_ocuppied_grid_position(new_position_relative_to_map, false)
	if is_myself_rich() and is_dragging: _message_if_move_me("Get off, commoner!", "May you hang!")
	else:_message_if_move_me("I'm coming!", "Wait for me, dammit!")

func _message_if_move_me(first_text: String, text_to_wait_time: String):
	await get_tree().create_timer(0.5).timeout
	_change_interact_ui_label(first_text)
	await get_tree().create_timer(0.5).timeout
	_change_interact_ui_label(text_to_wait_time)
	await get_tree().create_timer(1).timeout
	_change_interact_ui_label("")

func _messages_interspersed_over_time(time: float, text: String):
	await get_tree().create_timer(time).timeout
	_change_interact_ui_label(text)

func _animation_to_run_pufs():
	var animation_to_play = ""
	if is_myself_rich(): animation_to_play = DefinitionsHelper.ANIMATION_RUN_PUF
	else: animation_to_play = DefinitionsHelper.ANIMATION_JUMP_PUF
	reproduce_animation_without_queue(animation_to_play)

func _stop_move_is_rich():
	await get_tree().create_timer(wait_time_stop_rich).timeout
	is_dragging = false
	await get_tree().create_timer(wait_time_stop_rich).timeout
	reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_DIE_PUF)
	_look_to_mouse(get_local_mouse_position())
	await get_tree().create_timer(wait_time_stop_rich * 2).timeout
	reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_RESET_PUF)
	reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _calculate_current_paths_through_clic_position(clic_position: Vector2):
	var myself_local_position = tilemap.local_to_map(self.position)
	var current_clic_local_position = tilemap.local_to_map(clic_position)
	if tilemap.is_point_walkable_map_local_position(current_clic_local_position):
		if _is_not_ocuppied_position(current_clic_local_position):
			#if not _is_death_position(current_clic_local_position):
			current_paths = tilemap.get_current_path(myself_local_position, current_clic_local_position).slice(1)
			is_can_grid_move = false if current_paths.is_empty() else true

func _move_to_grid_position_through_current_paths():
	if current_paths.is_empty():
		is_your_moving = false
		is_look_to_target_position = false
		return
	reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_RUN_PUF)
	var target_position = tilemap.map_to_local(current_paths.front())
	is_look_to_target_position = true
	_emit_signal_with_ocuppied_grid_position(tilemap.local_to_map(self.global_position), true)
	self.global_position = self.global_position.move_toward(target_position, move_grid_speed)
	await get_tree().create_timer(wait_time_move).timeout
	if self.global_position == target_position:
		reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)
		is_your_moving = true
		current_paths.pop_front()
		_emit_signal_with_ocuppied_grid_position(target_position, true)

func _is_not_ocuppied_position(current_position: Vector2i) -> bool:
	current_position = tilemap.local_to_map(current_position)
	return not ocuppied_cells.has(current_position)

func _is_wall_position(current_position: Vector2i) -> bool:
	current_position = tilemap.local_to_map(current_position)
	return tilemap.is_point_wall_cells(current_position)

func _is_death_position(current_position: Vector2i) -> bool:
	current_position = tilemap.local_to_map(current_position)
	return tilemap.is_point_death_cells(current_position)

func _die(die: String):
	var animation_to_reproduce: String = ""
	await get_tree().create_timer(1).timeout 
	match die:
		DefinitionsHelper.WAY_DYING_SMASH: animation_to_reproduce = DefinitionsHelper.ANIMATION_DEATH_BY_SMASH_PUF
		DefinitionsHelper.WAY_DYING_BY_FALL_PUF: animation_to_reproduce = DefinitionsHelper.ANIMATION_DEATH_BY_FALL_PUF
		DefinitionsHelper.WAY_DYING_NEEDS: animation_to_reproduce = DefinitionsHelper.ANIMATION_DIE_PUF
	reproduce_animation_without_queue(animation_to_reproduce)
	stop_immediately()
	_change_interact_ui_label("&@$#/°")
	await get_tree().create_timer(1).timeout
	_change_interact_ui_label("")
	_destroy_after_time(1)

func _smash_rich():
	is_smashed_now = true
	is_dragging = false
	emit_signal("puf_smashed", self)
	smash_sprite.visible = true
	smash_animation_player.play(DefinitionsHelper.ANIMATION_DEATH_BY_SMASH_CURSOR)
	way_diying = DefinitionsHelper.WAY_DYING_SMASH
	await get_tree().create_timer(1.7).timeout 
	smash_sprite.visible = false

func _update_all_position_grid():
	local_cursor_map_position_relative_local_tilemap = tilemap.local_to_map(get_local_mouse_position())
	global_cursor_map_position_relative_local_tilemap = tilemap.local_to_map(get_global_mouse_position())
	global_cursor_map_position_relative_global_tilemap = tilemap.map_to_local(local_cursor_map_position_relative_local_tilemap)
	current_position_relative_to_local_tilemap = tilemap.local_to_map(self.position)

func _destroy_after_time(time: float):
	await get_tree().create_timer(time).timeout
	is_smashed_now = false
	emit_signal("cell_unocuppied", tilemap.local_to_map(self.position))
	self.queue_free()

func _invisible_after(node: Node2D, time: float):
	await get_tree().create_timer(time).timeout
	node.visible = false
	
func _change_interact_ui_label(text: String):
	if text: 
		interact_label.visible = true
		interact_label.text = text
	else: 
		interact_label.visible = false
		interact_label.text = ""

func _kockback(body: CharacterBody2D):
	var body_to_knockback: CharacterBody2D = body
	var other_body: CharacterBody2D = self
	if not is_myself_rich():
		body_to_knockback = self
		other_body = body
	var knockback_direction = (body_to_knockback.velocity - other_body.velocity).normalized() * -knockback_strength
	body_to_knockback.stop_immediately()
	body_to_knockback.reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_KNOCKBACK_JUMP_PUF)
	body_to_knockback.velocity = knockback_direction
	body_to_knockback.global_position += body_to_knockback.velocity
	await get_tree().create_timer(1).timeout
	body_to_knockback.rotation = 0

func stop_immediately():
	is_dragging = false
	self.velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	reproduce_animation_with_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)

func reproduce_animation_without_queue(animation: String):
	animation_player.play(animation)

func reproduce_animation_with_queue(animation: String):
	var actual_animation_name = animation_player.get_current_animation()
	var actual_animation = animation_player.get_animation(actual_animation_name)
	
	if animation_player.is_playing() and actual_animation_name == animation:
		if actual_animation.loop_mode == Animation.LoopMode.LOOP_NONE:
			if not animation_player.has_animation(animation):
				animation_player.queue(animation)
		else:
			return
	elif animation_player.is_playing() and actual_animation_name != animation:
		if actual_animation.loop_mode != Animation.LoopMode.LOOP_NONE:
			animation_player.stop()
			animation_player.play(animation)
		elif not animation_player.has_animation(animation):
			animation_player.queue(animation)
	else:
		animation_player.play(animation)

func _disappear_name_label():
	await get_tree().create_timer(wait_time_disappear_name).timeout
	name_label.text = ""

''' Métodos de señales '''
func _emit_signal_with_ocuppied_grid_position(current_grid_cell: Vector2, free_or_not: bool):
	var signal_name = "cell_unocuppied" if free_or_not else "cell_ocuppied"  
	emit_signal(signal_name, Vector2i(current_grid_cell))

func _emit_signal_if_dragging():
	var signal_name = "puf_dragging" if is_dragging else "puf_undragging"  
	emit_signal(signal_name, self)

func _on_ocuppied_cells(_ocuppied_cells):
	ocuppied_cells = _ocuppied_cells

func _on_death_cells(_death_cells):
	death_cells = _death_cells

func _on_mouse_area_mouse_entered():
	is_mouse_top = true
	name_label.text = get_name_of_puf()
	self.position.y += -2
	if is_myself_rich():
		reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_TERROR_PUF)
	else: 
		reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_PICK_ME)
	emit_signal("enter_mouse_above_me", self)

func _on_mouse_area_mouse_exited():
	is_mouse_top = false
	self.position.y += +2
	_disappear_name_label()
	if not is_dragging:
		reproduce_animation_with_queue(DefinitionsHelper.ANIMATION_DROP_PUF)
		reproduce_animation_with_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)
	emit_signal("exit_mouse_above_me", self)

func _on_celebration_all_pufs(type_celebration: String):
	if is_smashed_now:
		return
	var animation_to_play: String = ""
	match type_celebration:
		DefinitionsHelper.TYPE_CELEBRATION_SMASH_PUF:
			if not is_myself_rich(): animation_to_play = DefinitionsHelper.ANIMATION_CELEBRATION_PUF
			else: animation_to_play = DefinitionsHelper.ANIMATION_TERROR_PUF
			await get_tree().create_timer(1).timeout
			reproduce_animation_without_queue(animation_to_play)
	await get_tree().create_timer(wait_time_finish_celebration).timeout
	reproduce_animation_without_queue(DefinitionsHelper.ANIMATION_IDLE_PUF)

func _on_repulsion_area_body_entered(body): ##TODO: Poner un globo de alegria si se acerca un rico, de asco si es un pobre
	if is_myself_rich():
		if not body.is_myself_rich():
			_kockback(body)

func _on_repulsion_area_body_exited(body):
	if is_myself_rich():
		if not body.is_myself_rich():
			#_kockback(body)
			pass

''' Getters del Puf asociado a este CharacterBody2D '''
func get_social_class():
	match(myself.social_class):
		0: return DefinitionsHelper.POOR_SOCIAL_CLASS
		1: return DefinitionsHelper.RICH_SOCIAL_CLASS
		_: return "null"

func is_myself_rich():
	return get_social_class() == DefinitionsHelper.RICH_SOCIAL_CLASS

func get_background() -> String:
	return _get_variable_by_name("background")

func get_name_of_puf() -> String:
	return _get_variable_by_name("name_of_puf")

func get_surname() -> String:
	return _get_variable_by_name("surname")

func get_noble_title() -> String:
	return _get_variable_by_name("noble_title")

func get_profession() -> String:
	return _get_variable_by_name("profession")

func get_place() -> String:
	return _get_variable_by_name("place")

func get_hunger() -> float:
	return _get_variable_by_name("hunger")

func get_thirst() -> float:
	return _get_variable_by_name("thirst")

func get_height() -> float:
	return _get_variable_by_name("height")

func get_birth_year() -> int:
	return _get_variable_by_name("birth_year")

func get_years() -> int:
	return _get_variable_by_name("years")

func get_is_interactive() -> bool:
	return _get_variable_by_name("is_interactive")

func get_constitution() -> Puf.Constitution:
	return _get_variable_by_name("constitution")

func get_mood() -> Puf.Mood:
	return _get_variable_by_name("mood")

func get_health_status() -> Puf.Health_status:
	return _get_variable_by_name("health_status")

func get_ascendant() -> Puf:
	return _get_variable_by_name("ascendant")

func get_descendant() -> Array[Puf]:
	return _get_variable_by_name("descendant")

func get_full_name() -> String:
	return _get_variable_by_name("get_full_name")

func get_percentage_of_thrist() -> String:
	return _get_variable_by_name("get_percentage_of_thrist")

func get_percentage_of_hunger() -> String:
	return _get_variable_by_name("get_percentage_of_hunger")

func get_json_serialize() -> String:
	return _get_variable_by_name("get_json_serialize")

func _get_variable_by_name(name: String):
	match name:
		"background":
			return myself.background
		"name_of_puf":
			return myself.name_of_puf
		"surname":
			return myself.surname
		"noble_title":
			return myself.noble_title
		"profession":
			return myself.profession
		"place":
			return myself.place
		"hunger":
			return myself.hunger
		"thirst":
			return myself.thirst
		"height":
			return myself.height
		"birth_year":
			return myself.birth_year
		"years":
			return myself.years
		"is_interactive":
			return myself.is_interactive
		"constitution":
			return myself.constitution
		"social_class":
			return myself.social_class
		"mood":
			return myself.mood
		"mood":
			return myself.health_status
		"ascendant":
			return myself.ascendant
		"descendant":
			return myself.descendant
		"get_full_name":
			return myself.get_full_name()
		"get_percentage_of_thrist":
			return myself.get_percentage_of_thrist()
		"get_percentage_of_hunger":
			return myself.get_percentage_of_hunger()
		"get_json_serialize":
			return myself.jsonSerialize()		
		_:
			return null
	
