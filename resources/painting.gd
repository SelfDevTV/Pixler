class_name Painting
extends Resource

@export var painting_name: String
@export var grid_size: Vector2i
@export var image_texture: Texture2D
@export var required_tools: Array[String]
@export var unlocks_tool: String



func _load_image() -> Image:
    if image_texture == null:
        push_error("No image texture assigned to painting: " + painting_name)
        return null

    var img = image_texture.get_image()
    if img == null:
        push_error("Failed to get image from texture for painting: " + painting_name)
        return null

    grid_size = Vector2i(img.get_width(), img.get_height())
    return img
    
func create_cells() -> Array[Cell]:
    var img = _load_image()
    var cells: Array[Cell] = []
    cells.resize(grid_size.x * grid_size.y)

    if img == null:
        push_error("Cannot create cells: Image failed to load for painting: " + painting_name)
        return cells
    var width = img.get_width()
    var height = img.get_height()
    for y in range(height):
        for x in range(width):
            var index = y * width + x
            var col = img.get_pixel(x, y)
            var cell = Cell.new()
            cell.color = col
            cell.position = Vector2i(x, y)
            cells[index] = cell
    return cells
    
