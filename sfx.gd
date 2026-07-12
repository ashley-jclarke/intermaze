extends Node

#var audioplayer: AudioStreamPlayer
var punch: AudioStreamPlayer
var fire: AudioStreamPlayer
var win: AudioStreamPlayer

func _ready() -> void:
    #audioplayer = AudioStreamPlayer.new()
    punch = AudioStreamPlayer.new()
    punch.stream = load("res://assets/punch.mp3")
    add_child(punch)
    
    fire = AudioStreamPlayer.new()
    fire.stream = load("res://assets/fire.mp3")
    add_child(fire)
    
    win = AudioStreamPlayer.new()
    win.stream = load("res://assets/win.mp3")
    win.volume_db -= 20
    add_child(win)

func play_punch():
    punch.play()
func play_fire():
    fire.play()
func play_win():
    win.play()
    
