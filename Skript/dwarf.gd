extends Node3D

class_name dwarf

var dwarf_name : String
var held_tool
var workplace

var parent_player

var is_tool_connected := false

func _ready() -> void:
	
	parent_player = get_parent() as player
	
	dwarf_name = "Muradin"
	held_tool = null
	workplace = null


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if(event.is_action_pressed("left_mouse_click")):
		print("I'm ", self,", work here: ", workplace, ", hold this tool: ", held_tool)

func change_workplace(new_workplace):
	workplace = new_workplace
	
	if workplace:
		find_tool_for_work()
	else:
		drop_held_tool()
	

func find_tool_for_work():
	var required_tool = workplace.get_required_tool()
	
	if parent_player.idle_tools:
		for tool in parent_player.idle_tools:
			if tool.is_in_group(required_tool):
				if held_tool:
					if sorting_algorithm(tool, held_tool):
						held_tool = tool
				else :
					held_tool = tool
		
		parent_player.remove_tool_from_tree(held_tool)
		add_child(held_tool)
		held_tool.position = Vector3(0, 0.75, 0)
	else:
		if not is_tool_connected:
			parent_player.idle_tool_spawned.connect(waiting_for_tool)
			is_tool_connected = true

func drop_held_tool():
	
	if is_tool_connected:
		parent_player.idle_tool_spawned.disconnect(waiting_for_tool)
		is_tool_connected = false
	remove_child(held_tool)
	parent_player.dropped_tool(held_tool)
	held_tool = null

func waiting_for_tool():
	find_tool_for_work()

func sorting_algorithm(a, b):
	if(a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)):
		return true
	return false
