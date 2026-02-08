extends Node2D
class_name EmptySpace

@onready var walkable: TileMapLayer = $Map/walkable
@onready var players: Node = $Players
@onready var MultiplayerManager: Node = $Node
func _ready() -> void :
	MultiplayerManager.player_connected.connect(Callable(self, 'player_connected'))
	
func player_connected(id: int) -> void:
	place_creator.rpc(id)

func _process(delta: float) -> void:
	pass
	
func _on_creator_death(creator: MultiplayerPlayer) -> void:
	print(creator.last_player_id_hit)
	place_creator.rpc(creator.player_id)
	
	var killer : BasicCreator = players.get_node(str(creator.last_player_id_hit))
	if killer:
		killer.kill_count += 1

@rpc('call_local')
func place_creator(id: int) -> void:
	var creator : BasicCreator = players.get_node(str(id))
	if !creator:
		return
	prints(str(creator.player_id), multiplayer.get_unique_id(),'placed')
	var placement = Vector2i(randi_range(0, 64), randi_range(0, 64))
	var cell_data = walkable.get_cell_tile_data(placement)
	if !cell_data :
		place_creator(id)
	else:
		creator.velocity = Vector2.ZERO
		creator.position = Vector2(placement.x * 64 + 32, placement.y * 64 + 32)
		creator.kill_count = 1
		creator.increase_config('r', 1)
		creator.creator_died.connect(Callable(self, '_on_creator_death'))
	
