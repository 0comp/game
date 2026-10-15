# Starfall Salvagers Map

**Current game direction:** the [complete-game art, audio and feel design](../../docs/superpowers/specs/2026-10-13-starfall-art-audio-feel-design.md) defines a grassy social spaceport, modular ships and planet-specific egg/pet families.

The open Studio map now has **six inward-facing player plots surrounding a shared launch plaza**, following the user's sketch. Two robot shops flank the public launch pad. Every plot includes a personal starter-ship display, pet garden, nameplate, open entrance and dedicated spawn. Players receive exclusive session ownership of an available plot, which is released when they leave.

The home uses studded green grass, tan paths, wooden fences and avatar-scale props: counters roughly three studs tall, fences below head height and ships about fourteen studs wide. Rotated foundation rocks stay below the lawn; plot connections overlap slightly below the ground to prevent cracks and z-fighting. The previous oversized station and art pass are preserved in `ServerStorage.StarfallBeforeSixPlotHome`.

The latest polish adds fuller broadleaf and pine trees, flower planters, numbered lantern gates, layered cliff faces, pet-care corners and small workshop props. An orange departure gantry gives the shared launch pad a clearer silhouette; ship fins and nozzle frames add detail at the same scale. Flags sway, robot shopkeepers blink and an original display-only space pup idles beside the pet shop. The earlier home is preserved in `ServerStorage.StarfallBeforeHomePolish`.

Ground finishing replaces overlapping approach/entrance pieces with continuous paths, cuts the angled plaza junctions and separates path, pad and garden footprints. Raised floor layers prevent underlying stud patterns from showing through; ships and garden markers sit on the finished surfaces. That pass is preserved in `ServerStorage.StarfallBeforeSurfaceFinish`.

The current shops are open kiosks at x±27 with central counters, four approaches and an outer walking aisle. Robot shopkeepers turn toward nearby visitors. All seven display ships have compact booster pods, landing gear, cargo and named module attachments; plot ships share the same starter tier, while the public ship demonstrates additional armor and cargo. Boarding steps, landing markings, loading equipment and departure signals finish the public pad. The previous closed stalls and ships are retained in `ServerStorage.StarfallBeforeSpaceportRefinement`.

Six recognizable orbital planets replace the scattered sector dioramas, retaining their stable sector IDs. The old sectors/routes/backdrop are preserved in `ServerStorage.StarfallBeforePlanetVista`. A small cosmetic courier supplies background movement. The chart's risk previews remain presentation prototypes until equipment-based navigation is implemented.

## Planet surfaces and eggs

Each destination has **two separate models**:

- `Workspace.StarfallMap.Planets.[ID]`: the globe players will fly toward. `SurfaceIsland` and `ArrivalAnchor` ObjectValues link it to its surface scene and landing point; `ArrivalRadius` describes the future approach boundary.
- `Workspace.StarfallMap.PlanetIslands.[ID]`: the explorable island. `OrbitPlanet` links back to its globe. Surface scenes sit around X=10000–20000, spaced 5000 studs apart.

The intended travel flow is **fly to the orbital planet → teleport to the linked surface island**. Travel behavior is deferred at the user's request; no temporary selector or teleport service is installed.

The surface islands now have **rounded, asymmetric outlines roughly 350 studs across**, with individual coves and lobed shores. Their southern arrival meadows have room for **six ships**, with six invisible 40-by-32-stud clearance regions in two rows. There are no visible parking pads. Trees and props retain their original size. Egg placement avoids these clearance regions.

The square terrain grid has been replaced by fused contour surfaces, local hills of varied heights, a curved central trail, clustered vegetation/crystals, and a tapered floating-rock underside. Short hillside stairs reach the upper ground. Each island has 19–20 egg search zones. Sprout has a flower-ring nesting clearing. Native studded surface strips retain the classic Roblox finish; precise CSG collisions keep them inside the actual shores and coves. Earlier scenes are preserved in `ServerStorage.StarfallBeforeOrganicIslandsOriginal` and `ServerStorage.StarfallBeforeLandmarkComposition`.

Each world has a distinct focal landmark: Sprout's hollow heart tree, Rust's crashed scout ship, Frost's ice arch, Violet's giant mushroom family, Relic's temple gate, and Storm's beacon. Low planting in the gaps between ship envelopes makes arrival areas less bare without obstructing ships. Ordinary props keep their previous scale; these focal landmarks are intentionally larger.

| ID | Island | Visual theme |
|---|---|---|
| ScrapBelt | Sprout Moon | Emerald and forest greens; palette image 5 |
| DerelictField | Rust Crater | Taupe, ash, charcoal and lavender; palette image 3 |
| IceGraveyard | Frost Cove | Aqua, blue, pale ice and blush; palette image 2 |
| NebulaCurrent | Violet Wilds | Orchid, berry, violet and periwinkle; palette image 1 |
| AncientRuins | Relic Grove | Teal, mint, raspberry and blackberry; palette image 4 |
| SingularityEdge | Storm Reach | Aqua, cream, yellow and pink; palette image 6 |

