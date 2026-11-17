class_name Jogador
extends CharacterBody3D
## Jogador em primeira pessoa (Mateus).
##
## Estrutura da cena (cenas/jogador/jogador.tscn):
##   Jogador (CharacterBody3D)      -> gira para os lados (olhar esquerda/direita)
##   ├─ Colisao (CollisionShape3D)  -> cápsula do corpo
##   ├─ Cabeca (Node3D)             -> gira para cima/baixo
##   │   └─ Camera3D                -> recebe o balanço dos passos e o tremor
##   │       └─ RaioInteracao (RayCast3D) -> enxerga objetos interagíveis
##   ├─ SomPassos (AudioStreamPlayer3D)
##   └─ SomRespiracao (AudioStreamPlayer)
##
## Controles (Projeto > Configurações do Projeto > Mapa de Entrada):
##   WASD/setas andar, mouse olhar, Shift correr, E ou clique interagir,
##   Espaço segurar o fôlego, Esc soltar o mouse.
##
## Outras partes do jogo controlam o jogador por estas variáveis e funções:
##   pode_mover / pode_olhar / pode_segurar_folego  (cutscenes, esconderijo)
##   tremer(0.5)                                    (sustos)
##   sinal fez_barulho                              (a IA do lobisomem vai ouvir)

## Barulho feito pelo jogador. intensidade vai de 0 (nada) a 1 (muito alto).
signal fez_barulho(posicao: Vector3, intensidade: float)
## Um passo aconteceu (bom para sincronizar sons).
signal deu_passo(correndo: bool)
## O texto do objeto que o jogador está olhando mudou ("" = nenhum).
signal alvo_mudou(texto: String)
## Fôlego atual de 0 (sem ar) a 1 (cheio).
signal folego_mudou(fracao: float)
## O jogador segurou o fôlego até o fim e puxou o ar com força.
signal folego_acabou

@export_group("Movimento")
@export var velocidade_andar: float = 2.4
@export var velocidade_correr: float = 4.4
## Quanto maior, mais rápido chega à velocidade desejada.
@export var aceleracao: float = 10.0
@export var desaceleracao: float = 12.0

@export_group("Olhar")
@export_range(0.0005, 0.01, 0.0001) var sensibilidade_mouse: float = 0.0025
@export var limite_olhar_graus: float = 80.0

@export_group("Balanço da câmera")
@export var balanco_altura: float = 0.035
@export var balanco_lateral: float = 0.025
@export var passos_por_segundo_andando: float = 1.8
@export var passos_por_segundo_correndo: float = 2.7
## Inclinação leve da câmera ao andar de lado.
@export var inclinacao_lateral_graus: float = 1.5

@export_group("Estamina e fôlego")
## Segundos de corrida com a estamina cheia.
@export var estamina_maxima: float = 5.0
@export var recuperacao_estamina: float = 0.8
## Segundos que o Mateus aguenta sem respirar.
@export var folego_maximo: float = 6.0
@export var recuperacao_folego: float = 1.5

@export_group("Interação")
@export var alcance_interacao: float = 2.2

@export_group("Sons")
## Arraste aqui alguns sons de passo (.ogg/.wav). Um é sorteado a cada passo.
@export var sons_passos: Array[AudioStream] = []
## Respiração ofegante, tocada quando a estamina acaba.
@export var som_ofegante: AudioStream

var pode_mover: bool = true
var pode_olhar: bool = true
var pode_segurar_folego: bool = true

var esta_correndo: bool = false
var segurando_folego: bool = false
var estamina: float
var folego: float

var _cansado: bool = false
var _sem_ar: bool = false
var _entrada: Vector2 = Vector2.ZERO
var _fase_balanco: float = 0.0
var _forca_balanco: float = 0.0
var _passo_anterior: int = -1
var _trauma: float = 0.0
var _tempo_ruido: float = 0.0
var _ruido := FastNoiseLite.new()
var _alvo: Node = null
var _texto_alvo: String = ""
var _gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cabeca: Node3D = $Cabeca
@onready var camera: Camera3D = $Cabeca/Camera3D
@onready var raio: RayCast3D = $Cabeca/Camera3D/RaioInteracao
@onready var som_passos: AudioStreamPlayer3D = $SomPassos
@onready var som_respiracao: AudioStreamPlayer = $SomRespiracao


