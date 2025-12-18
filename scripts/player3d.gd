#probably split this into multiple scripts at some point
extends CharacterBody3D

#TODO: https://www.youtube.com/watch?v=9GCinm040RA

var player = Pokemon.new()
@export var playerSpecies: Resource
const tileSize = Vector2(24, 24)

@export var acceleration = 2
@export var airAcceleration = 0.1
@export var maxWalkSpeed = 3
@export var maxRunSpeed = 6
@export var jumpForce = 4

@export var floorFriction = 1.2
@export var airFriction = 1.1
var currentFriction = floorFriction

var currentAcceleration = acceleration
var currentMaxSpeed = maxWalkSpeed
var accelerationDiag = acceleration / sqrt(2)
var maxWalkSpeedDiag = maxWalkSpeed / sqrt(2)
var maxRunSpeedDiag = maxRunSpeed / sqrt(2)

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
		currentAcceleration = acceleration
		currentMaxSpeed = maxRunSpeed
	elif playerState == states.walking:
		currentAcceleration = acceleration
		currentMaxSpeed = maxWalkSpeed

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
			currentMaxSpeed = maxWalkSpeedDiag
		elif playerState == states.running:
			currentMaxSpeed = maxRunSpeedDiag
		currentAcceleration = accelerationDiag
	
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

func move(delta):
	#changing acceleration and fiction values based on whether or not the player is in the air
	if is_on_floor():
		currentFriction = floorFriction
		currentAcceleration = acceleration
	else:
		currentFriction = airFriction
		currentAcceleration = airAcceleration
	
	velocity.x += inputDirection.x * currentAcceleration * delta * 100
	velocity.z += inputDirection.z * currentAcceleration * delta * 100
	velocity.x = clampf(velocity.x, -currentMaxSpeed, currentMaxSpeed)
	velocity.z = clampf(velocity.z, -currentMaxSpeed, currentMaxSpeed)
	
	if inputDirection.x == 0:
		velocity.x *= 1.0 / currentFriction
	if inputDirection.z == 0:
		velocity.z *= 1.0 / currentFriction
	
	if is_equal_approx(velocity.x, 0):
		velocity.x = 0
	if is_equal_approx(velocity.z, 0):
		velocity.z = 0
	
	if !is_on_floor():
		velocity.y -= 9.81 * delta
	elif inputDirection.y != 0:
		velocity.y = jumpForce
	else:
		velocity.y = 0
	
	if velocity.y < -1:
		playerState = states.falling
	
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
