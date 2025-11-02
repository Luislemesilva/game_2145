extends Resource
class_name MissaoDraLys

static func criar() -> Dictionary:
	var dsl = DSLMissao.new()
	return dsl.criar("Derrotar A Dra. Lys", "Boss") \
	.objetivo("Chegar ao laboratorio da Dra. Lys") \
	.objetivo("Sobreviver as alucinações toxicas") \
	.objetivo("Destruir injetores de gás") \
	.objetivo("Derrotas Dra. Lys") \
	.recompensa_chave(1) \
	.recompensa_habilidade("Sensor de Toxidade") \
	.construir()
