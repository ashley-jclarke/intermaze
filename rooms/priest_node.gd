extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    $"../Priest".play("default")
    $Label.visible = false
    if not GameManager.last_run_win:
        $Label.text = "You failed...\nCome back to me after taking the right path."
    for body in $Area2D.get_overlapping_bodies():
        if body.is_in_group("player"):
            if body.playerid == multiplayer.get_unique_id():
                $Label.visible = true
                
