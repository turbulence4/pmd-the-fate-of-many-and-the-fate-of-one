class_name SpeciesResource extends Resource

#basic info & base stats (lvl 5)
@export var name: String
@export var maxHp: int
@export var attack: int
@export var defense: int
@export var spAttack: int
@export var spDefense: int
@export var speed: int
@export var types: Array[String]

#appearance
@export var spriteFrames: SpriteFrames
@export var spriteOffset := Vector2(0.5, 6.0)
@export var shadow: Texture
@export var shadowOffset := Vector2(0.0, 0.0)
