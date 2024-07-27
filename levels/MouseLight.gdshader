shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Called for every pixel the material is visible on.

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
