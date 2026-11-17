extends Node
## Estado global do jogo (um "autoload").
##
## O Godot carrega este script sozinho quando o jogo começa (veja
## Projeto > Configurações do Projeto > Globais / Autoload). Por isso
## qualquer script pode chamar, por exemplo: Jogo.concluir_objetivo("balde")
##
## Por enquanto ele cuida de duas coisas:
##   1. a lista de objetivos que aparece no canto da tela;
##   2. mensagens curtas (pensamentos do Mateus, avisos) na parte de baixo.

## Avisa a interface (HUD) que a lista de objetivos mudou.
signal objetivos_mudaram(objetivos: Array)
## Pede para a interface mostrar um texto por alguns segundos.
signal mensagem(texto: String, duracao: float)

## Cada objetivo é um dicionário: {"id": "balde", "texto": "Pegar o balde", "feito": false}
var objetivos: Array[Dictionary] = []


## Troca a lista inteira. Use no começo de cada fase.
## Exemplo: Jogo.definir_objetivos([["balde", "Pegar o balde de milho"], ["galinhas", "Dar milho às galinhas"]])
func definir_objetivos(lista: Array) -> void:
	objetivos.clear()
	for item in lista:
		objetivos.append({"id": str(item[0]), "texto": str(item[1]), "feito": false})
	objetivos_mudaram.emit(objetivos)


## Acrescenta um objetivo no fim da lista.
func adicionar_objetivo(id: String, texto: String) -> void:
	objetivos.append({"id": id, "texto": texto, "feito": false})
	objetivos_mudaram.emit(objetivos)


## Marca um objetivo como feito (ele fica riscado/apagado na tela).
func concluir_objetivo(id: String) -> void:
	for objetivo in objetivos:
		if objetivo["id"] == id and not objetivo["feito"]:
			objetivo["feito"] = true
			objetivos_mudaram.emit(objetivos)
			return


func objetivo_concluido(id: String) -> bool:
	for objetivo in objetivos:
		if objetivo["id"] == id:
			return objetivo["feito"]
	return false


func todos_concluidos() -> bool:
	for objetivo in objetivos:
		if not objetivo["feito"]:
			return false
	return true


## Mostra um texto curto na parte de baixo da tela.
func mostrar_mensagem(texto: String, duracao: float = 3.0) -> void:
	mensagem.emit(texto, duracao)
