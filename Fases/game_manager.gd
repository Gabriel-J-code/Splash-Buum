extends TileMap

# === CONFIGURAÇÕES DO ATLAS E DO MAPA ===
const TILE_SIZE: int = 64 # Tamanho do Tile (deve ser 64x64)
const SOURCE_ID: int = 0  # O ID da sua textura Atlas no TileSet (geralmente 0)
const LAYER_ID: int = 0   # O layer do TileMap usado para pintura (geralmente 0)

# Coordenadas do Atlas (Coluna, Linha) - Baseado na sua imagem (coluna vertical)
const TILE_COORDS_WALL: Vector2i    = Vector2i(0, 0) # Muro (cinza/tijolo)
const TILE_COORDS_NEUTRAL: Vector2i = Vector2i(0, 1) # Terreno Padrão (verde)
const TILE_COORDS_P1: Vector2i      = Vector2i(0, 2) # Cor Jogador 1 (azul)
const TILE_COORDS_P2: Vector2i      = Vector2i(0, 3) # Cor Jogador 2 (rosa)

# Mapeia o ID do jogador (1 ou 2) para as Coordenadas do Tile de Cor
const PLAYER_TO_TILE_COORDS = {
	1: TILE_COORDS_P1,
	2: TILE_COORDS_P2,
}

var score_p1: int = 0
var score_p2: int = 0
	
var perc_jogador_1: Label = null
var perc_jogador_2: Label = null

var total_colorable_tiles: float = 0.0 

var game_duration: float = 0.0
var time_label: Label = null # Variável para guardar a referência ao Label do tempo

const  GAME_OVER_SCENE = preload("res://cenaFinal.tscn") 
func _ready() -> void:
	# --- Referenciando os Labels ---	
	# 1. Encontrar o nó raiz (geralmente get_parent() se o TileMap for filho de Fase 1)
	# ou usar get_tree().root.get_node("Fase 1") se Fase 1 for a cena raiz.
	var scene_root = get_parent() 
	
	# 2. Navegar pelo caminho (AJUSTE OS NOMES DOS NÓS EXATAMENTE COMO NA SUA CENA)
	# CUIDADO: Os nomes dos nós devem ser exatos!
	if scene_root:
		perc_jogador_1 = scene_root.get_node("Control/Fundo Cenario/Control2/MarginContainer/MarginContainer/HBoxContainer/MarginContainerJ1/VBoxContainerJ1/PercJogador1")
		# Você precisa completar o caminho exato para o PercJogador2 também!
		perc_jogador_2 = scene_root.get_node("Control/Fundo Cenario/Control2/MarginContainer/MarginContainer/HBoxContainer/MarginContainerJ3/VBoxContainerJ1/PercJogador2")
	
	if perc_jogador_1:
		print("UI do Jogador 1 encontrada.")
	else:
		push_error("ERRO: Nó 'PercJogador1' não encontrado. Verifique o caminho!")
		
	if perc_jogador_2:
		print("UI do Jogador 2 encontrada.")
	else:
		push_error("ERRO: Nó 'PercJogador2' não encontrado. Verifique o caminho!")
		
	# --- Calcular Total de Tiles ---
	# Conta todos os tiles que não são Muro para o total de %
	for cell in get_used_cells(LAYER_ID):
		if get_cell_atlas_coords(LAYER_ID, cell) != TILE_COORDS_WALL:
			total_colorable_tiles += 1.0 
	update_score()
	
	time_label = get_parent().get_node("Control/Fundo Cenario/Control2/MarginContainer/MarginContainer/HBoxContainer/MarginContainerJ2/VBoxContainerJ1/LabelTempo") 
	start_game()
	
func _process(_delta: float) -> void:
	# Esta função é chamada a cada frame, mas só precisa rodar se o timer estiver ativo
	if $GameTimer.is_stopped():
		return
		
	var time_left = $GameTimer.time_left
	
	# Formata o tempo para Minutos:Segundos
	@warning_ignore("integer_division")
	var seconds = int(time_left) % 60
	var time_string = "%02d s" % [seconds]
	
	if time_label:
		time_label.text = time_string

func start_game() -> void:
	$GameTimer.start()
	game_duration = $GameTimer.wait_time
	# Opcional: Chama _process(delta) para atualizar o Label imediatamente
	_process(0) 

# === LÓGICA DA BOMBA E PINTURA ===

# Esta função é chamada pela bomba (sinal 'exploded')
func color_area_3x3(center_position: Vector2, player_id: int) -> void:
	"""
	Pinta uma área 3x3 no TileMap com a cor do jogador que soltou a bomba.
	Ignora tiles de Muro (parede).
		"""
	
	var tile_coords_to_set = PLAYER_TO_TILE_COORDS.get(player_id)
	if tile_coords_to_set == null:
		print("Erro: ID de jogador inválido.")
		return
		
	# Converte a posição mundial (pixel) para a coordenada da célula no TileMap
	var center_cell = local_to_map(center_position)
		
	# Itera sobre o padrão 3x3 (de -1 a 1 em X e Y)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var target_cell = center_cell + Vector2i(x, y)
			
			# Checa a coordenada atual do tile que está sendo pintado
			var current_coords = get_cell_atlas_coords(LAYER_ID, target_cell)
			
			# Se o tile alvo for o Muro (Wall), não pinta e pula para o próximo tile
			if current_coords == TILE_COORDS_WALL:
				continue
	
			# Pinta o tile com a nova cor
			# set_cell(layer, coordinates, source_id, atlas_coordinates)
			set_cell(LAYER_ID, target_cell, SOURCE_ID, tile_coords_to_set)
						
	# Recalcula e atualiza o placar após a pintura
	update_score()


