# Pixel Paint Idle Game - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an MVP idle game where autonomous slime workers paint pixel art grids, revealing hidden images while earning coins for progression.

**Architecture:** Scene-based Godot structure with autoloaded singletons for game state, economy, and save/load. Grid system manages cell data and rendering. Slime AI uses node-based state machine pattern with dedicated StateMachine node and State children for visual debugging and readability. Signal-based communication between systems. Painting resources use Texture2D for better editor integration and resource management.

**Tech Stack:** Godot 4.x, GDScript, Image texture manipulation for grid rendering, State Machine for slime AI, ResourceSaver/ResourceLoader for persistence.

---

## Development Phases

This plan is organized into 4 phases:
1. **Foundation:** Project setup, grid system, basic rendering
2. **Core Gameplay:** Slimes, AI, painting mechanics, economy
3. **Progression:** Gallery, paintings, save/load
4. **Polish:** Tutorial, UI, audio, particles, juice

Each phase builds on the previous and results in a testable increment.

---

## Phase 1: Foundation (Project Setup & Grid System)

### Task 1.1: Project Setup

**Goal:** Initialize Godot project with proper structure

**Files to Create:**
- `project.godot` (Godot project file)
- `res://scenes/` (directory)
- `res://scripts/` (directory)
- `res://assets/` (directory)
- `res://assets/images/` (directory)
- `res://assets/audio/` (directory)
- `res://autoload/` (directory for singletons)
- `res://resources/` (directory for custom resources)

**Steps:**
1. Create new Godot 4.x project in `/Users/dom/Documents/godot/idler`
2. Set project settings: window size (1280x720), stretch mode (viewport), aspect (keep)
3. Create directory structure as listed above
4. Configure version control (enable in project settings)
5. Test: Run empty project to verify setup

**Notes:**
- Use viewport stretch mode for consistent UI scaling
- Enable "Use Hidden Files" in project settings for better git integration

---

### Task 1.2: Cell Resource Definition

**Goal:** Define custom resource for cell data

**Files to Create:**
- `res://resources/cell.gd`

**What This Resource Needs:**
- Properties: position (Vector2i), color (Color), is_painted (bool), cell_type (enum)
- Cell types enum: NORMAL, ICE, ROCK (ICE and ROCK for future, only NORMAL in MVP)
- Export variables for inspector editing

**Steps:**
1. Create Cell resource class extending Resource
2. Define all properties with proper types
3. Add cell_type enum
4. Test: Create test Cell resource in editor, verify properties appear

**Testing Approach:**
- Manually create a Cell resource in Godot editor
- Verify all properties are editable
- Save as `.tres` file and reload to ensure persistence

---

### Task 1.3: Painting Resource Definition

**Goal:** Define custom resource that holds painting data

**Files to Create:**
- `res://resources/painting.gd`

**What This Resource Needs:**
- Properties: painting_name (String), grid_size (Vector2i), image_texture (Texture2D)
- Method to load image from texture and extract color data
- Method to create Cell array from image

**Steps:**
1. Create Painting resource class extending Resource
2. Define all properties
3. Implement method to get Image from image_texture using texture.get_image()
4. Implement method to iterate pixels and create Cell array with colors
5. Auto-calculate grid_size from image dimensions
6. Test: Create test painting resource with a simple texture assigned

**Testing Approach:**
- Create a 10x10 pixel art PNG manually and import to project
- Create Painting resource and assign texture in inspector
- Call the color extraction method
- Verify correct number of cells created (100)
- Verify colors match source image pixels
- Verify grid_size auto-calculated correctly

---

### Task 1.4: Grid Manager Singleton

**Goal:** Create autoloaded singleton to manage grid state

**Files to Create:**
- `res://autoload/grid_manager.gd`

**What This Singleton Needs:**
- Current painting data (Painting resource)
- Array of Cell data (cells: Array[Cell])
- Grid dimensions (grid_size: Vector2i)
- Painted cell count tracking (painted_count: int)
- Methods: load_painting(painting: Painting, painted_cells: Array[Vector2i] = []), get_cell_at(pos: Vector2i), is_cell_painted(pos: Vector2i)
- Method: get_unpainted_cell_positions() -> Array[Vector2i]
- Method: get_painted_cell_positions() -> Array[Vector2i] (for save system)
- Method: get_painted_count() -> int
- Method: get_total_count() -> int
- Method: get_current_painting() -> Painting
- Method: mark_cell_painted(position: Vector2i) (called by slimes, emits signal, tracks completion)
- Method: restore_painted_cells(positions: Array[Vector2i]) (for load system)
- Signal: cell_painted(position: Vector2i, color: Color)
- Signal: painting_complete()
- Signal: painting_loaded(painting: Painting)

**Steps:**
1. Create GridManager class as Node
2. Define properties and signals
3. Implement load_painting(painting: Painting, painted_cells: Array[Vector2i] = []):
   - Store painting reference
   - Create cells array from painting
   - If painted_cells provided, call restore_painted_cells()
   - Emit painting_loaded signal
4. Implement mark_cell_painted(position: Vector2i):
   - Get cell at position and mark as painted
   - Increment painted_count
   - Emit cell_painted signal with position and color
   - Check if painted_count == total cells, emit painting_complete if done
5. Implement helper methods for cell access and querying
6. Add to project autoload settings
7. Test: Load test painting, query cells, mark cells painted, verify signals emit

**Testing Approach:**
- Create manual test scene
- Get GridManager singleton reference
- Load test painting
- Call get_unpainted_cell_positions() and verify returns all positions
- Call mark_cell_painted() for a few positions
- Verify cell_painted signal emits with correct color
- Call get_unpainted_cell_positions() again, verify count decreased
- Verify get_painted_count() returns correct count
- Mark all remaining cells, verify painting_complete signal emits

---

### Task 1.5: Grid Renderer Scene

**Goal:** Visual representation of the grid using efficient Image texture approach

**Files to Create:**
- `res://scenes/grid_renderer.tscn`
- `res://scripts/grid_renderer.gd`

**What This Scene Needs:**
- Node2D as root
- Sprite2D child to display the grid texture
- Script that listens to GridManager signals
- Image resource for grid pixel data
- ImageTexture to display the Image on Sprite2D
- Cell size: 32x32 pixels for MVP (configurable scale factor)
- Method: cell_to_world(cell_pos: Vector2i) -> Vector2 (converts grid position to world coordinates)
- Optional: Custom _draw() overlay for grid borders

**Architecture Decision - Why Image Texture:**
- Individual nodes (ColorRect/Sprite2D per cell) = 10,000 nodes for 100x100 grid (very expensive!)
- Image texture = single Sprite2D, set pixels directly (extremely efficient)
- Since we're revealing pixel art, directly manipulating pixels is natural
- Scales to any grid size without performance issues

**Steps:**
1. Create scene with Node2D root
2. Add Sprite2D as child
3. Attach script to root
4. In _ready():
   - Get GridManager reference
   - Connect to cell_painted signal
   - Connect to painting_loaded signal
   - Create initial grid for current painting (if any)
