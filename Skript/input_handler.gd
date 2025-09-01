extends Node

@onready var main_camera = $"../Camera3D"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_click"):
		EventBus.world_left_clicked.emit()
	
	if event.is_action_pressed("right_mouse_click"):
		var mouse_pos = _get_global_mouse_position_3d()
		if mouse_pos:
			EventBus.world_right_clicked.emit(mouse_pos)

func _get_global_mouse_position_3d() -> Vector3:
	if not main_camera:
		print("no cam")
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position() 
	var space_state = get_viewport().get_world_3d().direct_space_state
	
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
