extends Node

func _ready() -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	
	var animDict := {}
	var curAttributesList := []
	var curDurationsList := []
	var curAnimName := ""
	var curAnimFrameWidth := 0
	var curAnimFrameHeight := 0
	var curItem := ""
	
	while parser.read() != Error.ERR_FILE_EOF:
		if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			curItem = parser.get_node_name()
		
		#todo: how to handle copyof?
		if parser.get_node_type() == XMLParser.NODE_TEXT and parser.get_node_data().strip_edges() != "":
			match curItem:
				"Name":
					curAnimName = parser.get_node_data()
				"Duration":
					curDurationsList.append(int(parser.get_node_data()))
				"FrameWidth":
					curAnimFrameWidth = int(parser.get_node_data())
				"FrameHeight":
					curAnimFrameHeight = int(parser.get_node_data())
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END and curItem == "Anim":
			curAttributesList.append(curDurationsList.duplicate())
			
			var tempW = curAnimFrameWidth
			var tempH = curAnimFrameHeight
			curAttributesList.append(tempW)
			curAttributesList.append(tempH)
			
			animDict[curAnimName] = curAttributesList.duplicate(true)
			curDurationsList.clear()
			curAttributesList.clear()
				
	print(animDict)
