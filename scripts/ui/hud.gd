extends CanvasLayer
## Interface na tela: mira, texto de interação, objetivos, legendas e
## barra de fôlego. Ela se conecta sozinha ao jogador (grupo "jogador")
## e ao autoload Jogo.

@onready var prompt: Label = %Prompt
@onready var lista_objetivos: VBoxContainer = %ListaObjetivos
@onready var painel_objetivos: Control = %PainelObjetivos
@onready var legenda: Label = %Legenda
@onready var barra_folego: ProgressBar = %BarraFolego

var _tween_legenda: Tween


func _ready() -> void:
	prompt.hide()
	legenda.hide()
	barra_folego.hide()

	Jogo.objetivos_mudaram.connect(_ao_mudar_objetivos)
	Jogo.mensagem.connect(mostrar_legenda)
	_ao_mudar_objetivos(Jogo.objetivos)

	var jogador := get_tree().get_first_node_in_group("jogador")
	if jogador:
		jogador.alvo_mudou.connect(_ao_mudar_alvo)
		jogador.folego_mudou.connect(_ao_mudar_folego)


func _ao_mudar_alvo(texto: String) -> void:
	if texto.is_empty():
		prompt.hide()
	else:
		prompt.text = "[%s] %s" % [_nome_da_tecla("interagir"), texto]
		prompt.show()


func _ao_mudar_folego(fracao: float) -> void:
	barra_folego.value = fracao
	barra_folego.visible = fracao < 0.999


func _ao_mudar_objetivos(objetivos: Array) -> void:
	for filho in lista_objetivos.get_children():
		filho.queue_free()
	painel_objetivos.visible = not objetivos.is_empty()
	for objetivo in objetivos:
		var rotulo := Label.new()
		rotulo.label_settings = prompt.label_settings
		if objetivo["feito"]:
			rotulo.text = "[x] " + objetivo["texto"]
			rotulo.modulate = Color(1, 1, 1, 0.45)
		else:
			rotulo.text = "[  ] " + objetivo["texto"]
		lista_objetivos.add_child(rotulo)


## Mostra um texto embaixo e apaga devagar depois de "duracao" segundos.
func mostrar_legenda(texto: String, duracao: float = 3.0) -> void:
	if _tween_legenda:
		_tween_legenda.kill()
	legenda.text = texto
	legenda.modulate.a = 1.0
	legenda.show()
	_tween_legenda = create_tween()
	_tween_legenda.tween_interval(duracao)
	_tween_legenda.tween_property(legenda, "modulate:a", 0.0, 0.6)
	_tween_legenda.tween_callback(legenda.hide)


## Nome da primeira tecla ligada a uma ação (respeita teclados AZERTY etc.).
func _nome_da_tecla(acao: String) -> String:
	for evento in InputMap.action_get_events(acao):
		var tecla := evento as InputEventKey
		if tecla:
			var codigo := DisplayServer.keyboard_get_keycode_from_physical(tecla.physical_keycode)
			return OS.get_keycode_string(codigo)
	return "?"
