extends Control

func _on_botao_jogar_pressed():
	# Muda para a cena da sua primeira fase (ou seletor de fases)
	# Certifique-se de colocar o caminho correto da sua cena aqui entre aspas!
	get_tree().change_scene_to_file("res://mundo.tscn")

func _on_botao_sair_pressed():
	# Fecha o jogo completamente
	get_tree().quit()
