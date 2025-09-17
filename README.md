# Godot Texture3D Visualizer

`visualizer.gdshader`(visualizer.gdshader) takes a 3-dimensional texture and renders it in a specified size.

The texture could be loaded from file or a [`Texture3DRD`](https://docs.godotengine.org/en/stable/classes/class_texture3drd.html) created on the GPU. It is provided to the shader as a `sampler3D` uniform.

For the purposes of demonstration we use a [`NoiseTexture3D`](https://docs.godotengine.org/en/stable/classes/class_noisetexture3d.html).

This is a GLSL compatible[^1] shader with some of Godot's preprocessor niceties.

[^1]: For actual differences of Godot Shading Language vs GLSL, check out [this page](https://docs.godotengine.org/en/stable/tutorials/shaders/converting_glsl_to_godot_shaders.html#doc-converting-glsl-to-godot-shaders).

## Instructions

1. Create a `MeshInstance3D` node in your scene.

2. Set `BoxMesh` as the Mesh. Set the size to `5m` x `5m` x `5m`.

3. Set the material or surface material override to a new `ShaderMaterial`.

4. Set `visualizer.gdshader` as the material shader by dragging the file or using "Load"/"Quick Load".

5. Set your 3D texture as the `tex` shader parameter.

6. Ensure "Model Size" shader parameter matches the box size.

## Screenshots

![Screenshots of Shader Parameters](/assets/shader_parameters.png)

![Screenshots of NoiseTexture3D](/assets/noise_texture_3d.png)
