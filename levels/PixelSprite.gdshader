shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
    // calculate the size of one "pixel" in UV coordinates
    vec2 pixelSize = 1.0/vec2(textureSize(TEXTURE, 0)) * 20.0;
    // calculate the position of the lower-left corner of the current pixel
    vec2 pixelPos = floor(uv / pixelSize) * pixelSize;
    // get the color of the lower-left corner pixel
    vec4 text = texture(TEXTURE, pixelPos);
	
	// Define the color of the edge border.
    vec3 edgeColor = vec3(0);
	
	COLOR = text;

    // Check the surrounding pixels in a neighborhood around the current pixel.
    for (float x = -1.0; x <= 2.5; x+=.25) {
        for (float y = -1.0; y <= 2.5; y+=.25) {

            vec2 offset = vec2(x, y) * 0.5 * pixelSize - 0.01;
            vec4 neighborColor = texture(TEXTURE, pixelPos + offset);

            if (neighborColor.a < 1.0) {
                COLOR.rgb = edgeColor;
                break;
            }
        }
    }
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
