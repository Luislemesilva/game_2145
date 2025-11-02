extends RefCounted
class_name DSLMissao

var missao: Dictionary

func criar(nome: String, tipo: String) -> DSLMissao:
	missao = {
		"id": nome.to_lower().replace(" ", "_"),
		"nome": nome,
		"tipo": tipo,
		"objetivos": [],
		"completa": false,
		"ativa": false
	}
	return self

func objetivo(descricao: String) -> DSLMissao:
	missao["objetivos"].append({
		"descricao": descricao,
		"completo": false
	})
	return self

func recompensa_habilidade(nome_habilidade: String) -> DSLMissao:
	missao["recompensa"] = {
		"tipo": "habilidade",
		"nome": nome_habilidade
	}
	return self

func recompensa_chave(numero: int) -> DSLMissao:
	missao["recompensa"] = {
		"tipo": "chave",
		"numero": numero
	}
	return self

func construir() -> Dictionary:
	return missao.duplicate(true) 
