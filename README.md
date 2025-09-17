![Godot Texture3D Visualizer](/assets/hero.png)

# Godot Texture3D Visualizer

[`visualizer.gdshader`](visualizer.gdshader) takes a 3-dimensional texture and renders it in a specified size.

The texture could be loaded from file or a [`Texture3DRD`](https://docs.godotengine.org/en/stable/classes/class_texture3drd.html) created on the GPU. It is provided to the shader as a `sampler3D` uniform.

For the purposes of demonstration we use a [`NoiseTexture3D`](https://docs.godotengine.org/en/stable/classes/class_noisetexture3d.html).

---

This is a GLSL compatible[^1] shader with some of Godot's preprocessor niceties.

[^1]: For actual differences of Godot Shading Language vs GLSL, check out [this page](https://docs.godotengine.org/en/stable/tutorials/shaders/converting_glsl_to_godot_shaders.html#doc-converting-glsl-to-godot-shaders).

## Instructions

1. Create a `MeshInstance3D` node in your scene.

2. Set the Mesh to be `BoxMesh` of size `5m`x`5m`x`5m`.

3. Set the Material or Surface Material Override to a new `ShaderMaterial`.

4. Set [`visualizer.gdshader`](visualizer.gdshader) as the material shader by dragging the file or using "Load"/"Quick Load".

5. Set your 3D texture as the "Tex" shader parameter.

6. Ensure the "Model Size" shader parameter matches the box size.

## Passing a texture to the shader uniform

```gdscript
@onready var node: MeshInstance3D = $Cube

func set_texture(texture: Texture3D) -> void:
	var mesh: BoxMesh = node.mesh
	# Grab the material. This depends on how/where you set it.
	var material: ShaderMaterial = mesh.material
	#var material: ShaderMaterial = mesh.surface_get_material(0)
	#var material: ShaderMaterial = node.get_surface_override_material(0)
	material.set_shader_parameter(&"tex", texture)
```

## Screenshots

### MeshInstance3D Material:

![Screenshots of MeshInstance3D Material](/assets/mesh_instance_3d.png)

---

### Shader parameters:

![Screenshots of Shader Parameters](/assets/shader_parameters.png)

---

### Noise texture:

![Screenshots of NoiseTexture3D](/assets/noise_texture_3d.png)
