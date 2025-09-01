extends Node


signal world_right_clicked(position: Vector3, building: Node)
signal world_left_clicked()
signal building_deselected(building: Node)

var current_selected_building: Node = null

func set_selected_building(building: Node):
	if current_selected_building:
		building_deselected.emit(current_selected_building)
		print("deselected buiilding: ", current_selected_building)
		
	current_selected_building = building
	print("selected building: ", building)

func get_current_selected_building() -> Node:
	return current_selected_building

func clear_current_selected_building() -> void:
	current_selected_building = null
