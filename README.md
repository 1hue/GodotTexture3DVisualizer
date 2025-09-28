![Godot Texture3D Visualizer](/assets/images/hero.png)

# Godot Texture3D Visualizer

<sup>Demo: https://1hue.github.io/demos/godot-texture3d-visualizer/</sup>

Render and visualize 3-dimensional textures in their entirety in 3D space using spatial shaders.

<br />

The magic happens in [`visualizer.gdshader`](/addons/texture3d_visualizer/visualizer.gdshader) which raymarches through a texture based on camera angle, and projects the texture onto the surface of a cube.

The texture could be loaded from file or it could be a [`Texture3DRD`](https://docs.godotengine.org/en/stable/classes/class_texture3drd.html) created on the GPU, but this is up to you - it _must be provided_ to the shader as a parameter.

The texture is ingested as a `sampler3D` uniform and is sampled for each fragment a number of times using raymarching.

For the purposes of demonstration, a [`NoiseTexture3D`](https://docs.godotengine.org/en/stable/classes/class_noisetexture3d.html) is used.

> [!NOTE]\
> **No AI generated code**. No unnecessary and expensive matrix math or space reconstruction. Only clean, minimal code.

> [!TIP]
> Note that the demo project may be in Compatibility mode. Switch to Forward+ to avoid quirks.

<br />

## Features

- **Irregular cuboid sizes**

  - Not just cubes; `1m×2m×3m` is acceptable.

- **LOD support**

  - When mipmaps are present, raymarching and sampling the texture at the specified mipmap level is fully supported.
  - Sampling at fidelities _higher_ than the texture size, e.g. `128` raymarching steps for a `64px` texture.

- **Proper raymarching - automatic calculation of view angle**

  - For a texture of `64px³`, the vast majority of fragments will raymarch less or more than `64` steps.

- **Smoothed and raw pixel view**

  - Nearest or linear filtering. Approximation or pixelation.

- **Rotation**

  - Sometimes, texture Z-depth ought to correspond to world Y. Or any other configuration.

<br />

## Instructions

<details>
<summary><h3>Shader use</h3></summary>

1. Create a `MeshInstance3D` node in your scene.

2. Set the Mesh to be `BoxMesh` of size `5m`x`5m`x`5m`.

3. Set the Material or Surface Material Override to a new `ShaderMaterial`.

4. Set [`visualizer.gdshader`](/addons/texture3d_visualizer/visualizer.gdshader) as the material's shader by dragging the file or using "Load"/"Quick Load".

5. Set your 3D texture as the "Tex" shader parameter.

6. Ensure the "Model Size" shader parameter matches the mesh size.
</details>
<details>
<summary><h3>As a plugin (optional)</h3></summary>
<br />

A basic helper node that sets up the shader is included as a Godot plugin.

1. Enable the "Texture3D Visualizer" plugin via Project Settings.

2. Add a `Texture3DVisualizer` node to your scene.

3. Set the Texture parameter.

This will simply create a BoxMesh with a Material Override and pass the texture to the shader.

</details>

<br />

## Common solutions

<details>
<summary>
<b>Q:</b> I'm seeing <strong>curvature</strong> in my texture around the edges.
</summary>
<br />

**A:** Ensure that your texture has the same proportions as the box size. For example, a `128x128x128` texture will become warped when trying to fit into a `128x64x128` space.

<br />
</details>

<details>
<summary>
<b>Q:</b> The texture is <strong>blurred/smoothed</strong>. I want to see the actual pixels with clear edges.
</summary>
<br />

**A:** Swap `filter_linear_mipmap` for `filter_nearest_mipmap` in [`visualizer.gdshader`](/addons/texture3d_visualizer/visualizer.gdshader#L5) to remove any texel approximation/smoothing.

</details>

<br />

## Passing a texture to the shader

Get a hold of your texture. Perhaps load it from file. Then, simply set it as the shader parameter `tex`:

```gdscript
# scene.gd

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
> The texture's orientation (XYZ) will align with world orientation (XYZ).
>
> To rearrange the axes and effectively flip your texture 90°, set the "Translation" parameter to `XZY`. This maps texture Z axis coordinates to world Y; texture `XYZ` -> world `XZY`.

<br />

## Compatibility

Tested with:

- Vulkan API
- Compatibility mode
- Godot v4.5
- Godot v4.4

The wireframe (cube outline) used for the demo works in Mobile/Forward+ only.

<br />

## Screenshots

### MeshInstance3D Material

![Screenshot of MeshInstance3D Material](/assets/images/mesh_instance_3d.png)

---

### Shader parameters

![Screenshot of Shader Parameters](/assets/images/shader_parameters.png)

---

### Compatibility mode

Top right of editor:

![Screenshot of Compatibility and Forward+ rendering modes](/assets/images/compatibility_mode.png)
