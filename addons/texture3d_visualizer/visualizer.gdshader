// Copyright (c) 2025 1hue - MIT License
shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled, blend_premul_alpha;

uniform sampler3D tex : hint_default_black, repeat_disable, filter_linear_mipmap;

/** The size (m³) of the cube mesh. Must be set manually, cannot be inferred. */
uniform vec3 model_size = vec3(5, 5, 5);

/**
 * Rotation of texture XYZ in model space.
 * For example, texture Z-depth might need to correspond to world Y, in which case selecting option [code]XZY[/code] swizzles the components XYZ -> XZY.
 */
uniform int translation : hint_enum("XYZ", "XZY", "YXZ", "YZX", "ZXY", "ZYX");

/**
 * Level of detail bias. How many texture sampling lookups (ray steps) will occur for each fragment.
 * Works hand in hand with actual texture LOD bias. The actual count of ray marching steps is based on texture size and view angle.
 * Lower for better quality. Higher for better performance.
 * Note that [b]positive values of this setting work only if mipmaps are present[/b].
 * Example:
 * Given a 64x64x64 texture; given the fragment is perfectly perpendicular to a surface (or looking straight down an edge); then the ray marching steps/texture samples for this fragment are:
 * [code]0.0[/code] - 64 texture samples
 * [code]1.0[/code] - 1 texture sample (only if mipmap present)
 * [code]-1.0[/code] - 128 texture samples
 * Diagonally the distance is greater (cube diagonal: ×1.73), hence, for those fragments, proportionally more ray marching steps are taken.
 */
uniform float lod_bias : hint_range(-1.0, 1.0, 0.01) = 0.0;

varying vec3 modelCoord;

float intersectBox(vec3 rayOrigin, vec3 rayDir, vec3 size) {
	// Avoid division by zero
	vec3 inverseDirection = 1.0 / rayDir;
	// Assume origin is center, so two opposing corners are -half and +half of size
	vec3 sizeHalf = size * 0.5;
	// Distances to near/far planes of each slab (pair of parallel planes)
	vec3 t0 = (-sizeHalf - rayOrigin) * inverseDirection;
	vec3 t1 = (sizeHalf - rayOrigin) * inverseDirection;
	vec3 tNear = min(t0, t1);
	vec3 tFar = max(t0, t1);
	// The farthest entry among the three axes
	float tEnter = max(max(tNear.x, tNear.y), tNear.z);
	// The nearest exit among the three axes
	float tExit = min(min(tFar.x, tFar.y), tFar.z);

	// No intersection if ray points away
	if (tExit < 0.0 || tEnter > tExit) {
		return -1.0;
	}
	return tExit;
}

vec3 getTextureLodSize() {
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	int currentLod = 0;
	#else
	int levelCount = textureQueryLevels(tex);
	int currentLod = lod_bias < 0.0
		? 0
		: int(floor(mix(0.0, float(levelCount - 1), lod_bias)));
	#endif

	// Base LOD 0=128x128, 1=64x64, 2=32x32, ...
	vec3 size = vec3(textureSize(tex, currentLod));
	// Allow sampling at fidelity higher than existing texels
	if (lod_bias < 0.0) {
		size *= pow(2, abs(lod_bias));
	}

	return size;
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
	modelCoord = VERTEX;
}

void fragment() {
	vec3 UVW = modelCoord / model_size + 0.5;

	// For this fragment, the direction of raymarching is opposite of VIEW
	vec4 rayDirWorld = INV_VIEW_MATRIX * vec4(-VIEW, 0); // View space to world space
	vec4 rayDirModel = inverse(MODEL_MATRIX) * rayDirWorld; // World space to model space
	vec3 rayDir = normalize(rayDirModel.xyz);

	vec3 texSize = swizzle(getTextureLodSize());
	vec3 texCoord = modelCoord * texSize / model_size;

	// Length in texture coordinate space, e.g. 128 when perpendicular to the far surface of a 128x128 tex
	float rayLength = intersectBox(texCoord, rayDir, texSize);
	if (rayLength < 0.0) {
		discard;
	}

	vec3 exitTexCoord = texCoord + (rayLength * rayDir);
	vec3 exitUVW = exitTexCoord / texSize + 0.5;

	// Number of ray steps must go hand in hand with mipmaps. Reducing the number of steps by simply
	// skipping over texels produces nonsensical results.
	// Scenarios where performance is important should have mipmaps generated.
	int raySteps = int(ceil(rayLength));

	vec4 acc = vec4(0);
	for (int i = 0; i < raySteps; i++) {
		float rayProgress = float(i) / float(raySteps - 1);
		vec3 coord = swizzle(mix(UVW, exitUVW, rayProgress));

		if (acc.a >= 1.0) {
			// Stop raymarching if fragment has accummulated full opacity
			break;
		}

		vec4 sample = texture(tex, coord, lod_bias);

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
