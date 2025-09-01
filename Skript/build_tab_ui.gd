extends Control

var parent_player

var selected_building

var _is_world_right_click_connected := false
var _is_world_left_click_connected := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_player = get_parent() as player
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func destroy():
	
	_disconnect_world_left_click()
	_disconnect_world_right_click()
	
	queue_free()

func _on_exit_button_pressed() -> void:
	EventBus.clear_current_selected_building()
	destroy()


func _on_lumber_hut_button_pressed() -> void:
	selected_building = "lumberjackHut"
	visible = false
	
	_connect_world_left_click()
	_connect_world_right_click()
	
	parent_player.trace_building_placement(3,3,3)

func _cancel_building_placement() -> void:
	
	_disconnect_world_left_click()
	_disconnect_world_right_click()
	
	parent_player.cancel_building_tracer()
	
	selected_building = null
	visible = true

@warning_ignore("shadowed_variable_base_class")
func _place_building(position: Vector3):
	if selected_building:
		
		_disconnect_world_left_click()
		_disconnect_world_right_click()
		
		parent_player.cancel_building_tracer()
		parent_player.place_building(position, selected_building)

func _connect_world_right_click() -> void:
	if not _is_world_right_click_connected:
		EventBus.world_right_clicked.connect(_place_building)
		_is_world_right_click_connected = true

func _disconnect_world_right_click() -> void:
	if _is_world_right_click_connected:
			EventBus.world_right_clicked.disconnect(_place_building)
			_is_world_right_click_connected = false

func _connect_world_left_click() -> void:
	if not _is_world_left_click_connected:
		EventBus.world_left_clicked.connect(_cancel_building_placement)
		_is_world_left_click_connected = true

func _disconnect_world_left_click() -> void:
	if _is_world_left_click_connected:
			EventBus.world_left_clicked.disconnect(_cancel_building_placement)
			_is_world_left_click_connected = false
