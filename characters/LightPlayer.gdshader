shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Calculate the distance from the current pixel to the center
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    // Calculate the alpha based on the distance and radius
    float alpha = smoothstep(radius, radius - softness, dist);
    alpha *= 0.1;
    // Output the final color
    COLOR = vec4(color.rgb, alpha);
}