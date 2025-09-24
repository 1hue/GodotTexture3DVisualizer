# Copyright (c) 2025 1hue - MIT License
## Helper for [code]visualizer.gdshader[/code]
##
## See the created [ShaderMaterial] on Geometry's Material Override for actual shader parameters.
## Direct use of the shader without this helper node is recommended.
@tool
extends MeshInstance3D
class_name Texture3DVisualizer

const VisualizerShader: Shader = preload("res://addons/texture3d_visualizer/visualizer.gdshader")
const WireframeShader: Shader = preload("res://addons/texture3d_visualizer/wireframe.gdshader")

@export var texture: Texture3D:
	set(value):
		texture = value
		if not material:
			_create_material()
		material.set_shader_parameter(&"tex", value)

@export var wireframe: bool: set = _set_wireframe


var material: ShaderMaterial:
	get: return material_override


func _ready() -> void:
	if not mesh:
		mesh = BoxMesh.new()
		mesh.size = Vector3(5,5,5)

	if not material_override:
		_create_material()

	if wireframe and not material_overlay:
		_create_wireframe()


func _set_wireframe(value: bool) -> void:
	wireframe = value

	if value:
		if not material_overlay:
			_create_wireframe()
		material_overlay.set_shader_parameter(&"wireframe", true)
	else:
		material_overlay = null


func _create_wireframe() -> void:
	material_overlay = ShaderMaterial.new()
	material_overlay.shader = WireframeShader


func _create_material() -> void:
	material_override = ShaderMaterial.new()
	material_override.shader = VisualizerShader
