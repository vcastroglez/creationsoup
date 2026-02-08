extends BasicCreator
class_name Creator


const DASH_FACTOR : float = 5
@onready var rlabel: Label = $CanvasLayer/RSprite/Label
@onready var glabel: Label = $CanvasLayer/GSprite/Label
@onready var blabel: Label = $CanvasLayer/BSprite/Label
@onready var alabel: Label = $CanvasLayer/ASprite/Label

@onready var rconfig: Label = $CanvasLayer/RSprite/config
@onready var gconfig: Label = $CanvasLayer/GSprite/config
@onready var bconfig: Label = $CanvasLayer/BSprite/config
@onready var aconfig: Label = $CanvasLayer/ASprite/config

var dash_factor = 1

func _process(delta):
	if Input.is_action_pressed('shift'):
		config_growth = 0.2
	else:
		config_growth = 0.1
		
	if Input.is_action_just_pressed("dash") and dash_factor == 1 :
		dash_factor += DASH_FACTOR
	elif dash_factor > 1 :
		dash_factor -= DASH_FACTOR * 0.1
		
	if Input.is_action_just_pressed("R") :
		increase_config('r', config_growth)
		
	if Input.is_action_just_pressed("G") :
		increase_config('g', config_growth)
		
	if Input.is_action_just_pressed("B") :
		increase_config('b', config_growth)
		
	if Input.is_action_just_pressed("A") :
		increase_config('a', config_growth)
	
	#clamp_config()
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if !being_pused and (input_direction.x != 0 or input_direction.y != 0) :
		velocity = input_direction * speed * dash_factor * delta
	elif !being_pused:
		velocity = Vector2.ZERO
		

	rconfig.text = str(round(config.r * 100))
	gconfig.text = str(round(config.g * 100))
	bconfig.text = str(round(config.b * 100))
	aconfig.text = str(round(config.a * 100))
	
	update_labels()

func update_labels() -> void:
	rlabel.text = str(round(color.r * 100))
	glabel.text = str(round(color.g * 100))
	blabel.text = str(round(color.b * 100))
	alabel.text = str(round(color.a * 100))
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		handle_click(event)
		
func handle_click(event : InputEventMouseButton):
	var target = get_global_mouse_position()
	shoot_projectile(target)
