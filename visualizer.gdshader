shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled, blend_premul_alpha;

const float EPS = 1e-9;

uniform sampler3D tex : hint_default_black, repeat_disable, filter_linear_mipmap;

/** The size (m³) of the cube mesh. Must be set manually as shaders cannot possibly infer this. */
uniform vec3 model_size = vec3(5, 5, 5);

/**
 * Rotation of texture XYZ in model space.
 * For example, texture Z-depth might need to correspond to world Y, in which case selecting option [code]XZY[/code] swizzles the components XYZ -> XZY.
 */
uniform int translation : hint_enum("XYZ", "XZY", "YXZ", "YZX", "ZXY", "ZYX");

/**
 * Level of detail bias. How many texture sampling lookups (ray steps) will occur for each fragment.
 * Works hand in hand with actual texture LOD bias.
 * Lower for better quality. Higher for better performance.
 * The actual number is based on texture size and view angle.
 * A value of [code]0.0[/code] with a 64x64x64 texture results in 64 samples when the fragment is "looking" straight down an edge or ~111 (x1.73) samples diagonally, in case of a cube.
 * Note that this setting works [b]only if mipmaps are present[/b].
 */
uniform float lod_bias : hint_range(0.0, 1.0, 0.01) = 0.0;

varying vec3 model;

vec3 calcRayExit(vec3 entry, vec3 direction) {
    // Guard each component to avoid division by zero while preserving sign
    vec3 direction_inverse = 1.0 / (direction + sign(direction) * EPS);
    vec3 t1 = (vec3(0) - entry) * direction_inverse;
    vec3 t2 = (vec3(1) - entry) * direction_inverse;
    //vec3 tmin = min(t1, t2);
    vec3 tmax = max(t1, t2);
    //float near = max(max(tmin.x, tmin.y), tmin.z);
    float far  = min(min(tmax.x, tmax.y), tmax.z);

    if (far <= 1e-6) return entry;

    return entry + direction * far;
}

float countTexels(vec3 direction, float ray_length) {
	#if CURRENT_RENDERER != RENDERER_COMPATIBILITY
	int current_lod = int(floor(mix(0.0, float(textureQueryLevels(tex) - 1), lod_bias)));
	#else
	int current_lod = 0;
	#endif

	ivec3 tex_size = textureSize(tex, current_lod);
	vec3 texel_vector = direction * vec3(tex_size) * ray_length;

	return length(texel_vector);
}

vec3 swizzle(in vec3 coord) {
	switch(translation) {
		case 1:
			return coord.xzy;
		case 2:
			return coord.yxz;
		case 3:
			return coord.yzx;
		case 4:
			return coord.zxy;
		case 5:
			return coord.zyx;
		default:
			return coord;
	}
}

void vertex() {
	model = VERTEX;
}

void fragment() {
	vec3 model_uvw = model / model_size + 0.5;

	// For this fragment, the direction of raymarching is opposite of VIEW
	vec4 ray_direction_world = INV_VIEW_MATRIX * vec4(-VIEW, 0); // View space to world space
	vec4 ray_direction_model = inverse(MODEL_MATRIX) * ray_direction_world; // World space to model space
	vec3 ray_direction = normalize(ray_direction_model.xyz);

	vec3 ray_exit = calcRayExit(model_uvw, ray_direction);

	float ray_length = length(ray_exit - model_uvw);

	// Number of ray steps must go hand in hand with mipmaps. Reducing the number of steps by simply
	// skipping over texels produces nonsensical results and is not worth it.
	// Any scenario where performance is important should have mipmaps generated anyway.
	int ray_steps = int(ceil(countTexels(ray_direction, ray_length)));

	vec4 acc = vec4(0);
	for (int i = 0; i < ray_steps; i++) {
		float ray_progress = float(i) / float(ray_steps - 1);
		vec3 coord = swizzle(mix(model_uvw, ray_exit, ray_progress));

		if (acc.a >= 1.0) {
			// Stop raymarching if fragment has accummulated full opacity
			break;
		}

		vec4 sample = texture(tex, coord, lod_bias);

		// Accummulate this texel to the fragment only if it has actual visible colour
		if (sample.r > 0.0) {
			acc.rgb += sample.rgb * sample.a;
			acc.rgb = clamp(acc.rgb, 0, 1);
			acc.a = 1.0 - (1.0 - acc.a) * (1.0 - sample.a); // 0.75 for two 0.5 alphas
		}
	}

	ALBEDO = acc.rgb;
	ALPHA = acc.a;
}