extends Node3D
class_name GameCamera

@export var rotate_speed: float = 0.3
@export var zoom_speed: float = 1.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 20.0

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	# --- Rotate when holding Right Mouse Button ---
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotation_y -= event.relative.x * rotate_speed * 0.01
		rotation_x -= event.relative.y * rotate_speed * 0.01
		rotation_x = clamp(rotation_x, -1.2, 1.2)  # limit vertical angle

	# --- Zoom when scrolling WHILE right-click is held ---
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(zoom_speed)

func _process(_delta: float) -> void:
	rotation_degrees = Vector3(rad_to_deg(rotation_x), rad_to_deg(rotation_y), 0.0)

func _zoom_camera(amount: float) -> void:
	var cam: Camera3D = $Camera3D
	var forward: Vector3 = -cam.transform.basis.z.normalized()
	var new_pos: Vector3 = cam.position + forward * amount
	var distance: float = new_pos.length()

	if distance >= min_zoom and distance <= max_zoom:
		cam.position = new_pos
