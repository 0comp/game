# Starfall Salvagers Sector Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `StarfallMap` child place with a compact 3D orbital station and a responsive six-sector star chart.

**Architecture:** Keep the current start place intact and add a new place under the same experience. Build the hub and sector diorama in Workspace; store sector display data in one shared ModuleScript; open a ScreenGui from a proximity prompt at the navigation console. This milestone previews sectors but does not teleport, roll loot, or alter player economy.

**Tech Stack:** Roblox Studio, Luau, anchored Parts/MeshParts, ProximityPrompt, ScreenGui, ModuleScript.

**Spec:** [Starfall Salvagers Sector Map Design](../specs/2026-10-13-starfall-sector-map-design.md)

## Global Constraints

- Preserve the current start place and existing player data.
- The current Studio `Place1` is unpublished (`PlaceId = 0`, `UniverseId = 0`); attaching a child place requires an experience to be created or published first.
- Keep the first milestone limited to the map and sector preview; no RNG, rewards, persistence, or cross-place teleporting.
- Make the map usable on desktop, mobile, and gamepad.

## Review Focus

- A small mobile viewport still shows the selected sector details and usable controls.
- Locked and available sectors are distinguishable through text/icon state as well as color.
- Closing the chart restores movement and input to the player.
- Unknown sector IDs fail safely and do not break the chart.
- Building the new place leaves the existing start place intact.

---

### Task 1: Establish the child place

**Files / Studio objects:** Roblox experience place list; new place `StarfallMap`.

**Interfaces:** No code dependency. Future tasks target the new place only.

- [ ] Confirm the intended owner and parent experience for the currently open `Place1`.
- [ ] Create or publish the parent experience if required; Studio currently reports zero place and universe IDs.
- [ ] Add a child place named `StarfallMap` under that same experience, leaving the existing start place unchanged.
- [ ] Set the new place's spawn and save it as the map-development target.

### Task 2: Block out the 3D hub and star-chart diorama

**Studio objects:** `Workspace.StarfallMap`, `Hub`, `StationPlatform`, `NavigationConsole`, `SectorDiorama`, and `Routes`.

**Interfaces:** Builds the physical stage used by the map UI in Task 4.

- [ ] Create a central station platform with a clear spawn area, navigation console, and room for future upgrade/salvage stations.
- [ ] Place six small sector dioramas around the station in two expanding rings: Scrap Belt, Ice Graveyard, Derelict Field, Nebula Current, Ancient Ruins, and Singularity Edge.
- [ ] Connect the sector markers to the station with anchored, non-collidable route segments; use distinct colors and brighter accents farther out.
- [ ] Add simple planet, asteroid, and station silhouettes using anchored parts; keep walk paths and the console unobstructed.

### Task 3: Define sector presentation data

**Create:** `ReplicatedStorage/StarfallMap/SectorCatalog` (ModuleScript).

**Interface:** Each sector entry supplies `Id`, `Name`, `Distance`, `Risk`, `Theme`, `Color`, `MapPosition`, and initial `Status` for the UI.

- [ ] Add the six sector entries with stable IDs and unique display names.
- [ ] Assign increasing distance and risk tiers from the inner ring to the outer ring.
- [ ] Give each sector a distinct visual theme and map color; include a text/icon status so state is not color-only.
- [ ] Keep all display data in this module so the GUI and diorama use the same sector definitions.

### Task 4: Build and wire the interactive star chart

**Create:** `StarterGui/StarfallMapGui` and its client controller; add a `ProximityPrompt` to `NavigationConsole`.

**Interfaces:** The controller reads `SectorCatalog`; sector node buttons update the selected-sector detail panel. The prompt opens the chart; a close button hides it.

- [ ] Create a full-screen chart panel with a dark starfield background, central station node, six sector nodes, and route lines between them.
- [ ] Add a detail panel showing selected sector name, distance, risk tier, and loot theme.
- [ ] Visually distinguish locked, available, and selected nodes using text/icons, brightness, and color.
- [ ] Connect the console prompt to open the chart and connect the close action to hide it and return control to the hub.
- [ ] Keep sector selection as preview-only; do not grant rewards or teleport in this milestone.

### Task 5: Polish and review the map in Studio

**Studio objects:** Lighting and map decoration in `StarfallMap`; no changes to the current start place.

- [ ] Add a space sky, restrained bloom/atmosphere, and a small number of particles to establish depth without obscuring the route graph.
- [ ] Check the hub from spawn and console viewpoints; make sure the six routes and nodes are easy to read.
- [ ] Inspect the chart at desktop, phone portrait, phone landscape, and gamepad input sizes; adjust layout and selection feedback as needed.
- [ ] Confirm the chart closes cleanly, each of the six nodes shows the correct details, and an unknown sector ID leaves the UI usable.
- [ ] Confirm the existing start place remains the experience entry point and was not altered.
