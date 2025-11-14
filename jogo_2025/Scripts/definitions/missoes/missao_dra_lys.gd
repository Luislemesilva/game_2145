extends Resource
class_name MissaoDraLys

static func criar() -> Dictionary:
	var dsl = DSLMissao.new()
	return dsl.criar("Derrotar A Dra. Lys", "Boss") \
	.objetivo("Chegar ao laboratorio da Dra. Lys") \
	.objetivo("Derrotas Dra. Lys") \
	.recompensa_chave(1) \
	.construir()
