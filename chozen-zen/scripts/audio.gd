extends Node

## Autoload "Audio": música, ambiente e efeitos em canais separados (Music, SFX, Ambience).
## Também dá som e uma leve reação de escala a todo botão do jogo, sem precisar ligar um a um.

const MUSIC_THEME := preload("res://assets/audio/music_tema_casa.wav")
const AMB_DAY := preload("res://assets/audio/amb_casa_dia.wav")
const AMB_NIGHT := preload("res://assets/audio/amb_casa_noite.wav")
const AMB_CLASSROOM := preload("res://assets/audio/amb_sala_de_aula.wav")
const AMB_STREET := preload("res://assets/audio/amb_rua.wav")
const MUSIC_TENSION := preload("res://assets/audio/music_tensao.wav")
const MUSIC_MELANCHOLY := preload("res://assets/audio/music_melancolia.wav")

const SFX := {
	"hover": preload("res://assets/audio/ui_hover.wav"),
	"click": preload("res://assets/audio/ui_click.wav"),
	"open": preload("res://assets/audio/ui_open.wav"),
	"choice": preload("res://assets/audio/choice_confirm.wav"),
	"rep_down": preload("res://assets/audio/rep_down.wav"),
	"rep_up": preload("res://assets/audio/rep_up.wav"),
	"energy_up": preload("res://assets/audio/energy_up.wav"),
	"memory": preload("res://assets/audio/memory.wav"),
	"objective": preload("res://assets/audio/objective.wav"),
	"blip": preload("res://assets/audio/text_blip.wav"),
	"transition": preload("res://assets/audio/transition.wav"),
	"pop": preload("res://assets/audio/emote_pop.wav"),
	"paper": preload("res://assets/audio/papel.wav"),
	"sting": preload("res://assets/audio/sting.wav"),
	"whispers": preload("res://assets/audio/cochicho.wav"),
	"phone": preload("res://assets/audio/celular.wav"),
	"door": preload("res://assets/audio/porta.wav"),
	"baby_cry": preload("res://assets/audio/bebe_chorando.wav"),
	"clink": preload("res://assets/audio/talheres.wav"),
	"page": preload("res://assets/audio/pagina.wav"),
	"ping": preload("res://assets/audio/notificacao.wav"),
	"impact": preload("res://assets/audio/impacto.wav"),
	"swoosh": preload("res://assets/audio/swoosh.wav"),
	"heartbeat": preload("res://assets/audio/batimento.wav"),
	"warm": preload("res://assets/audio/calor.wav"),
}
const STEPS := [
	preload("res://assets/audio/step_0.wav"), preload("res://assets/audio/step_1.wav"),
	preload("res://assets/audio/step_2.wav"), preload("res://assets/audio/step_3.wav"),
]
const SFX_VOICES := 10
const MUFFLED_HZ := 1100.0

var _music: AudioStreamPlayer
var _ambience: AudioStreamPlayer
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _music_tween: Tween
var _ambience_tween: Tween
var _muffle_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = _make_player("Music")
	_ambience = _make_player("Ambience")
	for i in SFX_VOICES:
		_voices.append(_make_player("SFX"))
	get_tree().node_added.connect(_on_node_added)

func _make_player(bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	return player

func play_music(stream: AudioStreamWAV = MUSIC_THEME, fade := 2.0) -> void:
	if _music.stream == stream and _music.playing:
		return
	_music.stream = _looping(stream)
	_music.volume_db = -40.0
	_music.play()
	_music_tween = _fade(_music, _music_tween, 0.0, fade)

func stop_music(fade := 1.0) -> void:
	_music_tween = _fade(_music, _music_tween, -40.0, fade)
	_music_tween.tween_callback(_music.stop)

func play_ambience(stream: AudioStreamWAV, fade := 1.5) -> void:
	if _ambience.stream == stream and _ambience.playing:
		return
	_ambience.stream = _looping(stream)
	_ambience.volume_db = -40.0
	_ambience.play()
	_ambience_tween = _fade(_ambience, _ambience_tween, 0.0, fade)

func stop_ambience(fade := 1.0) -> void:
	_ambience_tween = _fade(_ambience, _ambience_tween, -40.0, fade)
	_ambience_tween.tween_callback(_ambience.stop)

## Abafa a música (passa-baixa) — usado à noite e por trás de menus.
func set_music_muffled(muffled: bool, seconds := 1.2) -> void:
	var effect := AudioServer.get_bus_effect(AudioServer.get_bus_index("Music"), 0) as AudioEffectLowPassFilter
	if _muffle_tween:
		_muffle_tween.kill()
	_muffle_tween = create_tween()
	_muffle_tween.tween_property(effect, "cutoff_hz", MUFFLED_HZ if muffled else 20000.0, seconds)

func sfx(sound: String, volume_db := 0.0, pitch_jitter := 0.0) -> void:
	_play_voice(SFX[sound], volume_db, pitch_jitter)

## Efeito com tom definido (vozes dos personagens no diálogo).
func sfx_pitch(sound: String, pitch: float, volume_db := 0.0, pitch_jitter := 0.0) -> void:
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = SFX[sound]
	voice.volume_db = volume_db
	voice.pitch_scale = pitch * (1.0 + randf_range(-pitch_jitter, pitch_jitter))
	voice.play()

func step() -> void:
	_play_voice(STEPS.pick_random(), -4.0, 0.08)

func _play_voice(stream: AudioStream, volume_db: float, pitch_jitter: float) -> void:
	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = stream
	voice.volume_db = volume_db
	voice.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	voice.play()

func _looping(stream: AudioStreamWAV) -> AudioStreamWAV:
	var copy: AudioStreamWAV = stream.duplicate()
	copy.loop_mode = AudioStreamWAV.LOOP_FORWARD
	copy.loop_begin = 0
	copy.loop_end = int(stream.get_length() * stream.mix_rate)
	return copy

func _fade(player: AudioStreamPlayer, previous: Tween, to_db: float, seconds: float) -> Tween:
	if previous:
		previous.kill()
	var tween := create_tween()
	tween.tween_property(player, "volume_db", to_db, seconds)
	return tween

# --- Botões: som de hover/clique e uma leve reação de escala (game feel na interface).

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		var button := node as BaseButton
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.focus_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))
		button.focus_exited.connect(_on_button_unhover.bind(button))
		button.pressed.connect(sfx.bind("click"))
		button.resized.connect(func() -> void: button.pivot_offset = button.size / 2)

func _on_button_hover(button: BaseButton) -> void:
	if button.disabled:
		return
	sfx("hover", 0.0, 0.05)
	_scale_button(button, 1.03)

func _on_button_unhover(button: BaseButton) -> void:
	if not button.has_focus() and not button.is_hovered():
		_scale_button(button, 1.0)

func _scale_button(button: BaseButton, target: float) -> void:
	var tween := button.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2.ONE * target, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
