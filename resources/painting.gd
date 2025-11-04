class_name Painting
extends Resource

@export var painting_name: String
@export var grid_size: Vector2i
@export var image_texture: Texture2D
@export var required_tools: Array[String]
@export var unlocks_tool: String

@export_range(0, 20, 2) var shrink_factor: float = 0



func _load_image() -> Image:
    if image_texture == null:
        push_error("No image texture assigned to painting: " + painting_name)
        return null

    var img = image_texture.get_image()
    if img == null:
        push_error("Failed to get image from texture for painting: " + painting_name)
        return null

    
    if shrink_factor > 0:
        grid_size = Vector2i(floor(img.get_width() / shrink_factor), floor(img.get_height() / shrink_factor))
    else:
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
    
    if shrink_factor > 0:
        for y in range(0, height, shrink_factor):
            for x in range(0, width, shrink_factor):
                var index = (y / shrink_factor) * grid_size.x + (x / shrink_factor)
                var col = img.get_pixel(x, y)
                var cell = Cell.new()
                cell.color = col
                #cell.is_painted = true
                cell.position = Vector2i(floor(x / shrink_factor), floor(y / shrink_factor))
                cells[index] = cell
    else:
        for y in range(height):
            for x in range(width):
                var index = y * width + x
                var col = img.get_pixel(x, y)
                var cell = Cell.new()
                cell.color = col
                cell.position = Vector2i(x, y)
                cells[index] = cell
    return cells
    
