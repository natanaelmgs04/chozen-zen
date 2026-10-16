class_name Fase1Cenas
extends RefCounted

## Cenas da Fase 1, encenadas na própria casa com linguagem de cinema:
## - antes de cada enquete: a situação que pede uma decisão;
## - depois: o personagem fazendo o que o jogador escolheu, antes de ver o resultado.
## Falas com retrato (jogador à esquerda, mãe à direita), clima de cor por momento,
## impact frame nos choques e o celular em tela cheia nas conversas com a turma e o Lucas.
## Cada opção do roteiro aponta para uma cena pelo campo "cena" (ver fase1_roteiro.gd).

const PORTA_QUARTO := Vector2(1120, 212)
## Caminho por baixo da mesa e das cadeiras do jantar (y livre de móveis).
const CORREDOR_SOB_A_MESA := 650.0
const AO_LADO_DA_MAE := Vector2(964, 540)

var d: DiretorCasa
var player: CharacterBody2D
var mae: CharacterBody2D
var casa: Casa

func _init(diretor: DiretorCasa, p_casa: Casa) -> void:
	d = diretor
	player = d.player
	mae = d.mae
	casa = p_casa

func antes(id: String, variante := "") -> void:
	match id:
		"chegada":
			if variante == "corredor":
				await _antes_chegada_corredor()
			else:
				await _antes_chegada()
		"jantar":
			await _antes_jantar()
		"noite":
			await _antes_noite()

func depois(opcao: Dictionary) -> void:
	var metodo := "_depois_" + str(opcao.get("cena", ""))
	if has_method(metodo):
		await Callable(self, metodo).call()

# --- Chegada ------------------------------------------------------------------------

func _antes_chegada() -> void:
	_olhar_um_para_o_outro()
	d.emote(mae, "?", 1.0)
	await d.espera(0.6)
	if mae.global_position.distance_to(player.global_position) > 110.0:
		await mae.walk_to(_perto_de(player, mae, 95.0), 100.0)
		_olhar_um_para_o_outro()
	await d.dizer("mae", "preocupada", "Filho? Chegou tão quieto...\nAconteceu alguma coisa?")
	d.emote(player, "...", 1.4)
	await d.dizer("voce", "triste", "Não tô a fim de falar disso agora.", true)

func _antes_chegada_corredor() -> void:
	player.face("up")
	d.emote(mae, "!", 0.9)
	await d.dizer("mae", "surpresa", "Ei, ei! Nem um \"oi\" pra sua mãe?")
	_olhar_um_para_o_outro()
	var distancia := mae.global_position.distance_to(player.global_position)
	if distancia > 110.0:
		var passo := minf(distancia - 95.0, 220.0)
		await mae.walk_to(mae.global_position.move_toward(player.global_position, passo), 130.0)
	_olhar_um_para_o_outro()
	await d.dizer("mae", "preocupada", "Que cara é essa? Aconteceu alguma coisa?")
	await d.dizer("voce", "triste", "Só queria chegar no meu quarto...", true)

func _depois_contar() -> void:
	await player.walk_to(_perto_de(player, mae, 70.0), 90.0)
	_olhar_um_para_o_outro()
	await d.dizer("voce", "triste", "Hoje foi horrível, mãe... A professora achou uma cola embaixo da minha cadeira.")
	await d.dizer("voce", "irritado", "Mas não era minha! [shake rate=18 level=5]Ninguém acreditou em mim.[/shake]")
	d.emote(mae, "!", 0.8)
	d.clima("quente", 1.2)
	Audio.sfx("warm")
	await mae.walk_to(mae.global_position.move_toward(player.global_position, 18.0), 50.0)
	_olhar_um_para_o_outro()
	d.emote(mae, "coracao", 2.0)
	d.emote(player, "coracao", 2.0)
	await d.dizer("mae", "feliz", "[wave amp=22 freq=3]Ei... vem cá.[/wave] Eu acredito em você, tá bom?")
	await d.dizer("voce", "envergonhado", "...Obrigado, mãe.")

