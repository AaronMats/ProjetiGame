extends Control

# Muda para a cena para o seletor de fases
func _on_botao_jogar_pressed():
	get_tree().change_scene_to_file("res://menu/seletor_fases.tscn")

# Fecha o jogo
func _on_botao_sair_pressed():
	get_tree().quit()

# Muda pra tela de créditos
func _on_botao_creditos_pressed():
	get_tree().change_scene_to_file("res://menu/creditos.tscn")
