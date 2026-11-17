class_name Interagivel
extends StaticBody3D
## Objeto que o jogador pode usar com o botão de interagir (E ou clique).
##
## Como usar no editor:
##   1. Crie um nó StaticBody3D e arraste este script para ele
##      (ou adicione um nó do tipo "Interagivel" direto pela busca de nós).
##   2. Dê a ele um CollisionShape3D e um MeshInstance3D como filhos.
##   3. No Inspetor, escreva o "Texto Interacao" (ex.: "Pegar o balde").
##   4. Na aba Nó > Sinais, conecte o sinal "interagido" ao script da fase.
##
## A camada de colisão deve incluir a camada 3 ("interagivel") para o
## raio do jogador enxergar o objeto. O padrão abaixo já faz isso.

## Emitido quando o jogador aperta o botão de interagir olhando para o objeto.
signal interagido(jogador: Node)

## Texto que aparece no centro da tela, ex.: "[E] Pegar o balde".
@export var texto_interacao: String = "Interagir"
## Desligue para o objeto parar de reagir (ex.: tarefa ainda não liberada).
@export var ativo: bool = true
## Se ligado, o objeto só pode ser usado uma vez.
@export var uma_vez: bool = false


func _ready() -> void:
	# Camada 1 (mundo, para ser sólido) + camada 3 (interagivel).
	set_collision_layer_value(1, true)
	set_collision_layer_value(3, true)


## O jogador pergunta isto antes de mostrar o texto na tela.
func pode_interagir() -> bool:
	return ativo


## O jogador chama isto quando o botão é apertado.
func interagir(jogador: Node) -> void:
	if not ativo:
		return
	if uma_vez:
		ativo = false
	interagido.emit(jogador)
