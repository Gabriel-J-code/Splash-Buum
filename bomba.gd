extends Area2D

# === SINAIS ===
# Sinal emitido para o GameManager (TileMap) para iniciar a pintura.
signal exploded(center_position: Vector2, player_id: int)
# Sinal emitido para o Player para liberar o limite de bombas.
signal bomb_removed 

# === PROPRIEDADES ===
@export var fuse_time: float = 3.0 # Tempo até a explosão (3 segundos padrão)
var player_id: int = 0             # ID do jogador que colocou a bomba (1 ou 2)
const TILE_SIZE: int = 64          # Tamanho do Tile (para alinhamento no grid)

# === MÉTODOS NATIVOS ===

func _ready() -> void:
	# Conecta o sinal de 'timeout' do Timer (FuseTimer) à função de explosão
	#$FuseTimer.timeout.connect(_on_fuse_timer_timeout)
	pass

# === INICIALIZAÇÃO ===

func initialize(id: int, player_position: Vector2) -> void:
	"""
	Define o ID do jogador, alinha a bomba ao centro do tile e inicia o timer.
	Chamado pelo Player.gd.
	"""
	player_id = id
	
	# 1. Alinha a posição da bomba exatamente ao centro do tile (Grid Snap)
	var grid_x = round(player_position.x / TILE_SIZE) * TILE_SIZE
	var grid_y = round(player_position.y / TILE_SIZE) * TILE_SIZE
	global_position = Vector2(grid_x, grid_y)
	
	# 2. Inicia o Timer de Fusível
	$FuserTimer.start(fuse_time)

# === EXPLOSÃO ===

func _on_fuser_timer_timeout() -> void:
	"""
	Função chamada quando o Timer termina. Aciona a explosão e remove a bomba.
	"""
	# 1. EMITE O SINAL DE PINTURA: Diz ao GameManager para pintar a área 3x3
	exploded.emit(global_position, player_id)
	
	# 2. NOTIFICA O JOGADOR: Libera o slot de bomba para o jogador
	bomb_removed.emit() 
	
	# 3. TODO: Instanciar a cena/animação visual da explosão circular aqui
	$AnimatedSprite2D.play()
	
	# 4. Remove a bomba da cena
	queue_free() # Replace with function body.
