extends Node

var pkmn := "mudkip"
var animDict := {}
var curAttributesDict := {}
var curDurationsList := []
var curAnimName := ""
var curAnimFrameWidth := 0
var curAnimFrameHeight := 0
var curItem := ""
var curCopyOf := ""
var fps := 30
var walkFps := 42

func _ready() -> void:
	updateAllAnims()
	statGen()

func parseXml(pokemonName: String) -> void:
	var parser := XMLParser.new()
	parser.open("res://assets/sprites/pokemon/" + pokemonName + "/AnimData.xml")
	
	while parser.read() != Error.ERR_FILE_EOF:
		if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END]:
			curItem = parser.get_node_name()
		
		#TODO: add hitFrame so i can account for it when adding battling
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
		elif i == "Head":
			animDict[i]["dirVariantType"] = "noVariantsVertical"
		elif i == "Nod":
			animDict[i]["dirVariantType"] = "fourDir"
		elif i in ["Walk", "Attack", "Strike", "SpAttack", "Appeal", "Hurt", "Idle", "Swing", "Double", "Hop",
				  "Charge", "Shoot", "Rotate", "EventSleep", "Wake", "Float", "Trip", "Laying", "Faint", "Pain",
				  "Pose"]:
			animDict[i]["dirVariantType"] = "eightDir"
		else:
			animDict[i]["dirVariantType"] = "other"

func populateAnims(pokemonName: String) -> void:
	#make spriteframes
	var spriteFrames := SpriteFrames.new()
	spriteFrames.remove_animation("default")
	
	var dirs := ["Down", "DownRight", "Right", "UpRight", "Up", "UpLeft", "Left", "DownLeft"]
	
	for i in animDict.keys():
		var spritesheet: CompressedTexture2D
		
		if animDict[i]["copyOf"] == "":
			spritesheet = load("res://assets/sprites/pokemon/" + pokemonName + "/" + i + "-Anim.png")
		else:
			spritesheet = load("res://assets/sprites/pokemon/" + pokemonName + "/" + animDict[i]["copyOf"] + "-Anim.png")
		
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
				for j in dirs.size():
					var variantName = (i + dirs[j])
					spriteFrames.add_animation(variantName)
					spriteFrames.set_animation_loop_mode(variantName, SpriteFrames.LOOP_LINEAR)
					
					if i == "Walk":
						spriteFrames.set_animation_speed(variantName, walkFps)
					else:
						spriteFrames.set_animation_speed(variantName, fps)
					
					for k in spritesheet.get_width() / animDict[i]["frameWidth"]:
						var curFrameImg := AtlasTexture.new()
						curFrameImg.atlas = spritesheet
						curFrameImg.region = Rect2(k * animDict[i]["frameWidth"], j * animDict[i]["frameHeight"], animDict[i]["frameWidth"], animDict[i]["frameHeight"])
						spriteFrames.add_frame(variantName, curFrameImg, animDict[i]["durations"][k % animDict[i]["durations"].size()], k)
					
					#if the animation is actually two directional (but i put it under here
					#because the rows line up with the correct directions under eightDir),
					#delete every animation except for left & right/up & down
					if i in ["EventSleep", "Wake", "Float", "Trip", "Laying", "Faint", "Pain"]:
						for k in dirs:
							if k != "Left" and k != "Right":
								spriteFrames.remove_animation(i + k)
					elif i == "Pose":
						for k in dirs:
							if k != "Up" and k != "Down":
								spriteFrames.remove_animation(i + k)
					
			#uhhhhh this is probably fine i don't think any other animations are like this
			"fourDir":
				var rowsPerVariant = 2
				for j in dirs.size():
					var variantName = (i + dirs[j - 1])
					
					if j % rowsPerVariant == 1:
						spriteFrames.add_animation(variantName)
						spriteFrames.set_animation_loop_mode(variantName, SpriteFrames.LOOP_LINEAR)
						spriteFrames.set_animation_speed(variantName, fps)
					
					for k in spritesheet.get_width() / animDict[i]["frameWidth"]:
						var curFrameImg := AtlasTexture.new()
						curFrameImg.atlas = spritesheet
						curFrameImg.region = Rect2(k * animDict[i]["frameWidth"], j * animDict[i]["frameHeight"], animDict[i]["frameWidth"], animDict[i]["frameHeight"])
						if j % rowsPerVariant == 1:
							spriteFrames.add_frame(variantName, curFrameImg, animDict[i]["durations"][k % animDict[i]["durations"].size()], k)
							spriteFrames.add_frame(variantName, curFrameImg, animDict[i]["durations"][k % animDict[i]["durations"].size()], k)
			
	ResourceSaver.save(spriteFrames, "res://data/sprites/" + pokemonName + ".tres")

func updateAllAnims() -> void:
	var folders := DirAccess.get_directories_at("res://assets/sprites/pokemon/")
	
	for folder in folders:
		parseXml(folder)
		populateAnims(folder)
		animDict.clear()

#uhh the scope of this is increasing but thats probably fine
#---------stat dict population and pokemon tres gen---------
func statGen() -> void:
	var statDict := {}
	var statFile := FileAccess.open("res://data/stats/allbasestats.csv", FileAccess.READ)
	var key = []
	key.assign(statFile.get_csv_line())
	
	while !statFile.eof_reached():
		#convert the line from packedstringarray to regular array
		var curPkmn = []
		curPkmn.assign(statFile.get_csv_line())
		var curPkmnDict := {}
		
		#iterate through each element and add it to the dict for the current pokemon
		for i in range(curPkmn.size()):
			#convert from string to int if possible
			if curPkmn[i].is_valid_int():
				curPkmn[i] = int(curPkmn[i])
			#convert type values with two types to an array (type is the third value in each line)
			elif i == 2 and curPkmn[i].contains(" "):
				curPkmn[i] = curPkmn[i].split(" ")
			#actually add the values to a dictionary
			curPkmnDict[key[i]] = curPkmn[i]
		#add the current pokemon's stats to the dict containing all the stats
		statDict[curPkmn[1]] = curPkmnDict
	#print(statDict)
