@tool
extends Node2D
class_name Map
@onready var walkable: TileMapLayer = $walkable
@onready var void_map: TileMapLayer = $void

@export var map_width : int = 64 #this is in "tiles"
@export var map_height: int = 64 #not regenerating on purpose...

@export var walkable_limit : float = 0.0 :
	set(v):
		walkable_limit = v
		generate_map()
		notify_property_list_changed()

@export var current_seed : int = randi() :
	set(v):
		current_seed = v
		generate_map()
		notify_property_list_changed()
		
@export var frequency : float =  0.2 :
	set(v):
		frequency = v
		generate_map()
		notify_property_list_changed()
		
var noise : FastNoiseLite = FastNoiseLite.new()

func _ready() -> void :
	generate_map()
	
func generate_map() -> void :
	if !walkable :
		return
	generate_noise()
	place_tiles()
	place_borders()
	
func place_borders() -> void :
	var first = Vector2(0, 0)
	var second = Vector2(64 * map_width, 0)
	var third = Vector2(0, 64 * map_height)
	var fourth = Vector2(64 * map_width, 64 * map_height)
	
	createBorder(first, second)
	createBorder(first, third)
	createBorder(third, fourth)
	createBorder(second, fourth)
	
func createBorder(A : Vector2,B : Vector2) -> void :
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = A
	shape.b = B
	
	collision.shape = shape
	
	var body = RigidBody2D.new()
	body.gravity_scale = 0
	body.freeze = true
	body.add_child(collision)
	
	self.add_child(body)
	
func place_tiles() -> void :
	walkable.clear()
	void_map.clear()
	for x in range(map_width) :
		for y in range(map_height) :
			var noise_value = noise.get_noise_2d(x, y)
			var is_walkable = noise_value < walkable_limit
			if is_walkable :
				walkable.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
			else:
				void_map.set_cell(Vector2i(x,y), 0, Vector2i(1,0))
func generate_noise() -> void :
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = current_seed
	noise.frequency = frequency
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 1
	noise.fractal_lacunarity = 9
	
	var texture = NoiseTexture2D.new()
	texture.width = map_width
	texture.height = map_height
	texture.normalize = false
	texture.noise = noise
	
