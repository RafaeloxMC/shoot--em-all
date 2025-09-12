extends Node3D

@export var player: CharacterBody3D
@export var target_spawner: Area3D
@onready var exit: Area3D = $Exit
@onready var quit: Area3D = $Quit



func handle_ui_action():
	if player.has_node("Head/Camera3D/RayCast3D"):
		var raycast = player.get_node("Head/Camera3D/RayCast3D") as RayCast3D
		if raycast.is_colliding():
			var coll = raycast.get_collider()
			if coll == null:
				return
			if coll.name == exit.name:
				target_spawner.quit()
				self.hide()
			elif coll.name == quit.name:
				get_tree().quit()
				
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.menu_shot.connect(handle_ui_action)
	pass # Replace with function body.
