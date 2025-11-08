class_name Upgrade
extends Resource



@export var upgrade_name: String
@export var description: String
@export var upgrade_type: UpgradeManager.UPGRADE_TYPE

@export var base_effect: float = 1.0
@export var effect_per_level: float = 0.2

@export var base_cost: float = 10
@export var mult: float = 2

@export var max_level: int = 10

func get_cost_for_level(current_level: int) -> int:
    return int(base_cost * pow(mult, current_level))
    
func get_effect_at_level(level: int) -> float:
    return base_effect + (effect_per_level * level)
