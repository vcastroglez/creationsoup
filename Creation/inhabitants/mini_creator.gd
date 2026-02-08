extends CharacterBody2D
class_name BasicCreator

@export var color : Color
@export var white_creator: Sprite2D
@export var config : Color
@export var config_growth: float = 0.1
@export var speed: float = 10000.0
@export var kill_count = 1
var last_player_id_hit : int = 0

signal creator_died(creator : BasicCreator)
signal nickname_picked(id: int, nickname : String)
var being_pused = false
var direction : Vector2
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
	increase_config('r', 1)
	color = Color(0,0,0,0)

func _physics_process(delta: float) -> void:
	if !white_creator:
		return
	color.r = clamp(color.r + (0.1 * delta * kill_count), 0, 1)
	color.g = clamp(color.g + (0.1 * delta * kill_count), 0, 1)
	color.b = clamp(color.b + (0.1 * delta * kill_count), 0, 1)
	color.a = clamp(color.a + (0.3 * delta * kill_count), 0, 1)
	white_creator.modulate = color
	move_and_slide()

func increase_config(what: String, shoot_power : int) -> void :
	config = Color(0, 0, 0, config_growth * shoot_power)
	config[what] = config_growth * shoot_power
	
func get_clamp_config() -> Color :
	var to_return = Color(0,0,0,0)
	to_return.r = clamp(config.r, 0, color.r) 
	to_return.g = clamp(config.g, 0, color.g) 
	to_return.b = clamp(config.b, 0, color.b) 
	to_return.a = clamp(config.a, 0, color.a)
	return to_return 
	
func can_shoot() -> bool:
	var target = color * config * 10
	if target.r + target.g + target.b < config_growth:
		return false; 
	return true

@rpc('call_local')
func shoot_projectile(target : Vector2, player_id : int) -> void:
	var instance : BasicColor = BASIC_COLOR.instantiate()
	if !can_shoot():
		return
	instance.target = target
	instance.color = get_clamp_config()
	instance.player_id = player_id
	instance.global_position = global_position + (target - global_position).normalized() * 55
	get_tree().root.add_child(instance)
	
	color = color - instance.color

func _on_death_range_body_entered(body: Node2D) -> void:
	if body.name == 'void' :
		creator_died.emit(self)
