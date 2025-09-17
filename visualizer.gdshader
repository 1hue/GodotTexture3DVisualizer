shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled, blend_premul_alpha;

const float EPSILON = 1e-6; // 6‑7 correct decimal places for 32-bit floats

uniform sampler3D tex : hint_default_black, repeat_disable, filter_linear_mipmap;
/** The size (m³) of the cube mesh. Must be set manually as shaders cannot possibly infer this. */
uniform vec3 model_size = vec3(5, 5, 5);
/** The maximum number of texture lookups that will occur for each fragment. */
uniform int ray_steps : hint_range(0, 512, 1) = 64;

varying vec3 model;

bool fEqual(in float a, in float b) {
  return abs(a - b) < EPSILON;
}

bool fGreaterThan(in float a, in float b) {
  return (a - b) > EPSILON;
}

bvec3 fGreaterThan(in vec3 a, in float b) {
  return bvec3(fGreaterThan(a.x, b), fGreaterThan(a.y, b), fGreaterThan(a.z, b));
}

bool fLessThan(in float a, in float b) {
  return (b - a) > EPSILON;
}

bool fLessThanEqual(in float a, in float b) {
  return fLessThan(a, b) || fEqual(a, b);
}

bvec3 fLessThanEqual(in vec3 a, in float b) {
  return bvec3(fLessThanEqual(a.x, b), fLessThanEqual(a.y, b), fLessThanEqual(a.z, b));
}

bool fGreaterThanEqual(in float a, in float b) {
  return fGreaterThan(a, b) || fEqual(a, b);
}

bvec3 fGreaterThanEqual(in vec3 a, in float b) {
  return bvec3(fGreaterThanEqual(a.x, b), fGreaterThanEqual(a.y, b), fGreaterThanEqual(a.z, b));
}

bool isWithin(in vec3 coord, in float minBound, in float maxBound) {
	return all(fGreaterThanEqual(coord, minBound)) && all(fLessThanEqual(coord, maxBound));
}

void vertex() {
	model = VERTEX;
}

void fragment() {
	vec3 model_uv = model / model_size + 0.5;

	// For this fragment, the direction that we will raymarch towards
	vec4 ray_direction_world = INV_VIEW_MATRIX * vec4(-VIEW, 0.0); // View space -> world space
	vec4 ray_direction_model = inverse(MODEL_MATRIX) * ray_direction_world; // World space -> model space
	vec3 ray_direction = normalize(ray_direction_model.xyz);

	vec4 acc = vec4(0);

	for (int i = 0; i < ray_steps; i++) {
        // Step size goes [0, 0.1, .., 1]
        float step_size = float(i) / float(ray_steps - 1);
		vec3 coord = model_uv + step_size * ray_direction;

		if (acc.a >= 1.0 || !isWithin(coord, 0.0, 1.0)) {
			// Stop raymarching if fragment has accummulated full opacity or has gone beyond edge
			break;
		}

		vec4 sample = texture(tex, coord);

		// Accummulate this texel to the fragment only if it has actual visible colour
		if (sample.a > 0.0) {
			acc.rgb += sample.rgb * sample.a;
			acc.rgb = clamp(acc.rgb, 0, 1);
			acc.a = 1.0 - (1.0 - acc.a) * (1.0 - sample.a); // 0.75 for two 0.5 alphas
		}
	}

    ALBEDO = acc.rgb;
	ALPHA = acc.a;
}