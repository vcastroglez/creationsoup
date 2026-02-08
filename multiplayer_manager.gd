extends Node

var multiplayer_scene = preload("res://Creation/inhabitants/multiplayer_player.tscn")
signal player_connected(id: int)
@onready var players: Node = $"../Players"
@onready var empty_space: EmptySpace = $".."

const HOST = 'capj.dl.cl'
const PROTOCOL = 'wss'
#const HOST = 'localhost'
#const PROTOCOL = 'ws'
const PORT = 8088

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print('Starting server')
		become_host()

#region Host
func become_host() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_server(PORT, "127.0.0.1")
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	#_add_player_to_game(get_multiplayer_authority())
	
func _add_player_to_game(id: int) -> void:
	var player_to_add : MultiplayerPlayer = multiplayer_scene.instantiate()
	player_to_add.name = str(id)
	player_to_add.player_id = id
	
	players.add_child.call_deferred(player_to_add, true)
	empty_space.player_connected.call_deferred(id)
	
func _del_player(id: int) -> void:
	if not players.has_node(str(id)):
		return
	players.get_node(str(id)).queue_free()
#endregion

#region Client
func join() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client('wss://capj.dl.cl/site/creationsoup')
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(_server_disconnected)
func _server_disconnected():
	get_tree().reload_current_scene()
#endregion
