# Planet scenery refinement — 2026-10-15

Applied directly to the existing Place1 Studio session. The rejected DistinctWorlds terrain redesign remains excluded. No publishing occurred.

## Scope and evidence

| Planet | New scenery models | Structural types | Local dominant groups | Maximum new prop height |
|---|---:|---:|---|---:|
| Sprout | 110 | 6 | Pine Copse / Broadleaf Grove / Meadow Edge | 10.63 studs |
| Rust | 94 | 6 | Cargo Yard / Rib Wreckage / Scrap Shore | 7.27 studs |
| Frost | 103 | 6 | Blade Grove / Fan Field / Snowbank | 9.28 studs |
| Violet | 100 | 6 | Umbrella Thicket / Spore Forest / Sprout Beds | 9.70 studs |
| Relic | 118 | 6 | Column Walk / Collapsed Walls / Overgrown Approach | 8.52 studs |
| Storm | 107 | 6 | Crystal Comb / Receiver Outcrop / Rift Shore | 9.07 studs |

Sprout pilot replaced five of eight grove candidates with three shapes: layered pine, crooked tree, and log with stump. Player-facing and overhead captures were inspected before extending the pass. The complete pass replaces existing anchors with bounded shifts rather than filling the islands with more scenery. Existing broad clearings remain open.

Each world's three regions have different dominant types, confirmed from actual model attributes and counts. Examples: Sprout west has 19 pines and six crooked trees, east has 23 broad oaks and 11 saplings, and front has 31 shrubs with eight log scenes. Rust has a crate-dominant yard, rib-dominant wreckage, and panel-dominant shoreline. Frost has spires, fans, and snowbanks. Violet has umbrellas, layered fungi, and puffball beds. Relic has columns, broken walls, and mossy masonry. Storm has prisms, receivers, and rock spears.

Small scenes are represented by log/stump pairs, rubble heaps and split machinery, snow chunks and frost sprouts, puffball and spore patches, mossy masonry, and fragment nests. Shapes use native Roblox parts, selected studs, and exact assigned palette swatches. Scale and yaw vary independently.

## Preservation and clearance inspection

Before any scenery edits, exact serialized baseline strings were stored in `ServerStorage.StarfallBeforePropVarietyBaseline`, split into bounded StringValues. Fresh comparison after the pass confirmed:

- All six Terrain, LandingPad, and EggSpawnZones snapshots unchanged, including transforms, sizes, colors, materials, attachments and ObjectValue targets.
- Home Hub geometry snapshot unchanged.
- All nine saved gameplay/UI/debug script sources unchanged.
- Zero new props outside their planet's assigned palette.
- Zero unsupported new model roots (world bounds bottom compared to actual ground raycast).
- Zero path intersections across one-stud samples of each new model's world footprint.
- Zero egg clearing or shared landing footprint clearance violations.
- A mixture of nearby groups and isolated specimens: 66–86 new models per planet have another within 12 studs; 10–20 per planet have nearest neighbors beyond 17 studs.

Camera inspection covered each planet's local grove, avatar-height landing-to-landmark view, and whole-island overhead view. Main landmarks remain visible above surrounding ordinary scenery. The preserved paths and terrain profiles remain recognizable.

## Runtime and delivery

A fresh Play session showed eight ActiveEggs on every island and valid OrbitPlanet links for all six. Studio console output was empty. Returned Studio to Edit mode. Eggs remain placeholders; no rarity RNG or gameplay was introduced.

`tools/BuildStarfallInstaller.ps1` now runs PropVariety after BiomeArtDirection, and `InstallMap.luau` was regenerated successfully. Old props remain recoverable in ServerStorage. The installer refuses to overwrite an existing map; it was not run against the open place.
