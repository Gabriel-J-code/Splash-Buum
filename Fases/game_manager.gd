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
	Calcula a pontuação de cada jogador contando os tiles coloridos.
	"""
	var score_p1: int = 0
	var score_p2: int = 0
	
	# Itera sobre todas as células que foram alteradas no TileMap
	for cell in get_used_cells(LAYER_ID):
		# Pega as coordenadas do tile pintado
		var tile_atlas_coords = get_cell_atlas_coords(LAYER_ID, cell)
		
		if tile_atlas_coords == TILE_COORDS_P1:
			score_p1 += 1
		elif tile_atlas_coords == TILE_COORDS_P2:
			score_p2 += 1
		
		# Opcional: Contar o terreno neutro se precisar para porcentagem total
		# elif tile_atlas_coords == TILE_COORDS_NEUTRAL:
		#     # ...

	print("--- PLACAR ---")
	print("Jogador 1 (Azul): ", score_p1)
	print("Jogador 2 (Rosa): ", score_p2)
	
	# TODO: Implementar a lógica para atualizar os Labels/ProgressBars na UI aqui.