`WorldPalettes.luau` applies exactly one supplied palette per destination, including terrain, props, orbital globe and placeholder egg template. It runs after the expansion pass. Every assigned color is an exact swatch, with no generated intermediate shades. The original part color is retained in `PrePaletteColor`; palette identity and swatches are stored as model attributes. The chart uses matching destination colors. See `docs/superpowers/specs/2026-10-13-world-palettes.md` for hex values.

Press Play to run `StarfallEggSpawnService`. Each island maintains up to **8 eggs**, refilling up to two missing eggs every **6 seconds**. World eggs expire after **180 seconds**. These values are editable island attributes. Each biome uses one fixed egg design; randomness selects position and rotation only. Placement rejects unsupported edges, obstacles, landing areas, nearby eggs and nearby players. Eggs moved outside their `ActiveEggs` folder are no longer expired by the spawner. Pickup, hatching, rarity rolls and pet outcomes are not implemented by this pass.

Templates are in `ServerStorage.StarfallEggTemplates`; invisible authoring zones are under each island's `EggSpawnZones`. The builder archives earlier templates before replacement during a reinstall.

Play also adds quiet home music, positional engine ambience and a **SOUND** toggle. These sounds are local presentation; they do not change flight or progression.

Press **Play** in Studio. Open the chart using **M** or the **STAR CHART** button. The freestanding navigation console was removed at the user's request. Select a numbered node to inspect its distance, risk, and loot theme. Close the chart with its Close button or M.

## Source

### Studio-only debug travel

In the current Studio place, press Play and use **DEBUG TP — STUDIO ONLY** below the sound button. The collapsible panel has six island teleport buttons and **Return home**. The home button returns to your assigned plot. Teleports do not start visits, grant items, or change progression.

The two scripts in `debug/` return immediately unless `RunService:IsStudio()` is true. The server creates its remote only in Studio and accepts only the six known destinations or home. Neither script is included in `InstallMap.luau` or `BuildStarfallInstaller.ps1`; they are local inspection tools. If the current place is published with these scripts present, their release guards prevent the interface and remote from being created.

