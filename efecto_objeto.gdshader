shader_type spatial;
// Tarea B: el orbe de luz robada. flash y avance los cambia ControlEfectos desde GDScript

uniform vec3 color_base : source_color = vec3(0.239, 0.961, 0.878);   // #3DF5E0
uniform vec3 color_flash : source_color = vec3(0.91, 0.263, 0.227);   // #E8433A
uniform float flash : hint_range(0.0, 1.0) = 0.0;

// nivel 3: dissolve
uniform sampler2D ruido;
uniform float avance : hint_range(0.0, 1.0) = 0.0;
uniform float ancho_borde = 0.06;
uniform vec3 color_borde : source_color = vec3(0.8, 1.0, 0.97);

void fragment() {
	ALBEDO = mix(color_base, color_flash, flash);
	EMISSION = color_flash * flash;

	float r = texture(ruido, UV).r;
	if (r < avance) {
		discard;
	}
	if (avance > 0.0 && r < avance + ancho_borde) {
		EMISSION = color_borde * 2.0;
	}
}
