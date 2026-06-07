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
@onready var botao_pausa = $CanvasLayer/BotaoPausaTela

func _ready():
	# Configuração inicial do texto na tela
	label_cliques.text = "Cliques: 0"
	label_objetos.text = "Objetos Achados: 0"
	label_final.visible = false
	botao_terminar.visible = true
	botao_teste.visible = false
	botao_teste2.visible = false
	botao_pausa.visible = true
# --- DETECTOR DE CLIQUES GERAIS NO CENÁRIO ---
func _input(event):
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" é a tecla ESC por padrão
		$CanvasLayer/MenuPause.alternar_pause()
	
	# Verifica se a fase está encerrada
	if fase_encerrada:
		return 
	# Verifica o evento (clique)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Verifica se o botão terminar está visível E se o mouse está exatamente em cima dele
			if botao_terminar.visible and botao_terminar.get_global_rect().has_point(event.global_position):
				return 		
			# TRAVA USANDO A CAIXA DE COLISÃO REAL
			var lista_objetos = get_tree().get_nodes_in_group("objetos_fase")
			for obj in lista_objetos:
				# Chamamos a nossa nova função passando o objeto e a posição do clique
				if clicou_na_colisao(obj, event.global_position):
					total_cliques += 1
					label_cliques.text = "Cliques: " + str(total_cliques)
					return # Se clicou na colisão de qualquer chave,
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Verifica se o botão terminar está visível E se o mouse está exatamente em cima dele
				if botao_pausa.get_global_rect().has_point(event.global_position):
					return 		
	# Contabilisando o clique errado
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			total_cliques += 1
			label_cliques.text = "Cliques: " + str(total_cliques)
			# CHAMA O EFEITO VISUAL DO "X" passando a posição exata do clique
			criar_efeito_erro(event.global_position)

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
	botao_pausa.visible = false
# --- FUNÇÕES PARA OS BOTÕES DE VOLTAR E PRÓXIMA FASE --- 
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://seletor_fases.tscn")
	
func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Mundo.tscn")
	
#Criando efeito de erro
func criar_efeito_erro(posicao_do_clique):
	
	#Cria um nó de Sprite2D
	var x_erro = Sprite2D.new()
	x_erro.centered = true
	x_erro.scale = Vector2(0.075, 0.075)
	x_erro.texture = load("res://arts/X_vermelho_teste.png")
	x_erro.z_index = 10
	add_child(x_erro)
	x_erro.global_position = posicao_do_clique
	# --- FADE-OUT ---
	var tween = create_tween()
	tween.tween_property(x_erro, "modulate", Color(1, 1, 1, 0), 0.4)
	await tween.finished
	# Remove o nó da memória
	x_erro.queue_free()
	
	
	# Função que recebe o nó do objeto e a posição do clique,
func clicou_na_colisao(objeto: Node2D, posicao_do_clique: Vector2) -> bool:
	# 1. Procura o nó de colisão dentro do objeto
	var colisao = objeto.get_node_or_null("CollisionShape2D")
	# Se o objeto não tiver uma caixa de colisão, ignora ele
	if not colisao or not colisao.shape:
		return false
	# 2. Transforma a posição global do clique para a posição RELATIVA do objeto
	var posicao_local = colisao.to_local(posicao_do_clique)
	# 3. Pergunta para o formato geométrico se ele contém o ponto local
	return colisao.shape.collide_with_motion(
		colisao.transform, 
		Vector2.ZERO, 
		RectangleShape2D.new(), 
		Transform2D(0, posicao_local), 
		Vector2.ZERO
	)


func _on_botao_pausa_tela_pressed():
	$CanvasLayer/MenuPause.alternar_pause()
