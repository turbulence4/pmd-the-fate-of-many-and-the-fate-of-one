extends Node

func _ready() -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	var lineNum := 0
	var animDict := {}
	var curDurationsList = []
	
	while parser.read() != Error.ERR_FILE_EOF:		
		if parser.get_node_name() == "Durations" and parser.get_node_type() == XMLParser.NODE_ELEMENT:
			curDurationsList = []
		if parser.get_node_name() == "Duration":
			curDurationsList.append(parser.get_node_data())
		if parser.get_node_name() == "Durations" and parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			animDict += curDurationsList
		lineNum += 1
	
	print(animDict)
