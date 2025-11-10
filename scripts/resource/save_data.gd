class_name SaveData
extends Resource

@export var coins: int
@export var slime_count: int
@export var upgrade_levels: Dictionary[UpgradeManager.UPGRADE_TYPE, int]
@export var current_painting_name: String
@export var painting_progress: Dictionary[String, Painting]
@export var slime_last_positions: Array[Vector2i]