func _depois_disfarcar() -> void:
	d.emote(player, "nota", 1.3)
	await d.dizer("voce", "envergonhado", "Tá tudo bem, mãe. Só tô cansado. Valeu por perguntar.")
	d.emote(mae, "...", 1.5)
	await d.dizer("mae", "preocupada", "...Tá bom. Se quiser conversar, eu tô aqui.")

func _depois_ignorar() -> void:
	d.clima("frio", 1.0)
	var longe := player.global_position + (player.global_position - mae.global_position).normalized() * 55.0
	await player.walk_to(longe, 80.0)
	await d.espera(0.3)
	d.emote(mae, "triste", 1.8)
	await d.dizer("mae", "triste", "...Filho?")

func _depois_grosseiro() -> void:
	d.emote(player, "raiva", 1.6)
	d.impacto(player)
	d.clima("tensao", 0.3)
	d.inclinar(4.0, 0.3)
	await d.dizer("voce", "irritado", "[shake rate=30 level=12]ME DEIXA EM PAZ![/shake]")
	d.emote(mae, "!", 0.8)
	var recuo := mae.global_position + (mae.global_position - player.global_position).normalized() * 30.0
	await mae.walk_to(recuo, 140.0)
	mae.face_towards(player.global_position)
	d.inclinar(0.0, 1.2)
	d.clima("frio", 1.2)
	d.emote(mae, "triste", 1.8)
	await d.dizer("mae", "triste", "...Eu só queria ajudar.")

# --- Jantar -------------------------------------------------------------------------

func _antes_jantar() -> void:
	var lugar_mae := casa.assento("cadeira_e")
	var lugar := casa.assento("cadeira_d")
	# a mãe já está sentada na cabeceira esquerda; se ainda estiver a caminho, senta agora
	if not mae.sentada:
		await mae.walk_to(Vector2(lugar_mae["pos"][0], lugar_mae["pos"][1]), 160.0)
		mae.sentar("right")
	player.pode_levantar = false
	await d.andar(player, _rota_para_a_cabeceira(), 170.0)
	await player.sentar(Vector2(lugar["pos"][0], lugar["pos"][1]), "left", Vector2(lugar["saida"][0], lugar["saida"][1]))
	# os dois começam a comer, um de frente para o outro
	player.comer(true)
	mae.comer(true)
	Audio.sfx("clink")
	await d.espera(1.2)
	Audio.sfx("clink", -4.0)
	if GameState.has_flag("contou_mae"):
		d.clima("quente", 1.0)
		await d.dizer("mae", "feliz", "Eu acredito em você, viu? Amanhã cedo eu ligo pra escola.")
	else:
		if GameState.has_flag("ignorou") or GameState.has_flag("grosseiro"):
			d.emote(mae, "triste", 1.2)
			await d.dizer("mae", "triste", "...Come, vai esfriar.")
		Audio.sfx("phone")
		mae.comer(false)
		d.emote(mae, "celular", 1.3)
		await d.espera(1.0)
		d.clima("frio", 0.8)
		await d.dizer("mae", "surpresa", "Um e-mail da escola... [color=#b9616a]\"Ocorrência durante a avaliação\"[/color]?")
		player.comer(false)
		d.emote(player, "!", 1.0)
		Audio.sfx("heartbeat")
		await d.dizer("mae", "brava", "Filho. O que foi que aconteceu hoje?")
	mae.comer(false)
	Audio.sfx("baby_cry")
	d.emote(mae, "choro", 1.8)
	d.tremer(3.0)
	await d.dizer("mae", "preocupada", "Ai, não... agora não, meu amor...")
	player.comer(false)

func _depois_pegar_bebe() -> void:
	await _ir_ate_a_mae()
	d.clima("quente", 1.0)
	Audio.sfx("warm")
	d.emote(mae, "coracao", 1.8)
	await d.dizer("mae", "feliz", "Obrigada, filho. [wave amp=18 freq=3]Você não faz ideia do quanto isso ajuda.[/wave]")
	d.emote(mae, "nota", 1.4)
	await d.espera(1.0)

