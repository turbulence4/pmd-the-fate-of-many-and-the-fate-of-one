#probably split this into multiple scripts at some point
extends CharacterBody3D

#TODO: https://www.youtube.com/watch?v=9GCinm040RA

var player = Pokemon.new()
@export var playerSpecies: Resource
const tileSize = Vector2(24, 24)

@export var acceleration = 2
@export var airAcceleration = 0.1
@export var maxWalkSpeed = 3.0
@export var maxRunSpeed = 6.0
@export var jumpForce = 4

@export var floorFriction = 12
@export var airFriction = 4
var currentFriction = floorFriction

@export var mouseSens = 0.003
@export_range(-90, 0, 0.1, "radians_as_degrees") var maxAngle = 0 #bottom
@export_range(-90, 0, 0.1, "radians_as_degrees") var minAngle = -4 * PI/9 #top
@export_range(-90, 0, 0.1, "radians_as_degrees") var defaultAngle = -PI/12
@export var isCameraActive := true
@export var isCameraSmoothed := false
@export var cameraSpeed := 0.15

var currentAcceleration = acceleration
var currentMaxSpeed = maxWalkSpeed
var accelerationDiag = acceleration
var maxWalkSpeedDiag = maxWalkSpeed
var maxRunSpeedDiag = maxRunSpeed

var inputDirection = Vector3.ZERO
var direction = Vector3(0, 0, 1)
var cameraInput = Vector2.ZERO
@onready var cameraTarget = $cameraManager/cameraTarget

enum states {idle, walking, running, jumping, falling}
var playerState: states = states.idle

func _ready():
	#setup assets
	player.species = playerSpecies
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$sprites.offset = player.species.spriteOffset
	$shadow.texture = player.species.shadow
	$shadow.offset = player.species.shadowOffset
	
	#setup movement state
	playerState = states.idle
	
	#setup camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cameraTarget.rotation.x = defaultAngle

func _unhandled_input(event: InputEvent) -> void:
	if isCameraActive:
		handleCameraInput(event)

func stateManagement():
	match playerState:
		states.idle:
			$sprites.frame = 0
		states.walking:
			$sprites.speed_scale = 1
		states.running:
			$sprites.speed_scale = maxRunSpeed / maxWalkSpeed
	
	if playerState == states.running:
		currentAcceleration = acceleration
		currentMaxSpeed = maxRunSpeed
	elif playerState == states.walking:
		currentAcceleration = acceleration
		currentMaxSpeed = maxWalkSpeed

func _process(_delta: float) -> void:
	stateManagement()
	handleAnimations()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	handleMovementInput()
	smoothCamera()
	move(delta)

#TODO: make this not apply to rotation somehow
func smoothCamera():
	if isCameraSmoothed:
		$cameraManager.position = lerp($cameraManager.position, position, cameraSpeed)
	else:
		$cameraManager.position = position

func handleCameraInput(event: InputEvent):
	if event is InputEventMouseMotion:
		cameraTarget.rotation.y -= event.relative.x * mouseSens
		cameraTarget.rotation.y = wrapf(cameraTarget.rotation.y, 0.0, TAU)
		
		cameraTarget.rotation.x -= event.relative.y * mouseSens
		cameraTarget.rotation.x = clamp(cameraTarget.rotation.x, minAngle, maxAngle)

func handleMovementInput():
	#actual input
	inputDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputDirection.y = Input.get_action_strength("jump")
	inputDirection.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	#set direction for animation
	if inputDirection.x != 0 or inputDirection.z != 0:
		direction.x = inputDirection.x
		direction.z = inputDirection.z
	
	#set direction on camera
	if inputDirection.x != 0 or inputDirection.z != 0:
		rotation.y = cameraTarget.rotation.y
	
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
	#changing acceleration and friction values based on whether or not the player is in the air
	if is_on_floor():
		currentFriction = floorFriction
		currentAcceleration = acceleration
	else:
		currentFriction = airFriction
		currentAcceleration = airAcceleration
	
	var accelerationVector = Vector3(inputDirection.x * currentAcceleration * delta * 100, 0, inputDirection.z * currentAcceleration * delta * 100)
	accelerationVector = accelerationVector.rotated(Vector3(0, 1, 0), rotation.y)
	velocity += accelerationVector
	
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if horizontal.length() > currentMaxSpeed:
		horizontal = horizontal.normalized() * currentMaxSpeed
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	
	#friction
	if inputDirection == Vector3.ZERO:
		var horizontalForFric = Vector3(velocity.x, 0, velocity.z)
		horizontalForFric = horizontalForFric.move_toward(Vector3.ZERO, currentFriction * delta)
		velocity.x = horizontalForFric.x
		velocity.z = horizontalForFric.z
	
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
#november update: wow i still can't believe i ever thought doing it like this was a good idea
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
