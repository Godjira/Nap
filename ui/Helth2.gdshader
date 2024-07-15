shader_type canvas_item;

uniform float health : hint_range(0.0, 1.0);

void fragment() {
	// display health bar from left to right
	vec3 progressColor = vec3(0.8, 0.2, 0.1);
	vec4 final = vec4(0.0);

	vec2 uv = UV;
	// create texture mix
	vec4 text = texture(TEXTURE, UV);
	// calculate the size of one "pixel" in UV coordinates
	vec2 pixelSize = 1.0/vec2(textureSize(TEXTURE, 0)) * 5.0;
	// calculate the position of the lower-left corner of the current pixel
	vec2 pixelPos = floor(uv / pixelSize) * pixelSize;
	// get the color of the lower-left corner pixel
	vec4 text1 = texture(TEXTURE, pixelPos);
	final = text1;
	if(text1.r > 0.7) {
		// fill the health bar with the progress color
		if (UV.x < health) {
			final = vec4(progressColor, 1.0);
		} else {
			final = vec4(0.0, 0.0, 0.0, 0.0);
		}
	}
	COLOR = final;
}
