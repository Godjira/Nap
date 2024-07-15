shader_type canvas_item;

void vertex() {
	
}

void fragment() {
	vec2 col;
	float t = TIME*.01;
	vec2 uv = UV+vec2(t,t*2.0);
	float factor = 1.5;
	vec2 v1;
	for(int i=0;i<15;i++)
	{
	    uv *= -factor*factor;
	    v1 = uv.yx/factor;
	    uv += sin(v1+col+t*10.0)/factor;
	    col += vec2(sin(uv.x-uv.y+v1.x-col.y), sin(uv.y-uv.x+v1.y-col.x));
	}
	COLOR = vec4(vec3(col.x+4.0,col.x-col.y/2.0,col.x/5.0)/2.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
