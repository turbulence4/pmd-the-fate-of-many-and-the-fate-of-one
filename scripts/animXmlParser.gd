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
		if i in ["Sleep", "Eat", "Pull", "DeepBreath", "Sit", "LookUp", "Sink", "LeapForth", "Head",
				 "Cringe", "LostBalance", "TumbleBack", "HitGround", "Eat", "Tumble"]:
			animDict[i]["dirVariantType"] = "noVariants"
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
		match animDict[i]["dirVariantType"]:
			#everything is in one long row. in a for loop of length durations.size, make a frame with
			#framewidth and frameheight, then move over framewidth and make another one
			"noVariants":
				spriteFrames.add_animation(i)
				
				var spritesheet := load("res://assets/sprites/pokemon/snivy/" + i + "-Anim.png")
				var curFrameImg := AtlasTexture.new()
				curFrameImg.atlas = spritesheet
				
				#find some way to remove offset/blank space for some sprites
				for j in animDict[i]["durations"].size():
					curFrameImg.region = Rect2(j * animDict[i]["frameWidth"], 0, animDict[i]["frameWidth"], animDict[i]["frameHeight"])
					spriteFrames.add_frame(i, curFrameImg, animDict[i]["durations"][j], -1)
	
	ResourceSaver.save(spriteFrames, "res://data/pokemon/snivy.tres")
	
	#print(animDict)

func exampleSpriteFrames():
	var sprite_frames := SpriteFrames.new()

	# Remove the default animation.
	sprite_frames.remove_animation("default")
	
	sprite_frames.add_animation("Idle")
	sprite_frames.add_animation("Walk")
	sprite_frames.add_animation("Attack")
	
	sprite_frames.set_animation_loop("Idle", true)
	sprite_frames.set_animation_speed("Idle", 10.0)
	
	var sprite_sheet := load("res://assets/sprites/pokemon/snivy/Walk-Anim.png")

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = sprite_sheet
	atlas_texture.region = Rect2(0, 0, 64, 64)

	sprite_frames.add_frame("Idle", atlas_texture)
	
	var error := ResourceSaver.save(sprite_frames, "res://data/pokemon/snivy.tres")
