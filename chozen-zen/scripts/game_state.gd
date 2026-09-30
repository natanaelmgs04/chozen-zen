extends Node

## Autoload (RF-AGE-002): reputação global, começa em 100 e é ajustada por decisão.

signal reputation_changed(new_value: int)

const REPUTATION_MAX := 100
const REPUTATION_MIN := 0

var reputation: int = REPUTATION_MAX

func reset() -> void:
	reputation = REPUTATION_MAX
	reputation_changed.emit(reputation)

func apply_reputation_delta(delta: int) -> void:
	reputation = clampi(reputation + delta, REPUTATION_MIN, REPUTATION_MAX)
	reputation_changed.emit(reputation)
