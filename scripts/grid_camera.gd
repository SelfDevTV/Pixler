class_name GridCamera
extends Camera2D

@onready var grid_shader_rect: ColorRect = %GridShaderRect



# Camera modes
enum CameraMode {
    MANUAL,              # User controls (direct, responsive)
    FOLLOWING,           # Following a Node2D target (smooth)
    MOVING_TO_POSITION   # Moving to static position (smooth)
}

# State
var mode: CameraMode = CameraMode.MANUAL
var follow_target_node: Node2D = null
var target_position: Vector2
var target_zoom_level: int = 2  # Index into ZOOM_LEVELS

# Panning
var panning: bool = false
var pan_start_pos: Vector2
var pan_start_offset: Vector2

# Zoom
const ZOOM_LEVELS = [
    Vector2(0.25, 0.25),
    Vector2(0.5, 0.5),
    Vector2(1.0, 1.0),
    Vector2(2.0, 2.0),
    Vector2(4.0, 4.0),
    Vector2(8.0, 8.0),
    Vector2(16.0, 16.0)
]
var current_zoom_level: int = 6  # Start at 1.0x zoom

# Smooth interpolation settings
var smooth_position_speed: float = 5.0
var smooth_zoom_speed: float = 3.0

func _ready() -> void:
    zoom = ZOOM_LEVELS[current_zoom_level]
    zoom_to_show_full_grid()

func _process(delta: float) -> void:
    # Handle mode-specific behavior
    match mode:
        CameraMode.MANUAL:
            handle_manual_controls(delta)
        CameraMode.FOLLOWING:
            handle_following(delta)
        CameraMode.MOVING_TO_POSITION:
            handle_moving_to_position(delta)

    # Update shader parameters for grid rendering
    update_shader_parameters()

func handle_manual_controls(delta: float) -> void:
    # Discrete zoom with zoom-to-cursor
    if Input.is_action_just_pressed("zoom_in"):
        zoom_discrete(1)  # Zoom in one level
    if Input.is_action_just_pressed("zoom_out"):
        zoom_discrete(-1)  # Zoom out one level

    # Manual panning with middle mouse
    if Input.is_action_just_pressed("pan_activate"):
        panning = true
        pan_start_pos = get_viewport().get_mouse_position()
        pan_start_offset = offset

    if Input.is_action_just_released("pan_activate"):
        panning = false

    if panning:
        var current_mouse_pos = get_viewport().get_mouse_position()
        var mouse_delta = (pan_start_pos - current_mouse_pos) / zoom
        offset = pan_start_offset + mouse_delta

func handle_following(delta: float) -> void:
    # Check for manual input to cancel following
    if Input.is_action_just_pressed("zoom_in") or Input.is_action_just_pressed("zoom_out"):
        switch_to_manual()
        handle_manual_controls(delta)
        return

    if Input.is_action_just_pressed("pan_activate"):
        switch_to_manual()
        handle_manual_controls(delta)
        return

    # Follow the target
    if follow_target_node and is_instance_valid(follow_target_node):
        target_position = follow_target_node.global_position
        global_position = global_position.lerp(target_position, smooth_position_speed * delta)
    else:
        # Target is gone, switch back to manual
        switch_to_manual()

func handle_moving_to_position(delta: float) -> void:
    # Check for manual input to cancel movement
    if Input.is_action_just_pressed("zoom_in") or Input.is_action_just_pressed("zoom_out"):
        switch_to_manual()
        handle_manual_controls(delta)
        return

    if Input.is_action_just_pressed("pan_activate"):
        switch_to_manual()
        handle_manual_controls(delta)
        return

    # Smooth move to target position
    global_position = global_position.lerp(target_position, smooth_position_speed * delta)

    # Smooth zoom to target level
    var target_zoom_vector = ZOOM_LEVELS[target_zoom_level]
    zoom = zoom.lerp(target_zoom_vector, smooth_zoom_speed * delta)

    # Check if we've arrived (close enough)
    if global_position.distance_to(target_position) < 1.0 and zoom.distance_to(target_zoom_vector) < 0.01:
        global_position = target_position
        zoom = target_zoom_vector
        current_zoom_level = target_zoom_level
        switch_to_manual()

func zoom_discrete(direction: int) -> void:
    """Zoom in (direction=1) or out (direction=-1) by one discrete level, focusing on mouse cursor"""
    var old_zoom_level = current_zoom_level
    current_zoom_level = clampi(current_zoom_level + direction, 0, ZOOM_LEVELS.size() - 1)

    if old_zoom_level == current_zoom_level:
        return  # Already at min or max zoom

    # Get mouse position in world space before zoom
    var mouse_world_pos_before = get_global_mouse_position()

    # Apply new zoom
    zoom = ZOOM_LEVELS[current_zoom_level]

    # Get mouse position in world space after zoom
    var mouse_world_pos_after = get_global_mouse_position()

    # Adjust offset so mouse stays over the same world position
    offset += mouse_world_pos_before - mouse_world_pos_after

