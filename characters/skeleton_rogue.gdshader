shader_type spatial;

// Add properties to modify the pixelation level
uniform float PIXEL_SIZE : hint_range(1.0, 100.0) = 10.0;
uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;

void vertex() {
}

void fragment() {
    // Adjust the UV coordinates.
    vec2 adjusted_uv = floor(UV * PIXEL_SIZE) / PIXEL_SIZE;

    // Use the adjusted UV values to generate color.
    vec3 color = vec3(adjusted_uv.x, adjusted_uv.y, 0.0);
    
    ALBEDO = color;
}
