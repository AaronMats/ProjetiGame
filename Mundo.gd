extends Node2D

# --- VARIÁVEIS DO JOGO ---
var total_objetos_fase = 3   
var objetos_encontrados = 0
var total_cliques = 0
var fase_encerrada = false

# --- REFERÊNCIAS DA INTERFACE ---
@onready var label_cliques = $CanvasLayer/LabelCliques
@onready var label_objetos = $CanvasLayer/LabelObjetos
@onready var label_final = $CanvasLayer/LabelFinal
@onready var botao_terminar = $CanvasLayer/BotaoTerminar
@onready var botao_teste = $CanvasLayer/Button
@onready var botao_teste2 = $CanvasLayer/Button2

func _ready():
	# Configuração inicial do texto na tela
	label_cliques.text = "Cliques: 0"
	label_objetos.text = "Objetos Achados: 0"
	label_final.visible = false
	botao_terminar.visible = true
	botao_teste.visible = false
	botao_teste2.visible = false

# --- DETECTOR DE CLIQUES GERAIS NO CENÁRIO ---
func _input(event):
	# Verifica se a fase está encerrada
	if fase_encerrada:
		return 
	# Verifica o evento (clique)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Verifica se o botão terminar está visível E se o mouse está exatamente em cima dele
			if botao_terminar.visible and botao_terminar.get_global_rect().has_point(event.global_position):
				return 
	# Contabilisando o clique errado
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			total_cliques += 1
			label_cliques.text = "Cliques: " + str(total_cliques)

# --- FUNÇÃO PARA QUANDO ACHA UM OBJETo ---
func objeto_clicado(nome_do_objeto):
	if fase_encerrada:
		return
	
	# Contabiliza o objeto achado e atualiza a interface	
	objetos_encontrados += 1
	label_objetos.text = "Objetos Achados: " + str(objetos_encontrados)
	
	var objeto = get_node(nome_do_objeto)

	# Desabilita a colisão imediatamente para não registrar cliques duplos
	for filho in objeto.get_children():
		if filho is CollisionShape2D:
			filho.set_deferred("disabled", true)
	
	# --- ANIMAÇÃO DO OBJETO ENCONTRADO ---
	# 1. Garante que o objeto fique na frente de tudo na tela durante a animação
	if objeto is Node2D:
		objeto.z_index = 10
	
	# 2. CRIANDO A ANIMAÇÃO DE CRESCER SUAVEMENTE
	var tween_crescer = create_tween()
	tween_crescer.tween_property(objeto, "scale", Vector2(3, 3), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween_crescer.finished
	await get_tree().create_timer(1.0).timeout
	
	# 3. FADE-OUT
	var tween_sumir = create_tween()
	tween_sumir.tween_property(objeto, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween_sumir.finished
	objeto.queue_free()

# --- SINAIS DOS OBJETOS ---
func _on_Chave_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj01")

func _on_Chave2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj02")

func _on_Chave3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objeto_clicado("Obj03")


# --- SINAL DO BOTÃO TERMINAR FASE ---
func _on_BotaoTerminar_pressed():
	if fase_encerrada:
		return
		
	fase_encerrada = true

	var pontuacao
	# Porcentagem de acerto baseada em todos os cliques dados e objetos encontrados
	if total_cliques == 0:
		pontuacao = 0.0
	else:
		pontuacao = (float(objetos_encontrados) / float(total_objetos_fase)) * (float(objetos_encontrados) / float(total_cliques)) * 100.0

	# Garante que nunca saia do intervalo 0-100
	pontuacao = clamp(pontuacao, 0.0, 100.0)
	
	# Esconde o botão de terminar e deixa visível o texto final
	botao_terminar.visible = false
	label_final.visible = true
	
	
	# Mostra o resultado final na tela
	label_final.text = "--- FIM DE JOGO ---\n"
	label_final.text += "Pontuação Final: " + str(int(pontuacao)) + "%\n"
	label_final.text += "Total de Cliques: " + str(total_cliques)
	
	# Deixa visível os botões de voltar e próxima fase
	botao_teste.visible = true
	botao_teste2.visible = true
	
# --- FUNÇÕES PARA OS BOTÕES DE VOLTAR E PRÓXIMA FASE --- 
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://seletor_fases.tscn")
	
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Mundo.tscn")
