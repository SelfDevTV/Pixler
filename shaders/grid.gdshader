shader_type canvas_item;

// Grid configuration uniforms
uniform float cell_size = 32.0;
uniform vec2 camera_offset = vec2(0.0, 0.0);
uniform float line_width = 1.0;
uniform vec4 grid_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Painted cells texture and grid dimensions
uniform sampler2D painted_cells_texture;
uniform vec2 grid_size = vec2(32.0, 32.0);

void fragment() {
	// Calculate world position by adding camera offset to fragment coordinates
	vec2 world_pos = FRAGCOORD.xy + camera_offset;

	// Convert to grid space
	vec2 grid_pos = world_pos / cell_size;

	// Calculate which cell we're in
	vec2 cell_pos = floor(grid_pos);

	// Convert cell position to UV coordinates for texture sampling
	vec2 uv = (cell_pos + vec2(0.5)) / grid_size;

	// Sample the painted cells texture to check if this cell is painted
	vec4 cell_color = texture(painted_cells_texture, uv);

	// Calculate distance to nearest grid line using fract and fwidth for anti-aliasing
	vec2 grid = abs(fract(grid_pos - 0.5) - 0.5) / fwidth(grid_pos);

	// Get minimum distance (closest grid line in either x or y direction)
	float line = min(grid.x, grid.y);

	// Apply line width and convert to alpha
	float alpha = 1.0 - min(line / line_width, 1.0);

	// Hide grid line if cell is painted (alpha > threshold)
	if (cell_color.a > 0.1) {
		alpha = 0.0;
	}

	// Output the grid line color with calculated alpha
	COLOR = vec4(grid_color.rgb, alpha * grid_color.a);
}
