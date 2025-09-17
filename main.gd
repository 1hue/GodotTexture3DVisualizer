extends Node3D

@onready var camera_pivot: Node3D = %CameraPivot

var cam_rotation: float = deg_to_rad(30)

func _process(delta: float) -> void:
	camera_pivot.rotate_y(cam_rotation * delta)
