extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if multiplayer.get_unique_id() == 1:
        text = "IP: " + MultiplayerManager.ip + "\nPort: " + str(MultiplayerManager.port)
    else:
        text = ""
