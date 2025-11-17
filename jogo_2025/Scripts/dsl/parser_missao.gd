# scripts/dsl/parser_missao.gd
extends RefCounted
class_name ParserMissao

var tokens: Array
var posicao: int = 0
var erros: Array = []

# Token atual
func token_atual() -> Dictionary:
	if posicao >= tokens.size():
		return {"tipo": "EOF", "valor": "", "linha": 0, "coluna": 0}
	return tokens[posicao]

# Avança para o próximo token
func avancar():
	if posicao < tokens.size():
		posicao += 1

# Verifica se o token atual é do tipo esperado
func verificar(tipo: String) -> bool:
	var token = token_atual()
	return token["tipo"] == tipo

# ✅ CORREÇÃO: Consome um token do tipo esperado com melhor tratamento de erro
func consumir(tipo_esperado: String) -> Dictionary:
	if verificar(tipo_esperado):
		var token = token_atual()
		avancar()
		return token
	else:
		var token = token_atual()
		var mensagem_erro = "Esperado '%s', mas encontrou '%s' ('%s') na linha %d, coluna %d" % [
			tipo_esperado, token["tipo"], token["valor"], token["linha"], token["coluna"]
		]
		erro_sintaxe(mensagem_erro)
		
		# Estratégia de recuperação: procura pelo próximo token esperado
		var posicao_original = posicao
		while posicao < tokens.size() - 1 and token_atual()["tipo"] != tipo_esperado and token_atual()["tipo"] != "EOF":
			avancar()
		
		if verificar(tipo_esperado):
			print("🔧 PARSER: Recuperado no token: ", token_atual())
			return consumir(tipo_esperado)
		else:
			# Se não encontrou, volta para a posição original e avança apenas um
			posicao = posicao_original
			avancar()
			return {"tipo": "ERRO", "valor": ""}

# Função principal de parsing
func parse(_tokens: Array) -> Dictionary:
	tokens = _tokens
	posicao = 0
	erros = []
	
	print("🔧 PARSER: Iniciando com ", tokens.size(), " tokens")
	
	var programa = {
		"tipo": "PROGRAMA",
		"missoes": [],
		"erros": erros
	}
	
	# Parse múltiplas missões
	while posicao < tokens.size() and token_atual()["tipo"] != "EOF":
		if verificar("MISSAO"):
			var missao = parse_missao()
			if missao:
				programa["missoes"].append(missao)
		else:
			# ✅ CORREÇÃO MELHORADA: Mostra qual token está causando problema
			var token = token_atual()
			print("❌ Token inesperado: ", token["tipo"], " ('", token["valor"], "') na linha ", token["linha"])
			erro_sintaxe("Esperado declaração de MISSÃO, encontrado: " + token["tipo"])
			avancar()  # Pula token inválido
	
	print("🔧 PARSER: Finalizado com ", programa["missoes"].size(), " missões e ", erros.size(), " erros")
	return programa

# ✅ CORREÇÃO: Parse uma missão individual corrigido
func parse_missao() -> Dictionary:
	print("🔧 PARSER: Iniciando missão...")
	
	consumir("MISSAO")  # 'missao'
	
	var id_token = consumir("ID")  # Nome da missão
	print("🔧 PARSER: ID da missão: ", id_token["valor"])
	
	# ✅ CORREÇÃO: Agora consome "tipo" como token TIPO
	consumir("TIPO")  # Palavra 'tipo'
	print("🔧 PARSER: Palavra 'tipo' encontrada")
	
	# ✅ CORREÇÃO: Agora consome o tipo da missão como TIPO_MISSAO
	var tipo_token = consumir("TIPO_MISSAO")  # Tipo da missão (tutorial, chefao, final)
	print("🔧 PARSER: Tipo da missão: ", tipo_token["valor"])
	
	consumir("ABRE_CHAVE")  # '{'
	
	var objetivos = parse_objetivos()
	var recompensas = []
	
	# Recompensas são opcionais
	if verificar("RECOMPENSAS"):
		recompensas = parse_recompensas()
	
	consumir("FECHA_CHAVE")  # '}'
	
	var missao = {
		"tipo": "MISSAO",
		"id": id_token["valor"],
		"tipo_missao": tipo_token["valor"],
		"objetivos": objetivos,
		"recompensas": recompensas
	}
	
	print("🔧 PARSER: Missão '", missao["id"], "' parseada com sucesso!")
	return missao

# Parse a lista de objetivos
func parse_objetivos() -> Array:
	print("🔧 PARSER: Parseando objetivos...")
	
	consumir("OBJETIVOS")  # 'objetivos'
	consumir("ABRE_CHAVE")  # '{'
	
	var objetivos = []
	
	# Parse múltiplos objetivos
	while verificar("OBJETIVO"):
		consumir("OBJETIVO")  # 'objetivo'
		var descricao_token = consumir("STRING")  # Descrição do objetivo
		
		objetivos.append({
			"tipo": "OBJETIVO",
			"descricao": descricao_token["valor"]
		})
		print("🔧 PARSER: Objetivo adicionado: ", descricao_token["valor"])
	
	consumir("FECHA_CHAVE")  # '}'
	print("🔧 PARSER: Total objetivos: ", objetivos.size())
	return objetivos

# Parse a lista de recompensas
func parse_recompensas() -> Array:
	print("🔧 PARSER: Parseando recompensas...")
	
	consumir("RECOMPENSAS")  # 'recompensas'
	consumir("ABRE_CHAVE")  # '{'
	
	var recompensas = []
	
	# Parse múltiplas recompensas
	while verificar("HABILIDADE") or verificar("CHAVE"):
		if verificar("HABILIDADE"):
			consumir("HABILIDADE")  # 'habilidade'
			var nome_token = consumir("STRING")  # Nome da habilidade
			
			recompensas.append({
				"tipo": "HABILIDADE",
				"nome": nome_token["valor"]
			})
			print("🔧 PARSER: Habilidade adicionada: ", nome_token["valor"])
			
		elif verificar("CHAVE"):
			consumir("CHAVE")  # 'chave'
			var numero_token = consumir("NUMERO")  # Número da chave
			
			recompensas.append({
				"tipo": "CHAVE",
				"numero": int(numero_token["valor"])
			})
			print("🔧 PARSER: Chave adicionada: ", numero_token["valor"])
	
	consumir("FECHA_CHAVE")  # '}'
	print("🔧 PARSER: Total recompensas: ", recompensas.size())
	return recompensas

# Registra um erro de sintaxe
func erro_sintaxe(mensagem: String):
	var token = token_atual()
	var erro_info = {
		"tipo": "ERRO_SINTAXE",
		"mensagem": mensagem,
		"linha": token["linha"],
		"coluna": token["coluna"],
		"token": token["valor"]
	}
	erros.append(erro_info)
	print("❌ ERRO PARSER: ", erro_info)
