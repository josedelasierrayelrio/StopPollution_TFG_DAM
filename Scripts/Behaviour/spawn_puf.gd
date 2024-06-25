class_name SpawnPufs
extends Node3D

## Cantidad de pufs a spawnear
@export_range(1, 20, 1) var spawn_limit: int = 2
## Tiempo entre spawn y spawn
@export_range(1, 20, 1) var spawn_time: int = 1

var spawned_pufs: Array = []
var can_spawn: bool = true

@onready var parent = get_parent()
@onready var stage_scene: PackedScene = preload(PathsHelper.PATH_SCENARIO)
@onready var puf_scene = preload(PathsHelper.PATH_PUF)
@onready var spawn_counter = $SpawnCounter

func _ready():
	spawn_counter.wait_time = spawn_time
	spawn_counter.start()

func _process(delta):
	if can_spawn:
		if spawned_pufs.size() == spawn_limit:
			can_spawn = false
			spawn_counter.stop()

func _on_spawn_pufs():
	if spawn_counter.wait_time == spawn_time:
			if can_spawn:
				var new_puf_node = puf_scene.instantiate()
				spawned_pufs.push_back(new_puf_node)
				add_child(new_puf_node)
