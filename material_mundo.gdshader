shader_type spatial;

// Tarea A: la niebla negra de las catacumbas (Arias Albarracin Diomar Alexis)
// Dos ondas sumadas y color por altura entre valle (#0B0D14) y cresta (#3A3F4B)

uniform vec3 color_bajo : source_color = vec3(0.043, 0.051, 0.078);
uniform vec3 color_alto : source_color = vec3(0.227, 0.247, 0.294);

uniform float amplitud = 0.25;
uniform float longitud = 3.0;
uniform float periodo = 3.0;

uniform float amplitud2 = 0.08;
uniform float longitud2 = 1.3;
uniform float periodo2 = 1.9;

varying float altura;

float onda(float x, float t, float a, float l, float p) {
	return a * sin(TAU / l * x - TAU / p * t);
}

float pendiente(float x, float t, float a, float l, float p) {
	return a * (TAU / l) * cos(TAU / l * x - TAU / p * t);
}

void vertex() {
	float h = onda(VERTEX.x, TIME, amplitud, longitud, periodo)
		+ onda(VERTEX.x, TIME, amplitud2, longitud2, periodo2);
	float s = pendiente(VERTEX.x, TIME, amplitud, longitud, periodo)
		+ pendiente(VERTEX.x, TIME, amplitud2, longitud2, periodo2);
	VERTEX.y += h;
	NORMAL = normalize(vec3(-s, 0.0, 1.0));
	altura = h;
}

void fragment() {
	float m = clamp(altura / (2.0 * (amplitud + amplitud2)) + 0.5, 0.0, 1.0);
	ALBEDO = mix(color_bajo, color_alto, m);
	ROUGHNESS = 0.4;
}
