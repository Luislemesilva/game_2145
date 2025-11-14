extends Resource
class_name MissaoVigia

static func criar() -> Dictionary:
	var dsl = DSLMissao.new()
	return dsl.criar("Derrotar o Vigia", "chefao") \
		.objetivo("Hackear sistemas de segurança") \
		.objetivo("Sobreviver aos ataques do Vigia") \
		.objetivo("Hackear núcleo do Vigia") \
		.objetivo("Derrotar o Vigia") \
		.recompensa_chave(2) \
		.construir()
