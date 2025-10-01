extends Node2D
@onready var pause_menu = $PauseMenu 
var is_paused: bool = false

# =================================================================
# A. Lógica de Input (Pausar/Despausar)
# =================================================================

func _input(event: InputEvent) -> void:
	# Usa a ação padrão 'ui_cancel' (geralmente Esc ou P) para pausar
	if event.is_action_pressed("pausar"): 
		toggle_pause()

func toggle_pause() -> void:
	# Inverte o estado da pausa
	is_paused = not is_paused
	
	# Aplica o estado de pausa na árvore de cena
	get_tree().paused = is_paused 
	
	# Alterna a visibilidade do menu
	pause_menu.visible = is_paused
	
	# Gerencia o cursor do mouse (útil para jogos em 2D)
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# Assumindo que o jogo esconde o cursor
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

# =================================================================
# B. Métodos de Ação dos Botões (Conexões)
# =================================================================

# 1. CONTINUAR
func _on_continuar_pressed() -> void:
	print("ok")
	toggle_pause()

# 2. RECOMEÇAR
func _on_recomecar_pressed() -> void:
	# Importante: Despausa o jogo antes de recarregar a cena!
	get_tree().paused = false 
	get_tree().reload_current_scene()

# 3. CONFIGURAÇÕES (Placeholder)
func _on_configuracoes_pressed() -> void:
	print("Abrir Tela de Configurações")
	# TODO: Implementar a lógica de transição para a cena de Configurações

# 4. MENU INICIAL
func _on_menu_inicial_pressed() -> void:
	# Importante: Despausa o jogo antes de sair
	get_tree().paused = false 
	# AJUSTE O CAMINHO para a sua cena de Menu Inicial
	get_tree().change_scene_to_file("res://cenas inicial/cena_menu_inicial.tscn")
	
