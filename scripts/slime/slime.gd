class_name Slime
extends Node2D

var next_target: Vector2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $ProgressBar

@export var move_speed: float = 100.0
@export var paint_speed: float = 1.5
