extends CharacterBody2D

## Mãe: circula entre pontos da casa com pausas; quando o jogador chega perto,
## para e se vira para ele. Dispara o evento de decisão uma única vez (RF-MOV-002).

signal talk_requested

const WALK_SPEED := 45.0
const ARRIVE_DISTANCE := 4.0

@export var waypoints: Array[Vector2] = []
@export var pause_range := Vector2(1.5, 3.5)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var prompt: Label = $Prompt
@onready var interaction_area: Area2D = $InteractionArea

var _player: Node2D
var _talked := false
var _facing := "down"
var _target := Vector2.ZERO
var _walking := false
var _pause_left := 0.0
var _walk_time_left := 0.0

func _ready() -> void:
	prompt.visible = false
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	_pause_left = randf_range(pause_range.x, pause_range.y)

func _physics_process(delta: float) -> void:
	if _player:
		_face(_player.global_position - global_position)
		sprite.play("idle_" + _facing)
		return
	if not _walking:
		sprite.play("idle_" + _facing)
		_pause_left -= delta
		if _pause_left <= 0.0:
			_pick_next_waypoint()
		return
	var to_target := _target - global_position
	_walk_time_left -= delta
	# Desiste do ponto se ficar bloqueada (ex.: o jogador no caminho).
	if to_target.length() <= ARRIVE_DISTANCE or _walk_time_left <= 0.0:
		_walking = false
		_pause_left = randf_range(pause_range.x, pause_range.y)
		return
	velocity = to_target.normalized() * WALK_SPEED
	move_and_slide()
	_face(velocity)
	sprite.play("walk_" + _facing)

func _pick_next_waypoint() -> void:
	var candidates := waypoints.filter(func(p: Vector2) -> bool: return p.distance_to(global_position) > 24.0)
	if candidates.is_empty():
		_pause_left = randf_range(pause_range.x, pause_range.y)
		return
	_target = candidates.pick_random()
	_walk_time_left = _target.distance_to(global_position) / WALK_SPEED + 1.5
	_walking = true

func _face(direction: Vector2) -> void:
	if direction.length_squared() < 0.01:
		return
	if absf(direction.x) > absf(direction.y):
		_facing = "right" if direction.x > 0 else "left"
	else:
		_facing = "down" if direction.y > 0 else "up"

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player = body
	_walking = false
	prompt.visible = not _talked

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		prompt.visible = false
		_pause_left = randf_range(pause_range.x, pause_range.y)

func _unhandled_input(event: InputEvent) -> void:
	if _player and not _talked and event.is_action_pressed("interact"):
		_talked = true
		prompt.visible = false
		talk_requested.emit()
