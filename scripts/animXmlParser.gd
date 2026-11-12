extends Node

func _ready() -> void:
	var parser = XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	while parser.read() != Error.ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			print("i found a node element! aka a tag start. eg: <Duration>")
		
