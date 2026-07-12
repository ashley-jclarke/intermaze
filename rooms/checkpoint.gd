extends Node2D

func _ready() -> void:
    print(GameManager.attempt)
    print(GameManager.solution)
    GameManager.win()
    GameManager.reset()
    if GameManager.last_run_win:
        if multiplayer.is_server():
            GameManager.generate()
    
func _on_up_body_entered(body: Node2D) -> void:
    GameManager.handle_move(body, 0)

func _on_right_body_entered(body: Node2D) -> void:
    GameManager.handle_move(body, 1)
            
func _on_down_body_entered(body: Node2D) -> void:
    GameManager.handle_move(body, 2)

func _on_left_body_entered(body: Node2D) -> void:
    GameManager.handle_move(body, 3)
