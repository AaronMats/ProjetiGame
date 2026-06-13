extends Control

# Muda a cena para a primeira fase
func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://load/tela_tutorial.tscn")

# volta para o menu principal 
func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu_principal.tscn")
