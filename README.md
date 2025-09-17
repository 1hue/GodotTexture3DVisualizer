![Godot Texture3D Visualizer](/assets/hero.png)

# Godot Texture3D Visualizer

Render and visualize 3-dimensional textures in their entirety in 3D space using spatial shaders.

The magic happens inside [`visualizer.gdshader`](visualizer.gdshader) which raymarches through a texture based on camera angle, and renders the 3D contents of the texture onto the surfaces of a cube.

The texture could be loaded from file or it could be a [`Texture3DRD`](https://docs.godotengine.org/en/stable/classes/class_texture3drd.html) created on the GPU, but this is up to you - it _must be provided_ to the shader as a parameter.

The texture is ingested as a `sampler3D` uniform and is sampled for each fragment a number of times using ray marching. Maximum Ray Steps are customizable.

For the purposes of demonstration, a [`NoiseTexture3D`](https://docs.godotengine.org/en/stable/classes/class_noisetexture3d.html) is used.

> [!NOTE]\
> **No AI slop**. Clean, minimal code.

<br />

## Instructions

1. Create a `MeshInstance3D` node in your scene.

2. Set the Mesh to be `BoxMesh` of size `5m`x`5m`x`5m`.

3. Set the Material or Surface Material Override to a new `ShaderMaterial`.

4. Set [`visualizer.gdshader`](visualizer.gdshader) as the material shader by dragging the file or using "Load"/"Quick Load".

5. Set your 3D texture as the "Tex" shader parameter.

6. Ensure the "Model Size" shader parameter matches the box size.

<br />

## Passing a texture to the shader uniform

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
> The texture's XYZ will align with world XYZ. To rearrange the axes, we can use GLSL's component swizzling:
>
> ```glsl
> // Instead of the default xyz:
> vec4 sample = texture(tex, coord);
> // we can xzy to make the texture's Z axis correspond to world Y:
> vec4 sample = texture(tex, coord).xzy;
> ```

<br />

## Screenshots

### MeshInstance3D Material:

![Screenshots of MeshInstance3D Material](/assets/mesh_instance_3d.png)

---

### Shader parameters:

![Screenshots of Shader Parameters](/assets/shader_parameters.png)

---

### Noise texture:

![Screenshots of NoiseTexture3D](/assets/noise_texture_3d.png)
