extends Control

const EMPTY_SPACE = "res://Creation/empty_space.tscn"

@onready var text_edit: TextEdit = $TextureRect/TextEdit
@onready var button: Button = $TextureRect/Button
@onready var MultiplayerManager: Node = $"../../Node"

func _process(delta: float) -> void:
	#button.disabled = !text_edit.text
	pass

func _on_button_pressed() -> void:
	MultiplayerManager.join()
	%MainMenu.visible = false

func _become_host() -> void:
	MultiplayerManager.become_host()
	%MainMenu.visible = false
