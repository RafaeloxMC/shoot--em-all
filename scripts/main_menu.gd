extends Node3D

@export var player: CharacterBody3D
@export var target_spawner: Area3D
@export var ingame_menu: Node3D

@onready var play: Area3D = $Play
@onready var quit: Area3D = $Quit
@onready var score_label: Label3D = $Label3D
@onready var http_request: HTTPRequest = $HTTPRequest

var is_started = false
var sess_id = ""
var player_name = ""
var is_saving = false
var expecting_session_response = false

signal start()

const host = "https://api.sea.xvcf.dev"

func _handle_http_res(result, response_code, _headers, body):
	print("Res: " + str(result))
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("Body: " + JSON.stringify(json))
	
	if response_code != 200 && response_code != 201:
		return
	
	if json.has("sessionId") && expecting_session_response:
		sess_id = json["sessionId"]
		expecting_session_response = false
		print("Session created: " + sess_id)
	
	elif json.has("playerName") && json.has("message"):
		player_name = json["playerName"]
		is_saving = false
		update_score_display()
		print("Score saved for player: " + player_name)

func handle_ui_action(_hit: bool):
	if player.has_node("Head/Camera3D/RayCast3D"):
		var raycast = player.get_node("Head/Camera3D/RayCast3D") as RayCast3D
		if raycast.is_colliding():
			var coll = raycast.get_collider()
			if coll == null:
				print("No coll")
				return
			if coll.name == play.name:
				print("Starting")
				is_started = true
				start.emit()
				self.hide()
				expecting_session_response = true
				http_request.request(host + "/leaderboard/session", [], HTTPClient.METHOD_POST, "")
				ingame_menu.visible = true
			elif coll.name == quit.name:
				get_tree().quit()

func _ready() -> void:
	player.shot.connect(handle_ui_action)
	target_spawner.done.connect(show_score)
	score_label.hide()
	http_request.request_completed.connect(_handle_http_res)

var current_score: int
var current_accuracy: float

func show_score(score: int, accuracy: float):
	current_score = score
	current_accuracy = accuracy
	is_started = false
	self.visible = true
	score_label.visible = true
	is_saving = true
	update_score_display()
	
	var json = JSON.parse_string("{}")
	json["sessionId"] = sess_id
	json["score"] = score
	json["accuracy"] = accuracy / 100
	print("Submitting score with sessionId: " + sess_id)
	print(JSON.stringify(json))
	http_request.request(host + "/leaderboard", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(json))

func update_score_display():
	var status_text = "Saving..." if is_saving else "Saved!"
	var name_text = "Player: " + (player_name if player_name != "" else "Unknown")
	score_label.text = "Done!\nScore: " + str(current_score) + "\nAccuracy: " + str(current_accuracy) + "%\n" + name_text + "\n" + status_text

func _process(_delta: float) -> void:
	pass
