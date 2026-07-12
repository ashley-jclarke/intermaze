extends Label


func _process(_delta: float) -> void:
    visible = GameManager.room_cleared
    text = "123456789ABCDEFGHIJKL"[PuzzleGenerator.get_value(GameManager.attempt)]
