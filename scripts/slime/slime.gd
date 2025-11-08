class_name Slime
extends Node2D

var next_target: Vector2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar

var move_speed: float
var paint_speed: float

func _ready() -> void:
    calculate_stats()
    UpgradeManager.upgrade_purchased.connect(_on_upgrade_purchased)

func calculate_stats() -> void:
    move_speed = UpgradeManager.get_upgrade_effect(UpgradeManager.UPGRADE_TYPE.MOVE_SPEED)
    paint_speed = UpgradeManager.get_upgrade_effect(UpgradeManager.UPGRADE_TYPE.PAINT_SPEED)

func _on_upgrade_purchased(upgrade: UpgradeManager.UPGRADE_TYPE, new_level: int):
    print("upgrade bought")
    calculate_stats()
