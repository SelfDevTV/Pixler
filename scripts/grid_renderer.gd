class_name GridRenderer
extends Node2D

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var grid_shader_rect: ColorRect = %GridShaderRect

@export var cell_scale: int = 4

var image: Image
var image_texture: Texture2D

func _ready() -> void:
    GridManager.painting_loaded.connect(_on_painting_loaded)
    GridManager.cell_painted.connect(_on_cell_painted)
    sprite_2d.z_index = -1

    # Initialize shader uniforms
    var shader_material: ShaderMaterial = grid_shader_rect.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("cell_size", float(cell_scale))
    
    
func _process(delta: float) -> void:
    # Update shader camera offset for smooth grid rendering during camera movement
    var camera := get_viewport().get_camera_2d()
    if camera:
        var shader_material: ShaderMaterial = grid_shader_rect.material as ShaderMaterial
        if shader_material:
            var viewport_center := get_viewport_rect().size / 2.0
            var camera_offset := camera.get_screen_center_position() - viewport_center
            shader_material.set_shader_parameter("camera_offset", camera_offset)
        
    

    
func _on_cell_painted(pos: Vector2i, color: Color):
    # Update the pixel in the image texture to show the painted cell
    if image and image_texture:
        # Ensure the color has full alpha so the shader can detect it as painted
        image.set_pixel(pos.x, pos.y, color)
        image_texture.update(image)
    
func _on_painting_loaded(_painting: Painting):
    image = Image.create_empty(GridManager.grid_size.x, GridManager.grid_size.y, false, Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    for p in GridManager.get_painted_cell_positions():
            var c = GridManager.get_cell_at(p)
            image.set_pixelv(c.position, c.color)
            
    image_texture = ImageTexture.create_from_image(image)
    sprite_2d.texture = image_texture
    sprite_2d.scale = Vector2(cell_scale, cell_scale)

    # Pass texture and grid size to shader for painted cell detection
    var shader_material: ShaderMaterial = grid_shader_rect.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("grid_size", Vector2(GridManager.grid_size))
        shader_material.set_shader_parameter("painted_cells_texture", image_texture)

    
    
