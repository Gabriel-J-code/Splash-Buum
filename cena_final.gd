extends Control # Ou o tipo do nó raiz da sua cena de vitória

# === REFERÊNCIAS DE NÓS (AJUSTE OS CAMINHOS!) ===
@onready var player_1_label = $BoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Player1Label
@onready var player_2_label = $BoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Player2Label
@onready var nova_partida_button = $BoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/BtnNovaPartida
@onready var menu_inicial_button = $BoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/BtnMenuInicial


func initialize(winner_id: int) -> void:
	# Garante que a tela de vitória também está no modo Processamento
	self.set_process_mode(PROCESS_MODE_ALWAYS)
	
	# Esconde ambos os labels para mostrar apenas o vencedor
	if player_1_label and player_2_label:
		player_1_label.visible = false
		player_2_label.visible = false
		
	if winner_id == 1:
		if player_1_label:
			player_1_label.visible = true # Mostra apenas o label do vencedor
		
	elif winner_id == 2:
		if player_2_label:
			player_2_label.visible = true # Mostra apenas o label do vencedor
			
	elif winner_id == 0:
		# Trata o empate (ex: você pode usar um label separado 'Empate!')
		$BoxContainer/VBoxContainer/VBoxContainer/VencedorLabel.text = "Empate"
		
# === LÓGICA DOS BOTÕES ===

func _on_nova_partida_pressed() -> void:
	get_tree().paused = false 
	self.queue_free()
	get_tree().reload_current_scene()
	
func _on_menu_inicial_pressed() -> void:
	get_tree().paused = false 
	# AJUSTE O CAMINHO
	get_tree().change_scene_to_file("res://cenas inicial/cena_menu_inicial.tscn")
	self.queue_free()
