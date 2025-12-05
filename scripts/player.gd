extends CharacterBody2D

var player = Pokemon.new()
const tileSize = Vector2(24, 24)
#var spriteTween: Tween

func _ready():
	setup()

func _physics_process(_delta: float) -> void:
	controller()

func setup():
	#this is just a default, make a way to change this
	player.species = preload("res://data/pokemon/piplup.tres")
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$shadow.texture = player.species.shadow
	$shadow.offset = Vector2(player.species.shadowOffset, 0)

func controller():
	if Input.is_action_just_pressed("up") and !$up.is_colliding():
		move(Vector2(0, -1))
	elif Input.is_action_just_pressed("down") and !$down.is_colliding():
		move(Vector2(0, 1))
	elif Input.is_action_just_pressed("left") and !$left.is_colliding():
		move(Vector2(-1, 0))
	elif Input.is_action_just_pressed("right") and !$right.is_colliding():
		move(Vector2(1, 0))

func move(dir: Vector2):
	global_position += dir * tileSize
	'''$sprites.global_position -= dir * tileSize
	
	if spriteTween:
		spriteTween.kill()
	spriteTween = create_tween()
	spriteTween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	spriteTween.tween_property($sprites, "global_position", global_position, 0.2).set_trans(Tween.TRANS_LINEAR)'''
