extends Node

func _ready() -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	
	var animDict := {}
	var attributesList := []
	var curDurationsList := []
	var curAnimName := ""
	var curAnimFrameWidth := 0
	var curAnimFrameHeight := 0
	var curItem := ""
	
	while parser.read() != Error.ERR_FILE_EOF:		
		if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			curItem = parser.get_node_name()
			#print(curItem)
			#print(curAnimName)
		
		if parser.get_node_type() == XMLParser.NODE_TEXT and parser.get_node_data().strip_edges() != "":
			match curItem:
				"Name":
					curAnimName = parser.get_node_data()
				"Duration":
					curDurationsList.append(parser.get_node_data())
				"FrameWidth":
					curAnimFrameWidth = int(parser.get_node_data())
				"FrameHeight":
					curAnimFrameHeight = int(parser.get_node_data())
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			match curItem:
				"Anim":
					var tempDur := []
					for i in curDurationsList.size():
						tempDur.append(int(curDurationsList[i]))
					attributesList.append(tempDur)
					
					var tempW = curAnimFrameWidth
					var tempH = curAnimFrameHeight
					attributesList.append(tempW)
					attributesList.append(tempH)
					
					curDurationsList.clear()
					
					animDict[curAnimName] = attributesList
				
	print(animDict)


'''"Durations":
					var temp := []
					for i in curDurationsList.size():
						temp.append(int(curDurationsList[i]))
					attributesList.append(temp)
					animDict[curAnimName] = temp
					curDurationsList.clear()'''
