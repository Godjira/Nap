//shader_type canvas_item;
//
//void vertex() {
	//// Called for every vertex the material is visible on.
//}
//
//void fragment() {
	//vec4 color = texture(TEXTURE, UV);
	//float g = color.g;
	//color.g = 0.0;
	//color.r = g;
	//COLOR = color;
//}
//
////void light() {
	//// Called for every pixel for every light affecting the CanvasItem.
	//// Uncomment to replace the default light processing function with this one.
////}
shader_type canvas_item;

uniform float effect_strength : hint_range(0, 1) = 0.0;

void fragment() {
    vec2 uv = UV;
    
    // Add some waviness
    uv.x += sin(uv.y * 2.0 + TIME * 2.0) * 0.1 * effect_strength;
    uv.y -= cos(uv.x * 2.0 + TIME * 2.0) * 0.1 * effect_strength;
	
	uv *= sin(TIME) * effect_strength + 1.0;
    
    // Sample the texture with our modified UVs
    vec4 color = texture(TEXTURE, uv );
    color.r = color.g;
	color.g = 0.0;
    // Add some glow
    color.rgb += vec3(0.0, 0.7, 1.0) * effect_strength * 1.5;
    
    COLOR = color;
}