extends OverlayPanel

## Configurações: volumes por canal, tela cheia e acessibilidade (velocidade e tamanho do texto).

@onready var _sliders := {
	"volume_master": %MasterSlider as HSlider,
	"volume_music": %MusicSlider as HSlider,
	"volume_sfx": %SfxSlider as HSlider,
	"volume_ambience": %AmbienceSlider as HSlider,
}
@onready var _fullscreen: Button = %FullscreenButton
@onready var _text_speed: Button = %TextSpeedButton
@onready var _large_text: Button = %LargeTextButton

func _ready() -> void:
	super()
	for key in _sliders:
		var slider: HSlider = _sliders[key]
		slider.value = Settings.get(key)
		slider.value_changed.connect(_on_slider_changed.bind(key))
	_fullscreen.pressed.connect(func() -> void: _toggle("fullscreen"))
	_large_text.pressed.connect(func() -> void: _toggle("large_text"))
	_text_speed.pressed.connect(_cycle_text_speed)
	_refresh()

func close() -> void:
	Settings.save()
	super()

func _first_focus() -> Control:
	return _sliders["volume_master"]

func _on_slider_changed(value: float, key: String) -> void:
	Settings.set(key, value)
	Settings.apply()
	if key == "volume_sfx":
		Audio.sfx("click")

func _toggle(key: String) -> void:
	Settings.set(key, not Settings.get(key))
	Settings.apply()
	_refresh()

func _cycle_text_speed() -> void:
	Settings.text_speed = (Settings.text_speed + 1) % Settings.TEXT_SPEEDS.size()
	Settings.apply()
	_refresh()

func _refresh() -> void:
	_fullscreen.text = "Tela cheia: %s" % ("Sim" if Settings.fullscreen else "Não")
	_large_text.text = "Texto grande: %s" % ("Sim" if Settings.large_text else "Não")
	_text_speed.text = "Velocidade do texto: %s" % Settings.TEXT_SPEEDS[Settings.text_speed]
