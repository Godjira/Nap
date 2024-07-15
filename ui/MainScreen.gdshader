shader_type canvas_item;
uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;
uniform float blurAmount: hint_range(0.0, 1.0, 0.1);

const int num_iter = 5;
const float reci_num_iter_f = 1.0 / float(num_iter);

float random() {
	return fract(sin(dot(vec2(1.0), vec2(12.9898, 4.1414))) * 43758.5453);
}

float sat( float t ){
	return clamp( t, 0.0, 1.0 );
}

float linterp( float t ) {
	return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

float remap( float t, float a, float b ) {
	return sat( (t - a) / (b - a) );
}

vec3 spectrum_offset( float t ) {
	vec3 ret;
	float lo = step(t,0.5);
	float hi = 1.0-lo;
	float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
	ret = vec3(lo,1.0,hi) * vec3(1.0-w, w, 1.0-w);
	
	return pow( ret, vec3(1.0/2.2) );
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture( screenTexture,  SCREEN_UV);
	vec2 screenRatio = vec2(SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y, 1.0);
	vec3 sumcol = vec3(0.0);
	vec3 sumw = vec3(0.0);
	vec2 blurOrigin = SCREEN_PIXEL_SIZE * 0.5;
	
	vec2 toCenter = blurOrigin - UV * SCREEN_PIXEL_SIZE;
	float offset = random() + sin(TIME) * 0.001;
	for(int i = 0; i < num_iter; i++) {
		float t = float(i) * reci_num_iter_f;
		float percent = (float(i) + offset) / float(num_iter);
		vec3 w = mix(spectrum_offset(t),vec3(1.0),0.5);
		sumw+=w;
		sumcol += w * texture(screenTexture, SCREEN_UV + toCenter * percent * blurAmount * 0.2 / SCREEN_PIXEL_SIZE).rgb;
	}
	
	COLOR = vec4(sumcol / sumw, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
