extends Node

var current_painting_data: Painting
var cells: Array[Cell]
var cell_scale := 4
var painted_count: int = 0
var grid_size: Vector2i:
    get: return current_painting_data.grid_size if current_painting_data else Vector2i.ZERO

signal cell_painted(position: Vector2i, color: Color)
signal painting_loaded(painting: Painting)
signal painting_complete

   
    
func _pos_to_index(pos: Vector2i) -> int:
    return pos.y * grid_size.x + pos.x

func load_painting(painting: Painting, painted_cells: Array[Vector2i] = []):
    current_painting_data = painting
    cells = current_painting_data.create_cells()
    restore_painted_cells(painted_cells)
    painting_loaded.emit(painting)
    
func has_cell_at(pos: Vector2i) -> bool:
    if (pos.x < 0 or pos.x >= grid_size.x) or (pos.y < 0 or pos.y >= grid_size.y):
        return false
    var idx = _pos_to_index(pos)
    return idx >= 0 and idx < cells.size()

func get_cell_at(pos: Vector2i) -> Cell:
    var cell = cells[_pos_to_index(pos)]
    return cell
    
func get_painted_count() -> int:
    return painted_count
    
func get_total_count() -> int:
    return cells.size()
    
func get_current_painting() -> Painting:
    return current_painting_data
        
func has_unpainted_cells() -> bool:
    return cells.any(func(c: Cell): return not c.is_painted and has_cell_color(c))
    
func has_cell_color(cell: Cell) -> bool:
    return cell.color.a > 0.0
    
func mark_cell_painted(position: Vector2i):
    painted_count += 1
    var cell = cells[_pos_to_index(position)]
    cell.is_painted = true
    cell_painted.emit(position, cell.color)
    if not has_unpainted_cells():
        painting_complete.emit()

func is_cell_painted(pos: Vector2i) -> bool:
    return get_cell_at(pos).is_painted

func get_unpainted_cell_positions() -> Array[Vector2i]:
    var positions: Array[Vector2i] = []
    var colored_cells = get_colored_cells()
    for cell in colored_cells:
        if not cell.is_painted:
            positions.append(cell.position)
    return positions
    
func get_colored_cells() -> Array[Cell]:
    var colored_cells: Array[Cell] = []
    for cell in cells:
        if cell.color.a > 0.0:
            colored_cells.append(cell)
    return colored_cells
    
func get_painted_cell_positions() -> Array[Vector2i]:
    var positions: Array[Vector2i] = []
    for cell in cells:
        if cell.is_painted:
            positions.append(cell.position)
    return positions

func restore_painted_cells(positions: Array[Vector2i]):
    painted_count = positions.size()
    for p in positions:
        cells[_pos_to_index(p)].is_painted = true
        
func world_to_cell(pos: Vector2) -> Vector2i:
    var uncentered_pos = pos + Vector2(grid_size * cell_scale) * 0.5
    var cell_pos: Vector2 = uncentered_pos / cell_scale
    return Vector2i(cell_pos.floor())
        
func cell_to_world(pos: Vector2i) -> Vector2:
    var world = pos * cell_scale
    return Vector2(world.x - grid_size.x * cell_scale / 2.0, world.y - grid_size.y * cell_scale / 2.0)
 
