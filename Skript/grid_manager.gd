extends Node

var occupied_tiles = {} # Vector2 -> bool

func snap_to_grid(position: Vector3, building_width: int, building_length: int, building_height: float) -> Vector3:
	
	var snapped_position = position
	
	if building_width % 2 == 0:
		snapped_position.x = round(position.x)
	else :
		snapped_position.x = floor(position.x) + 0.5
	
	if building_length % 2 == 0:
		snapped_position.z = round(position.z)
	else :
		snapped_position.z = floor(position.z) + 0.5
	
	snapped_position.y = building_height/2
	
	return snapped_position

func is_tile_occupied(x, y) -> bool:
	return occupied_tiles.has(Vector2(x, y))

func set_tile_occupied(x, y, occupied):
	if occupied:
		occupied_tiles[Vector2(x, y)] = true
	else:
		occupied_tiles.erase(Vector2(x, y))

func snap_to_grid_coordinate(value: float) -> int:
	return int(round(value))

func check_for_occupied_tiles(position: Vector3, grid_normals) -> bool: 
	var is_collision = false
	var reserve_tiles = []
	
	var tmp_x : int = 0
	var tmp_z : int = 0
	
	for i in grid_normals:
		tmp_x = snap_to_grid_coordinate(position.x + i.x)
		tmp_z = snap_to_grid_coordinate(position.z + i.y)
		if is_tile_occupied(tmp_x, tmp_z):
			print("tile occupied at: ", tmp_x, " ", tmp_z)
			is_collision = true
		else:
			reserve_tiles.append(Vector2(tmp_x, tmp_z))
	
	if not is_collision:
		for i in reserve_tiles:
			set_tile_occupied(i.x, i.y, true)
	
	return is_collision

func erase_occupied_tiles(position: Vector3, grid_normals):
	var tmp_x : int = 0
	var tmp_z : int = 0
	
	for i in grid_normals:
		tmp_x = snap_to_grid_coordinate(position.x + i.x)
		tmp_z = snap_to_grid_coordinate(position.z + i.y)
		set_tile_occupied(tmp_x, tmp_z, false)
		print("erased tile: ", tmp_x, ", ", tmp_z)
