extends Area2D

@export var move_speed: float = 650.0
@export var min_x: float = 80.0
@export var max_x: float = 1072.0

var is_dragging: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		if event.pressed:
			_move_to_screen_x(event.position.x)
	elif event is InputEventScreenDrag:
		_move_to_screen_x(event.position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed
		if event.pressed:
			_move_to_screen_x(event.position.x)
	elif event is InputEventMouseMotion and is_dragging:
		_move_to_screen_x(event.position.x)

func _move_to_screen_x(screen_x: float) -> void:
	var canvas_x := get_canvas_transform().affine_inverse().basis_xform(Vector2(screen_x, 0)).x + get_canvas_transform().affine_inverse().origin.x
	position.x = clampf(canvas_x, min_x, max_x)

func _process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction += 1.0
	direction = clampf(direction, -1.0, 1.0)
	
	if direction != 0.0:
		position.x += direction * move_speed * delta
		position.x = clampf(position.x, min_x, max_x)
