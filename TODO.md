# Pixel Paint Idle Game - TODO

> **Last Updated:** 2025-11-06
> **Project Status:** ~25% Complete (Phase 1 Done, Phase 2 ~60% Done)
> **Full Plan:** [docs/plans/2025-11-03-pixel-paint-idle-implementation-plan.md](docs/plans/2025-11-03-pixel-paint-idle-implementation-plan.md)

---

## Current Status

### ✅ Completed (Phase 1 - Foundation)

- [x] Task 1.1: Project Setup
- [x] Task 1.2: Cell Resource Definition (`resources/cell.gd`)
- [x] Task 1.3: Painting Resource Definition (`resources/painting.gd`)
- [x] Task 1.4: Grid Manager Singleton (`autoload/grid_manager.gd`)
- [x] Task 1.5: Grid Renderer Scene (`scenes/grid_renderer.tscn`, `scripts/grid_renderer.gd`)
- [x] Task 1.6: Camera2D Setup (`scripts/grid_camera.gd`)

### ✅ Completed (Phase 2 - Core Gameplay)

- [x] Task 2.1: Economy Manager Singleton (`autoload/economy_manager.gd`)
- [x] Task 2.2: Slime State Machine States (Simplified to 4 states)
  - [x] Base State class (`scripts/slime/state.gd`)
  - [x] StateMachine (`scripts/slime/state_machine.gd`)
  - [x] StateIdle (`scripts/slime/state_idle.gd`)
  - [x] StateSelectTarget (`scripts/slime/state_select_target.gd`)
  - [x] StateMoving (`scripts/state_move.gd`)
  - [x] StatePainting (`scripts/state_painting.gd`)
- [x] Task 2.3: Slime Scene (`scenes/slime.tscn`, `scripts/slime/slime.gd`)
- [x] Task 2.4: Painting Mechanics Integration
- [x] Task 2.5: Base Station - **SKIPPED** (MVP simplified, no tank/refill)

### 🎯 MVP Simplifications

- **No Tank/Refill System:** Slimes work continuously without resource constraints
- **No Base Station:** Removed Returning and Refilling states
- **Simplified Loop:** Idle → SelectTarget → Moving → Painting → Idle

---

## 🚀 Sprint 1: Complete Core Loop (PRIORITY)

**Goal:** Get multiple slimes working + basic UI feedback

### Task 2.6: Slime Purchase System

- [x] Create `res://autoload/slime_manager.gd` singleton
- [x] Add to project autoload settings
- [x] Implement `purchase_slime() -> bool` method
  - Check EconomyManager for coins
  - Spawn slime at designated position
  - Add to slimes array
- [x] Implement `calculate_slime_cost() -> int` (exponential scaling)
  - Formula: `base_cost * pow(1.5, slime_count)`
  - Base cost: 10 coins
- [x] Add Signal: `slime_purchased(slime: Slime)`
- [x] **Test:** Purchase multiple slimes, verify they work independently

### Task 4.1: HUD Scene (Basic UI)

- [x] Create `res://scenes/ui/hud.tscn` with CanvasLayer root
- [x] Create `res://scripts/ui/hud.gd`
- [x] Add Labels:
  - Coin count (top-left)
  - Painting progress "X/Y cells" (top-center)
  - Slime count (top-right)
  - Painting name (top-center above progress)
- [x] Connect to signals:
  - `EconomyManager.coins_changed`
  - `GridManager.cell_painted`
  - `SlimeManager.slime_purchased`
- [x] Add to `main.tscn`
- [x] **Test:** Verify HUD updates in real-time

### Task 4.2: Buy Slime Button

- [x] Add Button to HUD (bottom-right)
- [x] Set text: "Buy Slime (X coins)"
- [x] Connect to `SlimeManager.purchase_slime()` on press
- [x] Listen to `EconomyManager.coins_changed` to enable/disable
- [x] Update cost label when `slime_purchased` signal emits
- [x] **Test:** Buy slimes, verify button cost updates and disables when can't afford

### Task 2.7: Movement Visualization (Optional Debug)

