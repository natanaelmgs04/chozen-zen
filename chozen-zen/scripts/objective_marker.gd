extends Node2D

## Seta flutuante que mostra onde está o objetivo atual.

const FILL := Color("d9878a")
const OUTLINE := Color("1f4b3b")

var _target: Node2D
var _point := Vector2.ZERO
var _height := 0.0
var _time := 0.0

func point_at_node(target: Node2D, height: float) -> void:
	_target = target
	_height = height
	visible = true

func point_at(point: Vector2) -> void:
	_target = null
	_point = point
	visible = true

func _process(delta: float) -> void:
	_time += delta
	var base := _target.global_position - Vector2(0, _height) if _target else _point
	global_position = base + Vector2(0, sin(_time * 4.0) * 6.0)

func _draw() -> void:
	var tri := PackedVector2Array([Vector2(-13, -16), Vector2(13, -16), Vector2(0, 4)])
	draw_colored_polygon(tri, FILL)
	tri.append(tri[0])
	draw_polyline(tri, OUTLINE, 3.0)