func _ready() -> void:
	estamina = estamina_maxima
	folego = folego_maximo
	raio.target_position = Vector3(0.0, 0.0, -alcance_interacao)
	camera.make_current()
	_ruido.frequency = 0.3  # tremor rápido (cerca de 9 vezes por segundo)
	capturar_mouse(true)


func _unhandled_input(evento: InputEvent) -> void:
	var movimento_mouse := evento as InputEventMouseMotion
	if movimento_mouse and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if pode_olhar:
			# screen_relative não muda com o tamanho da janela.
			rotate_y(-movimento_mouse.screen_relative.x * sensibilidade_mouse)
			cabeca.rotate_x(-movimento_mouse.screen_relative.y * sensibilidade_mouse)
			var limite := deg_to_rad(limite_olhar_graus)
			cabeca.rotation.x = clampf(cabeca.rotation.x, -limite, limite)
		return

	if evento.is_action_pressed("pausar"):
		capturar_mouse(false)
		return

	# Clicar na janela com o mouse solto prende o mouse de novo (e não interage).
	var clique := evento as InputEventMouseButton
	if clique and clique.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		capturar_mouse(true)
		get_viewport().set_input_as_handled()
		return

	if evento.is_action_pressed("interagir") and _alvo != null:
		_alvo.interagir(self)
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravidade * delta

	_entrada = Vector2.ZERO
	if pode_mover:
		_entrada = Input.get_vector("mover_esquerda", "mover_direita", "mover_frente", "mover_tras")

	_atualizar_estamina(delta)

	# Direção relativa para onde o jogador está virado.
	var direcao := transform.basis * Vector3(_entrada.x, 0.0, _entrada.y)
	var velocidade := velocidade_correr if esta_correndo else velocidade_andar
	var desejada := direcao * velocidade
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var taxa := aceleracao if desejada.length() > 0.01 else desaceleracao
	# 1 - exp(-taxa * delta) deixa a suavização igual em qualquer FPS.
	horizontal = horizontal.lerp(desejada, 1.0 - exp(-taxa * delta))
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	move_and_slide()

	_atualizar_folego(delta)
	_atualizar_alvo()


func _process(delta: float) -> void:
	_atualizar_balanco(delta)
	_atualizar_tremor(delta)


# --- Funções públicas -------------------------------------------------------