5. Implement _on_painting_loaded(painting: Painting):
   - Create new Image with dimensions matching painting grid_size
   - Fill Image with white color initially
   - Create ImageTexture from Image
   - Assign texture to Sprite2D
   - Set Sprite2D scale to make cells visible (e.g., scale = Vector2(32, 32) for 32x32 pixel cells)
   - Center the sprite appropriately
6. Implement _on_cell_painted(pos: Vector2i, color: Color):
   - Call image.set_pixelv(pos, color)
   - Call texture.update(image) to refresh the displayed texture
7. Implement cell_to_world(cell_pos: Vector2i) -> Vector2:
   - Calculate world position from cell position using sprite position and scale
   - Used by particle effects and UI elements
8. Optional: Override _draw() to render grid borders (draw lines between cells)
9. Test: Load test painting in GridManager, verify grid renders white cells

**Implementation Notes:**
- Use Image.FORMAT_RGBA8 for the image format
- The Image is pixel-based (1 pixel = 1 cell), Sprite2D scaling makes it visible
- For borders, either use _draw() overlay or scale up the image and add borders during creation
- queue_redraw() only needed if using _draw() for borders

**Testing Approach:**
- Create test scene that instances GridRenderer
- Set GridManager to load 10x10 test painting
- Run scene and verify 100 white cells appear (may be small until scaled)
- Verify Sprite2D scale makes cells visible (e.g., 32x32 pixels each)
- Manually emit cell_painted signal from debugger with test position and color
- Verify specific cell updates to correct color immediately
- Test with larger grid (50x50) to confirm performance is good

---

### Task 1.6: Camera2D Setup

**Goal:** Zoomable and pannable camera

**Files to Modify:**
- `res://scenes/grid_renderer.tscn` (add Camera2D as child)
- `res://scripts/camera_controller.gd` (new file)

**What the Camera Controller Needs:**
- Zoom controls: mouse wheel or pinch gesture
- Pan controls: middle mouse drag or touch drag
- Zoom limits: min (entire grid fits), max (cell detail visible)
- Smooth interpolation for camera movement
- Method: follow_position(pos: Vector2) for slime following
- Method: zoom_to_show_full_grid() for completion sequence
- Method: zoom_to(target_pos: Vector2, target_zoom: float) for animated transitions

**Steps:**
1. Add Camera2D to grid_renderer scene
2. Create camera_controller.gd script and attach
3. Implement _input() for zoom (mouse wheel)
4. Implement _input() for pan (mouse drag with middle button)
5. Add smooth position/zoom interpolation in _process()
6. Test: Run scene, zoom in/out, pan around

**Testing Approach:**
- Run grid scene
- Use mouse wheel to zoom - verify smooth zooming
- Middle-click drag to pan - verify smooth panning
- Zoom out fully - verify entire grid fits in view
- Zoom in fully - verify can see individual cell details

**Commit Point:** Foundation complete - grid system working

---

## Phase 2: Core Gameplay (Slimes, AI, Economy)

### Task 2.1: Economy Manager Singleton

**Goal:** Track and manage coins

**Files to Create:**
- `res://autoload/economy_manager.gd`

