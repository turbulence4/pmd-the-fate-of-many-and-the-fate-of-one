extends CharacterBody2D

var player = Pokemon.new()
@export var playerSpecies: Resource
@export var camera: Camera2D
const tileSize = Vector2(24, 24)

#in tiles per second
@export var walkSpeed = 1.8
@export var runSpeed = 16
var currentSpeed = walkSpeed

var inputDirection = Vector2(0, 0)
var direction = Vector2(0, 1)
var targetPos: Vector2

enum states {idle, walking, running}
var playerState: states = states.idle

func _ready():
	setup()

func setup():
	#setup assets
	player.species = playerSpecies
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$sprites.position = Vector2(position.x, player.species.spriteOffset)
	$shadow.texture = player.species.shadow
	$shadow.offset = player.species.shadowOffset
	
	#setup movement
	position = position.snapped(tileSize)
	playerState = states.idle

#does nothing atm
func stateManagement():
	match playerState:
		states.idle:
			pass
		states.walking:
			$sprites.speed_scale = 1
		states.running:
			$sprites.speed_scale = 2

func _process(delta: float) -> void:
	stateManagement()
	
	if playerState == states.running:
		currentSpeed = runSpeed
	elif playerState == states.walking:
		currentSpeed = walkSpeed
	
	handleAnimations()
	
	if playerState in [states.walking, states.running]:
		continueMovement(delta)
	handleInput()
	
	camera.position = position

func handleInput():
	inputDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputDirection.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if playerState in [states.walking, states.running]:
		return
	
	if inputDirection != Vector2.ZERO:
		direction.x = inputDirection.x
		direction.y = inputDirection.y
	
	if inputDirection.x != 0 and inputDirection.y != 0:
		currentSpeed /= sqrt(2)
	
	if inputDirection != Vector2.ZERO and !handleCollision(inputDirection):
		if Input.is_action_pressed("shift"):
			playerState = states.running
		else:
			playerState = states.walking
		startMovement(direction)

func startMovement(dir: Vector2):
	direction = dir
	targetPos = position + dir * tileSize

func continueMovement(delta):
	var step = direction * currentSpeed * tileSize * delta
	position += step
	
	if direction.dot(targetPos - position) <= 0:
		position = targetPos
		playerState = states.idle

func handleCollision(dir: Vector2) -> bool:
	return test_move(global_transform, dir * tileSize/2)

#maybe convert this to an animation tree at some point
func handleAnimations():
	if playerState in [states.walking, states.running]:
		match direction:
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
	elif playerState == states.idle:
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