## Prende (true) ou solta (false) o mouse na janela.
func capturar_mouse(prender: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if prender else Input.MOUSE_MODE_VISIBLE


## Faz a câmera tremer. quantidade de 0 a 1 (0.3 = leve, 1 = susto forte).
func tremer(quantidade: float) -> void:
	_trauma = clampf(_trauma + quantidade, 0.0, 1.0)


## Trava ou destrava o jogador (útil em diálogos e cutscenes).
func travar(travado: bool) -> void:
	pode_mover = not travado
	pode_olhar = not travado


# --- Estamina e fôlego ------------------------------------------------------

func _atualizar_estamina(delta: float) -> void:
	var quer_correr := pode_mover and Input.is_action_pressed("correr") \
		and _entrada.y < -0.1 and is_on_floor()
	esta_correndo = quer_correr and not _cansado and estamina > 0.0

	if esta_correndo:
		estamina = maxf(estamina - delta, 0.0)
		if estamina <= 0.0:
			_cansado = true
			if som_ofegante:
				som_respiracao.stream = som_ofegante
				som_respiracao.play()
	else:
		estamina = minf(estamina + recuperacao_estamina * delta, estamina_maxima)
		# Só volta a correr depois de recuperar um pouco.
		if _cansado and estamina >= estamina_maxima * 0.35:
			_cansado = false


func _atualizar_folego(delta: float) -> void:
	var antes := folego
	var apertando := Input.is_action_pressed("segurar_folego")

	if pode_segurar_folego and apertando and not _sem_ar and folego > 0.0:
		segurando_folego = true
		folego = maxf(folego - delta, 0.0)
		if folego <= 0.0:
			# Não aguentou: puxa o ar com barulho. A IA pode ouvir isso.
			segurando_folego = false
			_sem_ar = true
			folego_acabou.emit()
			fez_barulho.emit(global_position, 1.0)
			tremer(0.25)
	else:
		segurando_folego = false
		folego = minf(folego + recuperacao_folego * delta, folego_maximo)
		# Para segurar de novo é preciso soltar a tecla e recuperar um pouco.
		if _sem_ar and not apertando and folego >= folego_maximo * 0.3:
			_sem_ar = false

	if not is_equal_approx(antes, folego):
		folego_mudou.emit(folego / folego_maximo)


# --- Balanço da câmera e passos ---------------------------------------------

func _atualizar_balanco(delta: float) -> void:
	var velocidade_h := Vector2(velocity.x, velocity.z).length()
	var andando := is_on_floor() and velocidade_h > 0.3

	# A força do balanço cresce e some suavemente (sem "pulo" ao parar).
	var forca_alvo := 0.0
	if andando:
		forca_alvo = 1.4 if esta_correndo else 1.0
	_forca_balanco = lerpf(_forca_balanco, forca_alvo, 1.0 - exp(-8.0 * delta))

	if andando:
		var passos_por_segundo := passos_por_segundo_correndo if esta_correndo else passos_por_segundo_andando
		# Cada passo avança meia volta (PI) na fase.
		_fase_balanco += delta * passos_por_segundo * PI
		# A câmera desce ao ponto mais baixo uma vez por passo: é aí que o pé toca o chão.
		var passo_atual := floori((2.0 * _fase_balanco - 1.5 * PI) / TAU)
		if passo_atual != _passo_anterior:
			_passo_anterior = passo_atual
			_dar_passo()

	camera.position = Vector3(
		sin(_fase_balanco) * balanco_lateral * _forca_balanco,
		sin(_fase_balanco * 2.0) * balanco_altura * _forca_balanco,
		0.0)

	var inclinacao := -_entrada.x * deg_to_rad(inclinacao_lateral_graus)
	camera.rotation.z = lerpf(camera.rotation.z, inclinacao, 1.0 - exp(-6.0 * delta))


func _dar_passo() -> void:
	deu_passo.emit(esta_correndo)
	fez_barulho.emit(global_position, 0.8 if esta_correndo else 0.3)
	if not sons_passos.is_empty():
		som_passos.stream = sons_passos.pick_random()
		som_passos.pitch_scale = randf_range(0.9, 1.1)
		som_passos.play()


# --- Tremor (sustos) --------------------------------------------------------

func _atualizar_tremor(delta: float) -> void:
	_trauma = maxf(_trauma - delta * 1.2, 0.0)
	_tempo_ruido += delta * 30.0
	# Elevar ao quadrado deixa tremores pequenos bem sutis.
	var forca := _trauma * _trauma
	camera.h_offset = _ruido.get_noise_2d(_tempo_ruido, 0.0) * 0.08 * forca
	camera.v_offset = _ruido.get_noise_2d(0.0, _tempo_ruido) * 0.08 * forca


# --- Interação --------------------------------------------------------------

func _atualizar_alvo() -> void:
	var novo: Node = null
	if pode_mover and raio.is_colliding():
		novo = _achar_interagivel(raio.get_collider())

	var texto := ""
	if novo != null:
		texto = str(novo.get("texto_interacao")) if "texto_interacao" in novo else "Interagir"

	_alvo = novo
	if texto != _texto_alvo:
		_texto_alvo = texto
		alvo_mudou.emit(texto)


## Procura um nó com a função interagir() no objeto atingido ou nos pais dele.
func _achar_interagivel(objeto: Object) -> Node:
	var no := objeto as Node
	for _i in 3:
		if no == null:
			return null
		if no.has_method("interagir"):
			if no.has_method("pode_interagir") and not no.pode_interagir():
				return null
			return no
		no = no.get_parent()
	return null
