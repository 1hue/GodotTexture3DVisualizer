extends Node3D

const PerlinNoise: NoiseTexture3D = preload("res://resources/perlin_noise_texture_3d.tres")
const SimplexNoise: NoiseTexture3D = preload("res://resources/simplex_noise_texture_3d.tres")
const CellularNoise: NoiseTexture3D = preload("res://resources/cellular_noise_texture_3d.tres")

const SENSITIVITY: float = 0.01
const RETURN_SPEED: float = 0.7
const ROTATION_SPEED: float = deg_to_rad(20)
const MAX_PITCH: float = deg_to_rad(80.0)

@onready var camera_pivot: Node3D = %CameraPivot
@onready var node: MeshInstance3D = %Cube

var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var yaw: float = 0.0
var pitch: float = 0.0
var target_yaw: float = 0.0
var target_pitch: float = 0.0

var material: ShaderMaterial:
	get:
		var mesh: BoxMesh = node.mesh
		# In this case our material is directly on the Mesh
		var _material: ShaderMaterial = mesh.material
		#var _material: ShaderMaterial = mesh.surface_get_material(0)
		#var _material: ShaderMaterial = node.get_surface_override_material(0)
		return _material


func _process(delta: float) -> void:
	if is_dragging:
		yaw = lerp_angle(yaw, target_yaw, clamp(12.0 * delta, 0.0, 1.0))
	else:
		yaw += ROTATION_SPEED * delta
		target_pitch = lerp(target_pitch, 0.0, clamp(RETURN_SPEED * delta, 0.0, 1.0))

	pitch = lerp(pitch, target_pitch, clamp(12.0 * delta, 0.0, 1.0))

	camera_pivot.rotation = Vector3(pitch, yaw, 0.0)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.is_pressed()
			if is_dragging:
				last_mouse_pos = event.position

	elif event is InputEventMouseMotion and is_dragging:
		var delta: Vector2 = event.position - last_mouse_pos
		last_mouse_pos = event.position
		target_yaw -= delta.x * SENSITIVITY
		target_pitch = clamp(target_pitch - delta.y * SENSITIVITY, -MAX_PITCH, MAX_PITCH)


func set_texture(texture: Texture3D) -> void:
	material.set_shader_parameter(&"tex", texture)


func _on_button_pressed(idx: int) -> void:
	match idx:
		1:
			set_texture(SimplexNoise)
		2:
			set_texture(CellularNoise)
		_:
			set_texture(PerlinNoise)
