shader_type canvas_item;
uniform sampler2D noise: repeat_enable, filter_nearest;
uniform float fog_density : hint_range(0.0, 1.0, 0.1) = 0.01;
uniform vec2 speed = vec2(0.005, 0.001);

void fragment() {
	vec2 uv = UV + speed * TIME;
	float n = texture(noise, uv).r;
	float fog = clamp(n * 2.0 - 1.0, 0.0, 1.0);
	COLOR.a *= fog * fog_density;
}
