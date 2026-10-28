class_name LuzParpadeante
extends OmniLight3D
## Tarea B, nivel 1. La antorcha parpadea con ruido (suave), no con randf() (que salta).
## Con la misma semilla el parpadeo es el mismo en todos los PC.

@export var energia_base := 2.0
@export var amplitud := 0.3            # 0.3 = sube o baja hasta un 30 %
@export var velocidad := 4.0           # qué tan rápido recorre el ruido
@export var semilla := 7
@export var segundos_encendida := 0.0  # 0 = nunca se apaga; 8 = se apaga 8 s después de entrar
@export var k_apagado := 1.5           # 1/s: a los 2 s de apagarse queda el 5 % (e^-3)
@export var llama: Node3D              # la malla de la llama: se esconde con la antorcha apagada

var ruido := FastNoiseLite.new()
var t := 0.0


func _ready() -> void:
	ruido.seed = semilla
	ruido.frequency = 1.0          # sin esto casi no cambia (viene en 0.01)


func _process(delta: float) -> void:
	t += delta
	# la base baja con decaer: la antorcha se apaga suave, igual a cualquier FPS
	if segundos_encendida > 0.0 and t > segundos_encendida:
		energia_base = SistemaEventos.decaer(energia_base, 0.0, k_apagado, delta)
	light_energy = energia(energia_base, amplitud, ruido.get_noise_1d(t * velocidad))
	if llama != null:
		llama.visible = light_energy > 0.05


static func energia(base: float, amp: float, valor_ruido: float) -> float:
	return maxf(0.0, base * (1.0 + amp * valor_ruido))
