extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var sight = $SightArea
@onready var attackarea = $AttackArea
@onready var damagearea = $DamageArea
@onready var disengage = $DisengageArea

var step = 0
var attack_step = false

@export var health = 50
@export var speed = 200
@export var id: int
@export var damage_amount = 15

var target

@onready var sightshape = $SightArea/CollisionShape2D
@onready var disengageshape = $DisengageArea/CollisionShape2D
@onready var attackshape = $AttackArea/CollisionShape2D
@onready var damageshape = $DamageArea/CollisionShape2D
@onready var collisionshape = $CollisionShape2D

enum EnemyType {
    Blade,
    Scythe,
    Vampire,
    Boss_1,
    Cultist,
    Golem,
}

enum State {
    Idle, 
    Move, 
    Attack, 
    Damage,
    Death,
    Waiting
}

var stunned = false
var dead = false
var state = State.Idle
@export var type: EnemyType = EnemyType.Blade


func correct_shape_size():
    match type:
        EnemyType.Blade:
            collisionshape.shape.radius = 35
            damageshape.shape.radius = 60
            attackshape.shape.radius = 45
        EnemyType.Scythe:
            collisionshape.shape.radius = 35
            damageshape.shape.radius = 80
            attackshape.shape.radius = 60
        EnemyType.Vampire:
            collisionshape.shape.radius = 35
            damageshape.shape.radius = 60
            attackshape.shape.radius = 45
        EnemyType.Cultist:
            collisionshape.shape.radius = 35
            damageshape.shape.radius = 60
            attackshape.shape.radius = 45
        EnemyType.Boss_1:
            attackshape.shape.radius = 50
            damageshape.shape.radius = 100
            sightshape.shape.radius = 600
            disengageshape.shape.radius = 800
        EnemyType.Golem:
            attackshape.shape.radius = 80
            damageshape.shape.radius = 160
            sightshape.shape.radius = 600
            disengageshape.shape.radius = 800
            collisionshape.shape.radius = 82

func _ready() -> void:
    visible = false
    correct_shape_size()

func idle():
    match type:
        EnemyType.Blade: return "idle_sword"
        EnemyType.Scythe: return "idle_scythe"
        EnemyType.Vampire: return "idle_vampire"
        EnemyType.Boss_1: return "idle_boss"
        EnemyType.Cultist: return "idle_cultist"
        EnemyType.Golem: return "idle_golem"

func death():
    match type:
        EnemyType.Blade: return "death_sword"
        EnemyType.Scythe: return "death_scythe"
        EnemyType.Vampire: return "death_vampire"
        EnemyType.Boss_1: return "death_boss"
        EnemyType.Cultist: return "death_cultist"
        EnemyType.Golem: return "death_golem"
        
func attack():
    match type:
        EnemyType.Blade: 
            if step == 0:
                attack_step = true
                step = 1
                return "attack_sword"
            elif step == 1:
                step = 0
                return "attack_sword_2"
        EnemyType.Scythe: 
            if step == 0: 
                step = 3
                attack_step = true
                return "attack_scythe_1"
            elif step == 3:
                step = 2
                return "attack_scythe_2"
            elif step == 2:
                step = 1
                attack_step = true
                return "attack_scythe_3"
            elif step == 1:
                step = 0
                return "attack_scythe_4"
        EnemyType.Vampire: 
            if step == 0:
                step = 1
                attack_step = true
                return "attack_vampire"
            elif step == 1:
                step = 0
                return "attack_vampire_2"
        EnemyType.Boss_1: 
            if step == 0:
                step = 1
                attack_step = true
                return "attack_boss"
            elif step == 1:
                step = 0
                return "attack_boss_2"
        EnemyType.Cultist:
            if step == 0:
                step = 1
                attack_step = true
                return "attack_cultist"
            elif step == 1:
                step = 0
                return "attack_cultist_2"
        EnemyType.Golem: 
            if step == 0: 
                step = 1
                attack_step = true
                return "attack_golem"
            elif step == 1: 
                step = 0
                return "attack_golem_2"

func move():
    match type:
        EnemyType.Blade: return "move_sword"
        EnemyType.Scythe: return "move_scythe"
        EnemyType.Vampire: return "move_vampire"
        EnemyType.Boss_1: return "idle_boss"
        EnemyType.Cultist: return "move_cultist"
        EnemyType.Golem: return "move_golem"
        
func damage():
    match type:
        EnemyType.Blade: return "damage_sword"
        EnemyType.Scythe: return "damage_scythe"
        EnemyType.Vampire: return "damage_vampire"
        EnemyType.Boss_1: return "damage_boss"
        EnemyType.Cultist: return "damage_cultist"
        EnemyType.Golem: return "damage_golem"

