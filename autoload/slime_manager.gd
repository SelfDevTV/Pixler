extends Node

var slimes: Array[Slime] = []
var slimeScene: PackedScene = preload("uid://bcv285lotcjmh")

signal slime_purchased(slime: Slime)

func purchase_slime() -> bool:
    var cost = calculate_slime_cost()
    
    if EconomyManager.spend_coins(cost):
        var slime: Slime = slimeScene.instantiate()
        add_child(slime)
        slime.global_position = Vector2.ZERO
        slimes.append(slime)
        slime_purchased.emit(slime)
        return true
    return false
    
func calculate_slime_cost() -> int:
    var base = EconomyManager.game_config.slime_base_cost
    return base * pow(EconomyManager.game_config.slime_cost_multi, slimes.size())
    
