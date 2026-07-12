extends Node

signal stun
signal sync_chest

var peer
var ip
var port
var playername = "nameless"
var upnp

func _ready() -> void:
    multiplayer.peer_connected.connect(player_connected)
    multiplayer.peer_disconnected.connect(player_disconnected)
    multiplayer.connected_to_server.connect(connected_to_server)
    multiplayer.connection_failed.connect(connection_failed)
    
@rpc("any_peer", "call_local")
func clear_room():
    Debug.print("clear_room")
    if multiplayer.is_server() and not GameManager.room_cleared:
        sound_win.rpc()
        Debug.print("Cleared " + str(GameManager.attempt))
        GameManager.cleared_rooms.append(GameManager.attempt.duplicate())
        Debug.print(GameManager.cleared_rooms)
    GameManager.room_cleared = true
    
        
@rpc("any_peer", "call_remote")
func new_round(new_map, solution, _seed):
    Debug.print("new_round")
    GameManager.map = new_map
    GameManager.set_seed(_seed)
    GameManager.solution = solution

@rpc("authority", "call_local", "unreliable")
func sync_enemies(enemies: Dictionary):
    GameManager.enemies = enemies

@rpc("any_peer", "call_remote")
func damage_enemy(id, damage):
    print("DAMAGE ENEMY ", damage)
    GameManager.enemies[str(id)].damage_stack.append(damage)
    
@rpc("any_peer", "call_local")
func next_room(direction, attempt):
    if attempt != GameManager.attempt: return
    #print("CALL")
    GameManager.sudo_prev_direction = direction
    #print("Bfore: ", direction," ", GameManager.prev_direction, " ", GameManager.attempt," ", GameManager.turn)
    
    if (direction == 0 and GameManager.prev_direction == 2) or (direction == 2 and GameManager.prev_direction == 0) or (direction == 1 and GameManager.prev_direction == 3) or (direction == 3 and GameManager.prev_direction == 1) and GameManager.turn > -1:
        # prev direction is the 2nd to last not the last
        GameManager.attempt.pop_back()
        if GameManager.attempt:
            GameManager.prev_direction = GameManager.attempt[-1]
        else:
            GameManager.prev_direction = GameManager.sudo_prev_direction
        GameManager.turn -= 1
    else:
        GameManager.attempt.append(direction)
        GameManager.prev_direction = direction
        GameManager.turn += 1
    #print("After: ", direction," ", GameManager.prev_direction, " ", GameManager.attempt," ", GameManager.turn)

    if GameManager.turn >= GameManager.path_size-1 or GameManager.turn < 0:
        checkpoint.rpc()
    else:
        GameManager.load_room()
    if multiplayer.is_server():
        reload_room.rpc()

@rpc("any_peer", "call_local")
func checkpoint():
    GameManager.load_checkpoint()

@rpc("authority", "call_remote", "unreliable")
func sync_game(turn, room_index, path_size, map, solution, attempt, prev_direction, current_room, last_run_win, sudo_prev_direction, players, width, height, start_x, start_y):
    Debug.print("sync_game")
    GameManager.turn = turn
    GameManager.room_index = room_index
    GameManager.path_size = path_size
    GameManager.map = map
    GameManager.solution = solution
    GameManager.attempt = attempt
    GameManager.current_room = current_room
    GameManager.prev_direction = prev_direction
    GameManager.last_run_win = last_run_win
    GameManager.sudo_prev_direction = sudo_prev_direction
    GameManager.players = players
    PuzzleGenerator.width = width
    PuzzleGenerator.height = height
    PuzzleGenerator.start_x = start_x
    PuzzleGenerator.start_y = start_y
    #GameManager.load_current_room()
    #print("Synced")

func player_connected(id):
    print("Player " + str(id) + " connected ", multiplayer.get_unique_id())
    
func player_disconnected(id):
    print("Player " + str(id) + " disconnected")
    remove_player.rpc(id)
    if id == 1:
        get_tree().change_scene_to_file("res://ui/start.tscn")

func connected_to_server():
    print("Connected to server!")
    send_player_information.rpc_id(1, playername, multiplayer.get_unique_id())

func connection_failed():
    print("Failed to connect to server...")

@rpc("any_peer", "call_local")
func remove_player(id):
    GameManager.players.erase(id)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if upnp:
            upnp.delete_port_mapping(port, "UDP")
            upnp.delete_port_mapping(port, "TCP")
        get_tree().quit()

@rpc("authority", "call_remote")
func sync_chests_to_host(chests):
    Debug.print("sync_chests_to_host")
    GameManager.chests = chests
    sync_chest.emit()

@rpc("any_peer", "call_local")
func update_chest_items(chests):
    Debug.print("update_chest_items")
    GameManager.chests = chests
    sync_chest.emit()

