class_name Cell
extends Resource

enum CellType{
    NORMAL,
    ICE,
    ROCK
}

@export var position: Vector2i
@export var color: Color = Color.WHITE
@export var is_painted: bool = false
@export var cell_type: CellType = CellType.NORMAL
