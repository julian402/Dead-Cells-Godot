shader_type spatial;

// Tarea A Nivel 1: La superficie que se mueve con seno en vertex()

uniform vec3 color_bajo : source_color = vec3(0.043, 0.051, 0.078);
uniform float amplitud = 0.25;
uniform float longitud = 3.0;
uniform float periodo = 3.0;

float onda(float x, float t, float a, float l, float p) {
	return a * sin(TAU / l * x - TAU / p * t);
}

void vertex() {
	float h = onda(VERTEX.x, TIME, amplitud, longitud, periodo);
	VERTEX.y += h;
}

void fragment() {
	ALBEDO = color_bajo;
	ROUGHNESS = 0.4;
}
