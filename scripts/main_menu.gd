extends Node3D

@export var player: CharacterBody3D
@export var target_spawner: Area3D
@onready var play: Area3D = $Play
@onready var quit: Area3D = $Quit
@onready var score_label: Label3D = $Label3D

var is_started = false

signal start()

func handle_ui_action(_hit: bool):
	if player.has_node("Head/Camera3D/RayCast3D"):
		var raycast = player.get_node("Head/Camera3D/RayCast3D") as RayCast3D
		if raycast.is_colliding():
			var coll = raycast.get_collider()
			if coll == null:
				return
			if coll.name == play.name:
				is_started = true
				start.emit()
				self.hide()
			elif coll.name == quit.name:
				get_tree().quit()
				
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.shot.connect(handle_ui_action)
	target_spawner.done.connect(show_score)
	score_label.hide()
	pass # Replace with function body.

func show_score(score: int, accuracy: float):
	score_label.text = "Done!\nScore: " + str(score) + "\nAccuracy: " + str(accuracy) + "%"
	is_started = false
	self.visible = true
	score_label.visible = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