func fix_position():
    var frames: SpriteFrames = sprite.sprite_frames
    var tex = frames.get_frame_texture(sprite.animation, sprite.frame);
    sprite.position.y = -tex.get_height()*sprite.scale.y/2
    $AttackArea.position.y = sprite.position.y / 2
    $DamageArea.position.y = sprite.position.y / 2
    collisionshape.position.y = sprite.position.y / 2
    match type:
        EnemyType.Golem:
            pass
        _:
            damagearea.position.x = damageshape.shape.radius * 0.75
            if sprite.flip_h:
                damagearea.position.x *= -1
                           

func _process(delta: float) -> void: 
    fix_position()
    
    visible = not dead
    if multiplayer.is_server():
        if str(id) in GameManager.enemies.keys():
            if "damage_stack" in GameManager.enemies[str(id)]:
                for d in GameManager.enemies[str(id)].damage_stack:
                    damage_by_(d)
        if stunned: 
            velocity = Vector2.ZERO
            step = 0
        control(delta)
        GameManager.enemies[str(id)] = {
            "animation": sprite.animation,
            "frame": sprite.frame, 
            "flip_h": sprite.flip_h,
            "position": global_position,
            "health": health,
            "visible": visible,
            "stunned": stunned,
            "dead": dead,
            "damage_stack": []
        }
    else:
        if str(id) in GameManager.enemies.keys():
            var data = GameManager.enemies[str(id)]
            global_position = data.position
            sprite.animation = data.animation
            sprite.frame = data.frame
            sprite.flip_h = data.flip_h
            health = data.health
            visible = data.visible
            stunned = data.stunned
            dead = data.dead
    if stunned: 
        modulate = Color.BLACK
        target = null
    else: modulate = Color.WHITE

func control(delta):
    if health < 0 and state != State.Death:
        state = State.Death
        visible = false
    match state:
        State.Idle:
            velocity = Vector2.ZERO
            $Label.text = "IDLE"
            sprite.play(idle())
            var temp_target
            var distance = -1
            for body in sight.get_overlapping_bodies():
                if body.is_in_group("player"):
                    if body.state == body.State.Dead: continue
                    var this_distance = (global_position - body.global_position).length()
                    if this_distance < distance or distance == -1:
                        temp_target = body
                        distance = this_distance
            target = temp_target
            if target: state = State.Move
        State.Move:
            $Label.text = "Move " + str(health)
            sprite.play(move())
            var vel = (target.global_position - $AttackArea.global_position).normalized()*speed
            if target not in disengage.get_overlapping_bodies() or target.health < 0:
                target = null
                state = State.Idle
            velocity += vel
            if target in attackarea.get_overlapping_bodies():
                state = State.Attack
        State.Attack:
            velocity = Vector2.ZERO
            $Label.text = "Attack"
            sprite.play(attack())
            state = State.Waiting
        State.Waiting:
            $Label.text = "Waiting"
        State.Damage:
            $Label.text = "Damaged"
            if $StunCoolDown.is_stopped():
                state = State.Idle
        State.Death:
            $Label.text = "Dead"
            #visible = false
    
    if velocity.x > 0:
        sprite.flip_h = false
        
    if velocity.x < 0:
        sprite.flip_h = true
        
    move_and_slide()
    velocity = Vector2.ZERO

func _on_animated_sprite_2d_animation_finished() -> void:
    if not multiplayer.is_server(): return
    if state == State.Death or stunned:
        dead = true
        step = 0
    if state == State.Waiting:
        if step == 0:
            state = State.Idle
        else:
            sprite.play(attack())
    if attack_step and state != State.Death and not stunned:
        if type == EnemyType.Scythe and step == 1: velocity = (target.global_position - global_position).normalized()*2000
        MultiplayerManager.sound_punch.rpc()
        for body in damagearea.get_overlapping_bodies():
            if body.is_in_group("player"):
                body.damage(damage_amount)
        attack_step = false

func damage_by_(amount):
    health -= amount
    stunned = true
    if health > 0:
        state = State.Damage
        sprite.play(damage())
        $StunCoolDown.start(0.2)
    else:
        sprite.play(death())
        state = State.Death
    
    if not multiplayer.is_server(): 
        MultiplayerManager.damage_enemy.rpc_id(1, id, amount)    


func _on_stun_cool_down_timeout() -> void:
    if state != State.Death:
        state = State.Idle
        stunned = false
        
