# Discovery scenes and local elevation

Implemented directly in existing Place1; no publishing. Source: games/StarfallMap/DiscoveryScenes.luau. Installer regenerated with the new pass after PropVariety.

## Eighteen scenes

| Planet | Scenes | Added local elevation |
|---|---|---|
| Sprout | Tangled Grove; Sheltered Pond Garden; Luminous Meadow | 4 / 2 / 6 studs |
| Rust | Split Drive Wreck; Cargo Passage; Abandoned Repair Camp | 2 / 4 / 6 studs |
| Frost | Fractured Pool; Leaning Ice Passage; Frozen Excavator | 2 / 6 / 4 studs |
| Violet | Mushroom Canopy; Puffball Hollow; Spore Shelf Garden | 4 / 2 / 6 studs |
| Relic | Collapsed Gateway; Sunken Garden Court; Forgotten Sentinels | 4 / 2 / 6 studs |
| Storm | Broken Antenna Array; Crystal Generator; Suspended Fractures | 2 / 6 / 4 studs |

Local elevation is additive relief beneath each composition. Original island shapes and terrain were not rebuilt. New shelves have irregular outer contours, one-stud stairs, and biome-colored surfaces. A Sprout grove pilot was inspected at low player-facing height and overhead before extension. Later screenshots prompted replacing the initial square bases and pale stairs with more irregular outlines, notched stair access, and biome colors.

Each scene has a focal structure and supporting details, including spilled engine coils, cargo straps, repair tools, frozen machine windows, mushroom spots, worn runes, statue faces, and vegetation. Existing nearby small scenery was replaced rather than retained inside new solid geometry. Full prior Props copies are preserved per planet in ServerStorage.StarfallBeforeDiscoveryScenes.

## Inspection evidence

- All 18 scenes inspected in close Studio screenshots; whole-island overhead views inspected for all six. Sprout pilot additionally inspected from above before extension.
- Exact baseline comparison of all six Terrain, LandingPad and EggSpawnZones subtrees passed, as did the Home Hub geometry and nine saved gameplay/UI/debug script sources.
- Every new scene part uses an assigned palette color. No lighting changes.
- Actual scene foundation and stair footprints sampled against terrain and paths: zero unsupported bases, path intersections, obstructed stair centers, egg-clearance violations, or shared landing violations.
- Source placement excludes the landing-to-landmark corridor and reserves at least 29 studs from each egg-zone center. Three ray samples toward each main landmark found no new scene obstruction.
- Fresh Play session: three scenes and eight placeholder eggs per planet; all six orbit links valid.
- Nine new cosmetic motion groups observed moving near the client camera, all noncolliding. They use the existing distance-capped animator; no new gameplay scripts. Storm arcs use the existing seven-second spark cycle. Console output contained only the tool's camera-reset notice.
- Independent read-only source review found no actionable defects. Returned Studio to Edit mode.

The installer was regenerated successfully but was not run over the existing open map. Eggs remain placeholders and no rarity RNG was added.
