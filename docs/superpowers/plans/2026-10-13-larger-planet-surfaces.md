# Larger Planet Surfaces Implementation Plan

**Goal:** Enlarge all six egg-collection islands, provide natural clearance for six separate ships, and add walkable terrain while preserving avatar-scale props and placeholder eggs.

**Architecture:** Apply a separate `ExpandPlanetIslands.luau` authoring pass after PlanetIslands. Replace only surface terrain, redistribute existing props without scaling, and author six invisible ship clearance regions per island. Preserve orbital/surface links and arrival anchors. Update egg placement to avoid every clearance region.

**Constraints:** Work in the current Studio Edit session. No flight, teleport behavior, rarity RNG, publishing, or new tests. Use chunky studded Parts. Archive the previous surfaces before changes.

- [x] Create the expansion pass: approximately 240 by 272 stud footprints, broad flat southern arrival meadow, distinct hills/terraces/valleys, half-stud stairs at route crossings, spread landscaping.
- [x] Author six 40 by 32 stud clearance regions in two rows; keep them invisible, with no marked pads. Keep props outside the six ship envelopes; small scenery occupies the gaps and perimeter.
- [x] Update egg placement to reject these regions; retain eight placeholder eggs and existing refill behavior.
- [x] Apply live, inspect geometry and screenshots where available, update installer and documentation.

## Evidence

- Applied to all six islands in the open place. Each has 217 ground cells, 60–128 half-stud stair treads, 24 spawn zones, and six ship envelopes.
- Screenshots rendered again; inspected every biome. Clipped the meadow's front corners and added vegetation in the gaps and along its perimeter after the first view looked too bare.
- Live geometry inspection: six supported, unobstructed ship spaces per island; all globe/surface/arrival links intact. Bounding footprints approximately 240.08 by 272.08 studs.
- Play observation: eight placeholder eggs on each island, zero eggs inside the ship envelopes. No rarity data or travel behavior added.
- Installer regenerated. Earlier surfaces and the first expansion draft archived in ServerStorage. No tests added or run; no publishing.

**Review focus:** Orbital links and arrival anchor survive; no prop scaling; no overlapping coplanar floors; six ship envelopes fully supported and unobstructed; stairs connect different heights; egg zones cover terrain at the new elevations.
- Independent source review: one Important terrain-edge planting finding fixed. Cluster footprints now fit inside single terrain cells; small existing props clamped by conservative footprint radius. Live reapplication preserves all 36 unobstructed ship spaces and links. Installer includes final expansion and egg service sources exactly.
