extends Node2D

@export var player_scene: PackedScene
@export var spawn_positionu: Node2D
@export var spawn_positionr: Node2D
@export var spawn_positiond: Node2D
@export var spawn_positionl: Node2D
@export var directional: bool = false

var spawned_players = []

func _process(_delta: float) -> void:
    var spawn_position = spawn_positionu.global_position
    if directional:
        if GameManager.sudo_prev_direction == 1:
            spawn_position = spawn_positionr.global_position
        if GameManager.sudo_prev_direction == 2:
            spawn_position = spawn_positiond.global_position
        if GameManager.sudo_prev_direction == 3:
            spawn_position = spawn_positionl.global_position
            
    for i in GameManager.players:
        if i not in spawned_players:
            var new_player = player_scene.instantiate()
            new_player.global_position = spawn_position
            new_player.playername = GameManager.players[i].name
            new_player.playerid = i
            get_parent().add_child(new_player)
            spawned_players.append(i)
            
