#probably split this into multiple scripts at some point
extends CharacterBody3D

#TODO: https://www.youtube.com/watch?v=9GCinm040RA

var player = Pokemon.new()
@export var playerSpecies: Resource
const tileSize = Vector2(24, 24)

@export var walkSpeed = 2
@export var runSpeed = 5
@export var jumpForce = 4
var currentSpeed = walkSpeed
var walkDiag = walkSpeed / sqrt(2)
var runDiag = runSpeed / sqrt(2)

var inputDirection = Vector3.ZERO
var direction = Vector3(0, 0, 1)
var cameraInput = Vector2.ZERO

enum states {idle, walking, running, jumping, falling}
var playerState: states = states.idle

func _ready():
	setup()

func setup():
	#setup assets
	player.species = playerSpecies
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$sprites.offset = player.species.spriteOffset
	$shadow.texture = player.species.shadow
	$shadow.offset = player.species.shadowOffset
	
	#setup movement
	playerState = states.idle

func stateManagement():
	match playerState:
		states.idle:
			$sprites.frame = 0
		states.walking:
			$sprites.speed_scale = 1
		states.running:
			$sprites.speed_scale = 2

func _process(_delta: float) -> void:
	stateManagement()
	handleAnimations()
	
	if playerState == states.running:
		currentSpeed = runSpeed
	elif playerState == states.walking:
		currentSpeed = walkSpeed

func _physics_process(delta: float) -> void:
	handleMovementInput()
	handleCameraSmooth()
	move(delta)

func handleCameraSmooth():
	$cameraManager.position = lerp($cameraManager.position, position, 0.15)

func handleMovementInput():
	#actual input
	inputDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputDirection.y = Input.get_action_strength("jump")
	inputDirection.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	#set direction for animation
	if inputDirection.x != 0 or inputDirection.z != 0:
		direction.x = inputDirection.x
		direction.z = inputDirection.z
	
	#prevent speeding up when diagonal
	if inputDirection.x != 0 and inputDirection.z != 0:
		if playerState == states.walking:
			currentSpeed = walkDiag
		elif playerState == states.running:
			currentSpeed = runDiag
	
	#state handling
	if inputDirection.x != 0 or inputDirection.z != 0:
		if Input.is_action_pressed("shift"):
			playerState = states.running
		else:
			playerState = states.walking
	else:
		playerState = states.idle
	
	if !is_equal_approx(velocity.y, 0):
		if velocity.y > 0:
			playerState = states.jumping
		else:
			playerState = states.falling

#TODO: when in the air, make movement acceleration based
func move(delta):
	velocity.x = inputDirection.x * currentSpeed * delta * 100
	velocity.z = inputDirection.z * currentSpeed * delta * 100
	
	if !is_on_floor():
		velocity.y -= 9.81 * delta
	elif inputDirection.y != 0:
		velocity.y = jumpForce
	else:
		velocity.y = 0
	
	if velocity.y < -1:
		playerState = states.falling
	
	print(states.find_key(playerState))
	
	move_and_slide()

#IMSTUPID: maybe convert this to an animation tree at some point
#wow this is fucking awful
func handleAnimations():
	if playerState in [states.walking, states.running]:
		match inputDirection:
			Vector3(1, 0, 0):
				$sprites.play("walkRight")
			Vector3(-1, 0, 0):
				$sprites.play("walkLeft")
			Vector3(0, 0, 1):
				$sprites.play("walkDown")
			Vector3(0, 0, -1):
				$sprites.play("walkUp")
			Vector3(1, 0, 1):
				$sprites.play("walkDownRight")
			Vector3(-1, 0, 1):
				$sprites.play("walkDownLeft")
			Vector3(1, 0, -1):
				$sprites.play("walkUpRight")
			Vector3(-1, 0, -1):
				$sprites.play("walkUpLeft")
	elif playerState == states.idle:
		match direction:
			Vector3(1, 0, 0):
				$sprites.play("idleRight")
			Vector3(-1, 0, 0):
				$sprites.play("idleLeft")
			Vector3(0, 0, 1):
				$sprites.play("idleDown")
			Vector3(0, 0, -1):
				$sprites.play("idleUp")
			Vector3(1, 0, 1):
				$sprites.play("idleDownRight")
			Vector3(-1, 0, 1):
				$sprites.play("idleDownLeft")
			Vector3(1, 0, -1):
				$sprites.play("idleUpRight")
			Vector3(-1, 0, -1):
				$sprites.play("idleUpLeft")
	elif playerState in [states.jumping, states.falling]:
		match direction:
			Vector3(1, 0, 0):
				$sprites.play("idleRight")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(-1, 0, 0):
				$sprites.play("idleLeft")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(0, 0, 1):
				$sprites.play("idleDown")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(0, 0, -1):
				$sprites.play("idleUp")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(1, 0, 1):
				$sprites.play("idleDownRight")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(-1, 0, 1):
				$sprites.play("idleDownLeft")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(1, 0, -1):
				$sprites.play("idleUpRight")
				$sprites.frame = 2
				$sprites.pause()
			Vector3(-1, 0, -1):
				$sprites.play("idleUpLeft")
				$sprites.frame = 2
				$sprites.pause()
