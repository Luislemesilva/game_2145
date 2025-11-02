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

func carregar_missoes_principais():
	var missoes = [
		MissaoTutorial.criar(),
		MissaoDralys.criar(),
		MissaoVigia.criar(),
		MissaoMagnus.criar()
	]
	
	for missao in missoes:
		print("🎮 Missão carregada: ", missao["nome"])
		print("   Objetivos: ", missao["objetivos"].size())

func iniciar_missao(nome_missao: String):
	for missao in missoes_ativas:
		if missao["nome"] == nome_missao:
			return
	
	var nova_missao = encontrar_missao(nome_missao)
	if nova_missao:
		nova_missao["ativa"] = true
		missoes_ativas.append(nova_missao)
		print("🚀 Missão iniciada: ", nome_missao)

func completar_objetivo(nome_missao: String, indice_objetivo: int):
	var missao = encontrar_missao_ativa(nome_missao)
	if missao and indice_objetivo < missao["objetivos"].size():
		missao["objetivos"][indice_objetivo]["completo"] = true
		print("✅ Objetivo: ", missao["objetivos"][indice_objetivo]["descricao"])
		
		# Verificar se TODOS objetivos estão completos
		var todos_completos = true
		for objetivo in missao["objetivos"]:
			if not objetivo["completo"]:
				todos_completos = false
				break
		
		if todos_completos:
			completar_missao(nome_missao)

func completar_missao(nome_missao: String):
	var missao = encontrar_missao_ativa(nome_missao)
	if missao:
		missao["completa"] = true
		missao["ativa"] = false
		missoes_ativas.erase(missao)
		missoes_completas.append(missao)
		
		if missao.has("recompensa"):
			dar_recompensa(missao["recompensa"])
		
		print("🎉 MISSÃO COMPLETA: ", nome_missao)

func dar_recompensa(recompensa: Dictionary):
	match recompensa["tipo"]:
		"habilidade":
			habilidades.append(recompensa["nome"])
			print("⚡ Habilidade desbloqueada: ", recompensa["nome"])
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
	
	
func _process(delta):
	pass


static func debug_rapido():
	print("=== 🔍 DEBUG RÁPIDO ===")
	print("SistemaMissao carregado!")
	print("Total de missões conhecidas: 4")
	print("Use Espaço no player para ver estado atual")
