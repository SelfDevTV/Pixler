# Pixel Paint Idle Game - Claude Context

## Project Overview

An idle game where autonomous slime workers paint pixel art grids, revealing hidden images while earning coins for progression. Built in Godot 4.x with GDScript.

**Detailed Implementation Plan:** [docs/plans/2025-11-03-pixel-paint-idle-implementation-plan.md](docs/plans/2025-11-03-pixel-paint-idle-implementation-plan.md)

---

## Learning Philosophy - IMPORTANT!

**I want to learn by doing. Please follow these guidelines when helping me:**

### DO:

- ✅ Give me hints and nudges in the right direction
- ✅ Ask me questions to help me think through problems
- ✅ Explain the "why" behind architectural decisions
- ✅ Point me to relevant Godot documentation sections
- ✅ Provide pseudocode or architecture diagrams when I'm stuck
- ✅ Suggest what to search for or where to look
- ✅ Help me understand design patterns and best practices
- ✅ Review my code and ask questions about my approach
- ✅ If you give me code (after i asked), always provide with proper gdscript types, use the newest 4.5 docs. for example abstract classes and methods are also now available

### DON'T:

- ❌ Give me complete code solutions immediately (unless I explicitly ask)
- ❌ Write entire classes or systems without explanation
- ❌ Just hand me the answer without helping me understand
- ❌ Skip explaining trade-offs and alternatives

### When I'm Stuck:

1. First, ask me what I've tried and what I think might work
2. Guide me toward the solution with questions or hints
3. If I'm really blocked, give me a small snippet with thorough explanation
4. Help me learn from mistakes rather than just fixing them

---

## Key Architectural Decisions

Based on the implementation plan, here are the core patterns and approaches:

### Singletons (Autoloaded Managers)

- **GridManager**: Manages current painting state and cell data
- **EconomyManager**: Tracks coins and transactions
- **UpgradeManager**: Handles upgrade levels and effects
- **GalleryManager**: Manages painting collection and unlocks
- **SlimeManager**: Spawns and tracks slime workers
- **SaveManager**: Handles persistence
- **AudioManager**: Manages sound effects and music
- **TutorialManager**: Guides new players

### Design Patterns

- **State Machine**: Slime AI (Idle → SelectTarget → Moving → Painting → Returning → Refilling)
- **Observer Pattern**: Signal-based communication between systems
- **Resource Pattern**: Custom resources for Cell, Painting, Upgrade, SaveData
- **Image Texture Rendering**: Efficient grid display using single Sprite2D with pixel manipulation

### Core Systems

- **Grid System**: Image-based rendering (1 pixel = 1 cell, scaled for visibility)
- **Painting Data**: Texture2D resources that auto-extract color data
- **Signal Flow**: GridManager.cell_painted → GridRenderer updates + EconomyManager adds coin
- **Offline Progress**: Calculate earnings based on time elapsed (capped at 2 hours)

---

## Current Progress

**Phase:** Not Started
**Last Task Completed:** N/A
**Next Task:** Task 1.1 - Project Setup

### Phase Checklist

- [ ] Phase 1: Foundation (Project Setup & Grid System)
- [ ] Phase 2: Core Gameplay (Slimes, AI, Economy)
- [ ] Phase 3: Progression (Gallery, Paintings, Persistence)
- [ ] Phase 4: Polish (UI, Tutorial, Audio, Particles)

---

## Helpful Resources

### Godot Documentation

- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Image Class](https://docs.godotengine.org/en/stable/classes/class_image.html)
- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
- [Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)

### Common Godot Patterns

- State machines in Godot
- Using signals for decoupled systems
- ResourceSaver/ResourceLoader for persistence
- Image manipulation for pixel-based rendering

---

## Notes for Claude

- I'm working through the implementation plan task-by-task
- Each task has clear goals, steps, and testing approaches
- I may skip around or approach things differently than the plan - that's okay!
- Help me understand the Godot way of doing things
- Challenge my assumptions if you think there's a better approach

---

## Quick Reference

**Project Path:** `c:\Users\dhube\Documents\Godot\Pixler`
**Godot Version:** 4.x
**Language:** GDScript
**Main Scene:** Will be `res://scenes/main.tscn`
