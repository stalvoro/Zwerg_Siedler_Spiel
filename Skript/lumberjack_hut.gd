extends Node3D
class_name lumberjack_hut

var lumberHutUI = preload("res://Szenen/lumberjack_hut_ui.tscn")

@onready var harvesting_area : Area3D = $HarvestingArea
@onready var harvesting_mesh : MeshInstance3D = $HarvestingArea/HarvestingMesh

var _is_event_bus_connected := false
var _is_employment_connected := false

var parent_player

var grid_normals = [Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
Vector2(-1,0), Vector2(0,0), Vector2(1,0),
Vector2(-1,1), Vector2(0,1), Vector2(1,1)]

var mesh_width : int = 3
var mesh_height : int = 3
var mesh_length : int = 3

var required_tool = "axe"

var prioritySprout : bool 
var priorityYoung : bool 
var priorityGrown : bool 

var stopWork : bool

var lumberHutUIInst

var next_tree
var all_trees = []

var working_dwarf

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prioritySprout = true
	priorityYoung = true
	priorityGrown = true
	stopWork = false
	
	harvesting_mesh.visible = false
	
	parent_player = get_parent() as player
	
	if not _is_event_bus_connected:
		EventBus.building_deselected.connect(_on_building_deselected)
		_is_event_bus_connected = true
	
	employ_closest_idle_dwarf()

func get_required_tool():
	return required_tool

func employ_closest_idle_dwarf():
	if parent_player.idle_dwarves:
		for x in parent_player.idle_dwarves:
			if working_dwarf:
				if sorting_algorithm(x, working_dwarf):
					working_dwarf = x
			else:
				working_dwarf = x
		
		if _is_employment_connected:
			parent_player.idle_dwarf_spawned.disconnect(employ_closest_idle_dwarf)
			_is_employment_connected = false
		
		parent_player.idle_dwarves.erase(working_dwarf)
		working_dwarf.change_workplace(self)
		
	else:
		if not _is_employment_connected:
			parent_player.idle_dwarf_spawned.connect(employ_closest_idle_dwarf)
			_is_employment_connected = true
	print("empolyed dwarf: ", working_dwarf)

func fire_dwarf():
	if _is_employment_connected:
		parent_player.idle_dwarf_spawned.disconnect(employ_closest_idle_dwarf)
		_is_employment_connected = false
		
	if working_dwarf:
		working_dwarf.change_workplace(null)
		print("fired dwarf: ", working_dwarf)
		parent_player.append_dwarf_into_array(working_dwarf)
		working_dwarf = null


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if(event.is_action_pressed("left_mouse_click")):
		print("I'm a Lumberjack hut. I currently stand here: ", event_position)
		
		
		EventBus.set_selected_building(self)
		
		lumberHutUIInst = lumberHutUI.instantiate()
		add_child(lumberHutUIInst)
		
		print(all_trees)
		print("My next tree: ", next_tree)

func toggle_work(on):
	if !on:
		employ_closest_idle_dwarf()
		stopWork = false
	else:
		fire_dwarf()
		stopWork = true

func _on_building_deselected(building):
	if building == self and lumberHutUIInst:
		lumberHutUIInst.destroy()

func place_work_area(position: Vector3):
	harvesting_area.global_position = position
	lumberHutUIInst.visible = true

func select_next_tree():
	if all_trees:
		for x in all_trees :
			if(x.tree_stage == "grown" && priorityGrown):
				next_tree = x
				break
			elif (x.tree_stage == "young" && priorityYoung):
				next_tree = x
				break
			elif (x.tree_stage == "sprout" && prioritySprout):
				next_tree = x
				break
			else :
				next_tree = null
	else:
		next_tree = null

func sort_trees_in_array():
	all_trees.sort_custom(sorting_algorithm)

func sorting_algorithm(a, b):
	if(a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)):
		return true
	return false

func _on_harvesting_area_area_entered(area: Area3D) -> void:
	var my_tree = area.get_parent_node_3d() as tree
	all_trees.append(my_tree)
	sort_trees_in_array()
	select_next_tree()

func _on_harvesting_area_area_exited(area: Area3D) -> void:
	var my_tree = area.get_parent_node_3d() as tree
	all_trees.erase(my_tree)
	print("Erased tree from array: ", my_tree)
	select_next_tree()

func set_priority(tree_type, on_off):
	match tree_type:
		"grown" : 
			priorityGrown = on_off
		"young" :
			priorityYoung = on_off
		"sprout" :
			prioritySprout = on_off
	select_next_tree()

func delete_object():
	fire_dwarf()
	if _is_event_bus_connected:
		EventBus.building_deselected.disconnect(_on_building_deselected)
	
	GridManager.erase_occupied_tiles(global_position, grid_normals)
	
	queue_free()
