extends CharacterBody2D
class_name BasicCreator

@export var color : Color
@export var white_creator: Sprite2D
@export var config : Color
@export var config_growth: float = 0.1
@export var speed: float = 50000.0

signal creator_died(creator : BasicCreator)
var being_pused = false
const WHITE_CREATOR = preload("res://Art/white_creator.png")
const BASIC_COLOR = preload("res://Creation/BasicColor.tscn")

func push(timeout : float) -> void :
	being_pused = true
	await get_tree().create_timer(clamp(timeout - color.a * 0.4, config_growth, 1)).timeout
	being_pused = false
	
func init_creator() -> void:
	if !white_creator:
		white_creator = Sprite2D.new()
		white_creator.z_index = 1
		white_creator.texture = WHITE_CREATOR
		add_child(white_creator)
		
	var background = Sprite2D.new()
	background.z_index = 0
	background.texture = WHITE_CREATOR
	background.modulate = Color.BLACK
	background.scale.x = 1.1
	background.scale.y = 1.1
	background.position = Vector2(0.5,0.5)
	
	add_child(background)
	
	var death_range := Area2D.new()
	var death_shape := CollisionShape2D.new()
	var cicle_shape := CircleShape2D.new()
	cicle_shape.radius = 29.02
	death_shape.shape = cicle_shape
	death_range.body_entered.connect(Callable(self, '_on_death_range_body_entered'))
	self.add_child(death_range)
	death_range.add_child(death_shape)
	config = Color(0.1,0.1,0.1,0.1)
	color = Color(0,0,0,0)

func _physics_process(delta: float) -> void:
	if !white_creator:
		return
	color.r = clamp(color.r + (0.1 * delta), 0, 1)
	color.g = clamp(color.g + (0.1 * delta), 0, 1)
	color.b = clamp(color.b + (0.1 * delta), 0, 1)
	color.a = clamp(color.a + (0.1 * delta), 0, 1)
	white_creator.modulate = color	
	move_and_slide()

	
func increase_config(what: String, value : float) -> void :
	if config[what] >= 1:
		config[what] = 0.1
		return
	config[what] = config[what] + value
	
func get_clamp_config() -> Color :
	var to_return = Color(0,0,0,0)
	to_return.r = clamp(config.r, 0, color.r) 
	to_return.g = clamp(config.g, 0, color.g) 
	to_return.b = clamp(config.b, 0, color.b) 
	to_return.a = clamp(config.a, 0, color.a)
	return to_return 
	
func can_shoot() -> bool:
	if (
		color.r < config_growth and 
		color.g < config_growth and 
		color.b < config_growth and 
		color.a < config_growth
	):
		return false
	return true
	
func shoot_projectile(target : Vector2) -> void:
	var instance : BasicColor = BASIC_COLOR.instantiate()
	if !can_shoot():
		return
	instance.target = target
	instance.color = get_clamp_config()
	instance.creator = self
	instance.global_position = global_position + (target - global_position).normalized() * 55
	get_tree().root.add_child(instance)
	
	color = color - instance.color

func _on_death_range_body_entered(body: Node2D) -> void:
	if body.name == 'void' :
		creator_died.emit(self)
