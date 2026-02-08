extends RigidBody2D
class_name BasicColor

const WHITE_CREATOR = preload("res://Art/white_creator.png")
@export var color : Color = Color(1,1,1,1)
var color_power := 5000.0
@onready var timer: Timer = $Timer
@export var target : Vector2
@export var speed : float = 500.0
@export var player_id : int
var sprite : Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.scale.x = 0.5
	sprite.scale.y = 0.5
	sprite.texture = WHITE_CREATOR
	self.add_child(sprite)
	sprite.modulate = Color(color.r * 10, color.g * 10, color.b * 10, 1) 
	call_deferred("_set_up")

var target_reached = false
func _physics_process(delta: float) -> void:
	if !target or target_reached:
		return
	var direction = (target - global_position).normalized()
	linear_velocity = direction * speed
	if global_position.distance_to(target) < 5 :
		target_reached = true
		linear_velocity = Vector2.ZERO
		start_timer()
	
func _set_up() -> void:
	var area := Area2D.new()
	area.monitoring = true

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 17
	shape.shape = circle

	area.add_child(shape)
	add_child(area)

	area.body_entered.connect(Callable(self, "_on_body_entered"))

func _on_body_entered(body: BasicCreator) -> void:
	body.push(color.a * 0.5)
	var body_direction = body.direction
	var up_factor = -1 if body_direction.y < 0 else 1
	if color.r:
		body_direction.x = body_direction.x + (color_power * color.r) 
		body_direction.y = body_direction.y - (color_power * color.r) 
	if color.g:
		body_direction.y = body_direction.y + (up_factor * color_power * color.g * 2) 
	if color.b:
		body_direction.x = body_direction.x - (color_power * color.b) 
		body_direction.y = body_direction.y - (color_power * color.b) 
	body.velocity = body.velocity + body_direction
	body.color += color
	body.last_player_id_hit = player_id

func start_timer() -> void:
	if !color.a:
		queue_free()
		return
	timer.start(color.a * 2)

func _on_timer_timeout() -> void:
	
	queue_free()
