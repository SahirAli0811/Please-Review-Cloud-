extends Node2D

@export var fall_char_scene: PackedScene = preload("res://scene/Cloud_Player.tscn")

var base_spawn_interval: float = 1.8
var min_spawn_interval: float = 0.45
var base_fall_speed: float = 260.0
var speed_increase_per_point: float = 14.0

var min_x: float = 60.0
var max_x: float = 1092.0
var spawn_y: float = -50.0

var score: int = 0
var is_game_over: bool = false

@onready var score_label: Label = $Score
@onready var spawn_timer: Timer = $SpawnTimer
@onready var game_over_ui: CanvasLayer = $GameOverUI
@onready var final_score_label: Label = %FinalScoreLabel
@onready var name_input: LineEdit = %NameInput

func _ready() -> void:
	game_over_ui.visible = false
	score_label.text = "Score: 0"
	
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.start()

func _spawn_cloud() -> void:
	var new_char = fall_char_scene.instantiate()
	new_char.position = Vector2(randf_range(min_x, max_x), spawn_y)
	new_char.fall_speed = base_fall_speed + (score * speed_increase_per_point)
	add_child(new_char)

func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return
		
	_spawn_cloud()
	
	if score >= 10 and randf() < minf(0.15 + (score - 10) * 0.02, 0.65):
		_spawn_cloud()
	
	var next_interval := maxf(min_spawn_interval, base_spawn_interval - (score * 0.06))
	spawn_timer.wait_time = next_interval

func _on_basket_area_entered(area: Area2D) -> void:
	if is_game_over:
		return
		
	if area.is_in_group("falling"):
		score += 1
		score_label.text = "Score: " + str(score)
		area.queue_free()

func _on_lava_area_entered(area: Area2D) -> void:
	if is_game_over:
		return
		
	if area.is_in_group("falling"):
		area.queue_free()
		trigger_game_over()

func trigger_game_over() -> void:
	is_game_over = true
	spawn_timer.stop()
	
	get_tree().call_group("falling", "queue_free")
	
	final_score_label.text = "Final Score: " + str(score)
	game_over_ui.visible = true
	name_input.grab_focus()

func _on_submit_button_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name == "":
		player_name = "Anonymous"
		
	Global.add_score(player_name, score)
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")
