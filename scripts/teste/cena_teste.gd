extends Node3D
## Cena de teste do jogador. Serve só para experimentar andar, correr,
## olhar, interagir, segurar o fôlego e ver os objetivos funcionando.
## A fazenda de verdade (fase 1) vai ficar em cenas/fases/.
##
## Os sinais do balde e do gatilho estão conectados na própria cena
## (selecione o nó e veja a aba Nó > Sinais no editor).


func _ready() -> void:
	Jogo.definir_objetivos([
		["balde", "Pegar o balde de milho"],
		["fundos", "Dar uma volta até os fundos da casa"],
	])
	Jogo.mostrar_mensagem("WASD anda, Shift corre, E interage, Espaço segura o fôlego.", 6.0)


func _ao_pegar_balde(jogador: Node) -> void:
	Jogo.concluir_objetivo("balde")
	Jogo.mostrar_mensagem("Pesado esse trem, uai.")
	jogador.tremer(0.15)
	$BaldeMilho.queue_free()


func _ao_entrar_fundos(corpo: Node3D) -> void:
	if corpo is Jogador and not Jogo.objetivo_concluido("fundos"):
		Jogo.concluir_objetivo("fundos")
		Jogo.mostrar_mensagem("Silêncio estranho aqui atrás...")
