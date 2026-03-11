# GitHub merge conflict quick guide (keep incoming / current / both?)

When GitHub asks you to resolve a conflict, these options usually mean:

- **Current change**: the version on the branch you are merging *into* (often your branch in the PR conflict editor).
- **Incoming change**: the version from the branch being merged *from*.
- **Both changes**: keeps both blocks and you manually clean up duplicates/order after.

## Practical rule of thumb

- Choose **Current** if your branch already has the right/newer game logic and incoming is older.
- Choose **Incoming** if the other branch contains the intended update (for example, your teammate fixed the same file correctly there).
- Choose **Both** when both sides add valid content (common in docs, data tables, level lists, or independent methods), then manually edit to a final clean result.

## Safe conflict workflow

1. Read the conflict markers and identify *intent* on both sides.
2. Prefer preserving functionality over minimizing lines.
3. After choosing current/incoming/both, remove duplicate imports, duplicate node names, or duplicate keys.
4. Run the project/tests before committing conflict resolution.
5. Commit with a message like: `Resolve merge conflict in Main.tscn and project.godot`.

## For Godot-specific files

- `.tscn` and `.tres` can conflict on resource IDs and node ordering.
- If uncertain, choose **Both**, then open the scene in Godot editor and re-save so Godot normalizes formatting.
- Re-run the scene to verify cameras/lights/scripts still attach correctly.
