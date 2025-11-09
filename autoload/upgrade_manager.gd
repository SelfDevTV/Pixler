extends Node



enum UPGRADE_TYPE {
    MOVE_SPEED,
    PAINT_SPEED,
}

var upgrade_levels: Dictionary[UPGRADE_TYPE, int] = {
    UPGRADE_TYPE.MOVE_SPEED: 0,
    UPGRADE_TYPE.PAINT_SPEED: 0
}

var upgrades: Dictionary[UPGRADE_TYPE, Upgrade] = {
    UPGRADE_TYPE.PAINT_SPEED: preload("uid://cry33lw6f5ja2"),
    UPGRADE_TYPE.MOVE_SPEED: preload("uid://dcs3gdfbhrine")
}

signal upgrade_purchased(type: UPGRADE_TYPE, new_level: int)

func get_upgrade_level(type: UPGRADE_TYPE) -> int:
    return upgrade_levels[type]
    
func get_upgrade_max_level(type: UPGRADE_TYPE) -> int:
    return upgrades[type].max_level
    
func get_upgrade_effect(type: UPGRADE_TYPE, level: int = get_upgrade_level(type)) -> float:
    return upgrades[type].get_effect_at_level(level)
    
func get_upgrade_name(type: UPGRADE_TYPE) -> String:
    return upgrades[type].upgrade_name
    
func get_cost_for_current(type: UPGRADE_TYPE) -> float:
    return upgrades[type].get_cost_for_level(get_upgrade_level(type))

func purchase_upgrade(type: UPGRADE_TYPE) -> bool:
    
    var upgrade := upgrades[type]
    var curr_level := get_upgrade_level(type)
    
    if curr_level + 1 > upgrade.max_level:
        return false
    
    if EconomyManager.spend_coins(upgrade.get_cost_for_level(curr_level)):
        #upgrade slimes
        upgrade_levels[type] += 1
        upgrade_purchased.emit(type, curr_level + 1)
        return true
    
    return false
    
