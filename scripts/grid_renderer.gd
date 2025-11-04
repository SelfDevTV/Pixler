class_name GridRenderer
extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D

@export var cell_scale: int = 32

var image: Image
var image_texture: Texture2D

func _ready() -> void:
    GridManager.painting_loaded.connect(_on_painting_loaded)
    GridManager.cell_painted.connect(_on_cell_painted)
    sprite_2d.z_index = -1
    
    
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("left_click"):
        pass
        
    
func _draw_grid_border():
    if not image: return
    for x in range(GridManager.grid_size.x):
        for y in range(GridManager.grid_size.y):
            var painted = GridManager.is_cell_painted(Vector2i(x , y))
            if not painted:
                draw_rect(Rect2(x * cell_scale, y * cell_scale, cell_scale, cell_scale), Color.BLACK, false)
            
    
func _draw() -> void:
    _draw_grid_border()

func _cell_to_world(cell_pos: Vector2i) -> Vector2:
    return Vector2(cell_pos.x * cell_scale, cell_pos.y * cell_scale)
    
func _world_to_cell(world_pos: Vector2) -> Vector2i:
    return Vector2i(floor(world_pos.x / cell_scale), floor(world_pos.y / cell_scale))
    
func _on_cell_painted(pos: Vector2i, color: Color):
    queue_redraw()
    
func _on_painting_loaded(_painting: Painting):
    image = Image.create_empty(GridManager.grid_size.x, GridManager.grid_size.y, false, Image.FORMAT_RGBA8)
    image.fill(Color.RED)
    image_texture = ImageTexture.create_from_image(image)
    sprite_2d.texture = image_texture
    sprite_2d.scale = Vector2(cell_scale, cell_scale)
    queue_redraw()

    
    
