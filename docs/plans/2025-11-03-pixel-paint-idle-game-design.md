# Pixel Paint Idle Game - Design Document

**Date:** November 3, 2025
**Status:** Design Complete - Ready for Implementation

## Overview

An idle game that combines incremental mechanics with the satisfaction of revealing pixel art. Players buy autonomous slime workers that paint cells on a grid, gradually revealing hidden images while earning coins for upgrades and progression.

---

## Core Concept

### The Hook
- Blank grid (white cells, black borders) hides a complete pixel art image
- Each cell contains a hidden color
- Players can't paint directly - must buy slime workers
- Slimes autonomously select, travel to, and paint cells
- Each painted cell reveals its color and earns coins
- Coins buy more slimes and upgrades
- Complete paintings unlock tools and new paintings

### The Loop
1. Buy slime with coins
2. Slime picks unpainted cell and moves to it
3. Slime progressively paints cell (tank drains, color fills, particles/sound/coin popup)
4. When tank empty, slime returns to base station to refill
5. Repeat until painting complete
6. Celebrate completion, unlock rewards, choose next painting

---

## Visual Identity

### Slimes (Core Workers)
- **Appearance:** Cute liquid creatures, paint blobs with personality
- **Color:** Visually match their paint color (generic in MVP)
- **Size = Tank Level:** Slimes shrink as they paint, grow when refilled
- **Animations:** Bounce while moving, shrink during painting, celebrate when idle

### Paint Feedback (The Juicy Part)
When a slime paints a cell:
1. Slime arrives at target cell
2. Progressive fill animation - color gradually fills white cell (bottom-up or center-out)
3. Slime visually shrinks (tank draining)
4. Particle effects burst when cell completes
5. Sound effect plays (satisfying "splash" or "pop" with pitch randomization)
6. Coin popup floats up (+1 coin animation)

**Performance Note:** With 10+ slimes, effects scale gracefully. Settings allow particle density reduction.

---

## Progression System

### Gallery Structure

**Tutorial Phase:**
- Single tutorial painting (10x10 "Paint Drop" icon)
- Teaches: buying slimes, watching them work, tank system, upgrades, completion

**Post-Tutorial:**
- **World 1 visible:** 5-8 paintings unlocked immediately
- **Fog of war:** Many paintings visible but mysterious (locked/grayed out)
- **World structure:** Paintings organized into themed worlds for clarity

### Painting Progression
- **Early:** Small grids (10x10, 15x15) - quick wins
- **Mid:** Medium grids (25x25, 35x35) - require strategy
- **Late:** Large grids (50x50, 100x100+) - need optimization

**Difficulty Scaling (MVP):** More cells = longer completion time

### Meta-Progression: Tool System

**How It Works:**
- Some paintings contain special cells (ice cells, rock cells)
- Special cells require tools to paint
- Complete specific paintings → unlock tools as rewards
- Tools enable previously impossible paintings
- Tools can be upgraded for efficiency

**MVP Implementation:**
- Tools auto-equip to all slimes when owned
- If tool not owned, slimes skip special cells

**Future Implementation:**
- Manual tool assignment to specific slimes
- Strategic choice: give hammer to fastest slime
- Tool slots per slime (multiple tools)

**Example Path:**
1. Complete "Sunset Beach" → unlock Ice Hammer
2. Ice Hammer enables "Frozen Palace" (has ice cells requiring 3 hits)
3. Complete "Frozen Palace" → unlock Drill
4. Drill enables paintings with rock cells
5. Continue unlocking tools and paintings

---

## Cell Types

### Standard Cells (MVP)
- White cells with black borders
- Single paint action reveals color
- Drop 1 coin when completed

### Special Cells (Post-MVP)

**Ice Cells:**
- Require 3 "hits" before painting
- Visual: Frosted/crystalline appearance
- Require Ice Hammer tool
- Mechanics: Slime whacks 3 times, then paints normally
- Upgrades: Hammer strength (reduce hits), hammer speed

**Rock Cells:**
- Require drilling action
- Require Drill tool
- Multi-hit mechanics with different visual/audio
- Upgrades: Drill power, drill speed

**Future Cell Types:**
- Locked cells (need key)
- Puzzle cells (adjacent cells must be completed first)
- Bonus cells (extra coin rewards)

---

