extends Node
class_name SistemaMissao

var missoes_ativas: Array = []
var missoes_completas: Array = []
var habilidades: Array = []
var chaves: Array = []

var DSLMissao = preload("res://Scripts/dsl/dsl_missao.gd") 
var MissaoTutorial = preload("res://Scripts/definitions/missoes/missao_tutorial.gd")
var MissaoDralys = preload("res://Scripts/definitions/missoes/missao_dra_lys.gd") 
var MissaoVigia = preload("res://Scripts/definitions/missoes/missao_vigia.gd")
var MissaoMagnus = preload("res://Scripts/definitions/missoes/missao_magnus.gd")

func _ready():
	mostrar_banner_dsl() 
	carregar_missoes_principais()
	
	await get_tree().process_frame
	bloquear_todas_missoes_exceto_dra_lys()

func bloquear_todas_missoes_exceto_dra_lys():
	var cena_atual = get_tree().current_scene
	if not cena_atual or "d_toxico_2" not in str(cena_atual.scene_file_path):
		return
	
	print("🛡️  BLOQUEIO ATIVADO: Apenas Dra Lys permitida em DToxico_2")
	
	missoes_ativas.clear()
	
	if not encontrar_missao_ativa("Derrotar A Dra. Lys"):
		var missao_dra_lys = encontrar_missao("Derrotar A Dra. Lys")
		if missao_dra_lys:
			missao_dra_lys["ativa"] = true
			missao_dra_lys["completa"] = false
			missoes_ativas.append(missao_dra_lys)
			print(" Dra Lys forçada como única missão ativa")

func iniciar_missao_automatica_mapa():
	await get_tree().process_frame
	
	var cena_atual = get_tree().current_scene
	if not cena_atual:
		print("⚠️  Cena atual não encontrada")
		return
	
	var arquivo_cena = cena_atual.scene_file_path
	print("Verificando missões automáticas para: ", arquivo_cena)
	
	if "d_toxico_2" in str(arquivo_cena):
		print(" Mapa DToxico_2 detectado - Iniciando missão da Dra Lys...")
		await get_tree().create_timer(1.0).timeout
		
		if not encontrar_missao_ativa("Derrotar A Dra. Lys"):
			iniciar_missao("Derrotar A Dra. Lys")
			print(" Missão da Dra Lys iniciada automaticamente!")
		else:
			print("ℹ  Missão da Dra Lys já está ativa")

func carregar_missoes_principais():
	var missoes = [
		MissaoTutorial.criar(),
		MissaoDralys.criar(),
		MissaoVigia.criar(),
		MissaoMagnus.criar()
	]
	
	for missao in missoes:
		print(" Missão carregada: ", missao["nome"])
		print("   Objetivos: ", missao["objetivos"].size())

func iniciar_missao(nome_missao: String):
	var cena_atual = get_tree().current_scene
	if cena_atual and "d_toxico_2" in str(cena_atual.scene_file_path):
		if nome_missao != "Derrotar A Dra. Lys":
			print("🚫 Missão bloqueada em DToxico_2: ", nome_missao)
			return
	
	# Resto do código original...
	for missao in missoes_completas:
		if missao["nome"] == nome_missao:
			print("⚠️  Missão '" + nome_missao + "' já foi completada")
			return
	
	for missao in missoes_ativas:
		if missao["nome"] == nome_missao:
			print("  Missão '" + nome_missao + "' já está ativa")
			return
	
	var nova_missao = encontrar_missao(nome_missao)
	if nova_missao:
		nova_missao["ativa"] = true
		nova_missao["completa"] = false  
		missoes_ativas.append(nova_missao)
		mostrar_missao_iniciada(nome_missao)  
		mostrar_missao_formatada(nova_missao)

func completar_objetivo(nome_missao: String, indice_objetivo: int):
	var missao = encontrar_missao_ativa(nome_missao)
	if missao and indice_objetivo < missao["objetivos"].size():
		missao["objetivos"][indice_objetivo]["completo"] = true
		var descricao = missao["objetivos"][indice_objetivo]["descricao"]
		mostrar_objetivo_completo(descricao)
		

		var todos_completos = true
		for objetivo in missao["objetivos"]:
			if not objetivo["completo"]:
				todos_completos = false
				break
		
		if todos_completos:
			completar_missao(nome_missao)

func completar_missao(nome_missao: String):

	for i in range(missoes_ativas.size()):
		if missoes_ativas[i]["nome"] == nome_missao and not missoes_ativas[i]["completa"]:
			missoes_ativas[i]["completa"] = true
			
			
			var missao_completa = missoes_ativas[i]
			missoes_completas.append(missoes_ativas[i])
			missoes_ativas.remove_at(i)
			
			mostrar_missao_concluida(nome_missao)  
			distribuir_recompensas(missao_completa)
			return
	
	print("⚠  Missão '" + nome_missao + "' não encontrada ou já completa")

func distribuir_recompensas(missao: Dictionary):
	if missao.has("recompensas"):
		for recompensa in missao["recompensas"]:
			match recompensa["tipo"]:
				"chave":
					mostrar_recompensa_chave(recompensa["numero"])
					chaves.append(recompensa["numero"])
				"habilidade":
					print(" Habilidade desbloqueada: ", recompensa["nome"])
					habilidades.append(recompensa["nome"])

func dar_recompensa(recompensa: Dictionary):
	match recompensa["tipo"]:
		"habilidade":
			habilidades.append(recompensa["nome"])
			print(" Habilidade desbloqueada: ", recompensa["nome"])
		"chave":
			chaves.append(recompensa["numero"])
			print("🔑 Chave ", recompensa["numero"], " obtida!")

