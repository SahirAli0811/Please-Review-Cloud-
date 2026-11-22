extends Control

@onready var scores_list: VBoxContainer = %ScoresList

func _ready() -> void:
	Global.leaderboard_updated.connect(populate_leaderboard)
	populate_leaderboard()
	Global.fetch_online_scores()

func populate_leaderboard() -> void:
	for child in scores_list.get_children():
		child.queue_free()
		
	if Global.leaderboard.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No scores yet! Play a game to set a record."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scores_list.add_child(empty_label)
		return
		
	for i in range(min(Global.leaderboard.size(), 10)):
		var entry = Global.leaderboard[i]
		var row = Label.new()
		row.text = str(i + 1) + ". " + str(entry["name"]) + "  -  " + str(entry["score"])
		row.add_theme_font_size_override("font_size", 22)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scores_list.add_child(row)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/MainMenu.tscn")
