extends Control

func _on_botao_jogar_pressed():
	# Muda para a cena para o seletor de fases
	get_tree().change_scene_to_file("res://menu/seletor_fases.tscn")

func _on_botao_sair_pressed():
	# Fecha o jogo
	get_tree().quit()
