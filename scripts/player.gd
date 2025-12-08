extends CharacterBody2D

var player = Pokemon.new()
@export var playerSpecies: Resource
@export var camera: Camera2D
const tileSize = Vector2(24, 24)

#in tiles per second
@export var walkSpeed = 1.8
@export var runSpeed = 32
var currentSpeed = walkSpeed

var initialPosition = Vector2(0, 0) 
var inputDirection = Vector2(0, 0)
var lastInputDirection = Vector2(0, 0)
var targetPos: Vector2
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
	position = position.snapped(tileSize)
	initialPosition = position

func _process(delta: float) -> void:
	if isMoving:
		lastInputDirection = inputDirection
	
	handleAnimations()
	
	if Input.is_action_pressed("shift"):
		currentSpeed = runSpeed
	else:
		currentSpeed = walkSpeed
	if inputDirection.x != 0 and inputDirection.y != 0:
		currentSpeed /= sqrt(2)
	
	if isMoving:
		continueMovement(delta)
	else:
		handleInput()
	
	camera.position = position

func handleInput():
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	if input != Vector2.ZERO:
		inputDirection = input#.normalized()
		startMovement()

func startMovement():
	isMoving = true
	targetPos = position + inputDirection * tileSize.x

func continueMovement(delta):
	var step = inputDirection * currentSpeed * tileSize.x * delta

	'''replace with something like:
	velocity = step
	move_and_slide()'''
	position += step

	# Check if we passed or reached the target tile
	if inputDirection.dot(targetPos - position) <= 0:
		position = targetPos
		isMoving = false

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
