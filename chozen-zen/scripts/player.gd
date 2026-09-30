extends CharacterBody2D

const SPEED := 130.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _facing := "up"
var _input_locked := false

func _ready() -> void:
	add_to_group("player")

func lock_input(locked: bool) -> void:
	_input_locked = locked
	if locked:
		velocity = Vector2.ZERO
		move_and_slide()
		sprite.play("idle_%s" % _facing)

func _physics_process(_delta: float) -> void:
	if _input_locked:
		return
	var input_vector := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	velocity = input_vector.normalized() * SPEED
	move_and_slide()
	_update_animation(input_vector)

func _update_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		sprite.play("idle_%s" % _facing)
		return
	if absf(input_vector.x) > absf(input_vector.y):
		_facing = "right" if input_vector.x > 0 else "left"
	else:
		_facing = "down" if input_vector.y > 0 else "up"
	sprite.play("walk_%s" % _facing)
