class_name Fase1Roteiro

## Conteúdo do capítulo "Fase 1 — Família: Uma noite em casa".
## Cada opção: texto, reputacao, energia (custo negativo), feedback, flag (memória para o futuro).

const TITULO := "Fase 1 — Família"
const SUBTITULO := "Uma noite em casa"

## A introdução (a cola na prova) é contada pela cutscene de abertura; aqui ficam só as dicas
## que aparecem quando o jogador ganha o controle.
const DICAS: Array[String] = [
	"WASD / Setas: mover   ·   E: interagir   ·   Esc: pausar",
	"Energia: ser atencioso cansa. Com 0, você apaga de sono.",
	"Reputação: é como os outros te veem. O que você escolhe volta depois.",
]

const CHEGADA := {
	"id": "chegada",
	"titulo": "Chegando em casa",
	"contexto": "Você chega em casa depois de um dia cansativo. Sua mãe percebe que você está diferente e pergunta se aconteceu alguma coisa. Você não está muito a fim de conversar. O que você faz?",
	"opcoes": [
		{
			"texto": "Contar o que aconteceu e conversar com ela.",
			"reputacao": 0, "energia": -25, "flag": "contou_mae", "cena": "contar",
			"feedback": "Você decidiu conversar com alguém próximo e demonstrou confiança e respeito.",
		},
		{
			"texto": "Dizer que está tudo bem, mas agradecer pela preocupação.",
			"reputacao": -2, "energia": -10, "flag": "escondeu", "cena": "disfarcar",
			"feedback": "Você não quis conversar naquele momento, mas respondeu de maneira respeitosa.",
		},
		{
			"texto": "Ignorar a pergunta e ir para o quarto.",
			"reputacao": -5, "energia": 0, "flag": "ignorou", "cena": "ignorar",
			"feedback": "Você pode não querer conversar, mas ignorou alguém que demonstrou preocupação com você.",
		},
		{
			"texto": "Responder de forma grosseira.",
			"reputacao": -8, "energia": 0, "flag": "grosseiro", "cena": "grosseiro",
			"feedback": "Você poderia não querer conversar, mas escolheu tratar mal alguém que estava tentando ajudar.",
		},
	],
}

const CHEGADA_NO_CORREDOR := "Você tenta passar direto para o quarto, mas sua mãe percebe que você está diferente e pergunta se aconteceu alguma coisa. Você não está muito a fim de conversar. O que você faz?"

const JANTAR_CONTOU := {
	"id": "jantar",
	"titulo": "O jantar",
	"contexto": "Na mesa, sua mãe diz que acredita em você e que vai ligar para a escola amanhã cedo. No meio da conversa, o bebê começa a chorar e ela suspira, tão cansada quanto você.",
	"opcoes": [
		{
			"texto": "Pegar o bebê no colo para ela conseguir jantar.",
			"reputacao": 3, "energia": -25, "flag": "ajudou_bebe", "cena": "pegar_bebe",
			"feedback": "Você estava exausto, mas percebeu que sua mãe também estava. Ela sorri, aliviada.",
		},
		{
			"texto": "Agradecer o apoio e terminar de jantar.",
			"reputacao": 0, "energia": -5, "cena": "agradecer",
			"feedback": "Você agradeceu, mas deixou sua mãe se virar sozinha com o bebê.",
		},
		{
			"texto": "Pedir para ela não ligar: você resolve sozinho.",
			"reputacao": -2, "energia": -10, "flag": "pediu_nao_ligar", "cena": "nao_ligar",
			"feedback": "Ela respeita, mas fica preocupada. Agora resolver isso é com você.",
		},
		{
			"texto": "Reclamar do choro e levar o prato para o quarto.",
			"reputacao": -6, "energia": 0, "flag": "saiu_da_mesa", "cena": "reclamar_choro",
			"feedback": "Você estava esgotado, mas sua mãe também. A mesa fica em silêncio.",
		},
	],
}

const JANTAR_NAO_CONTOU := {
	"id": "jantar",
	"titulo": "O jantar",
	"contexto": "Durante o jantar, o celular da sua mãe vibra. É um e-mail da escola: a professora quer uma reunião amanhã sobre \"um problema na prova\". Sua mãe olha para você esperando uma explicação, enquanto o bebê começa a chorar.",
	"opcoes": [
		{
			"texto": "Contar a verdade: a cola não era sua.",
			"reputacao": 2, "energia": -20, "flag": "contou_mae", "cena": "contar_verdade",
			"feedback": "Você contou, mesmo cansado. Ela fica chateada por você não ter falado antes, mas acredita em você.",
		},
		{
			"texto": "Dizer que é um mal-entendido e que amanhã você explica.",
			"reputacao": -2, "energia": -5, "flag": "adiou", "cena": "adiar",
			"feedback": "Você ganhou tempo, mas sua mãe vai para a reunião sem saber o que esperar.",
		},
		{
			"texto": "Pegar o bebê no colo e mudar de assunto.",
			"reputacao": 1, "energia": -25, "flag": "ajudou_bebe", "cena": "pegar_bebe_fugir",
			"feedback": "Você ajudou sua mãe, mas fugiu da pergunta. O assunto não acabou.",
		},
		{
			"texto": "Dizer que a escola está exagerando e sair da mesa.",
			"reputacao": -6, "energia": 0, "flag": "saiu_da_mesa", "cena": "sair_exagero",
			"feedback": "Você se fechou. Amanhã sua mãe vai ouvir a história primeiro pela professora.",
		},
	],
}

