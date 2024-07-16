shader_type canvas_item;
uniform vec2 mouse_pos = vec2(0.5);
uniform float blurAmount: hint_range(0.0, 1.0, 0.1) = 1.0;

const int num_iter = 15;
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


void fragment() {
	vec4 color = texture( TEXTURE,  UV);
	vec2 screenRatio = vec2(SCREEN_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y, 1.0);
	vec3 sumcol = vec3(0.0);
	vec3 sumw = vec3(0.0);
	vec2 blurOrigin = SCREEN_PIXEL_SIZE * 0.5;
	
	vec2 toCenter = blurOrigin - UV * TEXTURE_PIXEL_SIZE;
	float offset = random() + sin(TIME) * 0.001;
	for(int i = 0; i < num_iter; i++) {
		float t = float(i) * reci_num_iter_f;
		float percent = (float(i) + offset) / float(num_iter);
		vec3 w = mix(spectrum_offset(t),vec3(1.0),0.5);
		sumw+=w*1.2;
		sumcol += w * texture(TEXTURE, UV + toCenter * percent * blurAmount * sin(TIME) / TEXTURE_PIXEL_SIZE).rgb;
	}
	if(color.a > 0.6){
		color.a = 1.0;
	}
	COLOR = vec4(sumcol / sumw, color.a);
}