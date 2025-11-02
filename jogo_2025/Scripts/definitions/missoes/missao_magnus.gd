extends Resource
class_name MissaoMagnus

static func criar() -> Dictionary:
	var dsl = DSLMissao.new() 
	return dsl.criar("Derrotar o Magnus", "final") \
		.objetivo("Infiltrar-se na Torre Syndicore") \
		.objetivo("Chegar ao topo da torre") \
		.objetivo("Sobreviver ao exoesqueleto de Magnus") \
		.objetivo("Usar pontos fracos expostos por GaMa") \
		.objetivo("Derrotar Magnus Veyne") \
		.objetivo("Reativar Projeto Solaris") \
		.construir()
