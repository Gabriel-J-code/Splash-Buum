extends CharacterBody2D
#signal  hit
@export var speed = 400
var screen_size

const BOMB_SCENE = preload("res://jogador/bomba.tscn") # AJUSTE ESTE CAMINHO!
var max_bombs: int = 2 # Quantas bombas o jogador pode ter ativas
var current_bombs: int = 0

@export var n_jogador = 1

var move_direita
var move_esquerda
var move_baixo
var move_cima
var b_colocar_bomba
var extra

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	screen_size = get_viewport_rect().size	
	if n_jogador == 1:
		move_direita = "j1_move_direita"
		move_esquerda = "j1_move_esquerda"
		move_baixo = "j1_move_baixo"
		move_cima = "j1_move_cima"
		b_colocar_bomba = "j1_confirma"
		extra = "j1_cancela"
		$AnimatedSprite2D.animation = "Jogador1"
	elif n_jogador == 2:
		move_direita = "j2_move_direita"
		move_esquerda = "j2_move_esquerda"
		move_baixo = "j2_move_baixo"
		move_cima = "j2_move_cima"
		b_colocar_bomba = "j2_confirma"
		extra = "j2_cancela"
		$AnimatedSprite2D.animation = "Jogador2"
		$AnimatedSprite2D.flip_h = true
		
		
	#hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(move_direita):
		velocity.x += 1
	if Input.is_action_pressed(move_esquerda):
		velocity.x -= 1
	if Input.is_action_pressed(move_baixo):
		velocity.y += 1
	if Input.is_action_pressed(move_cima):
		velocity.y -= 1
	if Input.is_action_just_pressed(b_colocar_bomba):
		place_bomb()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
		
	#animação
	if velocity.x != 0:
		#$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
		#$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false	

func place_bomb() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	
	# Checagem de segurança (não deve acontecer se a cena estiver configurada)
	if not game_manager:
		print("Erro: GameManager não encontrado!")
		return
		
	# 1. VERIFICAÇÃO DE LIMITE (Max Bombs)
	if current_bombs >= max_bombs:
		return
		
	# 2. VERIFICAÇÃO DE SOBREPOSIÇÃO
	if game_manager.is_tile_occupied_by_bomb(global_position):
		print("Já existe uma bomba neste tile.")
		return
		
	# SE PASSOU NAS DUAS CONDIÇÕES:
	
	# 3. Cria a bomba e aumenta o contador
	current_bombs += 1
	
	var bomb_instance = BOMB_SCENE.instantiate()
	get_parent().add_child(bomb_instance)
	
	# ** Adicione a bomba ao grupo 'bombs' **
	bomb_instance.add_to_group("bombs") 

	# 4. Conexões e Inicialização
	bomb_instance.exploded.connect(game_manager.color_area_3x3)
	bomb_instance.bomb_removed.connect(_on_bomb_removed)
	
	# Inicializa a bomba, que fará o alinhamento no grid
	bomb_instance.initialize(n_jogador, global_position)

# Novo método para ser chamado quando a bomba explodir e for removida
func _on_bomb_removed() -> void:	
	current_bombs -= 1
