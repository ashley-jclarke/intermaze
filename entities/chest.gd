extends Node2D

@onready var item_list = $List

@export var id = 0

var highlight = 0
var loot = []

var player_in_range = false

func _ready() -> void:
    if GameManager.attempt in GameManager.cleared_rooms: return
    MultiplayerManager.sync_chest.connect(sync)
    if multiplayer.is_server():
        loot = Item.get_loot()
        GameManager.chests[id] = loot.duplicate()
        MultiplayerManager.sync_chests_to_host.rpc(GameManager.chests)
    else:
        MultiplayerManager.request_chests.rpc_id(1, multiplayer.get_unique_id())
    
func sync():
    if id not in GameManager.chests.keys():
        MultiplayerManager.request_chests.rpc_id(1, multiplayer.get_unique_id())
        return
    var data = GameManager.chests[id]
    loot = data

func _process(_delta: float) -> void:
    player_in_range = false
    for body in $Area2D.get_overlapping_bodies():
        if body.is_in_group("player"):
            if body.playerid == multiplayer.get_unique_id():
                player_in_range = true
    
    for child in item_list.get_children():
        child.queue_free()
    for i in range(len(loot)):
        var new_text = Label.new()
        match loot[i][0]:
            Item.Items.HealthPotion: new_text.text = "Health Potion"
            Item.Items.SpeedPotion: new_text.text = "Speed Potion"
            Item.Items.StrengthPotion: new_text.text = "Strength Potion"
            Item.Items.Coin: new_text.text = "Coin"
        if i != highlight:
            new_text.modulate = Color.DIM_GRAY
        item_list.add_child(new_text)
    visible = len(loot) and GameManager.room_cleared
    item_list.visible = player_in_range
    if visible and item_list.visible:
        if Input.is_action_just_pressed("down") or (GameManager.controller_on and Input.is_action_just_pressed("controller_down")):
            highlight += 1
        elif Input.is_action_just_pressed("up") or (GameManager.controller_on and Input.is_action_just_pressed("controller_up")):
            highlight -= 1
        highlight = abs(highlight % len(loot))
        if Input.is_action_just_pressed("chest") or (GameManager.controller_on and Input.is_action_just_pressed("controller_chest")):
            var item = loot[highlight][0]
            GameManager.inventory.append([item, loot[highlight][1]])
            GameManager.chests[id].remove_at(highlight)
            MultiplayerManager.update_chest_items.rpc(GameManager.chests)
