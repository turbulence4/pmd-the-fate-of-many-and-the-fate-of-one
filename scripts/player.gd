extends CharacterBody2D

var player = Pokemon.new()
@export var playerSpecies: Resource
@export var camera: Camera2D
const tileSize = Vector2(24, 24)

#in tiles per second
@export var walkSpeed = 1.8
@export var runSpeed = 32
var currentSpeed = walkSpeed
var moveRemainingTicks: int = 0

var initialPosition = Vector2(0, 0) 
var inputDirection = Vector2(0, 0)
var lastInputDirection = Vector2(0, 0)
var isMoving = false
var amtMovedToNextTile = 0.0

func _ready():
	setup()

func setup():
	#setup assets
	player.species = playerSpecies
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$shadow.texture = player.species.shadow
	$shadow.offset = Vector2(player.species.shadowOffset, 0)
	
	#setup movement
	initialPosition = position

func _physics_process(delta: float) -> void:
	if isMoving:
		lastInputDirection = inputDirection
	
	handleAnimations()
	
	if Input.is_action_pressed("shift"):
		currentSpeed = runSpeed
	else:
		currentSpeed = walkSpeed
	
	if !isMoving:
		processMovementInput()
	elif inputDirection != Vector2.ZERO:
		move(delta)
	else:
		isMoving = false

	camera.position = position

func processMovementInput():
	inputDirection = Vector2.ZERO
	
	inputDirection.x = int(Input.get_action_strength("right")) - int(Input.get_action_strength("left"))
	inputDirection.y = int(Input.get_action_strength("down")) - int(Input.get_action_strength("up"))
	
	if inputDirection.x != 0 and inputDirection.y != 0:
		currentSpeed /= sqrt(2)
	
	if inputDirection != Vector2.ZERO:
		initialPosition = position
		isMoving = true

func move(delta: float):
	amtMovedToNextTile += currentSpeed * delta
	if amtMovedToNextTile >= 1:
		position = initialPosition + (tileSize * inputDirection)
		amtMovedToNextTile = 0.0
		isMoving = false
	else:
		position = initialPosition + (tileSize * inputDirection * amtMovedToNextTile)

func handleAnimations():
	if isMoving:
		match inputDirection:
			Vector2(1, 0):
				$sprites.play("walkRight")
			Vector2(-1, 0):
				$sprites.play("walkLeft")
			Vector2(0, 1):
				$sprites.play("walkDown")
			Vector2(0, -1):
				$sprites.play("walkUp")
			Vector2(1, 1):
				$sprites.play("walkDownRight")
			Vector2(-1, 1):
				$sprites.play("walkDownLeft")
			Vector2(1, -1):
				$sprites.play("walkUpRight")
			Vector2(-1, -1):
				$sprites.play("walkUpLeft")
	elif !isMoving:
		match lastInputDirection:
			Vector2(1, 0):
				$sprites.play("idleRight")
			Vector2(-1, 0):
				$sprites.play("idleLeft")
			Vector2(0, 1):
				$sprites.play("idleDown")
			Vector2(0, -1):
				$sprites.play("idleUp")
			Vector2(1, 1):
				$sprites.play("idleDownRight")
			Vector2(-1, 1):
				$sprites.play("idleDownLeft")
			Vector2(1, -1):
				$sprites.play("idleUpRight")
			Vector2(-1, -1):
				$sprites.play("idleUpLeft")
