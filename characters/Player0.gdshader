shader_type canvas_item;
uniform float hit_intesity : hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//COLOR = vec4(vec3(0.7), texture(TEXTURE, UV).a);
	COLOR.r = mix(COLOR.r, 10.0, hit_intesity);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
