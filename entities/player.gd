extends CharacterBody2D

@export var speed = 250
@export var strength = 45

var health
var playername = MultiplayerManager.playername
var playerid = -1
var stunned = false
var state
var step = 0
var attack_step = false
var flip_h = false

var dash_vel

enum State {
    Idle,
    Move,
    Attack,
    Dead,
}

@onready var sprite = $spritecenter/AnimatedSprite2D

func stun():
    $StunTimer.start(0.2)
    stunned = true

func _ready() -> void:
    state = State.Idle
    if playerid == -1:
        playerid = multiplayer.get_unique_id()
    
    if playerid == multiplayer.get_unique_id():
        health = GameManager.players[playerid].health
    else:
        health = GameManager.starting_health
    
    MultiplayerManager.stun.connect(stun)

func _physics_process(delta: float) -> void:
    #match state:
        #State.Idle:
            #$Label.text = "Idle"
        #State.Move:
            #$Label.text = "Move"
        #State.Dead:
            #$Label.text = "Dead"
            #health = 0
        #State.Attack:
            #$Label.text = "Attack"
        
    

    if not stunned:
        modulate = Color.WHITE
    else:
        modulate = Color.BLACK
    if flip_h:
        $spritecenter.scale.x = -1
    else:
        $spritecenter.scale.x = 1
    $Label.text = playername
    $CanvasLayer/ProgressBar.value = health
    $CanvasLayer.visible = playerid == multiplayer.get_unique_id()
    
    
    if playerid in GameManager.players.keys():
        if not multiplayer.is_server():
                var data = GameManager.players[playerid]
                health = data.health
                $SpellSprite.visible = data.spell_visible
                $SpellSprite.frame = data.spell_frame
        else:
            GameManager.players[playerid].spell_frame = $SpellSprite.frame
            GameManager.players[playerid].spell_visible = $SpellSprite.visible
            
    if playerid == multiplayer.get_unique_id():
        move()
        GameManager.stamina += delta*20
        GameManager.stamina = max(0,min(GameManager.stamina, 100))
        
        MultiplayerManager.update_position.rpc_id(1,
            global_position, 
            flip_h,
            sprite.frame,
            sprite.animation,
            state,
            multiplayer.get_unique_id()
        )
        
        if Input.is_action_just_pressed("use") or (GameManager.controller_on and Input.is_action_just_pressed("controller_use")):
            if GameManager.inventory:
                var itemdata = GameManager.inventory[0]
                var item = itemdata[0]
                var count = itemdata[1]
                
                match item:
                    Item.Items.HealthPotion:
                        print("Health Potion!")
                        if multiplayer.is_server():
                            GameManager.players[playerid].health += 10
                            health += 10
                        else:
                            MultiplayerManager.heal_player.rpc_id(1, playerid, 10)
                    Item.Items.SpeedPotion:
                        if GameManager.speed_time > Time.get_ticks_msec():
                            GameManager.speed_time += 10000
                        else:
                            GameManager.speed_time = Time.get_ticks_msec() + 10000
                    Item.Items.StrengthPotion:
                        if GameManager.strength_time > Time.get_ticks_msec():
                            GameManager.strength_time += 10000
                        else:
                            GameManager.strength_time = Time.get_ticks_msec() + 10000
                        
                
                if count-1 <= 0:
                    GameManager.inventory.remove_at(0)
                else:
                    GameManager.inventory[0] = [item, count-1]
                
    elif playerid in GameManager.players.keys():
        var data = GameManager.players[playerid]
        global_position = data.position
        flip_h = data.h_flip
        sprite.frame = data.frame
        if data.animation: sprite.animation = data.animation
        if data.state: state = data.state
        if data.queue_spell:
            GameManager.players[playerid].queue_spell = false
            use_spell()
        stunned = data.stunned
    else:
        print("DELETED")
        queue_free()
    
func use_spell():
    sprite.play("attack_swipe")
    attack_step = true
    step = 1
    state = State.Attack
    
func move():
    if health <= 0 and state != State.Dead:
        sprite.play("death")
        return

    var vel = Vector2.ZERO
    if not stunned and health > 0:
        vel = Vector2(Input.get_axis("left","right"), Input.get_axis("up", "down")).normalized()*speed
        if GameManager.controller_on:
            vel = Vector2(Input.get_axis("controller_left","controller_right"), Input.get_axis("controller_up", "controller_down")).normalized()*speed
 
    
    if vel.length() > 0 and state in [State.Move, State.Idle]:
        state = State.Move
    elif state == State.Move:
        state = State.Idle
    if vel.length() > 0:
        dash_vel = vel
    
    if GameManager.speed_time > Time.get_ticks_msec():
        vel *= 2
        
    
    
    if (Input.is_action_just_pressed("mapview") or (GameManager.controller_on and Input.is_action_just_pressed("controller_main"))) and not GameManager.room_cleared and state != State.Attack and state != State.Dead and health > 0:
        use_spell()
        MultiplayerManager.sound_fire.rpc()

    
    if state == State.Move:
        sprite.play("move")
    else:
        vel = Vector2.ZERO
        if state == State.Idle:
            sprite.play("idle")
    if vel.x > 0: 
        flip_h = false
    elif vel.x < 0:
        flip_h = true
    if Input.is_action_just_pressed("dash") or (GameManager.controller_on and Input.is_action_just_pressed("controller_dash")) and GameManager.stamina > 25:
        GameManager.stamina -= 25
        vel += dash_vel * 16
    velocity = vel
    
    move_and_slide()
    
func damage(val):
    if multiplayer.is_server():
        health -= val
        GameManager.players[playerid].health = health
        MultiplayerManager._sync_health()
        if playerid != 1:
            MultiplayerManager.stun_player.rpc_id(playerid)
        else:
            stun()

func _on_spell_sprite_animation_finished() -> void:
    if multiplayer.is_server():
        $SpellSprite.visible = false
        
func _on_stun_timer_timeout() -> void:
    stunned = false
    MultiplayerManager.set_stunned.rpc(playerid, stunned)

func _on_animated_sprite_2d_animation_finished() -> void:
    if state == State.Attack:
        if attack_step:
            for body in $Area2D.get_overlapping_bodies():
                if body.is_in_group("enemy"):
                    var scale = 1
                    if Time.get_ticks_msec() < GameManager.strength_time:
                        scale = 2
                    body.damage_by_(strength*scale)
        if step == 0:
            state = State.Idle
            attack_step = false
        elif step == 1:
            step = 0
            attack_step = false
            sprite.play("attack_swipe_2")
    if health <= 0:
        state = State.Dead
            
        
