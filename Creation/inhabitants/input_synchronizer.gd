extends MultiplayerSynchronizer

var input_direction

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	input_direction = Input.get_vector("left", "right", "up", "down")

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
