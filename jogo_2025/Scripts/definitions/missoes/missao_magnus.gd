extends Resource
class_name MissaoMagnus

static func criar() -> Dictionary:
	var dsl = DSLMissao.new() 
	return dsl.criar("Derrotar o Magnus", "final") \
		.objetivo("Usar pontos fracos expostos por GaMa") \
		.objetivo("Derrotar Magnus Veyne") \
		.construir()
