extends Node3D

const CellularNoise: NoiseTexture3D = preload("res://resources/cellular_noise_texture_3d.tres")
const PerlinNoise: NoiseTexture3D = preload("res://resources/perlin_noise_texture_3d.tres")


@onready var camera_pivot: Node3D = %CameraPivot

var cam_rotation: float = deg_to_rad(30)

func _process(delta: float) -> void:
	camera_pivot.rotate_y(cam_rotation * delta)
