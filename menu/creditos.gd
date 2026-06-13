extends Control

# volta para o menu principal 
func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu_principal.tscn")
