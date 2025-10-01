extends Control

signal resumo_jogo
signal recarregar_jogo
signal ir_para_configuracoes
signal ir_para_menu_inicial

func _ready() -> void:	
	hide()


func _on_continuar_pressed() -> void:	
	resumo_jogo.emit()


func _on_recomeçar_pressed() -> void:
	recarregar_jogo.emit()


func _on_configurações_pressed() -> void:
	ir_para_configuracoes.emit()


func _on_menu_inicial_pressed() -> void:
	ir_para_menu_inicial.emit()
