shader_type spatial;
uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
    // calculate the size of one "pixel" in UV coordinates
    vec2 pixelSize = 1.0/vec2(textureSize(screenTexture, 0)) * 30.0;
    // calculate the position of the lower-left corner of the current pixel
    vec2 pixelPos = floor(uv / pixelSize) * pixelSize;
    // get the color of the lower-left corner pixel
    vec4 text = texture(screenTexture, pixelPos);
	ALBEDO = text.rgb;

	// Define the color of the edge border.
    vec3 edgeColor = vec3(0);

    // Check the surrounding pixels in a neighborhood around the current pixel.
    for (float x = -1.0; x <= 0.5; x+=0.25) {
        for (float y = -1.0; y <= 0.5; y+=0.25) {

            vec2 offset = vec2(x, y) * pixelSize + 0.01;
            vec4 neighborColor = texture(screenTexture, pixelPos + offset);

            if (neighborColor.a < 1.0) {
                ALBEDO = edgeColor;
                ALPHA = 1.0;
                break;
            }
        }
    }
   


    // If there are no borders found, set ALPHA to 0.
    if(text.a < 1.0) {
        ALPHA = 0.0;
    }
}