func _depois_pegar_bebe_fugir() -> void:
	await _ir_ate_a_mae()
	d.emote(mae, "nota", 1.2)
	await d.espera(1.0)
	d.emote(mae, "?", 1.3)
	await d.dizer("mae", "preocupada", "Obrigada... mas a gente ainda vai falar desse e-mail.")

func _depois_agradecer() -> void:
	await d.dizer("voce", "neutro", "Valeu, mãe. De verdade.")
	player.comer(true)
	Audio.sfx("clink")
	await d.espera(0.6)
	Audio.sfx("baby_cry")
	d.emote(mae, "choro", 1.4)
	d.emote(player, "...", 1.3)
	await d.dizer("mae", "preocupada", "Imagina... *suspiro*")

func _depois_nao_ligar() -> void:
	await d.dizer("voce", "irritado", "Não liga pra escola, por favor. Eu resolvo sozinho.")
	d.emote(mae, "?", 0.9)
	await d.dizer("mae", "preocupada", "Tem certeza? ...Tá bom. Mas eu tô preocupada.")

func _depois_reclamar_choro() -> void:
	Audio.sfx("baby_cry")
	d.emote(player, "raiva", 1.4)
	d.fx.pulso_aberracao(8.0, 0.6)
	d.tremer(6.0)
	d.clima("tensao", 0.4)
	await d.dizer("voce", "irritado", "[shake rate=26 level=9]Não dá pra comer com esse choro![/shake]")
	await _sair_da_mesa()
	await d.dizer("mae", "triste", "...")

func _depois_sair_exagero() -> void:
	d.emote(player, "raiva", 1.2)
	d.clima("tensao", 0.4)
	await d.dizer("voce", "irritado", "A escola tá exagerando. Não aconteceu nada!")
	await _sair_da_mesa()
	await d.dizer("mae", "brava", "Volta aqui! A gente não terminou essa conversa!")

func _depois_contar_verdade() -> void:
	player.comer(false)
	await d.dizer("voce", "triste", "A cola não era minha, mãe. Juro. Acharam embaixo da minha cadeira.")
	d.emote(mae, "!", 0.9)
	await d.dizer("mae", "triste", "E por que você não me contou antes?")
	d.clima("quente", 1.2)
	Audio.sfx("warm")
	d.emote(mae, "coracao", 1.6)
	await d.dizer("mae", "neutra", "...Tudo bem. Eu acredito em você.")

func _depois_adiar() -> void:
	await d.dizer("voce", "envergonhado", "É um mal-entendido. Amanhã eu explico, prometo.")
	d.emote(mae, "?", 1.3)
	await d.dizer("mae", "preocupada", "Amanhã eu tenho reunião com a sua professora. Espero que você tenha razão.")

# --- Antes de dormir ----------------------------------------------------------------

func _antes_noite() -> void:
	player.face("up")
	d.clima("noite", 1.0)
	d.emote(player, "zzz", 1.2)
	await d.dizer("voce", "triste", "Que dia...", true)
	Audio.sfx("phone")
	d.emote(player, "celular", 1.2)
	await d.espera(0.8)
	player.face("down")
	d.fx.desfocar(3.0)
	await d.celular.abrir("Lucas", "online", "22:14")
	await d.celular.mensagem("Lucas", "e aí")
	await d.celular.mensagem("Lucas", "deu ruim hoje né?", false, 0.9)
	await d.espera(1.0)
	await d.celular.fechar()
	d.fx.desfocar(0.0)

func _depois_estudar() -> void:
	await d.dizer("voce", "neutro", "Se eu for bem amanhã, ninguém vai poder dizer nada.", true)
	d.emote(player, "livro", 1.8)
	Audio.sfx("page")
	await d.espera(0.7)
	Audio.sfx("page")
	await d.espera(0.9)
	await _entrar_no_quarto()