- [ ] Add Line2D node to `slime.tscn`
- [ ] Configure Line2D (width=2, yellow color with transparency)
- [ ] Add `@export var cell_offset: Vector2 = Vector2(-8, 8)` to slime.gd
- [ ] Add `debug_draw_path: bool = false` property
- [ ] Implement F3 key toggle in slime.gd `_input()`
- [ ] Update SelectTarget state to apply offset
- [ ] Update Moving state to draw/update line
- [ ] Update Painting state to hide line
- [ ] **Test:** Toggle F3, verify lines appear for slime paths

**Sprint 1 Success Criteria:**

- [ ] Can buy multiple slimes
- [ ] Multiple slimes paint independently
- [ ] HUD shows current game state
- [ ] Core idle loop is complete and playable

---

## 📈 Sprint 2: Add Progression

**Goal:** Give players meaningful choices and progression

### Task 3.1: Upgrade System

- [ ] Create `res://resources/upgrade.gd` (extends Resource)
  - Properties: upgrade_name, description, upgrade_type (enum)
  - Properties: base_cost, current_level, max_level
  - Method: `get_cost_for_next_level() -> int` (exponential)
  - Method: `get_effect_at_level(level: int) -> float`
- [ ] Create `res://autoload/upgrade_manager.gd` singleton
- [ ] Add to project autoload settings
- [ ] Define upgrade types enum: MOVE_SPEED, PAINT_SPEED
- [ ] Implement `purchase_upgrade(type: enum) -> bool`
- [ ] Implement `get_upgrade_level(type: enum) -> int`
- [ ] Implement `get_upgrade_multiplier(type: enum) -> float`
- [ ] Add Signal: `upgrade_purchased(type: enum, new_level: int)`
- [ ] Initialize default upgrades in `_ready()`
- [ ] **Test:** Purchase upgrades, verify levels increase

### Task 3.2: Apply Upgrades to Slimes

- [ ] Add method `calculate_stats()` to `slime.gd`
- [ ] In `_ready()`, query UpgradeManager for current levels
- [ ] Apply multipliers: `base_move_speed * upgrade_multiplier`
- [ ] Connect to `UpgradeManager.upgrade_purchased` signal
- [ ] Call `calculate_stats()` when upgrades purchased
- [ ] **Test:** Purchase upgrade, verify existing slimes get faster

### Task 4.3: Shop Menu Scene

- [ ] Create `res://scenes/ui/shop_menu.tscn` (Panel overlay)
- [ ] Create `res://scripts/ui/shop_menu.gd`
- [ ] Create `res://scenes/ui/upgrade_button.tscn` (reusable)
- [ ] Add TabContainer with tabs: "Upgrades", "Consumables", "Tools"
- [ ] Add ScrollContainer with upgrade buttons in Upgrades tab
- [ ] Each upgrade button shows: name, description, level, cost, effect
- [ ] Connect purchase buttons to `UpgradeManager.purchase_upgrade()`
- [ ] Implement show/hide logic
- [ ] Add "Shop" button to HUD
- [ ] **Test:** Open shop, purchase upgrades, verify UI updates

**Sprint 2 Success Criteria:**

- [ ] Players can purchase upgrades
- [ ] Upgrades meaningfully affect gameplay
- [ ] Shop UI is functional and clear

---

## 💾 Sprint 3: Persistence & Content

**Goal:** Save progress and add painting variety

### Task 3.5: Save/Load System

- [ ] Create `res://resources/save_data.gd` (extends Resource)
  - Properties: coins, slime_count, upgrade_levels (Dictionary)
  - Properties: current_painting_name, painting_progress (Dictionary)
  - Property: last_save_timestamp (int)
- [ ] Create `res://autoload/save_manager.gd` singleton
- [ ] Add to project autoload settings
- [ ] Implement `save_game() -> void`
  - Gather data from all manager singletons
  - Get painted cells from GridManager
  - Use ResourceSaver.save()
- [ ] Implement `load_game() -> SaveData`
  - Use ResourceLoader.load()
  - Return SaveData or null
- [ ] Implement `has_save_file() -> bool`
- [ ] Save file path: `user://save_game.tres`
- [ ] **Test:** Save, close project, reopen, load, verify state restored

### Task 3.6: Offline Progress Calculation

