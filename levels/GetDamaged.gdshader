shader_type canvas_item;

uniform float damage_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 damage_color : source_color = vec4(0.7, 0.0, 0.0, 1.0);
uniform float edge_softness : hint_range(0.0, 1.0) = 0.3;
uniform sampler2D SCREEN_TEXTURE;

void fragment() {
    // Calculate distance from center
    vec2 center = vec2(0.5, 0.5);
    float distance = length(UV - center);
    
    // Create a radial gradient
    float edge_effect = smoothstep(0.5 - edge_softness, 0.5, distance);
    
    // Mix the screen color with the damage color based on intensity and edge effect
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 final_color = mix(screen_color, damage_color, damage_intensity * edge_effect);
    
    COLOR = final_color;
	COLOR.a = 1.0 - final_color.r;
}