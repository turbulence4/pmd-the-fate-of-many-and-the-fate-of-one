class_name GameManager extends Node

#main script that controls flow
var gameState

func _ready():
	print("hello chat")
	setup()

func setup():
	gameState = GameState.new()
		
	var speciesPiplup = preload("res://data/pokemon/piplup.tres")
	var speciesMudkip = preload("res://data/pokemon/mudkip.tres")
	
	var player = Pokemon.new()
	player.species = speciesPiplup
	player.hp = player.species.maxHp
	gameState.player = player
	
	
