shader_type spatial;
render_mode unshaded, wireframe, blend_premul_alpha;

uniform bool wireframe = true;
uniform vec4 wireframe_color: source_color = vec4(1,1,1,1);

void vertex() {
	COLOR = wireframe_color;
}

void fragment() {
	if (!wireframe) {
		ALPHA = 0.0;
		discard;
	} else {
		ALBEDO = COLOR.rgb;
		ALPHA = COLOR.a;
	}
}