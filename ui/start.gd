extends Control

@export var address = "127.0.0.1"
@export var port = 8910
@export var lobby: PackedScene

@onready var hostport = $TabBar/Host/LineEdit
@onready var joinip = $TabBar/Join/IP
@onready var joinport = $TabBar/Join/Port
var peer

func _on_host_pressed() -> void:
    port = int(hostport.text)
    if $Panel/LineEdit.text:
        if MultiplayerManager.host(port):
            start_game()
    if $"TabBar/Host/Path Size".text:
        var num = int($"TabBar/Host/Path Size".text)
        if num:
            GameManager.path_size = min(num, 24)
    
func _on_join_pressed() -> void:
    address = joinip.text
    port = int(joinport.text)
    if $Panel/LineEdit.text:
        if MultiplayerManager.join(address, port):
            start_game()

func start_game():
    get_tree().change_scene_to_packed(lobby)


func _on_line_edit_text_changed(new_text: String) -> void:
    MultiplayerManager.playername = new_text


func _on_local_pressed() -> void:
    port = int(hostport.text)
    if $Panel/LineEdit.text:
        if MultiplayerManager.host(port, true):
            start_game()

func _physics_process(delta: float) -> void:
    GameManager.controller_on = $Panel/CheckButton.button_pressed
