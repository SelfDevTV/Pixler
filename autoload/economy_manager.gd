extends Node

var coins := 0
signal coins_changed(new_amount: int)

func _ready() -> void:
    GridManager.cell_painted.connect(func(position: Vector2i, color: Color): add_coins(1))

func add_coins(amount: int):
    coins += amount
    coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
    if amount <= coins:
        coins -= amount
        coins_changed.emit(coins)
        return true
    else:
        return false

func can_afford(amount: int) -> bool:
    return amount <= coins
    
func get_coins() -> int:
    return coins

func set_coins(amount: int):
    coins = amount
    coins_changed.emit(coins)
