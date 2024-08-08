shader_type particles;

void start() {
	// Called when a particle is spawned.
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	COLOR = vec4(vec3(1.0, 0.0, 0.0), 1.0);
}
