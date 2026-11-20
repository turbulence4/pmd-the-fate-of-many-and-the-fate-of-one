extends Node

func _ready() -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/snivy/AnimData.xml")
	
	var animDict := {}
	var curAttributesDict := {}
	var curDurationsList := []
	var curAnimName := ""
	var curAnimFrameWidth := 0
	var curAnimFrameHeight := 0
	var curItem := ""
	var curCopyOf := ""
	var fps := 24
	
	while parser.read() != Error.ERR_FILE_EOF:
		if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			curItem = parser.get_node_name()
		
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
				"CopyOf":
					curCopyOf = parser.get_node_data()
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END and curItem == "Anim":
			curAttributesDict["durations"] = curDurationsList.duplicate()
			
			var tempW = curAnimFrameWidth
			var tempH = curAnimFrameHeight
			var tempCO = curCopyOf
			curAttributesDict["frameWidth"] = tempW
			curAttributesDict["frameHeight"] = tempH
			curAttributesDict["copyOf"] = tempCO
			
			animDict[curAnimName] = curAttributesDict.duplicate(true)
			curDurationsList.clear()
			curAttributesDict.clear()
			curCopyOf = ""
	
	for i in animDict.keys():
		#handle copyof
		if animDict[i]["copyOf"] != "":
			animDict[i]["durations"] = animDict[animDict[i]["copyOf"]]["durations"]
	
		#assign direction type
		if i in ["Sleep", "Eat", "Pull", "DeepBreath", "Sit", "LookUp", "Sink", "LeapForth",
				 "Cringe", "LostBalance", "TumbleBack", "HitGround", "Tumble"]:
			animDict[i]["dirVariantType"] = "noVariantsHorizontal"
		if i == "Head":
			animDict[i]["dirVariantType"] = "noVariantsVertical"
		if i in ["EventSleep", "Wake", "Float", "Trip", "Laying", "Faint", "Pain"]:
			animDict[i]["dirVariantType"] = "twoDirLR"
		if i == "Pose":
			animDict[i]["dirVariantType"] = "twoDirUD"
		if i == "Nod":
			animDict[i]["dirVariantType"] = "fourDir"
		if i in ["Walk", "Attack", "Strike", "SpAttack", "Appeal", "Hurt", "Idle", "Swing", "Double", "Hop",
				 "Charge", "Shoot", "Rotate"]:
			animDict[i]["dirVariantType"] = "eightDir"
	
	#make spriteframes
	var spriteFrames := SpriteFrames.new()
	spriteFrames.remove_animation("default")
	
	for i in animDict.keys():
		var spritesheet: CompressedTexture2D
		
		if animDict[i]["copyOf"] == "":
			spritesheet = load("res://assets/sprites/pokemon/snivy/" + i + "-Anim.png")
		else:
			spritesheet = load("res://assets/sprites/pokemon/snivy/" + animDict[i]["copyOf"] + "-Anim.png")
		
		match animDict[i]["dirVariantType"]:
			"noVariantsHorizontal":
				spriteFrames.add_animation(i)
				spriteFrames.set_animation_loop_mode(i, SpriteFrames.LOOP_LINEAR)
				spriteFrames.set_animation_speed(i, fps)
				
				for j in spritesheet.get_width() / animDict[i]["frameWidth"]:
					var curFrameImg := AtlasTexture.new()
					curFrameImg.atlas = spritesheet
					curFrameImg.region = Rect2(j * animDict[i]["frameWidth"], 0, animDict[i]["frameWidth"], animDict[i]["frameHeight"])
					spriteFrames.add_frame(i, curFrameImg, animDict[i]["durations"][j % animDict[i]["durations"].size()], j)
			"noVariantsVertical":
				spriteFrames.add_animation(i)
				spriteFrames.set_animation_loop_mode(i, SpriteFrames.LOOP_LINEAR)
				spriteFrames.set_animation_speed(i, fps)
				
				for j in spritesheet.get_height() / animDict[i]["frameHeight"]:
					var curFrameImg := AtlasTexture.new()
					curFrameImg.atlas = spritesheet
					curFrameImg.region = Rect2(0, j * animDict[i]["frameHeight"], animDict[i]["frameWidth"], animDict[i]["frameHeight"])
					spriteFrames.add_frame(i, curFrameImg, animDict[i]["durations"][j % animDict[i]["durations"].size()], j)
			"eightDir":
				spriteFrames.add_animation(i)
				spriteFrames.set_animation_loop_mode(i, SpriteFrames.LOOP_LINEAR)
				spriteFrames.set_animation_speed(i, fps)
				
				
	
	ResourceSaver.save(spriteFrames, "res://data/pokemon/snivy.tres")
	
	#print(animDict)
