shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled, wireframe;

uniform bool wireframe = true;
uniform vec4 wireframe_color: source_color = vec4(1,1,1,1);

void vertex() {
	COLOR = wireframe_color;
}

void fragment() {
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	discard;
	#else
	if (!wireframe) {
		ALPHA = 0.0;
		discard;
	} else {
		ALBEDO = COLOR.rgb;
		ALPHA = COLOR.a;
	}
	#endif
}