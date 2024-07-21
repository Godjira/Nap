shader_type canvas_item;
uniform float progress: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform sampler2D NOISE_PATTERN;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise = texture(NOISE_PATTERN, UV);
	vec4 final = vec4(1.0, 0.1, 0.1, 1.0);
	COLOR.rgb = final.rgb;
	COLOR.a = noise.r;
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
