extends Area3D

@export var target: PackedScene
@export var main_menu: Node3D
@export var player: CharacterBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var timer: Timer = $Timer
@onready var label_3d: Label3D = $Label3D

var x_size
var y_size
var z_size

var enabled = false

var last_placed_target: float
var time_for_each: float = 1

var score = 0
var accuracy = 0
var shots = 0

signal done(score: int, accuracy: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.start.connect(set_enabled)
	player.shot.connect(calculate_accuracy)
	var shape = collision_shape_3d.shape as BoxShape3D
	if shape:
		x_size = shape.size.x * 4
		y_size = shape.size.y * 2
		z_size = shape.size.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if enabled == false:
		return
	label_3d.text = str(floor(timer.time_left * 100) / 100)
	if last_placed_target + time_for_each < Time.get_unix_time_from_system():
		if self.has_node("Target"):
			self.get_node("Target").free()
			print("Didn't hit target on time")
	if not self.has_node("Target"):
		var node = target.instantiate()
		self.add_child(node)
		
		var random_x = randf_range(-x_size/2, x_size/2)
		var random_y = randf_range(-y_size/2, y_size/2)
		var random_z = randf_range(-z_size/2, z_size/2)
		node.position = Vector3(random_x, random_y, random_z)
		last_placed_target = Time.get_unix_time_from_system()

func set_enabled():
	shots = 0
	score = 0
	accuracy = 0
	label_3d.visible = true
	enabled = true
	timer.start()
	
func calculate_accuracy(hit: bool):
	shots += 1
	if hit:
		score += 1
	
	accuracy = (float(score) / float(shots)) * 100.0
	print("Shots: " + str(shots))
	print("Score: " + str(score))
	print("Accuracy: " + str(accuracy) + "%")

	
func _on_timer_timeout() -> void:
	if self.has_node("Target"):
		self.get_node("Target").free()
	label_3d.hide()
	enabled = false
	done.emit(score, floor(accuracy * 100) / 100)
