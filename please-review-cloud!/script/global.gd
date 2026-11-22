extends Node

signal leaderboard_updated

var leaderboard: Array = []
const SAVE_PATH := "user://leaderboard.cfg"

# Optional: Paste your free Dreamlo.com private & public codes here for a shared online leaderboard across all itch.io players!
# Visit https://dreamlo.com -> Get Yours Now -> copy Private Code and Public Code below.
# When left blank, it uses browser local storage (IndexedDB on itch.io HTML5) with built-in starter scores.
@export var dreamlo_private_code: String = ""
@export var dreamlo_public_code: String = ""

var http_submit: HTTPRequest
var http_fetch: HTTPRequest

func _ready() -> void:
	http_submit = HTTPRequest.new()
	add_child(http_submit)
	http_submit.request_completed.connect(_on_submit_completed)
	
	http_fetch = HTTPRequest.new()
	add_child(http_fetch)
	http_fetch.request_completed.connect(_on_fetch_completed)
	
	load_local_scores()
	if dreamlo_public_code != "":
		fetch_online_scores()

func add_score(player_name: String, score: int) -> void:
	var clean_name := player_name.strip_edges()
	if clean_name == "":
		clean_name = "Anonymous"
	# Sanitize characters for URL safety
	clean_name = clean_name.replace("/", "_").replace("|", "_").replace("*", "_")
	
	# Save locally immediately so it never gets lost
	leaderboard.append({"name": clean_name, "score": score})
	leaderboard.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	save_local_scores()
	leaderboard_updated.emit()
	
	# Submit to global online leaderboard if configured
	if dreamlo_private_code != "":
		var url := "https://www.dreamlo.com/lb/%s/add/%s/%d" % [dreamlo_private_code, clean_name.uri_encode(), score]
		http_submit.request(url)

func fetch_online_scores() -> void:
	if dreamlo_public_code == "":
		return
	var url := "https://www.dreamlo.com/lb/%s/json" % dreamlo_public_code
	http_fetch.request(url)

func _on_submit_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code == 200:
		fetch_online_scores()

func _on_fetch_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return
	var json_text := body.get_string_from_utf8()
	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("dreamlo"):
		var lb = parsed["dreamlo"].get("leaderboard", null)
		if lb != null and lb.has("entry"):
			var entries = lb["entry"]
			var online_list: Array = []
			if typeof(entries) == TYPE_ARRAY:
				for item in entries:
					online_list.append({
						"name": str(item.get("name", "Player")),
						"score": int(item.get("score", 0))
					})
			elif typeof(entries) == TYPE_DICTIONARY:
				online_list.append({
					"name": str(entries.get("name", "Player")),
					"score": int(entries.get("score", 0))
				})
			if not online_list.is_empty():
				online_list.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
				leaderboard = online_list
				save_local_scores()
				leaderboard_updated.emit()

func save_local_scores() -> void:
	var config = ConfigFile.new()
	config.set_value("Scores", "list", leaderboard)
	config.save(SAVE_PATH)

func load_local_scores() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		leaderboard = config.get_value("Scores", "list", [])
