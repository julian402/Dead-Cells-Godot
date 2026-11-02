extends Node
# Tarea A nivel 1: lleva la hora y hace las cuentas del sol

const NARANJA = Color("0B0D14")   # el color bajo de la paleta en las catacumbas (#0B0D14)

@export var hora = 6.5            # h, al empezar (6.5 h -> elevacion 7.5 grados)
@export var duracion_dia = 48.0   # s reales que dura un dia de 24 h
@export var pausado = true        # fija en las catacumbas


func avanzar(dt):
	if not pausado:
		hora = fposmod(hora + 24.0 * dt / duracion_dia, 24.0)


static func elevacion(h):
	return (h - 6.0) * 15.0        # 6 h -> 0°, 12 h -> 90°, 18 h -> 180°


static func factor_sol(h):
	return max(0.0, sin(deg_to_rad(elevacion(h))))


static func color_sol(h):
	return NARANJA.lerp(Color.WHITE, factor_sol(h))
