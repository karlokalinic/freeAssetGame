# Next Vertical Slice Foundation

This refactor prepares the project for story-heavy expansion based on the root storyline document.

## New foundational systems

- **Narrative branching graph**
  - `scripts/game/narrative_data.gd`
  - `scripts/game/narrative_manager.gd`
  - Supports node/choice branching with side effects.

- **Voice resonance system (6 voices)**
  - `scripts/game/resonance_system.gd`
  - Tracks narrative skill-like voice levels (1–6).

- **Thought notebook system**
  - `scripts/game/thought_notebook.gd`
  - Unlockable internal thoughts from dialogue choices.

- **Evidence tracker**
  - `scripts/game/evidence_tracker.gd`
  - Stores discovered evidence entries.

- **Day/slot progression state**
  - Added to `scripts/game/game_state.gd`.
  - `advance_time_slot()` implements 4 slots/day up to day 10.

## Save payload expansion

Save data now includes:
- `resonance`
- `thoughts`
- `evidence`
- `narrative`
- `day`
- `time_slot`

## Recommended next step

Create a district/day scheduler layer and map each branch node to district + timeslot availability to match the full design document pacing.


## Ability layer added

- New `scripts/game/ability_system.gd` links progression systems to interaction power.
- Unlock logic now depends on combined resonance + notebook + evidence states.
- Next step: map abilities to district-specific scripted events and ending gates.
