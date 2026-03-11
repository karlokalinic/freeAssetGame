# Save System Notes (Godot 4.x)

This project uses Godot Variant binary serialization for persistence.

## Implementation

- `scripts/save_manager.gd`
  - `SaveManager.save_state(state: Dictionary)`
  - `SaveManager.load_state()`
- Save file path: `user://savegame.dat`
- Save payload includes:
  - locale
  - player/npc health
  - inventory + chest loot
  - dialogue index
  - player world position

## Serialization API used

- `var_to_bytes()`
- `bytes_to_var()`
- `FileAccess.store_buffer()`
- `FileAccess.get_buffer()`

## Versioning

`SaveManager` stores `version` and `timestamp_unix` in a wrapper dictionary.
If save version mismatches, load fails gracefully with an error message.

## Reference

Godot docs: Binary Serialization API
https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html
