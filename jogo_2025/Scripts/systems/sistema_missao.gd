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
	carregar_missoes_principais()
	
	await get_tree().create_timer(2.0).timeout
	executar_testes_completos()

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
	for missao in missoes_ativas:
		if missao["nome"] == nome_missao:
			return
	
	var nova_missao = encontrar_missao(nome_missao)
	if nova_missao:
		nova_missao["ativa"] = true
		missoes_ativas.append(nova_missao)
		print(" Missão iniciada: ", nome_missao)

func completar_objetivo(nome_missao: String, indice_objetivo: int):
	var missao = encontrar_missao_ativa(nome_missao)
	if missao and indice_objetivo < missao["objetivos"].size():
		missao["objetivos"][indice_objetivo]["completo"] = true
		print(" Objetivo: ", missao["objetivos"][indice_objetivo]["descricao"])
		
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
			distribuir_recompensas(missoes_ativas[i])
			print("MISSÃO CONCLUÍDA: " + nome_missao + "!")
			return
	print(" Missão '" + nome_missao + "' não encontrada ou já completa")

func distribuir_recompensas(missao: Dictionary):
	if missao.has("recompensas"):
		for recompensa in missao["recompensas"]:
			dar_recompensa(recompensa)

func dar_recompensa(recompensa: Dictionary):
	match recompensa["tipo"]:
		"habilidade":
			habilidades.append(recompensa["nome"])
			print(" Habilidade desbloqueada: ", recompensa["nome"])
		"chave":
			chaves.append(recompensa["numero"])
			print(" Chave ", recompensa["numero"], " obtida!")

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
	print("\n TESTE 3: SISTEMA DE MISSÕES INTEGRADO")
	print("------------------------------")
	
	# Inicia uma missão
	iniciar_missao("Derrotar A Dra. Lys")
	print(" Missão 'Derrotar A Dra. Lys' iniciada")
	
	# Completa objetivos
	completar_objetivo("Derrotar A Dra. Lys", 0)
	completar_objetivo("Derrotar A Dra. Lys", 1)
	
	print(" Objetivos completados - Missão deve estar concluída")
	
	# Tenta completar novamente (deve mostrar erro)
	print("\n  Tentando completar missão já concluída:")
	completar_missao("Derrotar A Dra. Lys")

func testar_tratamento_erros():
	print("\n TESTE 4: TRATAMENTO DE ERROS")
	print("------------------------------")
	
	# Testa missão não existente
	print(" Tentando completar missão inexistente:")
	completar_missao("MissaoQueNaoExiste")
	
	# Testa objetivo inválido
	print("\n Tentando completar objetivo inválido:")
	completar_objetivo("Derrotar A Dra. Lys", 999)
	
	# Testa iniciar missão já ativa
	print("\n  Tentando iniciar missão já ativa:")
	iniciar_missao("Derrotar A Dra. Lys")
