extends Resource
class_name MissaoTutorial

static func criar() -> Dictionary:
	var dsl = DSLMissao.new()
	return dsl.criar("Treinamento na base", "tutorial") \
		.objetivo("Aprender combate com Punchduka") \
		.objetivo("Aprender hacking com Lan") \
		.objetivo("Aprender cura com Dr. V") \
		.construir()
