extends Node2D

var starting = false

func _process(_delta: float) -> void:
    if multiplayer.get_unique_id() != 1:
        $Label.visible = false
        $Button.visible = false
    if starting:
        MultiplayerManager.checkpoint.rpc()

func _on_button_pressed() -> void:
    if multiplayer.get_unique_id() == 1:
        GameManager.generate()
        starting = true
