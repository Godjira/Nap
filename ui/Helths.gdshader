shader_type canvas_item;

void vertex() {
	
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}


void fragment() {
	vec2 col;
	float t = TIME*.005;
	vec2 uv = UV+vec2(t,t*2.0);
	float factor = 1.;
	vec2 v1;
	vec4 color = vec4(0.0);
	for(int i=0;i<15;i++)
	{
	    uv *= -factor*factor;
	    v1 = uv.yx/factor;
	    uv += sin(v1+col+t)/factor;
	    col += vec2(cos(uv.x-uv.y+v1.x-col.y), cos(uv.y-uv.x+v1.y-col.x));
	}

	float d = sdSphere(vec3(UV - 0.5, .0), 0.5);
	if (d<0.0) {
		vec4 color = vec4(vec3(col.x+4.0,col.x-col.y/2.0,col.x/5.0)/2.0, 1.0);
		vec3 p = vec3(0., UV - 0.5);
		// create light
		vec3 light = normalize(vec3(0.0, 0.0, 1.0));
		float diff = max(0.2, dot(light, normalize(p)));
		// add pixelized effect
		vec2 uv = UV;
		// calculate the size of one "pixel" in UV coordinates
		vec2 pixelSize = 1.0/SCREEN_UV * 20.1;
		// calculate the position of the lower-left corner of the current pixel
		vec2 pixelPos = floor(uv / pixelSize) * pixelSize;
		color.rgb = mix(color.rgb, vec3(0.0), smoothstep(0.5, 1.0, length(uv - pixelPos)));
		color.rgb *= diff;
		COLOR = color;
	} else {
		COLOR = vec4(0.0);	
	}
}