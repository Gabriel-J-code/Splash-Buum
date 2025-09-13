extends Control

@export var maximo_jogadores: int = 2
var jogadores_atuais: int = 1
var item_foco: int = 0
var itens_focaveis: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itens_focaveis.append($VBoxContainer/PlayBtn)
	itens_focaveis.append($VBoxContainer/ConfigBtn)
	itens_focaveis.append($VBoxContainer/SairBtn)
	
	mudar_jogadores(0)
	
	set_focus_on_item(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event):	
	if event.is_action_pressed("j1_move_cima"):
		# Move o foco para cima, pulando o item de jogadores
		item_foco = (item_foco - 1 + itens_focaveis.size()) % itens_focaveis.size()
		set_focus_on_item(item_foco)
		get_viewport().set_input_as_handled()		
				
	elif event.is_action_pressed("j1_move_baixo"):
		# Move o foco para baixo, pulando o item de jogadores
		item_foco = (item_foco + 1) % itens_focaveis.size()
		set_focus_on_item(item_foco)
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("j1_move_esquerda"):
		# Se o item de jogadores estiver visível, altera o número
		if item_foco == 0: # Se o foco for 'Opções', este é o 1o item do array de foco
			mudar_jogadores(-1)
			get_viewport().set_input_as_handled()
			
	elif event.is_action_pressed("j1_move_direita"):
		# Se o item de jogadores estiver visível, altera o número
		if item_foco == 0:
			mudar_jogadores(1)
			get_viewport().set_input_as_handled()
			
	elif event.is_action_pressed("j1_confirma"):
		# Simula um clique no item focado
		itens_focaveis[item_foco].emit_signal("pressed")
		get_viewport().set_input_as_handled()

	
func set_focus_on_item(index: int):
	# Remove o foco de todos os itens e adiciona ao item selecionado
	for item in itens_focaveis:
		item.release_focus()
	itens_focaveis[index].grab_focus()
	
func mudar_jogadores(direction: int):
	# Altera o número de jogadores, garantindo que não ultrapasse os limites
	jogadores_atuais += direction
	if jogadores_atuais > maximo_jogadores:
		jogadores_atuais = 1
	elif jogadores_atuais < 1:
		jogadores_atuais = maximo_jogadores
		
	var text = ""
	if int(jogadores_atuais) == 1:
		text = " Jogador"
	else:
		text = " Jogadores"
	$VBoxContainer/HBoxContainer/NJogadores.text = str(jogadores_atuais) + text


func _on_btn_esquerdo_pressed() -> void:
	mudar_jogadores(-1)


func _on_btn_direito_pressed() -> void:
	mudar_jogadores(1)