func encontrar_missao_ativa(nome: String) -> Dictionary:
	for missao in missoes_ativas:
		if missao["nome"] == nome:
			return missao
	return {}

func encontrar_missao(nome: String) -> Dictionary:
	var todas_missoes = [
		MissaoTutorial.criar(),
		MissaoDralys.criar(),
		MissaoVigia.criar(), 
		MissaoMagnus.criar()
	]
	
	for missao in todas_missoes:
		if missao["nome"] == nome:
			return missao.duplicate(true)
	return {}
	
func _process(_delta):
	pass

static func debug_rapido():
	print("===  DEBUG RÁPIDO ===")
	print("SistemaMissao carregado!")
	print("Total de missões conhecidas: 4")
	print("Use Espaço no player para ver estado atual")



func executar_testes_completos():
	print("\n" + "==================================================")
	print(" INICIANDO TESTES DO SISTEMA DE MISSÕES")
	print("==================================================")
	
	testar_parser_valido()
	testar_parser_invalido()
	testar_sistema_missoes()
	testar_tratamento_erros()
	
	print("\n" + "==================================================")
	print(" TODOS OS TESTES CONCLUÍDOS")
	print("==================================================")

func testar_parser_valido():
	print("\n TESTE 1: PARSER COM CÓDIGO VÁLIDO")
	print("------------------------------")
	
	var codigo_valido = """
missao MissaoTeste tipo tutorial {
	objetivos {
		objetivo "Primeiro objetivo de teste"
		objetivo "Segundo objetivo de teste"
	}
	recompensas {
		habilidade "Super Força"
		chave 5
	}
}
"""
	
	var lexer = LexerMissao.new()
	var tokens = lexer.tokenizar(codigo_valido)
	
	var parser = ParserMissao.new()
	var resultado = parser.parse(tokens)
	
	print(" Código válido parseado com sucesso!")
	print("   Missões encontradas: ", resultado["missoes"].size())
	print("   Erros: ", resultado["erros"].size())

func testar_parser_invalido():
	print("\n TESTE 2: PARSER COM CÓDIGO INVÁLIDO")
	print("------------------------------")
	
	var codigo_invalido = """
missao MissaoQuebrada tipo INVALIDO {
	objetivos {
		objetivo "Objetivo com erro"
	# Faltando fechamento
"""
	
	var lexer = LexerMissao.new()
	var tokens = lexer.tokenizar(codigo_invalido)
	
	var parser = ParserMissao.new()
	var resultado = parser.parse(tokens)
	
	print(" Código inválido detectado!")
	print("   Erros encontrados: ", resultado["erros"].size())
	for erro in resultado["erros"]:
		print("   - ", erro["mensagem"])

func testar_sistema_missoes():
	print("\n🎮 TESTE 3: SISTEMA DE MISSÕES INTEGRADO")
	print("------------------------------")
	
	iniciar_missao("Derrotar A Dra. Lys")
	print(" Missão 'Derrotar A Dra. Lys' iniciada")
	
	
	completar_objetivo("Derrotar A Dra. Lys", 0)
	completar_objetivo("Derrotar A Dra. Lys", 1)
	
	print(" Objetivos completados - Missão deve estar concluída")
	
	# Tenta completar novamente (deve mostrar erro)
	print("\n⚠  Tentando completar missão já concluída:")
	completar_missao("Derrotar A Dra. Lys")

func testar_tratamento_erros():
	print("\n TESTE 4: TRATAMENTO DE ERROS")
	print("------------------------------")
	

	print(" Tentando completar missão inexistente:")
	completar_missao("MissaoQueNaoExiste")
	
	
	print("\n Tentando completar objetivo inválido:")
	completar_objetivo("Derrotar A Dra. Lys", 999)
	
	
	print("\n Tentando iniciar missão já ativa:")
	iniciar_missao("Derrotar A Dra. Lys")


func mostrar_missao_formatada(missao: Dictionary):
	print(" MISSÃO: " + missao["nome"])
	
	
	if missao.has("tipo_missao"):
		print("    Tipo: " + missao["tipo_missao"])
	elif missao.has("tipo"):
		print("    Tipo: " + missao["tipo"]) 
	
	print("    Objetivos: " + str(missao["objetivos"].size()))
	
	if missao.has("recompensas") and missao["recompensas"].size() > 0:
		print("    Recompensas: " + str(missao["recompensas"].size()))
	print("")

func mostrar_objetivo_completo(descricao: String):
	print(" " + "OBJETIVO CONCLUÍDO: " + descricao)

func mostrar_missao_iniciada(nome: String):
	print("")
	print(" " + "MISSÃO INICIADA: " + nome)
	print("")

func mostrar_missao_concluida(nome: String):
	print("")
	print(" " + "MISSÃO CONCLUÍDA: " + nome)
	print("    PARABÉNS! Todas as tarefas foram cumpridas!")
	print("")

func mostrar_recompensa_chave(numero: int):
	print(" " + "RECOMPENSA: Chave " + str(numero) + " obtida!")
	print("")

func mostrar_banner_dsl():
	print("")
	print("====================================================================")
	print("                    SISTEMA DE MISSÕES DSL")
	print("====================================================================")
	print(" DSL Integrada com Godot Engine")
	print(" Linguagem de Domínio Específico para Missões")
	print("====================================================================")
	print("")
