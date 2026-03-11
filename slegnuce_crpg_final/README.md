# slegnuce_crpg_final (Godot 4.6 prototype)

This folder is a playable Godot 4.6 **CRPG vertical-slice prototype**.

## Included right now

- `project.godot` — Godot project settings and main scene entrypoint.
- `scenes/Main.tscn` — test map with:
  - ground plane
  - player pawn
  - NPC target with collider
  - loot chest with collider
  - top-down camera
  - HUD labels for controls, HP, inventory, and quest status
- `scripts/main.gd` — gameplay director (movement input, interaction routing, combat, loot, UI refresh, localization).
- `scripts/player_controller.gd` — movement logic for the player pawn.
- `scripts/save_manager.gd` — versioned binary save/load wrapper with validation and error reporting.
- `SAVE_SYSTEM.md` — focused save architecture notes.
- `assets/` — drop imported Sketchfab models/textures/audio here.

## Controls

- **LMB:** move player to clicked ground point.
- **RMB on NPC:** attack (close), talk (mid), or hint (far).
- **RMB on Chest:** loot item if in range.
- **L:** switch locale between Croatian/English UI text.
- **F5:** save game state to `user://savegame.dat` (versioned payload).
- **F9:** load game state from `user://savegame.dat` with compatibility checks.
- **R:** reset state to defaults.

## Binary save/load implementation (fact-checked)

Save/load uses Godot Variant binary serialization APIs:

- `var_to_bytes()` to serialize game state dictionary.
- `bytes_to_var()` to deserialize state.
- `FileAccess.store_buffer()` and `FileAccess.get_buffer()` for file I/O.

Reference: Godot docs (Binary Serialization API):
https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html

## Import and run

1. Open Godot 4.6.
2. Click **Import**.
3. Select `slegnuce_crpg_final`.
4. Run project (`F5`).

## Asset workflow notes

- Keep original filenames when importing from Sketchfab so source tracking stays easy.
- Recommended structure:
  - `assets/characters/`
  - `assets/environment/`
  - `assets/props/`
  - `assets/audio/voice/`
- Prefer `.glb` for model import speed and consistent scene setup in Godot.

## Merge conflict quick rule

If GitHub asks **Current / Incoming / Both**:

- Pick **Current** when your branch has the intended latest gameplay logic.
- Pick **Incoming** when the other branch clearly has the wanted fix.
- Pick **Both** for additive content, then clean duplicates and re-save scenes in Godot.

(Full details remain in `GITHUB_MERGE_CONFLICT_GUIDE.md`.)

## Next iteration targets

1. Replace placeholders with real Sketchfab models and animation trees.
2. Add click-to-attack animation events and VFX/SFX hooks.
3. Add enemy AI turn logic.
4. Move localization text into external data resource.
5. Create in-engine teaser capture scene and voiceover pipeline.
