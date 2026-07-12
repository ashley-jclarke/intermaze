extends Node

enum Enemies {
    Skeleton,
    Vampire,
}

var starting_health = 100

var speed_time = 0
var strength_time = 0

var inventory = []

@onready var rooms = [
    "res://rooms/room_2.tscn",
    "res://rooms/room_3.tscn",
    "res://rooms/room_2.tscn",
    "res://rooms/room_3.tscn",
    "res://rooms/room_2.tscn",
    "res://rooms/room_3.tscn",
    "res://rooms/room_2.tscn",
    "res://rooms/room_3.tscn",
    "res://rooms/room_4.tscn",
    "res://rooms/room_4.tscn",
    "res://rooms/room_5.tscn",
    "res://rooms/room_6.tscn",
    "res://rooms/room_7.tscn",
]

@onready var checkpoint = "res://rooms/checkpoint.tscn"
@onready var lobby = "res://rooms/room_1.tscn"

var current_room

var round = -1
var controller_on = true

var stamina = 100

var noise = FastNoiseLite.new()
var turn = -1
var room_index = -1
var players = {}
var path_size = 8
var enemies = {}
var chests = {}
var doorkeys = {}
var map
var solution
var last_run_win = true

var room_cleared = true

var cleared_rooms = []
var attempt = []
var prev_direction = -1
var sudo_prev_direction = -1

func _process(delta: float) -> void:
    if multiplayer.is_server():
        sync_game()
        MultiplayerManager.sync_enemies.rpc(GameManager.enemies)
    if attempt in cleared_rooms:
        room_cleared = true
        

func die():
    if multiplayer.is_server():
        current_room = lobby
        last_run_win = true
        inventory.clear()
        reset()
        load_current_room()

func _ready() -> void:
    current_room = lobby

func load_current_room():
    get_tree().change_scene_to_file(current_room)
    if multiplayer.is_server():
        sync_game()
        MultiplayerManager.reload_room.rpc()

func reset():
    strength_time = 0
    speed_time = 0
    print("Reset")
    if last_run_win and round > 0:
        path_size += 1
    cleared_rooms.clear()
    turn = -1
    prev_direction = -1
    room_index = -1
    room_cleared = true
    attempt.clear()
    for i in players:
        players[i].health = starting_health

func load_checkpoint():
    current_room = checkpoint
    if attempt == solution:
        last_run_win = true
    load_current_room()

func generate():
    var gen = PuzzleGenerator.generate_new_map(path_size)
    map = gen[1]
    solution = gen[2]
    print(solution)
    set_seed(randi())
    MultiplayerManager.new_round.rpc(map, solution, noise.seed)

func win():
    if multiplayer.is_server():
        round += 1
        print("Checking win...")
        print("Attempt: " + str(attempt))
        print("Solution: " + str(solution))
        last_run_win = attempt == solution or round == 0
        sync_game()
        
func set_seed(_seed):
    noise.seed = _seed

func load_room():
    if not multiplayer.is_server(): return
    room_index += 1
    var ri = randi()
    current_room = rooms[ri % len(rooms)]
    sync_game()
    load_current_room()
    
func handle_move(body: Node2D, direction):
    if not room_cleared: return
    
    if body.is_in_group("player"):
        if body.playerid == multiplayer.get_unique_id():
            MultiplayerManager.next_room.rpc_id(1, direction, GameManager.attempt)

func apply_win():
    pass

func sync_game():
    Debug.print("sync_game")
    MultiplayerManager.sync_game.rpc(
        turn, 
        room_index, 
        path_size, 
        map, 
        solution, 
        attempt, 
        prev_direction, 
        current_room, 
        last_run_win, 
        sudo_prev_direction, 
        players, 
        PuzzleGenerator.width, 
        PuzzleGenerator.height,
        PuzzleGenerator.start_x,
        PuzzleGenerator.start_y
        )
    MultiplayerManager.sync_enemies.rpc(enemies)

func sync_game_id(id):
    MultiplayerManager.sync_game.rpc(
        id,
        turn, 
        room_index, 
        path_size, 
        map, 
        solution, 
        attempt, 
        prev_direction, 
        current_room, 
        last_run_win, 
        sudo_prev_direction, 
        players, 
        PuzzleGenerator.width, 
        PuzzleGenerator.height,
        PuzzleGenerator.start_x,
        PuzzleGenerator.start_y
        )
