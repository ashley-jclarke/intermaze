extends Panel

var value = "#"
var blinking = true
var blink_time = 0.8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    $Label.text = value
    $Label.global_position = global_position
    $Label.scale = scale * 0.5
    $Label.modulate = modulate


func _on_timer_timeout() -> void:
    $Label.visible = not $Label.visible or not blinking
    $Timer.start(blink_time)