- [ ] Store `last_save_timestamp` in SaveData
- [ ] In `save_game()`, store `Time.get_unix_time_from_system()`
- [ ] In `load_game()`, calculate elapsed time
- [ ] Cap elapsed at 7200 seconds (2 hours)
- [ ] Calculate `coins_per_second` based on slimes and upgrades
- [ ] Call `EconomyManager.add_coins(offline_earnings)`
- [ ] **Test:** Save, edit timestamp, load, verify offline coins

### Task 3.3: Gallery Manager

- [ ] Create `res://autoload/gallery_manager.gd` singleton
- [ ] Add to project autoload settings
- [ ] Properties: paintings (Array[Painting]), completed (Array[String])
- [ ] Method: `load_paintings()` (scan resources or hardcode for MVP)
- [ ] Method: `is_painting_available(painting: Painting) -> bool`
- [ ] Method: `complete_painting(painting: Painting)`
- [ ] Method: `get_available_paintings() -> Array[Painting]`
- [ ] Signal: `painting_unlocked(painting: Painting)`
- [ ] **Test:** Load paintings, complete one, verify tracking

### Task 3.4: Painting Loading and Switching

- [ ] Add `load_painting(painting: Painting, painted_cells: Array = [])` to GridManager
- [ ] Clear existing cells array
- [ ] Load new painting and create cells
- [ ] If painted_cells provided, restore progress
- [ ] Emit `painting_loaded` signal
- [ ] GridRenderer recreates Image/ImageTexture on `painting_loaded`
- [ ] SlimeManager resets slimes to Idle on `painting_loaded`
- [ ] Track painted count, emit `painting_complete` when done
- [ ] **Test:** Switch paintings, verify grid updates and slimes continue

**Sprint 3 Success Criteria:**

- [ ] Game saves and loads all progress
- [ ] Offline progress works correctly
- [ ] Players can switch between paintings
- [ ] Painting completion is tracked

---

## 🎨 Phase 4: Polish (Later)

### UI Systems

- [ ] Task 4.4: Gallery Scene (painting selection interface)
- [ ] Task 4.5: Tutorial System (7-step new player guide)
- [ ] Task 4.7: Settings Menu (volume, particles, tutorial reset)

### Juice & Feel

- [ ] Task 4.6: Audio System (SFX and music)
- [ ] Task 4.8: Particle Effects (paint splash, coin popup)
- [ ] Task 4.9: Painting Completion Sequence (celebration!)

### Integration

- [ ] Task 4.10: Main Scene Integration (wire everything together)

### Content

- [ ] Task 5.1: Create 5 Painting Resources (pixel art images)

---

## 🧪 Testing Checklist

### After Sprint 1

- [ ] Multiple slimes work simultaneously without conflicts
- [ ] HUD updates in real-time
- [ ] Can't buy slime without enough coins
- [ ] Slime cost scales exponentially

### After Sprint 2

- [ ] Upgrades visibly affect slime behavior
- [ ] Upgrade costs scale correctly
- [ ] Can't purchase upgrade without enough coins
- [ ] Existing slimes get upgraded stats

### After Sprint 3

- [ ] Save/load preserves exact painting progress
- [ ] Offline progress caps at 2 hours
- [ ] Switching paintings clears grid correctly
- [ ] Painting completion triggers properly

### Edge Cases to Test Eventually

- [ ] Multiple slimes targeting same cell
- [ ] Purchasing with exact coin amount
- [ ] Very large grids (50x50+) performance
- [ ] Save/load during active painting

---

## 📝 Notes

**Architecture Decisions:**

- Using Image texture for grid (1 pixel = 1 cell, scaled up)
- Signal-based communication between systems
- Node-based state machine for slime AI
- Resource-based data structures (Cell, Painting, SaveData)

**Autoload Order (Important!):**

1. SaveManager
2. EconomyManager
3. UpgradeManager
4. GridManager
5. GalleryManager
6. SlimeManager
7. AudioManager

**Current Blockers:**

- None! Ready to implement Task 2.6

**Performance Targets:**

- 60 FPS with 10 slimes on 50x50 grid
- Smooth camera movement
- No lag on multiple simultaneous cell paints

---

## 🎯 Next Action

**Start with Task 2.6: Slime Purchase System**

Create the SlimeManager singleton to enable buying multiple slimes. This unlocks the core idle game loop where more slimes = faster painting = more coins = buy more slimes.

Good luck! 🎮