@rpc("any_peer", "call_remote")
func request_chests(id):
    Debug.print("request_chests")
    sync_chests_to_host.rpc_id(id, GameManager.chests)

@rpc("any_peer")
func send_player_information(_name, id):
    Debug.print("send_player_information")
    if !GameManager.players.has(id):
        GameManager.players[id] = {
            "name": _name,
            "id": id,
            "position": Vector2(0,0),
            "h_flip": false,
            "frame": 0,
            "health": GameManager.starting_health,
            "spell_visible": false,
            "spell_frame":0,
            "queue_spell": false,
            "stunned": false,
            "animation": null,
            "state": null,
            "inventory": {}
        }
    if multiplayer.is_server():
        GameManager.sync_game_id(id)
        for i in GameManager.players:
            send_player_information.rpc(GameManager.players[i].name, i)
    #print(multiplayer.get_unique_id(), GameManager.players)

@rpc("any_peer", "call_local", "unreliable")
func update_position(new_position, hflip, frame, animation, state, id):
    Debug.print("update_position")
    if not multiplayer.is_server(): return
    if id in GameManager.players.keys():
        GameManager.players[id].position = new_position
        GameManager.players[id].h_flip = hflip
        GameManager.players[id].frame = frame
        GameManager.players[id].animation = animation
        GameManager.players[id].state = state

func host(_port, local=false):
    if not local:
        upnp = UPNP.new()
        var discover_result = upnp.discover()
        if discover_result == UPNP.UPNP_RESULT_SUCCESS:
            if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
                var map_result_udp = upnp.add_port_mapping(_port, 0, "intermaze", "UDP", 0)
                var map_result_tcp = upnp.add_port_mapping(_port, 0, "intermaze", "TCP", 0)
                
                if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
                    upnp.add_port_mapping(port, port, "", "UDP")
                if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
                    upnp.add_port_mapping(port, port, "", "TCP")
        
        var external_ip = upnp.query_external_address()
        
        ip = external_ip
    else:
        ip = "127.0.0.1"
    
    port = _port
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(_port)
    if error != OK:
        print("Cannot host: " + str(error))
        return false
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    
    multiplayer.set_multiplayer_peer(peer)
    multiplayer.server_relay = true
    print("Waiting for players")
    send_player_information(playername, multiplayer.get_unique_id())
    return true

func join(_ip, _port):
    ip = _ip
    port = _port
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(_ip, _port)
    if error != OK:
        print("Failed to connect")
        return false
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    multiplayer.set_multiplayer_peer(peer)
    return true

func _sync_health():
    Debug.print("_sync_health")
    for i in GameManager.players:
        sync_health.rpc(GameManager.players[i].health, i)
    
@rpc("authority", "call_remote")
func sync_health(health, id):
    Debug.print("sync_health")
    if id in GameManager.players.keys():
        GameManager.players[id].health = health

@rpc("authority", "call_remote")
func stun_player():
    Debug.print("stun_player")
    stun.emit()

func _sync_spell():
    Debug.print("_sync_spell")
    if not multiplayer.is_server():return
    for i in GameManager.players:
        sync_spell.rpc(GameManager.players[i].spell_visible, GameManager.players[i].spell_frame, i)

@rpc("authority", "call_remote")
func sync_spell(visib, fram, id):
    Debug.print("sync_spell")
    if id in GameManager.players.keys():
        GameManager.players[id].spell_visible = visib
        GameManager.players[id].spell_frame = fram
        
func _sync_stunned():
    Debug.print("_sync_stunned")
    if not multiplayer.is_server():return
    for i in GameManager.players:
        set_stunned.rpc(GameManager.players[i].stunned, i)

@rpc("authority", "call_remote")
func sync_stunned(state, id):
    Debug.print("sync_stunned")
    if id in GameManager.players.keys():
        
        GameManager.players[id].stunned = state

@rpc("any_peer", "call_remote")
func use_spell(id):
    GameManager.players[id].queue_spell = true

@rpc("authority", "call_local")
func sound_punch():
    Sfx.play_punch()
@rpc("authority", "call_local")
func sound_fire():
    Sfx.play_fire()
@rpc("authority", "call_local")
func sound_win():
    Sfx.play_win()

@rpc("authority", "call_remote")
func reload_room():
    Debug.print("reload_room")
    if not multiplayer.is_server():
        GameManager.load_current_room()

@rpc("any_peer", "call_remote")
func set_stunned(id, stunned):
    Debug.print("set_stunned")
    if not id in GameManager.players.keys(): return
    GameManager.players[id].stunned = stunned

@rpc("any_peer", "call_remote")
func heal_player(id, amount):
    Debug.print("heal_player")
    GameManager.players[id].health += amount
    GameManager.players[id].health = min(GameManager.players[id].health, GameManager.starting_health)
    _sync_health()
    
    