- `BootstrapV2.luau`: fresh map root, original-scene backup and space enclosure.
- `LoadMeshKit.luau`: four generated model assets used as reusable shape templates.
- `RefineStation.luau`: hangar, observation deck, landing pads, machinery, paths and spawn.
- `RefineLandmarks.luau`: six sector landmarks, sculpted debris, docked ships and background depth.
- `ToyStyle.luau`: plastic palette, studs, simplified mesh finishes, toy nebula clouds and stair collision ramp.
- `ReferencePass.luau`: current reference-based palette and composition, rebuilt ships/booths/landmarks, signage, foundation, sky and backdrop. Earlier replaced props are retained in `ServerStorage.StarfallBeforeReference`.
- `HomeIsland.luau`: current six-plot ring, grassy floating foundations, public launch pad, two shops, smaller ships, vegetation, navigation and spawns. Runs after the earlier art passes and archives their hub.
- `HomePolish.luau`: landscaping, gates, cliffs, departure gantry, workshop props, mascot and ship details. Runs after HomeIsland and backs up the home before modifying it.
- `HomeFinish.luau`: nonoverlapping walking paths, cut plaza junctions, corrected pad/garden floor layers and complete shop exteriors. Runs after HomePolish.
- `SpaceportRefinement.luau`: open four-sided kiosks, new modular display ships, launch equipment, physical raised floors and stepped cliff bands. Runs after HomeFinish.
- `PlanetVista.luau`: six toy planet silhouettes, orbital rings and a cosmetic courier; archives earlier sector scenes/routes/backdrop.
- `PlanetIslands.luau`: six separate biome surface scenes, landing anchors, spawn zones, fixed egg templates and orbital/surface links. Renames the final orbital container from Sectors to Planets.
- `ExpandPlanetIslands.luau`: larger stepped terrain, unchanged-size landscaping, original six-ship arrival meadows and expanded egg search zones; ArrivalLandscape later replaces surface landing with one shared slot. Runs after PlanetIslands.
- `WorldPalettes.luau`: one exact user-supplied palette for each world, its orbital globe and placeholder egg template. Runs after ExpandPlanetIslands.
- `OrganicIslands.luau`: rounded CSG shores/coves, local contour hills, curved trails, scenery groves and tapered cliff layers. Runs after ExpandPlanetIslands.
- `WorldLandmarks.luau`: distinct focal scenery, clear monument approaches and low planting between ship envelopes. Runs after OrganicIslands.
- `IslandStudSkin.luau`: thin native studded top surfaces inside the curved geometry. Runs after OrganicIslands, before WorldPalettes.
- `BiomeArtDirection.luau`: irregular exact-palette ground patches, contrasting walks, pond/basin/ridge/court scenes, companion monuments, alternate vegetation silhouettes and restrained cosmic dust/floating stones. Replaces skin strips in place; archives replaced scenery under StarfallBeforeBiomeArt. Runs after ArrivalLandscape.
- `PropVariety.luau`: final scenery-only pass with six structural variants per biome, three locally dominant prop families, modest regrouping, small scene details, and a protected landing-to-landmark corridor. Archives replaced models in `ServerStorage.StarfallBeforePropVariety`; prototypes live in `StarfallSceneryKit`. Does not write terrain, home, paths, landing geometry, egg zones, lighting, or gameplay sources. Refuses to reapply to completed islands.
- `DiscoveryScenes.luau`: three local discovery scenes per planet, with irregular 2/4/6-stud relief shelves and clear steps. Runs after PropVariety. Saves full prior Props in `ServerStorage.StarfallBeforeDiscoveryScenes`, replaces eligible clutter only inside approved scene footprints, and reuses the existing cosmetic animator. Original Terrain remains intact. Completed scene names are skipped on rerun.
- `ArrivalLandscape.luau`: latest surface layout uses one shared landing anchor per planet for future client-side ships. Archives the six-slot layout, uses six authored compositions with different trail networks, terrain forms, thematic scene fragments and irregular groves. Prop sizes and angles vary; older grove silhouettes are also reduced in size selectively. Runs after IslandLife. Client-side ship visibility/flight is not yet implemented.
- `IslandLife.luau`: palette-matched log rings, flowers, crate fittings, ice fissures, mushroom spots, rune plaques and generator gauges. Runs after WorldPalettes.
- `IslandLife.client.luau`: nearby cosmetic bugs/drones, falling snow, spores, crystal/rune motes, occasional sparks, mushroom breathing and status lamp flickers. Distance-limited to 210 studs at 20 updates per second; no gameplay effects.
- `ExplorationDressing.luau`: three themed areas per world, layered biome scenery, winding studded trails and open egg pockets; preserves the original landing geometry at this stage; ArrivalLandscape applies the later single-slot request. Runs after IslandStudSkin and before WorldPalettes.
- `EggSpawnService.server.luau`: server-owned spatial spawning, support/clearance checks, population caps, expiry and refill; no rarity RNG.
- `HomeAmbience.client.luau`: local flag/mascot motion, shopkeeper blinks and visitor-facing rotation, courier movement, music, positional engine sound and mute control.
- `PlotService.server.luau`: exclusive session plot ownership, player nameplates, respawn selection and release on leaving.
- `SectorCatalog.luau`: sector names, chart positions, distances, risks, and loot themes.
- `MapUI.luau`: responsive chart rendering and selection.
- `MapClient.client.luau`: player UI, HUD chart button and M shortcut.
- `InstallMap.luau`: complete standalone Studio Command Bar installer, combining these sources.

## Reinstall in a blank place

Stop Play and run the complete contents of `InstallMap.luau` in Studio's Command Bar. It refuses to overwrite an existing `Workspace.StarfallMap`; move an earlier map into ServerStorage before rebuilding. The installer archives previous Starfall modules/client scripts, and keeps original baseplate, spawn, and Lighting effects in `ServerStorage.StarfallOriginalScene`. Mesh templates are loaded from the generated model asset IDs in `LoadMeshKit.luau` and cached in `ServerStorage.StarfallMeshKit`.

Regenerate the installer after source changes with `tools/BuildStarfallInstaller.ps1`. The older BuildMap/PolishMap/DetailMap source files describe the archived first version and are not used by the current installer.

The current map was authored locally in the open unpublished Studio place. Set the published experience's server player limit to six when configuring it; local map ownership already provides six slots. Flight, arrival teleportation, egg collection, pet economy and progression still require implementation. Ships and garden anchors currently show the map layout and do not grant pets or set a final pet-slot limit.

Sky asset: [Purple Nebula Space Skybox](https://create.roblox.com/store/asset/83555979203508), by Zalthen. The installer uses its six image IDs directly. No external asset scripts are installed.

Audio: [Chill Synth Lofi Nostalgic Vibes](https://create.roblox.com/store/asset/119229975910510), DistrokidOfficial; [Spaceship Interior Rocket Engine Constant 1](https://create.roblox.com/store/asset/9119414091), ProSoundEffects. Both were free Creator Store results and loaded successfully in the current local Studio session.





