# scripts/dsl/lexer_missao.gd
extends RefCounted
class_name LexerMissao

var tokens: Array = []
var erros: Array = []

func tokenizar(codigo: String) -> Array:
	tokens = []
	erros = []
	
	var linhas = codigo.split("\n")
	var numero_linha = 1
	
	for linha in linhas:
		tokenizar_linha(linha.strip_edges(), numero_linha)
		numero_linha += 1
	
	# Adiciona token de fim de arquivo
	tokens.append({"tipo": "EOF", "valor": "", "linha": numero_linha, "coluna": 1})
	
	return tokens

func tokenizar_linha(linha: String, numero_linha: int):
	if linha.is_empty() or linha.begins_with("//"):
		return
	
	var coluna = 1
	var i = 0
	var linha_length = linha.length()
	
	while i < linha_length:
		var char_atual = linha[i]
		
		# Ignora espaços em branco
		if char_atual == " " or char_atual == "\t":
			i += 1
			coluna += 1
			continue
			
		match char_atual:
			"{":
				adicionar_token("ABRE_CHAVE", "{", numero_linha, coluna)
				i += 1
				coluna += 1
			"}":
				adicionar_token("FECHA_CHAVE", "}", numero_linha, coluna)
				i += 1
				coluna += 1
			'"':
				# String
				var inicio = i
				i += 1
				coluna += 1
				while i < linha_length and linha[i] != '"':
					i += 1
					coluna += 1
				if i < linha_length:
					var valor = linha.substr(inicio + 1, i - inicio - 1)
					adicionar_token("STRING", valor, numero_linha, coluna - valor.length() - 1)
					i += 1
					coluna += 1
				else:
					erros.append({"linha": numero_linha, "mensagem": "String não fechada"})
			_:
				# Identificador ou palavra-chave
				if _is_letra(char_atual):
					var inicio = i
					while i < linha_length and _is_letra_ou_underscore(linha[i]):
						i += 1
						coluna += 1
					var valor = linha.substr(inicio, i - inicio)
					
					# ✅ CORREÇÃO: "tipo" agora é TIPO (não TIPO_PALAVRA)
					match valor:
						"missao": adicionar_token("MISSAO", valor, numero_linha, coluna - valor.length())
						"objetivos": adicionar_token("OBJETIVOS", valor, numero_linha, coluna - valor.length())
						"objetivo": adicionar_token("OBJETIVO", valor, numero_linha, coluna - valor.length())
						"recompensas": adicionar_token("RECOMPENSAS", valor, numero_linha, coluna - valor.length())
						"habilidade": adicionar_token("HABILIDADE", valor, numero_linha, coluna - valor.length())
						"chave": adicionar_token("CHAVE", valor, numero_linha, coluna - valor.length())
						"tipo": adicionar_token("TIPO", valor, numero_linha, coluna - valor.length())  # ✅ CORREÇÃO AQUI!
						"tutorial", "chefao", "final": adicionar_token("TIPO_MISSAO", valor, numero_linha, coluna - valor.length())  # ✅ CORREÇÃO
						_: adicionar_token("ID", valor, numero_linha, coluna - valor.length())
				# Número
				elif _is_digito(char_atual):
					var inicio = i
					while i < linha_length and _is_digito(linha[i]):
						i += 1
						coluna += 1
					var valor = linha.substr(inicio, i - inicio)
					adicionar_token("NUMERO", valor, numero_linha, coluna - valor.length())
				else:
					# Caractere não reconhecido
					erros.append({
						"linha": numero_linha, 
						"mensagem": "Caractere não reconhecido: '" + char_atual + "'"
					})
					i += 1
					coluna += 1

# Funções auxiliares (mantidas iguais)
func _is_letra(char: String) -> bool:
	return (char >= "a" and char <= "z") or (char >= "A" and char <= "Z")

func _is_letra_ou_underscore(char: String) -> bool:
	return _is_letra(char) or char == "_"

func _is_digito(char: String) -> bool:
	return char >= "0" and char <= "9"

func adicionar_token(tipo: String, valor: String, linha: int, coluna: int):
	tokens.append({
		"tipo": tipo,
		"valor": valor,
		"linha": linha,
		"coluna": coluna
	})