**What This Singleton Needs:**
- Property: coins (int)
- Signal: coins_changed(new_amount: int)
- Method: add_coins(amount: int)
- Method: spend_coins(amount: int) -> bool (returns false if can't afford)
- Method: can_afford(amount: int) -> bool
- Method: get_coins() -> int (for save system)
- Method: set_coins(amount: int) (for load system)

**Steps:**
1. Create EconomyManager class as Node
2. Define properties and signals
3. Implement methods with validation
4. In _ready(), connect to GridManager.cell_painted signal to add 1 coin per cell
5. Add to autoload
6. Test: Add/spend coins, verify signals emit, verify can't spend more than owned

**Testing Approach:**
- Get EconomyManager reference
- Connect to coins_changed signal
- Call add_coins(100), verify signal emits with 100
- Call spend_coins(50), verify returns true and signal emits with 50
- Call spend_coins(100), verify returns false and coins unchanged
- Call can_afford(50), verify returns true

---

### Task 2.2: Slime State Machine States (Node-Based)

**Goal:** Define node-based states for slime AI

**Files to Create:**
- `res://scripts/slime/state.gd` (base state class extending Node)
- `res://scripts/slime/state_machine.gd` (state machine controller)
- `res://scripts/slime/state_idle.gd`
- `res://scripts/slime/state_select_target.gd`
- `res://scripts/slime/state_moving.gd`
- `res://scripts/slime/state_painting.gd`
- `res://scripts/slime/state_returning.gd`
- `res://scripts/slime/state_refilling.gd`

**What the Base State Needs (state.gd):**
- Extends Node
- @export var state_name: String (for debugging in inspector)
- Reference to parent slime (set by StateMachine)
- Virtual methods: enter(), exit(), update(delta: float), physics_update(delta: float)
- Signal: transitioned(to_state_name: String) - emitted when ready to change state
- Can override _ready(), _process(), _physics_process() for node-based features

**What the StateMachine Needs (state_machine.gd):**
- Extends Node
- @export var initial_state: NodePath (select in inspector)
- Property: current_state (State node)
- Reference to parent slime (get_parent())
- Method: change_state(new_state_name: String) - validates and transitions
- Dictionary: valid_transitions for safety (optional but recommended)
- In _ready(): set initial state, connect signals from all child State nodes
- Method: _on_state_transitioned(to_state_name: String) - handles transition logic

**Idle State:**
- Add Timer node as child for idle delay
- Enter: Start timer (1 second)
- On timer timeout: emit transitioned("SelectTarget")
- Clean and readable - no manual delta tracking!

**SelectTarget State:**
- Enter: Query GridManager.get_unpainted_cell_positions()
- Enter: Choose target (random or nearest), set slime.target
- Enter: Immediately emit transitioned("Moving") or transitioned("Idle") if no targets
- Single-frame state - very simple logic

**Moving State:**
- Enter: Store target position
- Process: Check distance to target using _process(delta)
- Process: When arrived, emit transitioned("Painting")
- Can add animation or visual feedback easily

**Painting State:**
- Add Timer node as child for paint duration
- Enter: Start paint timer based on slime.paint_speed
- Process: Update visual paint progress (shader, animation, etc.)
- Process: Drain slime tank proportionally
- On timer timeout: Call GridManager.mark_cell_painted(), emit transitioned("Returning" or "SelectTarget")
- Exit: Check if tank empty, transition accordingly

**Returning State:**
- Enter: Set slime.target to base position
- Process: Move toward base, check distance
- Process: When arrived at base, emit transitioned("Refilling")

**Refilling State:**
- Add Timer node as child for refill animation
- Enter: Start refill timer
- Process: Fill tank progressively over time
- Process: Update visual feedback (tank fill animation)
- On timer timeout: emit transitioned("Idle")

**Steps:**
1. Create base State class extending Node
2. Create StateMachine class extending Node
3. Create each state subclass with Timer nodes where needed
4. Implement state logic using node features (timers, signals)
5. States emit `transitioned` signal instead of calling change_state directly
6. StateMachine handles all transition logic centrally

**Testing Approach:**
- Create test scene with Slime node
- Add StateMachine node as child with all State nodes as children
- Set initial_state in inspector to Idle
- Run scene and observe state transitions in debugger
- Inspector shows current state clearly in scene tree (highlighted node)
- Can pause and inspect state properties in real-time
- Verify state flow: Idle → SelectTarget → Moving → Painting → Returning → Refilling → Idle

**Architecture Benefits:**
- ✅ **Readability**: Each state is a visible node in scene tree
- ✅ **Debugging**: Current state highlighted in editor during runtime
- ✅ **Timer Nodes**: No manual delta tracking, cleaner code
- ✅ **Isolation**: States can't directly transition (emit signal instead)
- ✅ **Extensibility**: Easy to add AnimationPlayer, AudioStreamPlayer per state

---

### Task 2.3: Slime Scene and State Machine Integration

**Goal:** Slime entity with node-based AI state machine

**Files to Create:**
- `res://scenes/slime.tscn` (scene file)
- `res://scripts/slime.gd` (main slime script)

**Scene Hierarchy:**
```
Slime (CharacterBody2D) [slime.gd]
├── Sprite2D (placeholder colored circle)
└── StateMachine (Node) [state_machine.gd]
    ├── Idle (Node) [state_idle.gd]
    │   └── Timer (for idle delay)
    ├── SelectTarget (Node) [state_select_target.gd]
    ├── Moving (Node) [state_moving.gd]
    ├── Painting (Node) [state_painting.gd]
    │   └── Timer (for paint duration)
    ├── Returning (Node) [state_returning.gd]
    └── Refilling (Node) [state_refilling.gd]
        └── Timer (for refill duration)
```

**What the Slime Script Needs (slime.gd):**
- Extends CharacterBody2D
- @export properties for balancing:
  - base_move_speed: float = 100.0
  - base_paint_speed: float = 2.0 (seconds per cell)
  - base_tank_capacity: float = 10.0 (cells paintable)
  - base_refill_speed: float = 3.0 (seconds to refill)
- Runtime properties:
  - current_tank: float (current paint remaining)
  - target: Vector2 (current movement target)
  - base_position: Vector2 (refill station location)
  - current_cell: Vector2i (cell being painted)
- Methods:
  - move_toward_target(delta: float) - called by Moving/Returning states
  - get_distance_to(pos: Vector2) -> float - helper for states
  - drain_tank(amount: float) - called by Painting state
  - fill_tank(amount: float) - called by Refilling state
- No state management logic! That's all in StateMachine node

**What the StateMachine Script Needs (state_machine.gd):**
- Extends Node
- @export var initial_state: NodePath (set in inspector to point to Idle node)
- Property: current_state: State (reference to current active state node)
- Property: slime: Slime (get_parent() as Slime)
- In _ready():
  - Get all child State nodes and store in dictionary by name
  - Connect each state's `transitioned` signal to _on_state_transitioned()
  - Set slime reference on all state nodes
  - Call change_state() with initial_state
- Method: change_state(state_name: String):
  - Call current_state.exit() if exists
  - Find state node by name from children
  - Set as current_state
  - Call current_state.enter()
  - Print state change for debugging (optional)
- Method: _on_state_transitioned(to_state_name: String):
  - Called when any state emits transitioned signal
  - Validates transition (optional)
  - Calls change_state(to_state_name)
- In _process(delta):
  - Call current_state.update(delta) if state implements it
- In _physics_process(delta):
  - Call current_state.physics_update(delta) if state implements it

**Steps:**
1. Create slime.tscn with CharacterBody2D root
2. Add Sprite2D child with colored circle placeholder
3. Attach slime.gd script to root, define all properties and methods
4. Add StateMachine node as child with state_machine.gd script
5. Add all 6 state nodes as children of StateMachine
6. Add Timer nodes to states that need them (Idle, Painting, Refilling)
7. Attach state scripts to each state node
8. In inspector, set StateMachine's initial_state to Idle node path
9. Implement slime movement logic using CharacterBody2D.velocity
10. Test: Instance slime and verify full cycle works

**Implementation Notes:**
- **Slime.gd** handles physics and data (tank, movement, position)
- **StateMachine.gd** handles coordination and transitions
- **State scripts** handle decision logic and timing
- States access slime via `slime` property (set by StateMachine)
- Example state access: `slime.drain_tank(0.1)` or `slime.target = cell_pos`

**Testing Approach:**
- Create test scene with:
  - GridRenderer (for painted cells)
  - BaseStation at position (100, 100)
  - One Slime instance with base_position set to (100, 100)
- Load a small test painting (10x10)
- Run scene and observe:
  - ✅ Slime starts in Idle state (visible in scene tree)
  - ✅ Transitions to SelectTarget after 1 second
  - ✅ Picks random unpainted cell and transitions to Moving
  - ✅ Moves toward target cell smoothly
  - ✅ Reaches cell and transitions to Painting
  - ✅ Painting timer runs, tank drains, cell colors appear
  - ✅ When tank low, transitions to Returning
  - ✅ Moves back to base position
  - ✅ Reaches base and transitions to Refilling
  - ✅ Refilling timer runs, tank fills up
  - ✅ When full, transitions back to Idle
  - ✅ Cycle repeats indefinitely
- During runtime, pause and inspect:
  - Current state highlighted in scene tree
  - Slime.current_tank value updating
  - State timer values in inspector

**Debugging Tips:**
- Add `print("Entered: ", state_name)` in each state's enter() for console tracking
- Watch Remote Scene Tree in debugger to see current state
- Set breakpoints in state transition signals
- Use Godot's debugger to step through state changes

---

### Task 2.4: Painting Mechanics Integration

**Goal:** Connect slime painting to grid system

**Files to Modify:**
- `res://scripts/slime/state_painting.gd`
- `res://scripts/slime.gd`

**What Needs to Happen:**
- In Painting state, progressively fill cell color over paint_speed seconds
- Drain tank proportionally during painting
- When painting complete, call GridManager to mark cell as painted
- GridManager emits cell_painted signal
- GridRenderer updates pixel in texture (via image.set_pixelv)
- Economy adds coin

**Steps:**
1. In state_painting.gd, implement timer/counter for paint duration
2. Drain slime tank over paint duration
3. When complete, call GridManager.mark_cell_painted(position)
4. GridManager should emit cell_painted signal with color
5. EconomyManager should listen to cell_painted and add 1 coin
6. Test: Watch slime paint cell, verify cell changes color and coins increase

**Testing Approach:**
- Load test painting with known colors
- Spawn slime and let it paint a cell
- Verify:
  - Cell color changes from white to correct color
  - Coins increase by 1
  - Slime tank decreases
  - Slime returns to base when tank empty

---

### Task 2.5: Base Station

**Goal:** Visual marker and refill point for slimes

**Files to Create:**
- `res://scenes/base_station.tscn`
- `res://scripts/base_station.gd`

**What the Base Station Needs:**
- Node2D or Area2D as root
- Visual sprite (simple colored square or circle for MVP)
- Position in scene (bottom-left corner for MVP)
- Property: refill_speed (how fast slimes refill)
- Method: refill_slime(slime: Slime, delta: float)

**Steps:**
1. Create base_station scene
2. Add sprite visual (placeholder colored square)
3. Position at (100, 100) or similar for MVP
4. Create script with refill logic
5. Modify Refilling state to call base_station.refill_slime()
6. Test: Slime reaches base and refills tank

**Testing Approach:**
- Add base station to test scene
- Watch slime cycle: paint → empty tank → return to base → refill
- Verify slime tank increases during refill
- Verify slime returns to painting after refill complete

---

### Task 2.6: Slime Purchase System

**Goal:** Allow player to buy slimes with coins

**Files to Create:**
- `res://autoload/slime_manager.gd`

**What This Singleton Needs:**
- Property: slimes (Array[Slime])
- Property: slime_cost (int), increases with each purchase
- Signal: slime_purchased(slime: Slime)
- Method: purchase_slime() -> bool (spawns slime if can afford)
- Method: calculate_slime_cost() -> int (exponential scaling)
- Reference to slime scene for instancing

**Steps:**
1. Create SlimeManager singleton
2. Implement purchase logic: check economy, spawn slime, add to array
3. Implement cost calculation (exponential: base_cost * pow(1.5, slime_count))
4. Add to autoload
5. Test: Purchase slimes, verify they spawn and cost increases

**Testing Approach:**
- Start with 1000 coins
- Purchase first slime - verify cost is low (e.g., 10 coins)
- Purchase second slime - verify cost increased (e.g., 15 coins)
- Purchase third slime - verify cost increased again (e.g., 22 coins)
- Verify all slimes are working independently
- Try purchasing with insufficient coins - verify fails

---

### Task 2.7: Slime Movement Visualization (Debug MVP)

**Goal:** Add debug visualization for slime movement paths and improve positioning

**Files to Modify:**
- `res://scripts/slime/state_select_target.gd`
- `res://scripts/slime/state_move.gd`
- `res://scripts/slime/state_painting.gd`
- `res://scenes/slime.tscn`
- `res://scripts/slime.gd`

**What This Task Adds:**

1. **Offset Positioning:**
   - Slime stops BEFORE the target cell (not on top of it)
   - Cell remains visible during painting
   - Fixed offset approach: position slime bottom-left of cell
   - Offset: `Vector2(-8, 8)` or similar (configurable)

2. **Path Visualization (Debug):**
   - Line2D node showing path from slime to target
   - Simple dotted line effect (using Line2D texture or width property)
   - Toggle on/off with debug key (F3 or D key)
   - Only visible when debug mode enabled

**Scene Changes:**
- Add Line2D node as child of Slime
- Configure Line2D: width = 2, default_color = Color.YELLOW with transparency
- For dotted effect: Set Line2D texture or use custom shader (optional for MVP)

**Script Changes:**

**In slime.gd:**
- Add property: `@export var cell_offset: Vector2 = Vector2(-8, 8)`
- Add property: `debug_draw_path: bool = false`
- Add method: `set_debug_draw(enabled: bool)` to toggle Line2D visibility
- In `_input()`: Listen for F3/D key to toggle `debug_draw_path`

**In state_select_target.gd:**
- When setting target cell, apply offset:
  ```gdscript
  var cell_world_pos = GridManager.cell_to_world(target_cell)
  slime.next_target = cell_world_pos + slime.cell_offset
  ```
- This ensures slime positions beside/below cell instead of directly on it

**In state_move.gd:**
- In enter(): Set Line2D points if debug enabled
  ```gdscript
  if slime.debug_draw_path:
      slime.path_line.points = [Vector2.ZERO, slime.next_target - slime.global_position]
  ```
- In update(): Update line start point as slime moves (optional - creates "trailing" effect)
- Alternative: Keep static line from selection point to target

**In state_painting.gd:**
- In enter(): Hide/clear Line2D
  ```gdscript
  slime.path_line.visible = false
  ```

**Steps:**
1. Add Line2D node to slime.tscn scene as child of root
2. Configure Line2D properties in inspector (width, color, default_color alpha ~0.7)
3. Add cell_offset and debug properties to slime.gd
4. Implement debug toggle input handling (F3 key)
5. Modify SelectTarget state to apply offset when calculating target position
6. Modify Move state to draw/update line when debug enabled
7. Modify Painting state to hide line
8. Test: Toggle debug mode, verify line appears/disappears, verify slime positions correctly

**Implementation Notes:**
- **Line2D coordinates are relative to parent** (the Slime node), so use local positions
- Point[0] = Vector2.ZERO (slime's position)
- Point[1] = next_target position relative to slime (target - slime.global_position)
- For dotted effect: Simple approach is to set Line2D width to 2-3 and use antialiased property
- Advanced dotted: Use Line2D texture property with repeating dot pattern

**Testing Approach:**
- Run game with slimes active
- Press F3 to enable debug visualization
- Verify:
  - Yellow line appears from slime to target cell
  - Line updates/disappears as slime moves
  - Line hidden when slime reaches target and starts painting
  - Slime positions to the side/bottom of cell (not obscuring it)
  - Cell being painted is clearly visible
  - Can see cell color reveal without slime blocking view
- Press F3 again to disable
- Verify lines disappear but slime positioning remains offset
- Test with multiple slimes - each has its own line

**Why Offset Positioning Matters:**
- Player can see the cell being painted (UX improvement)
- Creates visual separation between worker and work
- Makes slime feel like it's "working on" the cell, not "standing on" it
- Critical for seeing color reveals and particle effects

**Why Debug-Only for MVP:**
- Avoid visual clutter with multiple slimes
- Test usefulness before committing to polished feature
- Easy to toggle during development
- Can be upgraded to full feature in post-MVP if players like it

**Future Enhancement Ideas (Post-MVP):**
- Animated "marching ants" dotted line (shader with time offset)
- Only show line for selected/hovered slime
- Make it a purchasable upgrade: "Slime Planner - See what slimes are thinking!"
- Color-code lines by slime or target cell color
- Show predicted path for multiple targets ahead

**Commit Point:** Core gameplay working - slimes paint and earn coins, with debug visualization

---

## Phase 3: Progression (Gallery, Paintings, Save/Load)

### Task 3.1: Upgrade System

**Goal:** Define and manage upgrades

**Files to Create:**
- `res://autoload/upgrade_manager.gd`
- `res://resources/upgrade.gd`

**What Upgrade Resource Needs:**
- Properties: upgrade_name (String), description (String), upgrade_type (enum)
- Properties: base_cost (int), current_level (int), max_level (int)
- Method: get_cost_for_next_level() -> int (exponential)
- Method: get_effect_at_level(level: int) -> float

**Upgrade Types (enum):**
- MOVE_SPEED, PAINT_SPEED, TANK_CAPACITY, REFILL_SPEED, PAINT_EFFICIENCY

**What UpgradeManager Needs:**
- Dictionary of upgrades by type
- Method: purchase_upgrade(type: enum) -> bool
- Method: get_upgrade_level(type: enum) -> int
- Method: get_upgrade_multiplier(type: enum) -> float
- Signal: upgrade_purchased(type: enum, new_level: int)

**Steps:**
1. Create Upgrade resource class
2. Create UpgradeManager singleton
3. Initialize default upgrades in _ready()
4. Implement purchase logic (check economy, increment level)
5. Implement multiplier calculation (e.g., 1.0 + level * 0.1)
6. Add to autoload
7. Test: Purchase upgrades, verify levels increase and costs scale

**Testing Approach:**
- Get UpgradeManager reference
- Purchase MOVE_SPEED upgrade level 1
- Verify cost deducted and level increased
- Purchase again, verify cost higher
- Get multiplier for MOVE_SPEED, verify it's 1.1 (10% increase)
- Create new slime and verify it uses upgraded move_speed

---

### Task 3.2: Apply Upgrades to Slimes

**Goal:** Slimes use upgrade values

**Files to Modify:**
- `res://scripts/slime.gd`

**What Needs to Change:**
- In _ready(), query UpgradeManager for current upgrade levels
- Apply multipliers to: move_speed, paint_speed, tank_capacity, refill_speed
- Listen to upgrade_purchased signal to update existing slimes
- Recalculate stats when upgrade purchased

**Steps:**
1. Add method calculate_stats() to slime.gd
2. Query UpgradeManager for each upgrade type
3. Apply multipliers: base_move_speed * upgrade_multiplier
4. Connect to upgrade_purchased signal
5. Call calculate_stats() on signal receive
6. Test: Purchase upgrade, verify existing slimes get faster/better

**Testing Approach:**
- Spawn slime and note its move speed
- Purchase MOVE_SPEED upgrade
- Verify slime moves faster immediately
- Spawn new slime and verify it also has increased speed
- Purchase PAINT_SPEED upgrade
- Verify slimes paint faster

---

### Task 3.3: Gallery Manager

**Goal:** Manage painting selection and unlocks

**Files to Create:**
- `res://autoload/gallery_manager.gd`

**What This Singleton Needs:**
- Array of all painting resources (paintings: Array[Painting])
- Array of completed painting IDs (completed: Array[String])
- Method: load_paintings() to populate painting array from resources folder
- Method: is_painting_available(painting: Painting) -> bool (checks sequential unlocking)
- Method: complete_painting(painting: Painting) (marks complete)
- Method: get_available_paintings() -> Array[Painting]
- Signal: painting_unlocked(painting: Painting)

**Steps:**
1. Create GalleryManager singleton
2. Implement painting loading (scan resources folder or hardcode for MVP)
3. Implement sequential unlock logic (painting N requires painting N-1 to be complete)
4. Implement completion logic (add to completed)
5. Add to autoload
6. Test: Load paintings, check availability, complete painting, verify next unlocks

**Testing Approach:**
- Create 3 test painting resources (Painting 1, 2, 3)
- Load paintings in GalleryManager
- Verify only Painting 1 is available initially
- Complete Painting 1
- Verify Painting 2 is now available
- Complete Painting 2
- Verify Painting 3 is now available

---

### Task 3.4: Painting Loading and Switching

**Goal:** Load selected painting onto grid

**Files to Modify:**
- `res://autoload/grid_manager.gd`
- `res://autoload/gallery_manager.gd`

**What Needs to Happen:**
- Player selects painting from gallery
- GridManager loads painting data
- GridRenderer clears old texture and creates new one for the new painting
- Slimes reset state and start working on new painting
- When all cells painted, emit painting_complete signal

**Steps:**
1. Add method load_painting(painting: Painting, painted_cells: Array[Vector2i] = []) to GridManager
2. Clear existing cells array
3. Load new painting and create cells
4. If painted_cells provided, call restore_painted_cells(painted_cells) to restore progress
5. Emit painting_loaded signal
6. GridRenderer listens to painting_loaded and recreates Image/ImageTexture with new dimensions
7. SlimeManager listens to painting_loaded and resets slimes to Idle
8. Track painted cell count, emit painting_complete when all cells done
9. Test: Switch between paintings, verify grid updates and slimes continue working

**Testing Approach:**
- Start with Painting A loaded
- Let slime paint a few cells
- Call load_painting(Painting B)
- Verify:
  - Grid clears and shows new painting grid
  - Slimes reset and start working on new painting
  - Coin earning continues
- Let painting complete fully
- Verify painting_complete signal emits

---

### Task 3.5: Save/Load System

**Goal:** Persist player progress

**Files to Create:**
- `res://autoload/save_manager.gd`
- `res://resources/save_data.gd`

**What SaveData Resource Needs:**
- Properties: coins (int), slime_count (int), upgrade_levels (Dictionary)
- Properties: completed_paintings (Array[String])
- Properties: current_painting_name (String)
- Properties: painting_progress (Dictionary) - maps painting_name (String) to painted_cells (Array[Vector2i])
- Property: slime_last_positions (Array[Vector2i]) - last painted cell per slime for continuity

**Notes on painting_progress:**
- Key: painting_name (String)
- Value: Array of painted cell positions (Array[Vector2i]) or PackedVector2Array for efficiency
- Allows restoration of exact visual progress for any painting
- On load: GridManager marks cells at these positions as painted

**What SaveManager Needs:**
- Method: save_game() -> void
- Method: load_game() -> SaveData
- Method: has_save_file() -> bool
- Save file path: user://save_game.tres
- Gather data from all manager singletons

**Steps:**
1. Create SaveData resource class
2. Create SaveManager singleton
3. Implement save_game():
   - Create SaveData instance
   - Populate from EconomyManager, UpgradeManager, GalleryManager, etc.
   - Get painted cell positions from GridManager.get_painted_cell_positions()
   - Store in painting_progress Dictionary with current_painting_name as key
   - Use ResourceSaver.save()
4. Implement load_game():
   - Use ResourceLoader.load()
   - Return SaveData or null if no file
5. Implement has_save_file()
6. Add to autoload
7. Test: Save game, close project, reopen, load game, verify state restored

**Testing Approach:**
- Play game: earn coins, buy slimes, purchase upgrades, paint cells
- Note specific painted cell positions and colors
- Call save_game()
- Close and reopen project
- Call load_game()
- Verify:
  - Coins match saved amount
  - Slime count matches
  - Upgrade levels match
  - Current painting loaded with previously painted cells visible
  - Painted cells are at correct positions with correct colors
  - Unpainted cells remain white

**Commit Point:** Progression systems complete - gallery and save/load working

---

## Phase 4: Polish (UI, Tutorial, Audio, Particles)

### Task 4.1: HUD Scene

**Goal:** Display game information

**Files to Create:**
- `res://scenes/ui/hud.tscn`
- `res://scripts/ui/hud.gd`

**What the HUD Needs:**
- Label for coin count (top-left)
- Label for painting progress (top-center) "245/400 cells"
- Label for slime count (top-right) "5 slimes working"
- Label for painting name (top-center above progress)
- CanvasLayer as root for UI rendering

**Steps:**
1. Create HUD scene with CanvasLayer root
2. Add labels with proper anchors and positions
3. Create script that listens to relevant signals:
   - EconomyManager.coins_changed
   - GridManager.cell_painted (for progress)
   - SlimeManager.slime_purchased
4. Update labels when signals received
5. Add to main game scene
6. Test: Play game and verify HUD updates in real-time

**Testing Approach:**
- Run game with HUD visible
- Buy slime - verify slime count updates
- Paint cells - verify progress updates
- Earn coins - verify coin count updates
- Load different painting - verify painting name updates

---

### Task 4.2: Buy Slime Button

**Goal:** Persistent button to purchase slimes

**Files to Modify:**
- `res://scenes/ui/hud.tscn`

**What the Button Needs:**
- Positioned bottom-right corner
- Shows current cost: "Buy Slime (50 coins)"
- Disabled state when can't afford (grayed out)
- Calls SlimeManager.purchase_slime() on press
- Updates cost label when slimes purchased

**Steps:**
1. Add Button to HUD scene
2. Position bottom-right with proper anchors
3. Connect to SlimeManager.slime_purchased signal
4. Update button text with current cost
5. Listen to EconomyManager.coins_changed to enable/disable
6. Connect pressed signal to purchase logic
7. Test: Click button, verify slime purchased and cost updates

**Testing Approach:**
- Start game with 100 coins
- Click "Buy Slime" button
- Verify slime spawns
- Verify button cost increases
- Spend coins until can't afford next slime
- Verify button becomes disabled
- Earn more coins, verify button re-enables

---

### Task 4.3: Shop Menu Scene

**Goal:** Overlay panel for upgrades and items

**Files to Create:**
- `res://scenes/ui/shop_menu.tscn`
- `res://scripts/ui/shop_menu.gd`
- `res://scenes/ui/upgrade_button.tscn` (reusable upgrade item)

**What the Shop Menu Needs:**
- Panel container with close button
- ScrollContainer with VBoxContainer for upgrades list
- Initially hidden, shown when menu button pressed
- Dim background overlay when open
- List of upgrade buttons (one per upgrade type)
- Each shows: name, description, level, cost, effect
- Purchase button disabled if can't afford

**What Each Upgrade Button Needs:**
- Label for name
- Label for description
- Label for level: "Level 3"
- Label for cost: "Cost: 150 coins"
- Label for effect: "+30% speed"
- Button to purchase
- Connects to UpgradeManager.purchase_upgrade()

**Steps:**
1. Create shop_menu scene with Panel root and ColorRect overlay
2. Add ScrollContainer with VBoxContainer for upgrades
3. Create upgrade_button reusable scene
4. Instance upgrade_button for each upgrade type
5. Connect each button to purchase logic
6. Implement show/hide logic
7. Test: Open shop, purchase upgrades, close shop

**Testing Approach:**
- Add menu button to HUD
- Click to open shop
- Verify shop appears with all upgrades listed
- Verify each shows correct level and cost
- Purchase an upgrade
- Verify level increases and cost updates
- Verify button disabled when can't afford
- Close shop, verify it hides

---

### Task 4.4: Gallery Scene

**Goal:** Painting selection interface

**Files to Create:**
- `res://scenes/ui/gallery.tscn`
- `res://scripts/ui/gallery.gd`
- `res://scenes/ui/painting_thumbnail.tscn`

**What the Gallery Needs:**
- Full-screen panel overlay
- GridContainer showing painting thumbnails
- Each thumbnail shows: mini preview, name, status (completed/available/locked)
- Click thumbnail to see details
- Details panel: full preview, grid size, "Start Painting" button

**What Each Thumbnail Needs:**
- TextureRect for preview image
- Label for painting name
- Visual indicator for status (color-coded border or icon)
- Locked paintings show lock icon and tooltip: "Complete [Previous Painting] to unlock"

**Steps:**
1. Create gallery scene with full-screen panel
2. Create painting_thumbnail reusable scene
3. In gallery script, populate GridContainer with thumbnails from GalleryManager
4. Implement click to show details
5. Implement "Start Painting" button to load painting
6. Handle locked paintings (tooltip showing previous painting requirement)
7. Test: Open gallery, click paintings, start painting

**Testing Approach:**
- Open gallery
- Verify only first painting is available initially
- Verify locked paintings grayed out with lock icon
- Click locked painting, verify shows "Complete [Previous Painting] to unlock"
- Click available painting, verify shows details
- Click "Start Painting", verify painting loads and gallery closes
- Complete painting and reopen gallery, verify marked as complete and next painting unlocked

---

### Task 4.5: Tutorial System

**Goal:** Guide new players through mechanics

**Files to Create:**
- `res://autoload/tutorial_manager.gd`
- `res://scenes/ui/tutorial_overlay.tscn`

**What the Tutorial Needs:**
- Step-by-step progression (7 steps from design)
- Highlight specific UI elements (arrows, outlines)
- Text boxes with instructions
- Block player input to non-highlighted elements
- Track completion (saved in save file)
- Skip option for testing

**Tutorial Steps:**
1. Welcome message
2. Buy first slime (free)
3. Watch slime paint cells
4. Tank refill explanation
5. Buy second slime
6. Open shop and buy upgrade
7. Painting completion and gallery

**Steps:**
1. Create TutorialManager singleton
2. Create tutorial_overlay scene with dimming and highlight system
3. Define tutorial step data (text, highlighted element, completion trigger)
4. Implement step progression logic
5. Implement highlight rendering (ColorRect outline around target)
6. Block input to non-highlighted elements
7. Save tutorial completion flag
8. Test: New game triggers tutorial, can complete all steps

**Testing Approach:**
- Delete save file to trigger new game
- Follow tutorial steps:
  - Verify each step highlights correct UI element
  - Verify instructions are clear
  - Verify can only interact with highlighted elements
  - Verify progression to next step on completion
- Complete tutorial, verify saves completion flag
- Restart game, verify tutorial doesn't repeat

---

### Task 4.6: Audio System

**Goal:** Add sound effects and music

**Files to Create:**
- `res://autoload/audio_manager.gd`
- `res://scenes/audio_player_pool.tscn` (for SFX)

**What AudioManager Needs:**
- AudioStreamPlayer for background music (looping)
- Object pool of AudioStreamPlayers for SFX (multiple can play simultaneously)
- Method: play_sfx(sound_name: String, pitch_variation: float = 0.0)
- Method: play_music(music_name: String)
- Volume controls (music_volume, sfx_volume)
- Methods to set volume (used by settings)

**Required Sounds (Placeholders OK):**
- paint_complete.wav (cell painted)
- slime_move.wav (subtle squish)
- refill.wav (tank refilling)
- button_click.wav
- purchase.wav
- painting_complete.wav (fanfare)
- background_music.ogg (gentle loop)

**Steps:**
1. Find or create placeholder audio files
2. Import audio files to assets/audio/
3. Create AudioManager singleton
4. Implement SFX pooling (5-10 AudioStreamPlayers)
5. Implement play_sfx with pitch randomization
6. Implement music playback
7. Add audio triggers:
   - Listen to cell_painted signal → play paint_complete
   - Button presses → play button_click
   - Purchases → play purchase
   - Painting complete → play fanfare
8. Test: Play game and verify all sounds trigger correctly

**Testing Approach:**
- Run game with audio enabled
- Paint cells, verify paint sound plays (with pitch variation)
- Buy slime/upgrade, verify purchase sound
- Complete painting, verify fanfare
- Adjust volume in settings (next task), verify volume changes
- Mute audio, verify all sound stops

---

### Task 4.7: Settings Menu

**Goal:** Player preferences

**Files to Create:**
- `res://scenes/ui/settings_menu.tscn`
- `res://scripts/ui/settings_menu.gd`

**What Settings Menu Needs:**
- Panel overlay (similar to shop)
- Volume sliders: Music, SFX (0-100)
- Particle density dropdown: Low, Medium, High
- Tutorial reset button
- Close button
- Save settings to save file

**Steps:**
1. Create settings_menu scene
2. Add volume sliders (HSlider)
3. Connect sliders to AudioManager.set_music_volume() / set_sfx_volume()
4. Add particle density option (affects particle counts in painting effects)
5. Add tutorial reset button (clears tutorial_complete flag)
6. Save settings in SaveData
7. Load settings on game start
8. Test: Change settings, verify applied, reload game, verify persisted

**Testing Approach:**
- Open settings
- Adjust music volume, verify music volume changes
- Adjust SFX volume, paint cell, verify SFX volume changes
- Set particle density to Low, verify fewer particles spawn
- Close and reopen game, verify settings persisted

---

### Task 4.8: Particle Effects

**Goal:** Juicy visual feedback

**Files to Create:**
- `res://scenes/effects/paint_splash.tscn` (particle effect)
- `res://scenes/effects/coin_popup.tscn` (animated label)

**What Paint Splash Needs:**
- GPUParticles2D or CPUParticles2D
- Emit particles when cell painted
- Color matches cell color
- Short burst (0.3-0.5 seconds)
- Spawned at cell position

**What Coin Popup Needs:**
- Label with "+1" text
- Animated upward float with fade out
- Golden/yellow color
- Spawned at cell position
- Auto-deletes after animation

**Steps:**
1. Create paint_splash particle scene
2. Configure particle properties: lifetime, velocity, color, gravity
3. Create coin_popup scene with Label and AnimationPlayer
4. Animate: position (float up), modulate alpha (fade out), scale (slightly grow)
5. Modify GridRenderer to spawn effects when cell painted:
   - Listen to cell_painted signal
   - Calculate world position from cell position (cell_pos * cell_scale + offset)
   - Instance and spawn particle/popup at that position
6. Test: Paint cells, verify particles and coin popups appear at correct positions

**Testing Approach:**
- Paint cells and observe:
  - Particle burst appears at cell position
  - Particles match cell color
  - Particles disappear after short time
  - "+1" coin popup floats up and fades
  - Multiple cells can trigger effects simultaneously without lag

---

### Task 4.9: Painting Completion Sequence

**Goal:** Satisfying completion celebration

**Files to Create:**
- `res://scenes/ui/completion_panel.tscn`
- `res://scripts/ui/completion_panel.gd`

**What Completion Panel Needs:**
- Full-screen overlay
- "Painting Complete!" banner with animation
- Stats display: time, cells, coins earned
- Rewards display: "Ice Hammer Unlocked!" (if applicable)
- Buttons: "Add to Gallery", "Choose Next Painting"
- Celebration particles across screen
- Fanfare audio

**Steps:**
1. Create completion_panel scene
2. Add banner, stats labels, reward display, buttons
3. Listen to GridManager.painting_complete signal
4. On complete:
   - Pause slimes
   - Camera zoom out to show full painting
   - Play fanfare
   - Spawn celebration particles
   - Show completion panel with stats
5. "Add to Gallery" button calls GalleryManager.complete_painting()
6. "Choose Next Painting" button opens gallery
7. Test: Complete painting, verify full sequence plays

**Testing Approach:**
- Create small test painting (5x5) for quick completion
- Let slimes complete it
- Verify sequence:
  - Slimes pause
  - Camera zooms out smoothly
  - Fanfare plays
  - Particles spawn
  - Panel appears with correct stats
  - Click "Add to Gallery", verify painting marked complete
  - Click "Choose Next", verify gallery opens

---

### Task 4.10: Main Scene Integration

**Goal:** Assemble all pieces into playable game

**Files to Create:**
- `res://scenes/main.tscn`
- `res://scripts/main.gd`

**What Main Scene Needs:**
- GridRenderer instance
- BaseStation instance
- HUD instance
- All UI overlays (Shop, Gallery, Settings, Tutorial, Completion)
- Camera controller
- Game initialization logic

**What Main Script Needs:**
- On _ready():
  - Check for save file
  - If exists: load game, restore state
  - If not: start tutorial
  - Load first painting (tutorial or saved)
- Handle menu button presses (open shop, gallery, settings)
- Handle ESC key (pause menu or close current overlay)

**Steps:**
1. Create main scene
2. Instance all required scenes
3. Create main.gd script
4. Implement initialization logic
5. Wire up menu buttons
6. Implement pause/resume logic
7. Set as main scene in project settings
8. Test: Full game flow from start to completion

**Testing Approach:**
- Run game with no save file:
  - Verify tutorial starts
  - Complete tutorial
  - Verify can play normally
- Close and reopen:
  - Verify save loads correctly
  - Verify state restored
- Play full loop:
  - Buy slimes
  - Purchase upgrades
  - Complete painting
  - Select new painting
  - Verify all systems work together

**Commit Point:** MVP complete - fully playable game

---

## Phase 5: Content Creation

### Task 5.1: Create Painting Resources

**Goal:** Add real content to the game

**Files to Create:**
- `res://assets/images/paintings/tutorial_paint_drop.png` (10x10)
- `res://assets/images/paintings/sunset.png` (15x15)
- `res://assets/images/paintings/tree.png` (20x20)
- `res://assets/images/paintings/cat.png` (25x25)
- `res://assets/images/paintings/castle.png` (35x35)
- Corresponding `.tres` Painting resources for each

**Steps:**
1. Find or create 5 pixel art images (free sources: OpenGameArt, itch.io)
2. Import into project as Texture2D resources
3. Create Painting resource for each:
   - Set painting_name
   - Assign image_texture in inspector (drag and drop PNG)
   - grid_size will auto-calculate from texture dimensions
4. Register paintings with GalleryManager (in sequential order)
5. Test: Load each painting, verify renders correctly

**Testing Approach:**
- Open gallery
- Verify all 5 paintings appear
- Start each painting and verify:
  - Correct grid size
  - Correct colors when painted
  - Image is recognizable when complete

---

## Post-MVP Enhancements (Not Required for MVP)

### Future Task: Color Specialization
- Allow slimes to specialize in specific colors
- Add color analysis to paintings
- Modify shop to show color-specific slime purchases
- Update upgrade system for per-color upgrades

### Future Task: Advanced Camera
- Slime double-click to follow
- Smooth camera transitions between slimes
- Camera shake on painting completion

### Future Task: Slime Visuals
- Replace placeholder sprites with proper slime art
- Add idle, moving, painting, refilling animations
- Size variation based on tank level
- Celebration animation when painting complete

### Future Task: Performance Optimization
- Object pooling for particles and coin popups
- Reduce signal emissions (batch cell updates)
- Optimize pathfinding for many slimes
- LOD system for large grids (reduce detail when zoomed out)

---

## Testing Strategy

### Manual Testing Checklist

After each phase, verify:

**Phase 1:**
- [ ] Grid renders correctly for various sizes
- [ ] Cells have white fill and black borders
- [ ] Camera can zoom and pan smoothly

**Phase 2:**
- [ ] Slimes spawn at base
- [ ] Slimes navigate to cells
- [ ] Painting animation plays
- [ ] Cells change color when painted
- [ ] Coins increase
- [ ] Slimes return to base when tank empty
- [ ] Slimes refill at base
- [ ] Multiple slimes work simultaneously without conflicts

**Phase 3:**
- [ ] Upgrades increase slime stats
- [ ] Upgrade costs scale correctly
- [ ] Paintings load from gallery
- [ ] Painting completion detected
- [ ] Save/load preserves all state
- [ ] Slimes resume from last painted position on load

**Phase 4:**
- [ ] HUD displays accurate information
- [ ] All UI elements respond to input
- [ ] Tutorial guides new players correctly
- [ ] Audio plays at appropriate times
- [ ] Particles appear without performance issues
- [ ] Completion sequence is satisfying

### Edge Cases to Test

1. **Multiple slimes targeting same cell:** Last to arrive should find cell already painted and select new target
2. **Save/load during painting:** Should restore exact painting progress
3. **Purchasing with exact coin amount:** Should succeed
4. **Completing painting with no remaining paintings:** Should handle gracefully
5. **Very large grids (100x100):** Performance should remain acceptable
6. **All slimes refilling simultaneously:** Should not cause bottleneck
7. **Slimes resuming from saved positions:** Should continue painting organically from last painted cell

---

## Asset Checklist

### Required Assets (Placeholders OK for MVP)

**Graphics:**
- [ ] Slime sprite (colored circle OK)
- [ ] Base station sprite (colored square OK)
- [ ] Cell border texture (simple black line OK)
- [ ] Particle texture (small white square OK)
- [ ] UI panel backgrounds (solid color OK)
- [ ] Button textures (Godot default OK)
- [ ] 5 pixel art paintings (sourced or created)

**Audio:**
- [ ] Paint complete SFX
- [ ] Slime move SFX
- [ ] Refill SFX
- [ ] Button click SFX
- [ ] Purchase SFX
- [ ] Completion fanfare
- [ ] Background music loop

**Fonts:**
- [ ] UI font (Godot default OK, custom font nice-to-have)

---

## Godot-Specific Notes

### Painting Resource Design Choice

**Why Texture2D instead of String path:**
- **Inspector Preview:** Texture shows visual preview in Godot inspector, making it easy to see which image is assigned
- **Resource Management:** Godot handles loading/unloading automatically, preventing resource leaks
- **Type Safety:** Export variable enforces Texture2D type, preventing invalid file paths
- **Drag & Drop:** Easy assignment in editor by dragging PNG files directly to property
- **No Path Issues:** Eliminates runtime errors from incorrect file paths or missing files
- **Grid Size Auto-Calc:** Can extract dimensions directly from texture without manual entry

### Recommended Node Structure

```
Main (Node2D)
├── GridRenderer (Node2D)
│   ├── Sprite2D (displays grid as single texture)
│   └── Camera2D
├── BaseStation (Node2D)
├── Slimes (Node2D container)
│   └── Slime (CharacterBody2D)
│       ├── Sprite2D
│       └── StateMachine (Node)
│           ├── Idle (State)
│           │   └── Timer
│           ├── SelectTarget (State)
│           ├── Moving (State)
│           ├── Painting (State)
│           │   └── Timer
│           ├── Returning (State)
│           └── Refilling (State)
│               └── Timer
└── UI (CanvasLayer)
    ├── HUD
    ├── ShopMenu
    ├── Gallery
    ├── Settings
    ├── TutorialOverlay
    └── CompletionPanel
```

### Autoload Order

Should load in this order (affects dependencies):
1. SaveManager
2. EconomyManager
3. UpgradeManager
4. GridManager
5. GalleryManager
6. SlimeManager
7. TutorialManager
8. AudioManager

### Node-Based State Machine Best Practices

**Architecture:**
- StateMachine node manages all transitions and state lifecycle
- State nodes are children of StateMachine (visible in scene tree)
- States emit `transitioned(state_name)` signal, never call transitions directly
- Slime owns data (tank, position, speed), StateMachine owns behavior flow

**Benefits:**
- **Visual Debugging**: Current state highlighted in remote scene tree during gameplay
- **Inspector Access**: Pause game and inspect state properties, timer values in real-time
- **Readability**: Scene hierarchy shows all possible states at a glance
- **Timer Nodes**: Use Timer.timeout signal instead of manual delta tracking
- **Modularity**: Each state can have AnimationPlayer, AudioStreamPlayer, etc.

**Pattern:**
```gdscript
# Base State (state.gd)
extends Node
signal transitioned(to_state_name: String)
var slime: Slime  # Set by StateMachine

func enter() -> void:
    pass  # Override in subclasses

func exit() -> void:
    pass  # Override in subclasses

func update(delta: float) -> void:
    pass  # Called from StateMachine._process()

# Example State (state_idle.gd)
extends State

@onready var timer: Timer = $Timer

func enter() -> void:
    timer.start(1.0)

func _on_timer_timeout() -> void:
    transitioned.emit("SelectTarget")
```

**Debugging:**
- Use `print("[%s] Entered" % state_name)` in each state's enter() method
- Watch Remote → Remote Scene Tree in Godot debugger
- Set breakpoints in StateMachine._on_state_transitioned()
- Export state_name on each State for inspector visibility

### Signals Best Practices

- Use signals for cross-system communication (not direct references)
- Emit signals AFTER state changes (not before)
- Keep signal parameter count low (1-3 parameters max)
- Document what each signal means in comments
- States emit `transitioned` signal instead of directly calling state changes

### Performance Considerations

- Use `call_deferred()` for adding/removing nodes during gameplay
- Batch GridManager signals (emit cell_batch_painted instead of per-cell)
- Use object pools for particles and popups
- Disable process/physics_process on nodes that don't need it (use signals instead)

---

## Success Criteria for MVP

The MVP is complete when:

1. **Tutorial works:** New player can complete tutorial without confusion
2. **Core loop works:** Buy slime → watch paint → earn coins → buy upgrades → repeat
3. **Progression works:** Complete painting → unlock in gallery → select new painting
4. **Persistence works:** Save/load restores all progress correctly, slimes resume from last painted positions
5. **Polish works:** Audio, particles, and UI feel satisfying
6. **Performance acceptable:** 60 FPS with 10 slimes and 50x50 grid
7. **No critical bugs:** No crashes, softlocks, or progress-blocking issues

---

## Next Steps After Plan

1. Review this plan thoroughly
2. Set up git repository for version control
3. Create initial Godot project
4. Begin Phase 1 implementation
5. Commit frequently (after each task completion)
6. Playtest regularly (daily if possible)
7. Gather feedback from others
8. Iterate on balance and feel
9. Plan post-MVP features based on feedback

---

**Plan Complete!**

This implementation plan provides a clear roadmap from empty project to playable MVP. Each task is designed to be completable in one sitting, with clear goals, testing steps, and commit points.

Follow the phases in order for best results. Don't skip testing steps - they catch issues early.

Good luck building your pixel paint idle game!
