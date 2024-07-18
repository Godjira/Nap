shader_type canvas_item;
uniform float progress: hint_range(0.0, 1.0, 0.1) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 final = vec4(1.0);
	// fire shader
	final = vec4(1.0, 0.0, 0.0, 1.0);
	final = mix(final, vec4(UV, 0.0, 1.0), progress);
	COLOR = final;
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
