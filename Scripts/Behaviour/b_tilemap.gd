extends TileMap

signal spawn_coordinates(spawn_coordinates)
signal death_coordinates(death_coordinates)
signal wall_coordinates(wall_coordinates)
signal ocuppied_coordinates(ocuppied_coordinates)

var astar_grid = AStarGrid2D.new():
	get: 
		return astar_grid
var map_rect = Rect2i()
var tile_size: Vector2i = get_tileset().tile_size
var tilemap_size: Vector2i = get_used_rect().end - get_used_rect().position
var ocuppied_cells : Array[Vector2i]
var wall_cells: Array[Vector2i] = []
var spawn_cells: Array[Vector2i] = []
var death_cells: Array[Vector2i] = []

@onready var path: TileMap = $Path

func _ready():
	map_rect = Rect2i(Vector2i(), tilemap_size)
	astar_grid.region = map_rect
	astar_grid.cell_size = tile_size
	astar_grid.offset = tile_size * 0.5
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	
	# Recorremos cada capa en busca de celdas que no sean transitables y luego las seteamos como tal
	
	for i in range(astar_grid.size.x):
		for j in range(astar_grid.size.y):
			var coordinates: Vector2i = Vector2i(i, j)
			for h in self.get_layers_count(): # Recorre cada capa
				var tile_data = self.get_cell_tile_data(h, coordinates)
				if tile_data:
					var cell_point_solid: bool = false
					if self.get_cell_source_id(h, coordinates) >= 0:
						if (tile_data.get_custom_data(DefinitionsHelper.TILEMAP_LAYER_TYPE_WALL) == true):
							cell_point_solid = true
							wall_cells.append(coordinates)
						if (tile_data.get_custom_data(DefinitionsHelper.TILEMAP_LAYER_TYPE_SPAWN) == true):
							cell_point_solid = false
							spawn_cells.append(coordinates)
						if (tile_data.get_custom_data(DefinitionsHelper.TILEMAP_LAYER_TYPE_DEATH) == true):
							cell_point_solid = false
							death_cells.append(coordinates)
						astar_grid.set_point_solid(coordinates, cell_point_solid)
					else: 
						if h == 3:
							self.set_cell(h, coordinates, 0) 
	spawn_cells = get_cells_between(spawn_cells[0], spawn_cells[1]) 

		# self.set_cell(0,coor_wall,30) # Muestra los espacios intransitables
	emit_signal("spawn_coordinates", spawn_cells)
	emit_signal("death_coordinates", death_cells)
	emit_signal("wall_coordinates", wall_cells)

func is_point_death_cells(map_position) -> bool:
	return death_cells.has(map_position)

func is_point_wall_cells(map_position) -> bool:
	return wall_cells.has(map_position)

func is_point_walkable_map_local_position(map_position) -> bool:
	if map_rect.has_point(map_position):
		return not astar_grid.is_point_solid(map_position)
	return false

func is_point_walkable_global_position(local_position) -> bool:
	var map_position = local_to_map(local_position)
	if map_rect.has_point(map_position):
		return not astar_grid.is_point_solid(map_position)
	return false

func get_current_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	return astar_grid.get_id_path(from, to)

func get_cells_between(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	var x1 = min(start.x, end.x)
	var y1 = min(start.y, end.y)
	var x2 = max(start.x, end.x)
	var y2 = max(start.y, end.y)

	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			coordinates.append(Vector2i(x, y))

	return coordinates

func get_id_path_without_wall(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
		return astar_grid.get_id_path(
			local_to_map(start),
			local_to_map(end)
		).slice(1)

func find_path(start: Vector2i, goal: Vector2i) -> void:
	path.clear()
	var start_cell = local_to_map(start)
	var end_cell = local_to_map(goal)
	
	if start_cell == end_cell or !astar_grid.is_in_boundsv(start_cell) or !astar_grid.is_in_boundsv(end_cell):
		return

	var id_path = astar_grid.get_id_path(start_cell, end_cell)
	for id in id_path:
		path.set_cell(0, id, 1, Vector2(0, 0))

func _on_manager_pufs_born_puf(puf):
	puf.connect("cell_ocuppied", Callable(self, "_on_cell_ocuppied"))
	puf.connect("cell_ocuppied", Callable(self, "_on_cell_unocuppied"))

func _on_cell_ocuppied(cell: Vector2i):
	ocuppied_cells.append(cell)
	emit_signal("ocuppied_coordinates", ocuppied_coordinates)

func _on_cell_unocuppied(cell: Vector2i):
	if ocuppied_cells:
		if ocuppied_cells.has(cell):
			ocuppied_cells.erase(cell)
			emit_signal("ocuppied_coordinates", ocuppied_coordinates)
