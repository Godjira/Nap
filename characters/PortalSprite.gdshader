shader_type canvas_item;

uniform float dash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 dash_direction = vec2(1.0, 0.0);

void fragment() {
    vec2 dash_uv = UV;
    
    // Apply motion blur based on dash intensity and direction
    for(float i = 0.0; i < 10.0; i++) {
        float offset = (i / 10.0) * dash_intensity + sin(TIME);
        dash_uv -= dash_direction * offset * 0.01;
        COLOR += texture(TEXTURE, dash_uv);
    }
    
    // Normalize the color
    COLOR /= 10.0;
    
    // Increase the brightness slightly to compensate for the blur
    COLOR.rgb *= 1.2;
}