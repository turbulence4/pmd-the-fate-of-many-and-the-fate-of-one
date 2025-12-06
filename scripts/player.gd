extends CharacterBody2D

var player = Pokemon.new()
const tileSize = Vector2(24, 24)

@export var walkSpeed = 8
@export var runSpeed = 64
var currentSpeed = walkSpeed
var initialPosition = Vector2(0, 0)
var inputDirection = Vector2(0, 0)
var isMoving = false
var amtMovedToNextTile = 0.0

func _ready():
	setup()

func _physics_process(delta: float) -> void:
	if !isMoving:
		processMovement()
	elif inputDirection != Vector2.ZERO:
		move(delta)
	else:
		isMoving = false

func setup():
	#this is just a default, make a way to change this
	#setup assets
	player.species = preload("res://data/pokemon/piplup.tres")
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$shadow.texture = player.species.shadow
	$shadow.offset = Vector2(player.species.shadowOffset, 0)
	
	#setup movement
	initialPosition = position

func processMovement():
	if Input.is_action_pressed("shift"):
		currentSpeed = runSpeed
	else:
		currentSpeed = walkSpeed
	
	inputDirection.x = int(Input.get_action_strength("right") - Input.get_action_strength("left"))
	inputDirection.y = int(Input.get_action_strength("down") - Input.get_action_strength("up"))
	
	if inputDirection.x > 0 and $right.is_colliding():
		inputDirection.x = 0
	if inputDirection.x < 0 and $left.is_colliding():
		inputDirection.x = 0
	if inputDirection.y > 0 and $down.is_colliding():
		inputDirection.y = 0
	if inputDirection.y < 0 and $up.is_colliding():
		inputDirection.y = 0
	
	if inputDirection != Vector2.ZERO:
		initialPosition = position
		isMoving = true;

func move(delta: float):
	amtMovedToNextTile += currentSpeed * delta
	if amtMovedToNextTile >= 1:
		position = initialPosition + (tileSize * inputDirection)
		amtMovedToNextTile = 0.0
		isMoving = false
	else:
		position = initialPosition + (tileSize * inputDirection * amtMovedToNextTile)
