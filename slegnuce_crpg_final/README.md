# slegnuce_crpg_final (Godot 4.6 prototype)

Playable Godot 4.6 vertical slice with clear startup chronology:

1. **Main Menu**
2. **Settings check**
3. **Scene Hub**
4. **Choose one of 5 functional scenes**

## Scene flow

- `scenes/MainMenu.tscn` (startup scene)
- `scenes/SceneHub.tscn` (scene selection)
- `scenes/Game_PrudinaCenter.tscn`
- `scenes/Game_Clinic.tscn`
- `scenes/Game_Archive.tscn`
- `scenes/Game_Riverbank.tscn`
- `scenes/Game_Industrial.tscn`

## Modular backend architecture

- `scripts/main.gd` — gameplay orchestrator only.
- `scripts/main_menu.gd` — main menu + settings UI wiring.
- `scripts/scene_hub.gd` — scene selection hub and transitions.
- `scripts/player_controller.gd` — click-to-move character controller.
- `scripts/save_manager.gd` — versioned save API.
- `scripts/game/constants.gd` — constants + localized text DB.
- `scripts/game/translator.gd` — localization helper.
- `scripts/game/game_state.gd` — runtime state model and serialization payload mapping.
- `scripts/game/hud_controller.gd` — HUD rendering, animated show/hide, drag-to-move tutorial panel.
- `scripts/game/settings_manager.gd` — shared settings persistence/apply layer.
- `scripts/game/narrative_data.gd` — branching dialogue graph data.
- `scripts/game/narrative_manager.gd` — branching runtime controller.
- `scripts/game/resonance_system.gd` — six-voice resonance progression.
- `scripts/game/thought_notebook.gd` — internal thought unlocks.
- `scripts/game/evidence_tracker.gd` — evidence collection state.
- `scripts/game/ability_system.gd` — ability unlock progression from resonance/thought/evidence.
- `scripts/game/spatial_audio_trigger.gd` — drop-in 3D trigger audio source.
- `scripts/game/idle_bob.gd` — lightweight visual idle animation.

## Story branchings foundation

- Dialogue mode opens when close to NPC.
- Choice inputs:
  - UI buttons
  - keyboard `1/2/3`
- Choices can modify:
  - resonance voices,
  - thought notebook,
  - evidence tracker,
  - day/time-slot progression.

## UX polish implemented

- Tutorial panel can be opened/closed via button or `TAB`.
- Tutorial panel is draggable and animated (fade in/out).
- Cursor switches to hand over interactables.
- `ESC` returns player to Scene Hub from any gameplay scene.

## Environmental audio feature (3D trigger)

A reusable trigger is in each gameplay scene (`DoorbellTrigger`) and can be placed anywhere.

How to use:
1. Select `DoorbellTrigger/AudioStreamPlayer3D`.
2. Drag & drop any audio stream resource into `stream`.
3. Move `DoorbellTrigger` anywhere in 3D world.
4. Set trigger radius on `DoorbellTrigger/CollisionShape3D`.

## Audio + Graphics settings (Linux & Windows friendly)

Main menu settings include:
- Fullscreen
- Borderless
- VSync
- 3D Render Scale
- Master / Environment / SFX volume sliders

Settings persist in `user://settings.cfg` and are applied in both menu and gameplay.

## Save system

- `scripts/save_manager.gd` stores versioned payload in `user://savegame.dat`.
- Uses `var_to_bytes()` / `bytes_to_var()` and `FileAccess` buffer methods.
- Reference:
  - https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html


## Progression upgrade (meaningful interactivity)

- Choices now feed **resonance + thoughts + evidence** and automatically unlock gameplay abilities.
- Current unlock path: `cross_reference`, `interview_pressure`, `toxicology_sense`, `public_statement`.
- Ability unlocks are persistent in save data and visible in HUD.
- Special actions can be triggered in gameplay (`Q`, `E`) once unlocked.
