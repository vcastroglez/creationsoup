extends Control

const EMPTY_SPACE = "res://Creation/empty_space.tscn"

@onready var button: Button = $TextureRect/Button
@onready var MultiplayerManager: MultiplayerManager = $"../../Node"

func _on_button_pressed() -> void:
	MultiplayerManager.join()
	%MainMenu.visible = false


func _on_button_2_pressed() -> void:
	MultiplayerManager.become_host()
	%MainMenu.visible = false
