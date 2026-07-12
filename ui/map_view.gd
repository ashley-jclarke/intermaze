extends Node2D

var active = false

@export var speed = 800
@export var margin = 10
@export var map_node: PackedScene

@onready var map_paper = $PaperUiPanelCartoony
@onready var item_list = $ VBoxContainer
@onready var bufwheel = $CanvasLayer/BufWheel2
@onready var bufwheel2 = $CanvasLayer/BufWheel
@onready var stamina_wheel = $CanvasLayer/BufWheel4
@onready var health_wheel = $CanvasLayer/BufWheel3

var offsets = []

var last_map

func _ready() -> void:
    draw_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var speed_dif = max(0, GameManager.speed_time - Time.get_ticks_msec())
    var speed_scale = (int((speed_dif) / 10000.0)+1) * 10000
    bufwheel.max_value = move_toward(bufwheel.max_value, speed_scale, delta * 800 * 100)
    bufwheel.value = move_toward(bufwheel.value, speed_dif, delta * 800 * 50)
    var strength_dif = max(0, GameManager.strength_time - Time.get_ticks_msec())
    var strength_scale = int((strength_dif) / 10000.0) * 10000 + 10000
    bufwheel2.max_value = move_toward(bufwheel2.max_value, strength_scale, delta * 800 * 100)
    bufwheel2.value = move_toward(bufwheel2.value, strength_dif, delta * 800 * 50)
    
    stamina_wheel.value = move_toward(stamina_wheel.value, GameManager.stamina, delta*800*50)
    health_wheel.value = move_toward(health_wheel.value, GameManager.players[multiplayer.get_unique_id()].health, delta*800*50)
    
    for child in item_list.get_children():
        child.queue_free()
    for i in range(len(GameManager.inventory)):
        var new_text = Label.new()
        match GameManager.inventory[i][0]:
            Item.Items.HealthPotion: new_text.text = "Health Potion"
            Item.Items.SpeedPotion: new_text.text = "Speed Potion"
            Item.Items.StrengthPotion: new_text.text = "Strength Potion"
            Item.Items.Coin: new_text.text = "Coin"
        new_text.text += " " + str(GameManager.inventory[i][1])
        new_text.scale *= 2
        item_list.add_child(new_text)
    
    if (Input.is_action_just_pressed("mapview") or (GameManager.controller_on and Input.is_action_just_pressed("controller_main"))) and GameManager.room_cleared:
        active = not active
    
    draw_map()
    
    if active:
        map_paper.position.y = move_toward(map_paper.position.y, 648 - map_paper.texture.get_height()*4, delta*speed)
    else:
        map_paper.position.y = move_toward(map_paper.position.y, 620, delta*speed)

func draw_map():
    if not GameManager.map or (GameManager.map == last_map and last_map != null): return
    for child in map_paper.get_children():
        child.queue_free()
    offsets.clear()
    
    var cur_x = PuzzleGenerator.start_x
    var cur_y = PuzzleGenerator.start_y
    var correct = true
    
    var incorrects = []
    
    var played = [Vector2(cur_x, cur_y)]
    
    for i in range(len(GameManager.attempt)):
        var direction = GameManager.attempt[i]
        
        while Vector2(cur_x, cur_y) in played:
            match direction:
                0: cur_y -= 1
                1: cur_x += 1
                2: cur_y += 1
                3: cur_x -= 1
                
        cur_x %= PuzzleGenerator.width
        cur_y %= PuzzleGenerator.height
        if cur_x < 0:
            cur_x += PuzzleGenerator.width
        if cur_y < 0:
            cur_y += PuzzleGenerator.height
        played.append(Vector2(cur_x, cur_y))
    
        var true_direction = GameManager.solution[i]
        if direction != true_direction: 
            incorrects.append(Vector2(cur_x, cur_y))
            correct = false
    print(played)
            
    
    print(cur_x, " ", cur_y, " ", PuzzleGenerator.width, " ", PuzzleGenerator.height)
    
    for y in range(len(GameManager.map)):
        var row = GameManager.map[y]
        var dimension = float(max(len(GameManager.map),len(row))) + 1
        for x in range(len(row)):
            var val = row[x]
            if val == -1 and not ((Vector2(x, y) in incorrects)):                
                continue
            var new_text = map_node.instantiate()
            new_text.blinking = false
            
            if x == PuzzleGenerator.start_x and y == PuzzleGenerator.start_y and Vector2(x, y) not in incorrects:
                new_text.modulate = Color.DIM_GRAY
            elif x == cur_x and y == cur_y:
                new_text.blinking = true
                new_text.modulate = Color.BLACK
            else:
                new_text.modulate = Color.BLACK
                
            if val != -1 and (correct or (Vector2(x, y) not in incorrects)):
                new_text.value = "123456789XBCDEFGHIJKL"[val]
            else:
                new_text.value = "#"
                if x == cur_x and y == cur_y:
                    new_text.value = "123456789XBCDEFGHIJKL"[PuzzleGenerator.get_value(GameManager.attempt)]
                new_text.modulate = Color.RED
            map_paper.add_child(new_text)
            var offset_x = ((x+1) / dimension) * ((map_paper.texture.get_width() - 2*margin) ) 
            var offset_y = ((y+1) / dimension) * ((map_paper.texture.get_height() - 2*margin))
            new_text.position.x = offset_x - 0.5*map_paper.texture.get_width() + margin
            new_text.position.y = +margin + offset_y
            new_text.scale = map_paper.scale
            new_text.z_index = z_index + 2
            offsets.append([Vector2(offset_x, offset_y), Vector2(x,y)])
    
    last_map = GameManager.map
