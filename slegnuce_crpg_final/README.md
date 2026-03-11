# slegnuce_crpg_final (Godot 4.6 vertical slice)

Playable narrative-investigation prototype inspired by **Slegnuće: Raspuklina**.

## What is now implemented

- Main menu scene with expanded settings (video, audio, FOV, UI scale, language).
- Snow-village 3D game scene that uses multiple repo assets (`snow_town`, character models, `paper_tablet`, `church`).
- Click-to-move exploration.
- Multi-character interaction loop:
  - Guard (dialogue/combat gate)
  - Journalist Iva (branching narrative choices)
  - Loot chest and evidence node (inventory + progression)
  - Town Hall resolution trigger (multiple ending outcomes)
- Story choices that branch into legal/civic/ambiguous ending flavor text.
- Save/load support for both gameplay state and branching values.
- Croatian/English text support for all core interactions.

## Controls

- **LMB**: move player.
- **RMB**: interact with target under cursor (NPCs, chest, evidence, town hall).
- **TAB**: show/hide tutorial panel.
- **H**: toggle HUD root visibility.
- **C**: clear dialogue line.
- **L**: switch language.
- **F5 / F9**: save/load.
- **R**: restart scene quickly.
- **ESC**: return to main menu.

## Run

1. Open Godot 4.6.
2. Import folder `slegnuce_crpg_final`.
3. Run project (`F5`) — main scene is `MainMenu.tscn`.
