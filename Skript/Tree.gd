extends Node3D

class_name tree

@onready var sprout_mesh = $sprout_mesh
@onready var young_mesh = $young_mesh
@onready var grown_mesh = $grown_mesh

@onready var sprout_collision = $Area3D/sprout_collision
@onready var young_collision = $Area3D/young_collision
@onready var grown_collision = $Area3D/grown_collision

@onready var grow_timer = $Timer

var tree_stage : String

var tree_height : int

var grid_normals = [Vector2(0,0)]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_tree()
	global_position = GridManager.snap_to_grid(global_position,1,1,tree_height)
	GridManager.check_for_occupied_tiles(global_position,grid_normals)


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if(event.is_action_pressed("left_mouse_click")):
		print("I'm a ",tree_stage, " tree")

func create_grown_tree():
	tree_stage = "grown"
	young_mesh.visible = false
	sprout_mesh.visible = false
	young_collision.disabled = true
	sprout_collision.disabled = true
	tree_height = 3

func create_young_tree():
	tree_stage = "young"
	grown_mesh.visible = false
	sprout_mesh.visible = false
	grown_collision.disabled = true
	sprout_collision.disabled = true
	tree_height = 2

func create_sprout_tree():
	tree_stage = "sprout"
	young_mesh.visible = false
	grown_mesh.visible = false
	young_collision.disabled = true
	grown_collision.disabled = true
	tree_height = 1

func generate_tree():
	var random_number = rng.randi_range(1,3)
	match random_number:
		1:
			create_grown_tree()
		2:
			create_young_tree()
		3:
			create_sprout_tree()


func _on_timer_timeout() -> void:
	match tree_stage:
		"sprout" :
			sprout_mesh.visible = false
			sprout_collision.disabled = true
			young_mesh.visible = true
			young_collision.disabled = false
			tree_stage = "young"
			global_position.y += 0.5
			tree_height = 2
		"young" :
			young_mesh.visible = false
			young_collision.disabled = true
			grown_mesh.visible = true
			grown_collision.disabled = false
			tree_stage = "grown"
			global_position.y += 0.5
			tree_height = 3
		"grown" :
			grow_timer.queue_free()
