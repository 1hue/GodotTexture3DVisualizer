extends Node3D

const PerlinNoise: NoiseTexture3D = preload("res://resources/perlin_noise_texture_3d.tres")
const SimplexNoise: NoiseTexture3D = preload("res://resources/simplex_noise_texture_3d.tres")
const CellularNoise: NoiseTexture3D = preload("res://resources/cellular_noise_texture_3d.tres")

@onready var camera_pivot: Node3D = %CameraPivot
@onready var node: MeshInstance3D = $Cube

var cam_rotation: float = deg_to_rad(30)


func _process(delta: float) -> void:
	camera_pivot.rotate_y(cam_rotation * delta)


func set_texture(texture: Texture3D) -> void:
	var mesh: BoxMesh = node.mesh
	# Grab the material. In this case the material is directly on the Mesh.
	var material: ShaderMaterial = mesh.material
	#var material: ShaderMaterial = mesh.surface_get_material(0)
	#var material: ShaderMaterial = node.get_surface_override_material(0)
	material.set_shader_parameter(&"tex", texture)


func _on_button_pressed(idx: int) -> void:
	match idx:
		1:
			set_texture(SimplexNoise)
		2:
			set_texture(CellularNoise)
		_:
			set_texture(PerlinNoise)
