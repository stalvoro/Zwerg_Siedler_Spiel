extends Control

var parent_lumberHut

@onready var sproutToggle = $PanelContainer/MarginContainer/VBoxContainer/PrioritySelect/SproutButton
@onready var youngToggle = $PanelContainer/MarginContainer/VBoxContainer/PrioritySelect/YoungTreeButton
@onready var grownToggle = $PanelContainer/MarginContainer/VBoxContainer/PrioritySelect/GrownTreeButton
@onready var stopWork = $PanelContainer/MarginContainer/VBoxContainer/WorkSettingsSelect/StopWork

var _is_world_right_click_connected := false
var _is_world_left_click_connected := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_lumberHut = get_parent() as lumberjack_hut
	sproutToggle.set_pressed_no_signal(parent_lumberHut.prioritySprout)
	youngToggle.set_pressed_no_signal(parent_lumberHut.priorityYoung)
	grownToggle.set_pressed_no_signal(parent_lumberHut.priorityGrown)
	stopWork.set_pressed_no_signal(parent_lumberHut.stopWork)
	
	parent_lumberHut.harvesting_mesh.visible = true
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_close_lumber_hut_ui_pressed() -> void:
	destroy()

func _on_assign_work_area_pressed() -> void:
	_connect_world_left_click()
	_connect_world_right_click()
	
	visible = false

func _connect_world_left_click() -> void:
	if not _is_world_left_click_connected:
		EventBus.world_left_clicked.connect(_cancel_workplace_placement)
		_is_world_left_click_connected = true

func _disconnect_world_left_click() -> void:
	if _is_world_left_click_connected:
		EventBus.world_left_clicked.disconnect(_cancel_workplace_placement)
		_is_world_left_click_connected = false

func _connect_world_right_click() -> void:
	if not _is_world_right_click_connected:
		EventBus.world_right_clicked.connect(_assign_work_area)
		_is_world_right_click_connected = true

func _disconnect_world_right_click() -> void:
	if _is_world_right_click_connected:
		EventBus.world_right_clicked.disconnect(_assign_work_area)
		_is_world_right_click_connected = false

func _cancel_workplace_placement() -> void:
	_disconnect_world_left_click()
	_disconnect_world_right_click()
	
	visible = true

func _assign_work_area(position: Vector3):
	_disconnect_world_left_click()
	_disconnect_world_right_click()
	
	parent_lumberHut.place_work_area(position)

func destroy():
	_disconnect_world_right_click()
	_disconnect_world_left_click()
	parent_lumberHut.harvesting_mesh.visible = false
	queue_free()

func _on_sprout_button_toggled(toggled_on: bool) -> void:
	compute_priority_select_buttons("sprout", toggled_on)

func _on_young_tree_button_toggled(toggled_on: bool) -> void:
	compute_priority_select_buttons("young", toggled_on)

func _on_grown_tree_button_toggled(toggled_on: bool) -> void:
	compute_priority_select_buttons("grown", toggled_on)

func compute_priority_select_buttons(tree_state, true_false):
	parent_lumberHut.set_priority(tree_state, true_false)

func _on_stop_work_toggled(toggled_on: bool) -> void:
	parent_lumberHut.toggle_work(toggled_on)

func _on_demolish_building_pressed() -> void:
	parent_lumberHut.delete_object()