## Economy & Upgrades

### Slime Purchases
- First slime: Free (tutorial) or very cheap
- Each additional slime: Exponential cost increase
- More slimes = faster painting = more coins/second

### Slime Upgrades (Global - Affect All Slimes)

**Movement/Efficiency:**
- **Move Speed:** Travel to cells faster
- **Paint Speed:** Fill color into cells faster
- **Paint Efficiency:** Use less tank per cell painted

**Tank System:**
- **Max Tank Capacity:** Paint more cells before refilling
- **Refill Speed:** Shorter downtime at base station
- **Auto-Refill Range:** Slimes refill from nearby range (don't need full return trip)

**Power Upgrades:**
- **AOE Paint:** Paint multiple cells in radius simultaneously
- **Multi-Target:** Queue multiple cells before refilling
- **Coin Multiplier:** Earn more coins per cell painted

### Consumable Items
- **Line Paint:** One-time use, paints entire row/column instantly
- Purchase with coins, limited use creates strategic decisions
- Future: Additional power-ups and boosters

### Upgrade Strategy
- All upgrades use exponential cost scaling
- Early game: Quick upgrades, immediate impact
- Mid game: Balance new slimes vs upgrading existing
- Late game: Optimization required for large paintings

---

## Idle Mechanics

### Offline Progress
- **System:** Robots work while game is closed
- **Cap:** Maximum accumulation (e.g., 2 hours of progress)
- **Purpose:** Reward regular check-ins without being punishing
- **Display:** HUD shows "1h 45m until cap" when approaching limit
- **Calculation:** On game load, calculate time passed (capped), simulate progress, award coins

### Active vs Offline
- Active play: Full speed, watch satisfying animations
- Offline: Same rate but no visuals
- Encourages 2-3 check-ins per day

---

## User Interface

### Camera System
- **Zoomable Canvas:** Pinch/scroll to zoom in and out
- **Pan Controls:** Drag to move around larger paintings
- **Slime Follow:** Double-click slime to track its movement
- **Manual Pan:** Disengages follow mode
- **Smooth Transitions:** Camera easing for polished feel

### HUD (Always Visible)
- **Coin Balance:** Top corner, real-time updates
- **Progress Indicator:** "245/400 cells" or percentage bar
- **Active Slime Count:** "5 slimes working"
- **Current Painting Name:** "Frozen Palace"
- **Offline Cap Timer:** "1h 45m until cap" (when relevant)

### Persistent Buttons
- **Buy Slime Button:** Bottom-right, always visible, shows cost
- **Menu Button:** Bottom-left, opens shop/upgrades overlay
- **Gallery Button:** Top bar, opens painting selection
- **Slime List Panel:** Small side panel showing active slimes (for double-click follow)

### Shop Menu (Overlay/Panel)

**Tab 1 - Slime Upgrades:**
- Lists all available upgrades
- Shows: current level, next level cost, effect description
- Purchase buttons

**Tab 2 - Consumables:**
- Line Paint (quantity owned, purchase option)
- Future power-ups

**Tab 3 - Tools:**
- Owned tools displayed (Ice Hammer, Drill, etc.)
- Tool upgrade options
- Locked tools show requirements: "Complete Frozen Palace to unlock"

### Gallery Screen
- Grid of painting thumbnails
- **Status Colors:**
  - Completed: Full color thumbnail
  - Available: Normal appearance
  - Locked: Grayed out + lock icon
- **Locked Paintings:** Show requirements ("Requires: Ice Hammer")
- **Click Painting:** Preview, grid size, estimated difficulty, rewards
- **"Start Painting" Button:** Loads painting onto canvas

---

## Painting Completion Flow

### Celebration Sequence
1. **Pause & Celebrate:** All slimes stop and play celebration animation (bounce/cheer)
2. **Camera Zoom:** Zoom out to show full completed painting
3. **Fanfare:** Sound effect + particle explosion across canvas
4. **Banner:** "Painting Complete!" with animation

### Stats Screen
- Time taken to complete
- Total cells painted
- Total coins earned from this painting
- Number of slimes used

### Rewards Display
- Final coin tally
- Tool unlocked (if applicable): "Ice Hammer Unlocked!" with visual
- New paintings unlocked notification

### Gallery Integration
- "Add to Gallery" button
- Painting flies/transitions into gallery slot with animation
- Before/after comparison shown (blank grid → completed art)
- Completion timestamp saved

### Player Choice
- "Choose Next Painting" button → Opens gallery
- Player selects next challenge
- Smooth transition to new painting

---

## Tutorial & Onboarding

### Tutorial Painting: "Paint Drop" (10x10)

**Step 1 - Welcome:**
- Display empty 10x10 grid
- Text: "Welcome! This blank canvas hides a secret image. Let's reveal it!"
- Highlight shop area

**Step 2 - Buy First Slime:**
- Arrow points to "Buy Slime" button
- "Click here to buy your first slime!"
- First slime is FREE
- Slime spawns at base station with animation

**Step 3 - Watch It Work:**
- "Your slime will automatically paint cells and earn coins. Watch!"
- Let slime paint 3-5 cells
- Highlight coin counter increasing
- "Each painted cell earns you coins!"

**Step 4 - Tank System:**
- Slime tank runs low (visual shrinking)
- "Your slime's paint tank is empty. It's returning to refill!"
- Watch slime pathfind back to base
- Refill animation plays
- "Now it's back to work!"

**Step 5 - Buy Second Slime:**
- Wait until player has enough coins
- "You've earned enough! Buy another slime to paint faster!"
- Player purchases second slime
- Show both working simultaneously

**Step 6 - Introduce Upgrades:**
- "Open the shop menu to make your slimes better!"
- Highlight menu button
- Player opens shop
- Highlight one cheap upgrade (Paint Speed level 1)
- Player purchases
- "Notice how they paint faster now!" with visual comparison

**Step 7 - Completion:**
- Tutorial painting completes
- Full celebration sequence plays (first experience)
- "Amazing! Your first painting is complete. Now explore the gallery!"
- Gallery automatically opens
- World 1 paintings visible, fog of war established

### Post-Tutorial Learning
- Tool requirements explained when clicking locked paintings
- Special cells explained when first encountered (context-sensitive)
- No hand-holding after tutorial

---

## Technical Architecture

### Tech Stack
- **Engine:** Godot 4.x
- **Language:** GDScript
- **Assets:** PNG pixel art, grid-based rendering

### Core Systems

**1. Grid System:**
- 2D array/data structure storing cell states
- Each cell: `{color: Color, painted: bool, cell_type: enum, position: Vector2}`
- Grid size variable per painting (10x10 to 100x100+)
- Efficient cell lookup for pathfinding

**2. Slime AI:**
- **State Machine:** Idle → SelectTarget → MovingToCell → Painting → ReturningToBase → Refilling
- **Pathfinding:** A* or simple direct line for MVP (grid-based movement)
- **Target Selection:** Random or nearest unpainted cell algorithm
- **Tank Management:** Current tank level, drain rate per paint action
- **Tool Handling:** Check if cell requires tool, skip if not owned

**3. Painting System:**
- Cell reveal animation (progressive fill shader or sprite animation)
- Color data loaded from source image file (PNG)
- Completion tracking: cells_painted / total_cells
- Particle system for paint effects
- Audio manager for randomized SFX

**4. Economy System:**
- Coin accumulation (real-time delta)
- Offline earnings calculation on game load
- Upgrade cost formulas (exponential scaling)
- Purchase validation (can afford checks)
- Save currency state

**5. Save System:**
- **Player Progress:** coins, owned_slimes, upgrade_levels, owned_tools
- **Painting States:** completed_paintings[], current_painting_id, current_progress
- **Offline Timestamp:** last_save_time for offline calculation
- **Tool Unlocks:** tools_unlocked[]
- Format: JSON or Godot Resource

**6. Gallery/Progression:**
- **Painting Database:** JSON or Resource files
  - Grid size, color data, requirements, rewards, thumbnail
- **Unlock Logic:** Check requirements against player progress
- **Tool Rewards:** Defined per painting completion

---

## Audio Design

### Sound Effects
- **Paint SFX:** Satisfying "splash" or "pop" when cell completes (randomized pitch)
- **Slime Movement:** Soft squish sounds (subtle, volume scales with slime count)
- **Refill SFX:** "Glug glug" refill sound at base station
- **UI SFX:** Button clicks, purchase confirmations, menu open/close
- **Celebration:** Fanfare/jingle on painting completion
- **Tool Use:** Distinct sounds for hammer hits, drill, etc. (post-MVP)

### Music
- **Ambient Background:** Soft, gentle, non-intrusive (suitable for idle game)
- **Loopable:** Seamless loop for extended play sessions
- **Volume:** Lower than SFX by default

### Settings
- Volume sliders: Music, SFX (separate controls)
- Mute all option
- Audio continues when app in background (optional setting)

---

## Balance & Pacing

### Early Game (First 10 minutes)
- Tutorial painting: 2-3 minutes with 1 slime
- Immediate affordance for upgrades/slimes
- Quick satisfaction loop

### Mid Game (10-60 minutes)
- Paintings: ~10-15 minutes with upgraded slimes
- Strategic decisions: new slimes vs upgrades
- Tool unlocks create "aha!" moments

### Late Game (1+ hours)
- Large paintings: 30+ minutes even with optimization
- Requires efficient slime management
- Completion feels earned and rewarding

### Offline Progress
- **Cap:** 2 hours maximum accumulation
- **Encourages:** 2-3 check-ins per day
- **Feel:** "I made progress while away" without trivializing active play

### Upgrade Costs
- Exponential scaling but balanced
- Each upgrade feels impactful immediately
- Players see visible speed improvements

---

## Settings Menu

**Audio:**
- Music volume slider
- SFX volume slider
- Mute all toggle

**Graphics:**
- Particle density (Low/Medium/High) for performance
- Framerate cap option

**Gameplay:**
- Offline progress cap display (show/hide timer in HUD)
- Tutorial reset button

**Other:**
- Credits
- Version number
- Link to feedback/support

---

## MVP Feature List

### Must Have (Build First)

**Core Gameplay:**
- Single tutorial painting (10x10 grid)
- 3-5 additional paintings (varying grid sizes: 15x15, 20x20, 25x25)
- Buy generic slimes (paint all colors)
- Basic upgrades: Move Speed, Paint Speed, Tank Capacity
- Slime AI: Pathfinding, painting animation, refilling behavior
- Paint animation with particles and sound
- Coin economy (earning, spending, balance display)
- Offline progress with 2-hour cap
- Gallery screen (select painting from available set)
- Save/load system (player progress persists)
- Tutorial sequence (all 7 steps)

**UI/UX:**
- Zoomable/pannable canvas
- HUD (coins, progress, slime count, painting name, offline timer)
- Persistent "Buy Slime" button
- Shop menu with upgrade tabs
- Gallery with painting selection
- Settings (volume, particle density)

**Polish:**
- Basic audio (paint SFX, UI clicks, background music)
- Completion celebration sequence
- Smooth camera transitions

### Nice to Have (Post-MVP)

**Progression:**
- Tool system (Ice Hammer, Drill, special cells)
- 10+ additional paintings
- Fog of war in gallery
- World organization/themes
- More upgrade types (AOE, Multi-target, Coin Multiplier)

**Features:**
- Consumable items (Line Paint)
- Tool upgrade system
- Manual slime-to-tool assignment
- Slime naming/customization

### Save for Much Later

**Advanced Features:**
- Color specialization system (slimes specialize in specific colors)
- Upgradeable base station
- Color generation mini-game
- Advanced slime AI modes (player-directed priorities)
- Community/imported images
- Achievements system
- Daily challenges

---

## Asset Requirements

### Pixel Art
- **Source:** Existing pixel art from free/CC0 sources (OpenGameArt, itch.io)
- **Format:** PNG files
- **Sizes:** 10x10, 15x15, 20x20, 25x25, 35x35, 50x50 grids
- **Variety:** Different themes (nature, objects, characters, patterns)
- **Quality:** Clear, recognizable images when complete

### Slime Sprites
- Idle animation (bounce loop)
- Moving animation (squish as they move)
- Painting animation (shrink as tank drains)
- Refilling animation (grow at base)
- Celebration animation (jump/cheer)
- Multiple sizes for tank level visualization

### UI Elements
- Button sprites (Buy Slime, Menu, Gallery)
- Panel backgrounds (shop, stats, gallery)
- Icons (coins, tools, upgrades)
- Progress bars
- Lock icons for unavailable paintings

### Effects
- Particle textures (paint splashes, sparkles)
- Cell fill animations or shaders
- Celebration particles (confetti, stars)

### Audio
- Paint sound variations (5+ different pitched pops)
- Slime movement squish
- Refill sound
- UI clicks
- Purchase confirmation
- Completion fanfare
- Background music track (loopable, 2-3 minutes)

---

## Future Expansion Ideas

### Color Specialization (Major Feature)
- Slimes can be "trained" to specialize in specific colors
- Specialized slimes get bonuses (e.g., +50% speed on their color)
- Adds strategic layer: analyze painting colors before buying
- Shop UI shows color breakdown per painting
- "Yellow slimes: 3 owned, Level 2 speed upgrade"

### Upgradeable Base Station
- Base starts as simple refill point
- Upgrades: Faster refill, multiple refill stations, auto-refill radius
- Visual progression (base gets fancier)

### Color Generation Mini-Game
- Separate mini-game to "generate" paint colors
- Mix primary colors to create secondaries
- Adds resource management layer
- Unlocks at mid-game

### Manual Tool Assignment
- Drag-and-drop tools onto specific slimes
- Strategic choices (give hammer to fastest slime)
- Tool slots per slime (can carry multiple)

### Advanced Gallery Features
- Filter paintings by: size, difficulty, completion status
- Sort by: completion time, coin rewards, theme
- Search function
- Statistics page (total cells painted, total time, etc.)

### Social/Meta Features
- Share completed paintings
- Daily challenges (complete specific painting for bonus)
- Leaderboards (fastest completion times)
- Achievements (paint 1000 cells, own 10 slimes, etc.)

---

## Success Metrics

### Player Engagement
- Average session length: 5-15 minutes
- Daily return rate: 60%+ (driven by offline cap)
- Tutorial completion rate: 80%+
- Paintings completed per player: 5+ average

### Core Loop Validation
- Players buy 2+ slimes within first session
- At least one upgrade purchased in first session
- Positive feedback on "watching slimes work" satisfaction

### Retention
- Day 1 retention: 50%+
- Day 7 retention: 25%+
- Monthly retention: 10%+

---

## Development Phases

### Phase 1: Core MVP (2-4 weeks)
- Grid system + cell rendering
- Basic slime AI (movement, painting, refilling)
- Single painting implementation
- Coin economy
- Buy slimes + 2-3 basic upgrades
- Save/load system
- Minimal UI

### Phase 2: Content & Polish (1-2 weeks)
- Tutorial implementation
- 5+ paintings with gallery
- Full UI (shop, gallery, HUD)
- Audio implementation
- Particle effects and juice
- Offline progress system

### Phase 3: Balance & Testing (1 week)
- Playtest with real users
- Balance upgrade costs and progression
- Fix bugs and edge cases
- Performance optimization
- Settings menu

### Phase 4: Post-MVP Features (Ongoing)
- Tool system + special cells
- More paintings (expand to 20+)
- Additional upgrades
- Consumable items
- Quality of life improvements based on feedback

---

## Open Questions & Future Decisions

1. **Exact offline cap duration:** 2 hours? 4 hours? Tune based on playtesting.
2. **Starting coin amount:** 0? Small amount to buy first upgrade immediately?
3. **Slime cost progression:** Linear, exponential, or Fibonacci?
4. **Maximum slimes allowed:** Hard cap (e.g., 10) or unlimited?
5. **Cell types variety:** How many different special cell types in full game?
6. **Tool assignment UI:** Drag-drop, menu-based, or contextual?
7. **Color specialization timing:** Mid-game unlock or separate mode?
8. **Monetization (if applicable):** Premium paintings? Cosmetic slimes? Ad-supported?

---

## Conclusion

This design creates a satisfying idle game that combines:
- **Passive satisfaction:** Watching slimes autonomously paint
- **Active strategy:** Choosing upgrades, managing economy, selecting paintings
- **Visual reward:** Revealing beautiful pixel art
- **Meta-progression:** Tools unlock new challenges

The MVP is scoped to validate the core loop quickly while preserving room for expansion through tools, special cells, color specialization, and advanced features.

**Next Steps:**
1. Validate design with potential players (show mockups/prototype)
2. Source pixel art assets
3. Set up Godot project structure
4. Begin Phase 1 development (core systems)
5. Iterate based on playtesting feedback
