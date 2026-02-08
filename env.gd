extends Node

var loaded_keys : Dictionary = {}
var loaded := false
func _ready() -> void:
	load_env("res://.env")

func env(key : String, default: Variant = null) -> Variant:
	if !loaded :
		return default
	if loaded_keys[key]:
		return loaded_keys[key]
	return default

func load_env(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if !file:
		loaded = true
		print("Failed to open file: ", path)
		return
		
	var content = file.get_as_text()
	var lines = content.split("\n")
	for line in lines:
		var key_value = line.split('=')
		if key_value.size() !=2 || !key_value[0] || !key_value[1]:
			continue
		loaded_keys[key_value[0]] = key_value[1]
	file.close()
	loaded = true