func _depois_perguntar_lucas() -> void:
	d.fx.desfocar(3.0)
	await d.celular.abrir("Lucas", "online", "22:15")
	await d.celular.mensagem("Lucas", "deu ruim hoje né?", false, 0.0)
	await d.celular.mensagem("Você", "a cola era sua?", true)
	await d.celular.digitando_e_some("Lucas", 1.6)
	await d.celular.mensagem("Lucas", "...", false, 1.0)
	await d.celular.mensagem("Lucas", "foi mal. era minha", false, 1.2)
	Audio.sfx("heartbeat")
	d.fx.pulso_aberracao(7.0, 0.7)
	await d.celular.mensagem("Lucas", "não fala nada pfv", false, 0.8)
	await d.espera(1.2)
	await d.celular.fechar()
	d.fx.desfocar(0.0)
	d.emote(player, "!", 1.2)
	await d.dizer("voce", "surpreso", "Eu sabia.", true)

func _depois_dormir() -> void:
	await d.dizer("voce", "triste", "Amanhã eu resolvo isso.", true)
	d.emote(player, "zzz", 1.6)
	await d.espera(0.8)
	await _entrar_no_quarto()

func _depois_indireta() -> void:
	d.fx.desfocar(3.0)
	await d.celular.abrir("Seu story", "agora mesmo", "22:15")
	await d.celular.mensagem("Você", "tem gente muito falsa nessa sala.", true)
	await d.espera(0.6)
	for aviso in ["Bia reagiu ao seu story", "Rafa: quem??", "Duda: eita kkkk", "Gui: tá falando de quem?", "27 visualizações", "Lucas visualizou"]:
		d.celular.notificacao(aviso)
		await d.espera(0.4)
	await d.espera(1.2)
	await d.celular.fechar()
	d.fx.desfocar(0.0)
	d.emote(player, "suor", 1.8)
	await d.dizer("voce", "envergonhado", "...Talvez não tenha sido uma boa ideia.", true)

# --- Ajudantes ----------------------------------------------------------------------

func _olhar_um_para_o_outro() -> void:
	mae.face_towards(player.global_position)
	var direcao := mae.global_position - player.global_position
	if absf(direcao.x) > absf(direcao.y):
		player.face("right" if direcao.x > 0 else "left")
	else:
		player.face("down" if direcao.y > 0 else "up")

## Ponto a `distancia` de `ate`, na direção de `de`.
func _perto_de(de: Node2D, ate: Node2D, distancia: float) -> Vector2:
	return ate.global_position + (de.global_position - ate.global_position).normalized() * distancia

## Contorna a mesa (por baixo, ou pela direita se ele vier de cima) até a cabeceira direita.
func _rota_para_a_cabeceira() -> Array[Vector2]:
	var p := player.global_position
	var saida: Array = casa.assento("cadeira_d")["saida"]
	var destino := Vector2(saida[0], saida[1])
	var rota: Array[Vector2] = []
	if p.x > destino.x - 30.0:
		rota.append(Vector2(p.x, destino.y))
	elif p.y < 430.0:
		rota.append(Vector2(1372, p.y))
		rota.append(Vector2(1372, destino.y))
	else:
		rota.append(Vector2(p.x, CORREDOR_SOB_A_MESA))
		rota.append(Vector2(destino.x, CORREDOR_SOB_A_MESA))
	rota.append(destino)
	return rota

## Levanta da cabeceira e dá a volta por baixo da mesa até o lado da mãe.
func _ir_ate_a_mae() -> void:
	player.pode_levantar = false
	await player.levantar()
	player.lock_input(true)
	await d.andar(player, [Vector2(player.global_position.x, CORREDOR_SOB_A_MESA),
		Vector2(AO_LADO_DA_MAE.x, CORREDOR_SOB_A_MESA), AO_LADO_DA_MAE], 170.0)
	player.face("right")

## Levanta de uma vez (o prato fica na mesa) e vai embora pela sala.
func _sair_da_mesa() -> void:
	player.pode_levantar = false
	await player.levantar()
	player.lock_input(true)
	await player.walk_to(Vector2(1300, 700), 150.0)
	d.emote(mae, "triste", 1.6)
	await d.espera(0.6)

func _entrar_no_quarto() -> void:
	await player.walk_to(PORTA_QUARTO, 90.0)
	var tween := player.create_tween()
	tween.tween_property(player, "modulate:a", 0.0, 0.4)
	await tween.finished
