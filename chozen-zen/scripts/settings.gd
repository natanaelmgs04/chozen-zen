extends Node

## Autoload "Settings": volumes, tela cheia e acessibilidade, salvos em user://settings.cfg.

signal changed

const PATH := "user://settings.cfg"
const TEXT_SPEEDS := ["Normal", "Rápida", "Instantânea"]
const CHARS_PER_SECOND := [45.0, 110.0, 0.0]
const FONT_SIZE_NORMAL := 18
const FONT_SIZE_LARGE := 22

var volume_master := 0.9
var volume_music := 0.7
var volume_sfx := 0.9
var volume_ambience := 0.8
var fullscreen := false
var text_speed := 0
var large_text := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load()
	apply()

func apply() -> void:
	_set_bus("Master", volume_master)
	_set_bus("Music", volume_music)
	_set_bus("SFX", volume_sfx)
	_set_bus("Ambience", volume_ambience)
	# Só troca o modo quando a opção muda: no navegador, forçar "janela" quebra o tamanho do canvas.
	var current := DisplayServer.window_get_mode()
	var is_fullscreen := current == DisplayServer.WINDOW_MODE_FULLSCREEN or current == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if is_fullscreen != fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	ThemeDB.get_project_theme().default_font_size = FONT_SIZE_LARGE if large_text else FONT_SIZE_NORMAL
	changed.emit()

func save() -> void:
	var config := ConfigFile.new()
	for key in ["volume_master", "volume_music", "volume_sfx", "volume_ambience", "fullscreen", "text_speed", "large_text"]:
		config.set_value("settings", key, get(key))
	config.save(PATH)

## 0 = texto aparece de uma vez.
func chars_per_second() -> float:
	return CHARS_PER_SECOND[text_speed]

func _load() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	for key in config.get_section_keys("settings"):
		set(key, config.get_value("settings", key))

func _set_bus(bus: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.001)
