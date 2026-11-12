extends Node

func _ready() -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	
	var animDict := {}
	var curDurationsList := []
	var curAnimName := ""
	var curItem := ""
	
	while parser.read() != Error.ERR_FILE_EOF:
		if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			curItem = parser.get_node_name()
		
		if parser.get_node_type() == XMLParser.NODE_TEXT and parser.get_node_data().strip_edges() != "":
			match curItem:
				"Name":
					curAnimName = parser.get_node_data()
				"Duration":
					curDurationsList.append(parser.get_node_data())
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			match curItem:
				"Durations":
					var temp := []
					for i in curDurationsList.size():
						temp.append(int(curDurationsList[i]))
					animDict[curAnimName] = temp
					curDurationsList.clear()
	print(animDict)
