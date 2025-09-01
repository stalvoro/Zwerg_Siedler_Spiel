extends Node3D

class_name player

signal idle_dwarf_spawned()
signal idle_tool_spawned()

var build_tab_ui = preload("res://Szenen/build_tab_ui.tscn")
var build_tab_ui_inst

var lumberjackHut = preload("res://Szenen/lumberjack_hut.tscn")
var dwarf_scene = preload("res://Szenen/dwarf.tscn")
var axe_scene = preload("res://Szenen/axe.tscn")

@onready var traced_mesh_instance = $HighlightMesh
@onready var traced_mesh_collision = $HighlightMesh/Area3D/CollisionShape3D

var traced_mesh_width : int = 0
var traced_mesh_length : int = 0
var traced_mesh_height : int = 0

# size of TownHall mesh needs adjustment on change
var mesh_width : float = 4
var mesh_length : float = 4
var mesh_height : float = 4

var grid_normals = [Vector2(-1.5,-1.5), Vector2(-0.5,-1.5),Vector2(0.5,-1.5),Vector2(1.5,-1.5),
Vector2(-1.5,-0.5), Vector2(-0.5,-0.5),Vector2(0.5,-0.5),Vector2(1.5,-0.5),
Vector2(-1.5,0.5), Vector2(-0.5,0.5),Vector2(0.5,0.5),Vector2(1.5,0.5),
Vector2(-1.5,1.5), Vector2(-0.5,1.5),Vector2(0.5,1.5),Vector2(1.5,1.5)]

var idle_dwarves = []
var idle_tools = []

var _is_building_deselect_connected := false

var blocked_counter : int = 0

var building_tracer := false
var main_camera : Camera3D
var space_state : PhysicsDirectSpaceState3D
var tmp := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	
	traced_mesh_collision.disabled = true
	
	main_camera = get_viewport().get_camera_3d()
	traced_mesh_instance.visible = false
	
	if not _is_building_deselect_connected:
		EventBus.building_deselected.connect(_on_building_deselected)
		_is_building_deselect_connected = true
	
	@warning_ignore("narrowing_conversion")
	global_position = GridManager.snap_to_grid(global_position,mesh_width,mesh_length,mesh_height)
	GridManager.check_for_occupied_tiles(global_position,grid_normals)
	
	spawn_dwarf()
	spawn_axe()

func _process(delta: float) -> void:
	if building_tracer:
		var mouse_position = get_global_mouse_position_3d()
		#print(mouse_position)
		if mouse_position:
			traced_mesh_instance.global_position = GridManager.snap_to_grid(mouse_position,traced_mesh_width,traced_mesh_length, traced_mesh_height)

func get_global_mouse_position_3d() -> Vector3:
	if not main_camera:
		print("no cam")
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position() 
	space_state = get_world_3d().direct_space_state
	
	var from = main_camera.project_ray_origin(mouse_pos)
	var to = from + main_camera.project_ray_normal(mouse_pos) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	query.collision_mask = 1
	query.exclude = []
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		var distance = -from.y / (to - from).normalized().y
		return from + (to - from).normalized() * distance

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if(event.is_action_pressed("left_mouse_click")):
		
		EventBus.set_selected_building(self)
		
		build_tab_ui_inst = build_tab_ui.instantiate()
		add_child(build_tab_ui_inst)
		
		print(idle_dwarves)
		print(idle_tools)

func remove_tool_from_tree(tool):
	idle_tools.erase(tool)
	remove_child(tool)

func spawn_axe():
	var new_axe = axe_scene.instantiate()
	add_child(new_axe)
	new_axe.position = Vector3(0,-1.75,2.5)
	append_tool_into_array(new_axe)

func append_tool_into_array(new_tool):
	idle_tools.append(new_tool)
	idle_tool_spawned.emit()

func spawn_dwarf():
	var new_dwarf = dwarf_scene.instantiate() as dwarf
	add_child(new_dwarf)
	new_dwarf.global_position = Vector3(0,0.5,0)
	append_dwarf_into_array(new_dwarf)

func append_dwarf_into_array(new_dwarf):
	idle_dwarves.append(new_dwarf)
	idle_dwarf_spawned.emit()

func _on_building_deselected(building):
	if building == self:
		build_tab_ui_inst.destroy()

@warning_ignore("shadowed_variable_base_class")
func place_building(position: Vector3, building: String):
	
	set_process(false)
	
	var building_mesh_width : int = 0
	var building_mesh_length : int = 0
	var building_mesh_height : int = 0
	
	var new_building
	
	match building:
		"lumberjackHut":
			new_building = lumberjackHut.instantiate() as lumberjack_hut
			building_mesh_width = new_building.mesh_width
			building_mesh_length = new_building.mesh_length
			building_mesh_height = new_building.mesh_height
			
	
	var new_position : Vector3 = GridManager.snap_to_grid(position, building_mesh_width, building_mesh_length, building_mesh_height)
	if not GridManager.check_for_occupied_tiles(new_position, new_building.grid_normals):
		add_child(new_building)
		new_building.global_position = new_position
	
	build_tab_ui_inst.visible = true
	build_tab_ui_inst.selected_building = false

func dropped_tool(tool):
	idle_tools.append(tool)
	add_child(tool)
	tool.position = Vector3(0,-1.75,2.5)

func delete_player():
	if _is_building_deselect_connected:
		EventBus.building_deselected.disconnect(_on_building_deselected)
		_is_building_deselect_connected = false
	
	queue_free()

func trace_building_placement(building_mesh_width : int, building_mesh_length : int, building_mesh_height : int):
	
	traced_mesh_width = building_mesh_width
	traced_mesh_length = building_mesh_length
	traced_mesh_height = building_mesh_height
	
	traced_mesh_instance.mesh.size.x = building_mesh_width
	traced_mesh_instance.mesh.size.y = building_mesh_length
	traced_mesh_instance.mesh.size.z = building_mesh_height
	
	traced_mesh_collision.shape.size = Vector3(building_mesh_width-0.1, building_mesh_length-0.1, building_mesh_height-0.1)
	traced_mesh_collision.disabled = false
	traced_mesh_instance.visible = true
	
	building_tracer = true
	set_process(true)

func cancel_building_tracer():
	traced_mesh_instance.visible = false
	building_tracer = false
	traced_mesh_collision.disabled = true
	set_process(false)

func _change_higlight_mesh_color(blocked):
	if blocked:
		blocked_counter += 1
	else:
		blocked_counter -= 1
	
	if blocked_counter == 0:
		traced_mesh_instance.mesh.material.albedo_color = Color(0.282, 0.91, 0.294, 0.192)
	else:
		traced_mesh_instance.mesh.material.albedo_color = Color(0.842, 0.106, 0.261, 0.192)


func _on_area_3d_area_entered(area: Area3D) -> void:
	_change_higlight_mesh_color(true)


func _on_area_3d_area_exited(area: Area3D) -> void:
	_change_higlight_mesh_color(false)
