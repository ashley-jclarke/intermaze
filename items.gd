extends Node

enum Items {
    HealthPotion,
    SpeedPotion,
    StrengthPotion,
    Coin,
}

var loot_table = [
    [],[],[],[],[],
    [
        [Items.HealthPotion, 1],
        [Items.Coin, 2]
    ],[
        [Items.HealthPotion, 2],
    ],[
        [Items.SpeedPotion, 1],
    ],[
        [Items.Coin, 3]
    ],[
        [Items.Coin, 2]
    ],[
        [Items.Coin, 4]
    ],[
        [Items.SpeedPotion, 1],
        [Items.Coin, 2]
    ],[
        [Items.HealthPotion, 1],
        [Items.Coin, 3]
    ],[
        [Items.HealthPotion, 1],
        [Items.SpeedPotion, 1],
        [Items.StrengthPotion, 1],
    ],
    [
        [Items.StrengthPotion, 1],
    ],
    [
        [Items.StrengthPotion, 2],
    ],
    [
        [Items.StrengthPotion, 3],
    ],
    [
        [Items.StrengthPotion, 3],
    ],
    [
        [Items.StrengthPotion, 3],
    ],
    [
        [Items.StrengthPotion, 3],
    ],
]

func get_loot():
    return loot_table[randi() % len(loot_table)]
