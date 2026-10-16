extends Node2D

## Ponteiros do relógio de parede: o dos segundos anda de verdade (a casa tem vida).

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var agora := Time.get_time_dict_from_system()
	var segundos: float = agora["second"]
	var minutos: float = agora["minute"] + segundos / 60.0
	var horas: float = fmod(agora["hour"], 12.0) + minutos / 60.0
	_ponteiro(horas / 12.0, 8.0, 3.0, Color("2a1a12"))
	_ponteiro(minutos / 60.0, 12.0, 2.0, Color("2a1a12"))
	_ponteiro(floorf(segundos) / 60.0, 13.0, 1.0, Color("b9616a"))

func _ponteiro(fracao: float, comprimento: float, largura: float, cor: Color) -> void:
	var angulo := fracao * TAU - PI / 2.0
	draw_line(Vector2.ZERO, Vector2.from_angle(angulo) * comprimento, cor, largura)
