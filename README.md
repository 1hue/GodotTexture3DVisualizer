![Godot Texture3D Visualizer](/assets/hero.png)

# Godot Texture3D Visualizer

Render and visualize 3-dimensional textures in their entirety in 3D space using spatial shaders.

Demo: https://1hue.github.io/demos/godot-texture3d-visualizer/

The magic happens in [`visualizer.gdshader`](visualizer.gdshader) which raymarches through a texture based on camera angle, and renders the 3D contents of the texture onto the surface of a cube.

The texture could be loaded from file or it could be a [`Texture3DRD`](https://docs.godotengine.org/en/stable/classes/class_texture3drd.html) created on the GPU, but this is up to you - it _must be provided_ to the shader as a parameter.

The texture is ingested as a `sampler3D` uniform and is sampled for each fragment a number of times using ray marching. Maximum Ray Steps are customizable.

For the purposes of demonstration, a [`NoiseTexture3D`](https://docs.godotengine.org/en/stable/classes/class_noisetexture3d.html) is used.

> [!NOTE]\
> **No AI generated code**. No unnecessary and expensive matrix math or space reconstruction. Only clean, minimal code.

<br />

## Instructions

1. Create a `MeshInstance3D` node in your scene.

2. Set the Mesh to be `BoxMesh` of size `5m`x`5m`x`5m`.

3. Set the Material or Surface Material Override to a new `ShaderMaterial`.

4. Set [`visualizer.gdshader`](visualizer.gdshader) as the material's shader by dragging the file or using "Load"/"Quick Load".

5. Set your 3D texture as the "Tex" shader parameter.

6. Ensure the "Model Size" shader parameter matches the box size.

> [!TIP]
> Note that the demo project may be in Compatibility mode. Switch to Forward+ to avoid quirks.

<br />

## Passing a texture to the shader

Get a hold of your texture. Perhaps load it from file. Then, simply set it as the shader parameter `tex`:

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

The texture is then, effectively, transferred from the CPU to the GPU and available to the shader as a `sampler3D` uniform (variable).

<br />

> [!TIP]
> The texture's orientation (XYZ) will align with world orientation (XYZ). To rearrange the axes and effectively flip your texture 90°, set the "Translation" parameter to `XZY`. This maps texture Y coordinate to world Z: texture XYZ -> world XZY.

<br />

## Compatibility

Tested using:

- Vulkan API
- Compatibility mode
- Godot 4.5

The wireframe (cube outline) used for the demo works in Mobile/Forward+ only.

<br />

## Screenshots

### MeshInstance3D Material

![Screenshot of MeshInstance3D Material](/assets/mesh_instance_3d.png)

---

### Shader parameters

![Screenshot of Shader Parameters](/assets/shader_parameters.png)

---

### Compatibility mode

Top right of editor:

![Screenshot of Compatibility and Forward+ rendering modes](/assets/compatibility_mode.png)
