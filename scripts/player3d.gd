extends CharacterBody3D

var player = Pokemon.new()
@export var playerSpecies: Resource
const tileSize = Vector2(24, 24)

#in tiles per second
@export var walkSpeed = 4
@export var runSpeed = 16
var currentSpeed = walkSpeed

var inputDirection = Vector3(0, 0, 0)
var direction = Vector3(0, 0, 1)

enum states {idle, walking, running}
var playerState: states = states.idle

func _ready():
	setup()

func setup():
	#setup assets
	player.species = playerSpecies
	player.hp = player.species.maxHp
	$sprites.sprite_frames = player.species.spriteFrames
	$shadow.texture = player.species.shadow
	#fix: $shadow.position = Vector3(0, 0, player.species.shadowOffset)
	
	#move this to process once i implement camera movement
	spriteCameraSync()
	
	#setup movement
	playerState = states.idle

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
	
	handleInput(delta)

func handleInput(delta):
	inputDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputDirection.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if inputDirection != Vector3.ZERO:
		direction.x = inputDirection.x
		direction.z = inputDirection.z
	
	if inputDirection.x != 0 and inputDirection.z != 0:
		currentSpeed /= sqrt(2)
	
	if inputDirection != Vector3.ZERO:
		if Input.is_action_pressed("shift"):
			playerState = states.running
		else:
			playerState = states.walking
		move(inputDirection, delta)	
	else:
		playerState = states.idle

func move(dir: Vector3, delta):
	position += dir * currentSpeed * delta

func spriteCameraSync():
	#wow i haven't used this formula since middle school lmao
	var adjacent = sqrt(pow($camera.position.x - position.x, 2) + pow($camera.position.z - position.z, 2))
	var opposite = $camera.position.y - position.y
	#will need to fix accounting for the camera's rotation once i add the ability to move it
	var theta = abs(atan(opposite / adjacent) + $camera.rotation.x)
	$sprites.rotation.x = -theta
	#$shadow.rotation.x = -theta

#maybe convert this to an animation tree at some point
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