# === LÓGICA DE PONTUAÇÃO ===

func update_score() -> void:
	"""
	Calcula e atualiza a pontuação de cada jogador.
	"""
	# 1. ZERAR AS PONTUAÇÕES
	score_p1 = 0
	score_p2 = 0
	var score_neutral: int = 0 # Incluímos o score neutro para o cálculo total

	# Itera sobre todas as células que foram alteradas no TileMap
	for cell in get_used_cells(LAYER_ID):
		var tile_atlas_coords = get_cell_atlas_coords(LAYER_ID, cell)
		
		if tile_atlas_coords == TILE_COORDS_P1:
			score_p1 += 1
		elif tile_atlas_coords == TILE_COORDS_P2:
			score_p2 += 1
		elif tile_atlas_coords == TILE_COORDS_NEUTRAL:
			score_neutral += 1
		
		# O Muro (WALL) é ignorado, pois não é colorível.

	# 2. CALCULAR O TOTAL DE TILES COLORÍVEIS
	# O total é a soma de todos os tiles pintados + tiles neutros
	total_colorable_tiles = float(score_p1 + score_p2 + score_neutral)

	# Checagem para evitar divisão por zero (se o mapa estiver completamente vazio)
	if total_colorable_tiles == 0.0:
		total_colorable_tiles = 1.0 

	# 3. CALCULAR E ATUALIZAR AS PORCENTAGENS
	var percent_p1 = (score_p1 / total_colorable_tiles) * 100.0
	var percent_p2 = (score_p2 / total_colorable_tiles) * 100.0

	if perc_jogador_1:
		# Exibe a porcentagem com uma casa decimal e a pontuação bruta
		perc_jogador_1.text = "(%.1f%% - %d tiles)" % [percent_p1, score_p1]

	if perc_jogador_2:
		perc_jogador_2.text = "(%.1f%% - %d tiles)" % [percent_p2, score_p2]

	print("--- PLACAR --- Total Tiles Coloríveis:", total_colorable_tiles)
	print("P1: %d (%.1f%%) | P2: %d (%.1f%%)" % [score_p1, percent_p1, score_p2, percent_p2])
	
	
func is_tile_occupied_by_bomb(world_position: Vector2) -> bool:
	"""
	Verifica se existe um nó 'Bomb' na célula do TileMap.
	"""
	# 1. Converte a posição mundial para a coordenada da célula no TileMap
	var cell_coords = local_to_map(world_position)
	# 2. Converte a coordenada da célula de volta para a posição mundial central
	var tile_center = map_to_local(cell_coords)
	# 3. Usa um método de checagem de área (como um raycast ou get_tree())
	#    Para simplificar, vamos iterar sobre todos os filhos da cena principal
	#    que estão centralizados no tile_center.
	# Melhor forma: Se você criou um grupo "bombs" ou "bomb" para suas bombas,
	# itere sobre o grupo e compare a posição.
	for bomb_node in get_tree().get_nodes_in_group("bombs"):
		# Se a bomba estiver exatamente na posição central da célula
		if bomb_node.global_position.is_equal_approx(tile_center):
			return true
	return false


func _on_game_timer_timeout() -> void:
	# 1. Certifica-se de que a pontuação está finalizada
	update_score() 
	
	# 2. Determina o Vencedor
	var winner_id: int
	
	# Assumindo que score_p1 e score_p2 são variáveis globais ou calculadas
	# com os valores finais (o que já está sendo feito em update_score)
	var final_score_p1 = score_p1 # Use a pontuação final calculada
	var final_score_p2 = score_p2 

	if final_score_p1 > final_score_p2:
		winner_id = 1
	elif final_score_p2 > final_score_p1:
		winner_id = 2
	else:
		# Em caso de empate, você pode definir um ID especial (ex: 0)
		winner_id = 0 
		print("EMPATE!")

	# 3. Transição para a Tela de Vitória
	transition_to_game_over(winner_id)
	
func transition_to_game_over(winner_id: int) -> void:
	# 1. Pausa o jogo (se não estiver já pausado)
	get_tree().paused = true 
	
	# 2. Instancia a nova cena de Game Over
	var game_over_screen = GAME_OVER_SCENE.instantiate()
	
	# 3. Adiciona a cena de Game Over no nó raiz da árvore
	get_tree().root.add_child(game_over_screen) 
	
	# 4. Chama a função de inicialização da tela de Game Over
	game_over_screen.initialize(winner_id)
	
	# 5. Opcional: Remove a cena do jogo (Fase 1) do loop, se desejar.
	# get_parent().queue_free()
