extends RefCounted
class_name DSLMissao

var missao: Dictionary

func _init():
	
	missao = {
		"id": "",
		"nome": "",
		"tipo": "",
		"objetivos": [],
		"recompensas": [],  
		"completa": false,
		"ativa": false
	}

func criar(nome: String, tipo: String) -> DSLMissao:
	missao["id"] = nome.to_lower().replace(" ", "_")
	missao["nome"] = nome
	missao["tipo"] = tipo
	missao["objetivos"] = []
	missao["recompensas"] = []  
	missao["completa"] = false
	missao["ativa"] = false
	return self

func objetivo(descricao: String) -> DSLMissao:
	missao["objetivos"].append({
		"descricao": descricao,
		"completo": false
	})
	return self

func recompensa_habilidade(nome_habilidade: String) -> DSLMissao:
	missao["recompensas"].append({
		"tipo": "habilidade",
		"nome": nome_habilidade
	})
	return self

func recompensa_chave(numero: int) -> DSLMissao:
	missao["recompensas"].append({
		"tipo": "chave",
		"numero": numero
	})
	return self

func recompensa(tipo: String, valor) -> DSLMissao:
	match tipo:
		"habilidade":
			recompensa_habilidade(valor)
		"chave":
			recompensa_chave(int(valor))
		_:
			push_error("Tipo de recompensa desconhecido: " + tipo)
	return self

func construir() -> Dictionary:
	return missao.duplicate(true)

func ativar() -> DSLMissao:
	missao["ativa"] = true
	return self

func completar() -> DSLMissao:
	missao["completa"] = true
	return self

func get_estatisticas() -> Dictionary:
	return {
		"objetivos_total": missao["objetivos"].size(),
		"objetivos_completos": missao["objetivos"].filter(func(obj): return obj["completo"]).size(),
		"recompensas_total": missao["recompensas"].size(),
		"ativa": missao["ativa"],
		"completa": missao["completa"]
	}