const JANTAR_MAGOADA := "Mesmo magoada com você, sua mãe chama para jantar. "

const NOITE := {
	"id": "noite",
	"titulo": "Antes de dormir",
	"contexto": "No quarto, você lembra: amanhã cedo tem a prova de recuperação, e a professora ainda acha que você colou. O celular vibra. É o Lucas, que sentava atrás de você: \"e aí, deu ruim hoje né?\"",
	"opcoes": [
		{
			"texto": "Estudar para a recuperação.",
			"reputacao": 0, "energia": -30, "flag": "estudou", "cena": "estudar",
			"feedback": "Você revisou a matéria até tarde. Amanhã vai chegar preparado.",
		},
		{
			"texto": "Perguntar ao Lucas se a cola era dele.",
			"reputacao": 0, "energia": -15, "flag": "confrontou_lucas", "cena": "perguntar_lucas",
			"feedback": "Ele demora para responder. Depois: \"foi mal, era minha. não fala nada, pfv\".",
		},
		{
			"texto": "Deixar tudo para amanhã e dormir.",
			"reputacao": 0, "energia": 0, "flag": "dormiu", "cena": "dormir",
			"feedback": "Você apaga assim que deita. Pelo menos amanhã vai acordar descansado.",
		},
		{
			"texto": "Postar uma indireta sobre \"gente falsa\" nas redes.",
			"reputacao": -6, "energia": -5, "flag": "indireta", "cena": "indireta",
			"feedback": "Em minutos, a turma toda está comentando. Nem todo mundo entendeu do mesmo jeito.",
		},
	],
}

const LANCHE_ENERGIA := 15

## Aviso mostrado logo após escolhas que voltam depois (inspirado no "vai se lembrar disso").
const MEMORIAS := {
	"contou_mae": "Sua mãe vai lembrar que você confiou nela.",
	"escondeu": "Sua mãe percebeu que você escondeu algo.",
	"ignorou": "Sua mãe vai lembrar disso.",
	"grosseiro": "Sua mãe vai lembrar disso.",
	"ajudou_bebe": "Sua mãe vai lembrar da sua ajuda.",
	"pediu_nao_ligar": "Agora, resolver isso é com você.",
	"saiu_da_mesa": "Sua mãe vai lembrar disso.",
	"adiou": "Sua mãe vai à reunião sem saber de nada.",
	"estudou": "Você vai chegar preparado amanhã.",
	"confrontou_lucas": "Agora você sabe de quem era a cola.",
	"indireta": "A turma toda vai lembrar disso.",
}

const FIM_DA_DEMO := "Fim da demo — a história continua na Fase 2: Escola."


static func chegada(no_corredor: bool) -> Dictionary:
	var evento: Dictionary = CHEGADA.duplicate(true)
	if no_corredor:
		evento["contexto"] = CHEGADA_NO_CORREDOR
	return evento


static func jantar() -> Dictionary:
	var contou := GameState.has_flag("contou_mae")
	var evento: Dictionary = (JANTAR_CONTOU if contou else JANTAR_NAO_CONTOU).duplicate(true)
	if GameState.has_flag("ignorou") or GameState.has_flag("grosseiro"):
		evento["contexto"] = JANTAR_MAGOADA + evento["contexto"]
	return evento


static func resumo(apagou: bool) -> String:
	var linhas: Array[String] = []
	if GameState.has_flag("contou_mae") and GameState.has_flag("pediu_nao_ligar"):
		linhas.append("Sua mãe sabe a verdade, mas prometeu não se envolver: amanhã você encara a professora sozinho.")
	elif GameState.has_flag("contou_mae"):
		linhas.append("Sua mãe acredita em você e vai à escola amanhã cedo.")
	elif GameState.has_flag("adiou"):
		linhas.append("Sua mãe vai à reunião sem saber a sua versão da história.")
	else:
		linhas.append("Sua mãe vai ouvir a história primeiro pela professora.")

	if GameState.has_flag("ajudou_bebe"):
		linhas.append("Ela não vai esquecer que você ajudou quando ela também estava exausta.")
	if GameState.has_flag("saiu_da_mesa"):
		linhas.append("O jantar terminou em silêncio. O clima em casa ainda vai estar pesado amanhã.")

	if apagou:
		linhas.append("Você apagou no sofá antes de se preparar para a recuperação.")
	elif GameState.has_flag("estudou"):
		linhas.append("Você vai para a prova de recuperação preparado.")
	elif GameState.has_flag("confrontou_lucas"):
		linhas.append("Você descobriu que a cola era do Lucas, e ele pediu segredo. Contar ou não é uma decisão para amanhã.")
	elif GameState.has_flag("indireta"):
		linhas.append("Sua indireta já está circulando no grupo da turma.")
	elif GameState.has_flag("dormiu"):
		linhas.append("Você dormiu cedo: vai acordar descansado, mas sem ter estudado.")

	var texto := ""
	for linha in linhas:
		texto += "•  " + linha + "\n"
	return texto.strip_edges()
