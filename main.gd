extends Node3D

const CellularNoise: NoiseTexture3D = preload("res://resources/cellular_noise_texture_3d.tres")
const PerlinNoise: NoiseTexture3D = preload("res://resources/perlin_noise_texture_3d.tres")


@onready var camera_pivot: Node3D = %CameraPivot
@onready var node: MeshInstance3D = $Cube

var cam_rotation: float = deg_to_rad(30)

func _process(delta: float) -> void:
	camera_pivot.rotate_y(cam_rotation * delta)

func set_texture(texture: Texture3D) -> void:
	var mesh: BoxMesh = node.mesh
	# Grab the material. This depends on how/where you set it.
	var material: ShaderMaterial = mesh.material
	#var material: ShaderMaterial = mesh.surface_get_material(0)
	#var material: ShaderMaterial = node.get_surface_override_material(0)
	material.set_shader_parameter(&"tex", texture)
