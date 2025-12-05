extends CharacterBody2D

var player = Pokemon.new()

func _ready():
	setup()
	controller()

func setup():
	#this is just a default, make a way to change this
	player.species = preload("res://data/pokemon/piplup.tres")
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$shadow.texture = player.species.shadow
	$shadow.offset = Vector2(player.species.shadowOffset, 0)

func controller():
	var directionX := Input.get_axis("left", "right")
	var directionY := Input.get_axis("down", "up")
	if directionX:
		player.position.x += directionX
		print("x")
	if directionY:
		player.position.y += directionY
		print("y")
