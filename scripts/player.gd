extends CharacterBody2D

var player = Pokemon.new()
@export var playerSpecies: Resource
@export var camera: Camera2D
const tileSize = Vector2(24, 24)

#in tiles per second
@export var walkSpeed = 1.8
@export var runSpeed = 32
var currentSpeed = walkSpeed


var inputDirection = Vector2(0, 0)
var direction = inputDirection
var targetPos: Vector2
var isMoving = false

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

func _process(delta: float) -> void:
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
		handleCollision(inputDirection)
	
	handleAnimations()
	camera.position = position

func handleInput():
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if isMoving:
		return
	
	inputDirection = Vector2.ZERO
	inputDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputDirection.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if inputDirection != Vector2.ZERO and !handleCollision(inputDirection):
		startMovement(inputDirection)

func handleCollision(dir: Vector2) -> bool:
	return test_move(global_transform, dir * tileSize/2)

func startMovement(dir: Vector2):
	if handleCollision(dir):
		return
	
	if !handleCollision(dir):
		isMoving = true
		targetPos = position + inputDirection * tileSize

func continueMovement(delta):
	var step = inputDirection * currentSpeed * tileSize * delta
	position += step

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
		match direction:
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
