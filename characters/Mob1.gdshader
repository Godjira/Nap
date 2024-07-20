shader_type canvas_item;
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform float threshold;
uniform float intensity;
uniform float opacity;
uniform vec4 glow_color : source_color;

void vertex() {
	VERTEX *= clamp(sin(TIME) * 1.4, 0.6, 0.7);
}


void fragment() {
	// Get the pixel color from the texture
	vec4 pixel_color = texture(TEXTURE, UV);
	pixel_color.rgb += mix(color1.rgb, color2.rgb, sin(TIME)) * 0.3;
	COLOR = pixel_color;
}


//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
