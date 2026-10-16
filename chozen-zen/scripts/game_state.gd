extends Node

## Autoload: estado da vida do personagem.
## Reputação dura a vida toda (RF-AGE-002); Energia reinicia a cada capítulo (RF-ENE-001);
## flags guardam as escolhas para as consequências futuras (RF-CAP-002).

signal reputation_changed(new_value: int)
signal energy_changed(new_value: int)

const REPUTATION_MAX := 100
const ENERGY_MAX := 100
const ENERGY_CHAPTER_START := 50

var reputation: int = REPUTATION_MAX
var energy: int = ENERGY_CHAPTER_START
var flags := {}

func reset() -> void:
	reputation = REPUTATION_MAX
	flags.clear()
	reputation_changed.emit(reputation)
	start_chapter()

func start_chapter() -> void:
	energy = ENERGY_CHAPTER_START
	energy_changed.emit(energy)

func apply_reputation_delta(delta: int) -> void:
	reputation = clampi(reputation + delta, 0, REPUTATION_MAX)
	reputation_changed.emit(reputation)

func apply_energy_delta(delta: int) -> void:
	energy = clampi(energy + delta, 0, ENERGY_MAX)
	energy_changed.emit(energy)

func can_afford(option: Dictionary) -> bool:
	return energy + int(option.get("energia", 0)) >= 0

func apply_option(option: Dictionary) -> void:
	if option.has("flag"):
		flags[option["flag"]] = true
	apply_energy_delta(option.get("energia", 0))
	apply_reputation_delta(option.get("reputacao", 0))

func has_flag(flag: String) -> bool:
	return flags.has(flag)
