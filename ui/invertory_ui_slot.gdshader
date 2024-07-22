shader_type canvas_item;

uniform float rotation_speed : hint_range(0, 10) = .5;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    // Calculate rotation
    float angle = TIME * rotation_speed;
    float sine = sin(angle);
    float cosine = cos(angle);
    
    // Translate UV to rotate around center
    vec2 uv = UV - center;
    vec2 rotated_uv = vec2(
        uv.x * cosine - uv.y * sine,
        uv.x * sine + uv.y * cosine
    );
    rotated_uv += center;
    
    // Sample the main texture with rotated UVs
    vec4 main_color = texture(TEXTURE, rotated_uv);
    
    // Sample the slot texture
    vec4 slot_color = texture(TEXTURE, UV);
    if(UV.x > 0.99 || UV.x < 0.02 || UV.y > 0.98 || UV.y < 0.02) {
		main_color.rgb = slot_color.rgb;
	}
    // Combine the textures
    COLOR = main_color;
}