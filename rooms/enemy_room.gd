extends Node2D

func _ready() -> void:
    GameManager.room_cleared = false

func _process(delta: float) -> void:
    if multiplayer.is_server():
        var living_player = false
        var player_count = 0
        for child in get_children():
            if child.is_in_group("player"):
                player_count += 1
                if child.state != child.State.Dead: living_player = true
        
        if not living_player and player_count > 0:
            GameManager.die()
        
        for child in get_children():
            if child.is_in_group("enemy"):
                if GameManager.room_cleared:
                    child.state = child.State.Death
                    child.dead = true
                if not child.dead: return
        MultiplayerManager.clear_room.rpc()
        
    

func _on_up_body_entered(body: Node2D) -> void:
    if len(GameManager.attempt) >= PuzzleGenerator.width:
        for i in range(PuzzleGenerator.width):
            if GameManager.attempt[len(GameManager.attempt) - i] != 0:
                GameManager.handle_move(body, 0)
                return
        if body.is_in_group("player"):
            body.global_position = $Node2D.global_position
            return
    GameManager.handle_move(body, 0)

func _on_right_body_entered(body: Node2D) -> void:
    if len(GameManager.attempt) >= PuzzleGenerator.width:
        for i in range(PuzzleGenerator.width):
            if GameManager.attempt[len(GameManager.attempt) - i] != 1:
                GameManager.handle_move(body, 1)
                return
        if body.is_in_group("player"):
            body.global_position = $Node2D2.global_position
            return
    GameManager.handle_move(body, 1)
            
func _on_down_body_entered(body: Node2D) -> void:
    if len(GameManager.attempt) >= PuzzleGenerator.width:
        for i in range(PuzzleGenerator.width):
            if GameManager.attempt[len(GameManager.attempt) - i] != 2:
                GameManager.handle_move(body, 2)
                return
        if body.is_in_group("player"):
            body.global_position = $Node2D3.global_position
            return
    GameManager.handle_move(body, 2)


func _on_left_body_entered(body: Node2D) -> void:
    if len(GameManager.attempt) >= PuzzleGenerator.width:
        for i in range(PuzzleGenerator.width):
            if GameManager.attempt[len(GameManager.attempt) - i] != 3:
                GameManager.handle_move(body, 3)
                return
        if body.is_in_group("player"):
            body.global_position = $Node2D4.global_position
            return
    GameManager.handle_move(body, 3)
