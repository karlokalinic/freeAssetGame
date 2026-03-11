# slegnuce_crpg_final (Godot 4.6 prototype)

Playable Godot 4.6 vertical slice with clear startup chronology:

1. **Main Menu**
2. **Settings check**
3. **New Game**
4. **In-game minimal HUD + expandable tutorial panel**

## Scene flow

- `scenes/MainMenu.tscn` (startup scene)
- `scenes/Game.tscn` (gameplay)

## Modular backend architecture

- `scripts/main.gd` — gameplay orchestrator only.
- `scripts/main_menu.gd` — main menu + settings UI wiring.
- `scripts/player_controller.gd` — click-to-move character controller.
- `scripts/save_manager.gd` — versioned save API.
- `scripts/game/constants.gd` — constants + localized text DB.
- `scripts/game/translator.gd` — localization helper.
- `scripts/game/game_state.gd` — runtime state model and serialization payload mapping.
- `scripts/game/hud_controller.gd` — HUD rendering, animated show/hide, drag-to-move tutorial panel.
- `scripts/game/settings_manager.gd` — shared settings persistence/apply layer.
- `scripts/game/spatial_audio_trigger.gd` — drop-in 3D trigger audio source.
- `scripts/game/idle_bob.gd` — lightweight visual idle animation.

## UX polish implemented

- **Tutorial panel** can be:
  - opened/closed via button and `TAB`,
  - dragged around with mouse,
  - animated fade in/out,
  - cleared with `Clear Msg`.
- **Cursor interaction feedback**:
  - cursor switches to pointing hand when hovering NPC/chest.
- **Idle animation**:
  - NPC/chest use subtle bob + rotate movement.

## Environmental audio feature (3D trigger)

A reusable trigger is in scene (`DoorbellTrigger`) and can be placed anywhere.

How to use:
1. Select `DoorbellTrigger/AudioStreamPlayer3D`.
2. Drag & drop any audio stream resource into `stream`.
3. Move `DoorbellTrigger` anywhere in 3D world.
4. Set trigger radius on `DoorbellTrigger/CollisionShape3D`.

When `Player` enters trigger area, audio plays (one-shot by default).

## Audio + Graphics settings (Linux & Windows friendly)

Main menu settings now include:
- Fullscreen
- Borderless
- VSync
- 3D Render Scale (performance/quality tradeoff)
- Master / Environment / SFX volume sliders

Settings persist in `user://settings.cfg` and are applied both in menu and gameplay.

## Controls (Game scene)

- **LMB:** move player
- **RMB on NPC:** talk/attack by range
- **RMB on chest:** loot by range
- **TAB:** show/hide tutorial panel
- **H:** show/hide entire HUD
- **C:** clear message
- **L:** switch language HR/EN
- **F5/F9:** save/load
- **R:** reset state

## Save system

- `scripts/save_manager.gd` stores versioned payload in `user://savegame.dat`.
- Uses `var_to_bytes()` / `bytes_to_var()` and `FileAccess` buffer methods.
- Reference:
  - https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html

## Integrated models from repository

- `snow_town.glb` (environment)
- `sara_-_lod_lady_character.glb` (player visual)
- `business_man.glb` (NPC visual)