func switch_to_manual() -> void:
    """Switch to manual mode and clear any following/movement state"""
    mode = CameraMode.MANUAL
    follow_target_node = null

# Public API for automated camera movements

func follow_target(target: Node2D) -> void:
    """Continuously follow a moving target (e.g., a slime)"""
    if target and is_instance_valid(target):
        follow_target_node = target
        target_position = target.global_position
        mode = CameraMode.FOLLOWING

func stop_following() -> void:
    """Stop following the current target"""
    switch_to_manual()

func follow_position(pos: Vector2) -> void:
    """Move camera to a static position with smooth interpolation"""
    target_position = pos
    target_zoom_level = current_zoom_level  # Keep current zoom
    mode = CameraMode.MOVING_TO_POSITION

func zoom_to(target_pos: Vector2, target_zoom: float) -> void:
    """Smoothly move to position and zoom to specific level (for cinematic moments)"""
    target_position = target_pos

    # Find closest zoom level to requested zoom
    var closest_level = 0
    var closest_distance = abs(ZOOM_LEVELS[0].x - target_zoom)
    for i in range(ZOOM_LEVELS.size()):
        var distance = abs(ZOOM_LEVELS[i].x - target_zoom)
        if distance < closest_distance:
            closest_distance = distance
            closest_level = i

    target_zoom_level = closest_level
    mode = CameraMode.MOVING_TO_POSITION

func zoom_to_show_full_grid() -> void:
    """Zoom out and center to show the entire grid (for completion celebration)"""
    # Get grid size from parent GridRenderer
    var grid_renderer = get_parent()
    if grid_renderer and grid_renderer.has_method("get_grid_size"):
        var grid_size = grid_renderer.get_grid_size()
        var cell_size = grid_renderer.cell_size if grid_renderer.has("cell_size") else 32

        # Calculate grid dimensions in world space
        var grid_width = grid_size.x * cell_size
        var grid_height = grid_size.y * cell_size

        # Center position
        target_position = Vector2(grid_width / 2.0, grid_height / 2.0)

        # Calculate zoom to fit grid in viewport
        var viewport_size = get_viewport_rect().size
        var zoom_x = viewport_size.x / grid_width
        var zoom_y = viewport_size.y / grid_height
        var ideal_zoom = min(zoom_x, zoom_y) * 0.9  # 90% to leave some margin

        # Find closest zoom level
        var closest_level = 0
        var closest_distance = abs(ZOOM_LEVELS[0].x - ideal_zoom)
        for i in range(ZOOM_LEVELS.size()):
            var distance = abs(ZOOM_LEVELS[i].x - ideal_zoom)
            if distance < closest_distance:
                closest_distance = distance
                closest_level = i

        target_zoom_level = closest_level
        mode = CameraMode.MOVING_TO_POSITION
    else:
        # Fallback: zoom to a reasonable level and center at origin
        target_position = Vector2.ZERO
        target_zoom_level = 1  # 0.5x zoom
        mode = CameraMode.MOVING_TO_POSITION

func update_shader_parameters() -> void:
    """Update the grid shader with current camera position and zoom"""
    if not grid_shader_rect:
        return

    var shader_material = grid_shader_rect.material as ShaderMaterial
    if not shader_material:
        return

    # Calculate the world position that corresponds to the top-left of the viewport
    # Formula: world_pos = screen_pos / zoom + camera_offset
    # Solving for camera_offset: camera_offset = camera_world_center - viewport_center / zoom
    var viewport_center = get_viewport_rect().size / 2.0
    var camera_world_center = get_screen_center_position()
    var camera_offset = camera_world_center - viewport_center / zoom

    # Calculate grid origin offset (for centered sprite)
    # If the sprite is centered, cell (0,0) is not at world (0,0)
    
    # FIXME: needs a rework in final version, getting parent is bad
    var grid_renderer = get_parent()
    var grid_origin_offset = Vector2.ZERO

    if grid_renderer:
        var grid_size = GridManager.grid_size
        var cell_size = grid_renderer.cell_scale

        # Check if sprite is centered
        var sprite = grid_renderer.get_node_or_null("Sprite2D")
        if sprite and sprite.get("centered"):
            # If centered, the top-left corner is at negative half dimensions
            var grid_dimensions = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
            grid_origin_offset = -grid_dimensions / 2.0

    # Pass parameters to shader
    shader_material.set_shader_parameter("camera_offset", camera_offset)
    shader_material.set_shader_parameter("camera_zoom", zoom)
    shader_material.set_shader_parameter("grid_origin_offset", grid_origin_offset)
   
