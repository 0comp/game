# Planet Islands and Egg Spawning Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan inline, with one independent final source review.

**Goal:** Add six explorable themed floating planet islands and spatially random egg spawning, without rarity RNG.

**Architecture:** PlanetIslands.luau authors terrain, props, landing anchors, invisible spawn zones and fixed biome egg templates. EggSpawnService.server.luau uses those zones/templates to maintain a bounded live egg population on the server. Workspace.StarfallMap.Planets holds six orbital destination models; PlanetIslands holds six separate surface scenes in a distant area around X=10000. Each planet links to its island and arrival anchor, and the island links back to the planet.

**Tech Stack:** Roblox Parts/Models, Luau, server-side raycasting and overlap queries, Studio MCP, standalone local installer.

**Spec:** User request in this conversation; gameplay/art source of truth remains docs/superpowers/specs/2026-10-13-starfall-art-audio-feel-design.md.

## Global Constraints

- Work in the existing unpublished Studio place; no publishing.
- Six home plots, open shops and chart-console removal remain intact.
- Visible studs, chunky geometry, avatar-scale vegetation and clear routes.
- Randomness selects positions and rotation only. No rarity, pet rolls, hatching, rewards or drop tables.
- User explicitly selected islands/spawning only; no travel UI or teleport system.
- Latest user clarification: intended travel is flight toward the orbital planet followed by teleportation to its separate surface island. Prepare model links now; arrival/travel behavior remains later work.
- No unit tests requested. Inspect the authored scenes and runtime spawning in Studio.

## Review Focus

- Eggs on terrain edges, obstacles, landing zones or steep/unsupported surfaces must be rejected.
- Expired/deleted eggs refill within the configured cap; models moved out of ActiveEggs must not be destroyed as world spawns.
- Raised terraces must have walkable stairs at avatar scale.
- Existing home, planet IDs and scripts must survive installation/reinstallation without duplicates.
- Fixed biome egg designs must not introduce rarity attributes or outcome RNG.

## Task 1: Six islands and egg templates

**Files:** Create games/StarfallMap/PlanetIslands.luau; update SectorCatalog.luau with matching display names and biome descriptions.

**Produces:** Workspace.StarfallMap.PlanetIslands.[stable sector ID], each containing Terrain, Props, LandingPad, EggSpawnZones and ActiveEggs. Attributes: DisplayName, EggTargetCount=8, EggLifetimeSeconds=180, EggRefillSeconds=6. ServerStorage.StarfallEggTemplates.[ID] supplies one fixed visual template per biome.

- [x] Build Sprout Moon, Rust Crater, Frost Cove, Violet Wilds, Relic Grove and Storm Reach with distinct palettes, outlines, vegetation and landmarks.
- [x] Add landing pads, anchors, nonoverlapping paths and stairs to raised terraces.
- [x] Add seven invisible spawn zones per island, and biome egg templates with ground-level pivots.
- [x] Separate orbital planet models from distant surface scenes and add one-to-one island/arrival links; inspect screenshots and terrain/route bounds.

## Task 2: Server spawning and installer integration

**Files:** Create games/StarfallMap/EggSpawnService.server.luau; modify tools/BuildStarfallInstaller.ps1 and games/StarfallMap/README.md.

**Consumes:** Task 1 hierarchy and templates. **Produces:** At most eight world eggs per island, spatially randomized after ground, support, clearance and separation checks.

- [x] Spawn initial eggs, track expiry and refill removed/expired eggs at the configured interval.
- [x] Reject obstructed, unsupported, edge-adjacent and landing-area candidates.
- [x] Archive any earlier matching server script before installing the new one; embed both new sources in the standalone installer.
- [x] Observe live eggs, inspect locations, remove one world egg and observe refill, inspect runtime output.
- [x] Request read-only source review, record results, regenerate installer and leave Studio in Edit.

Review fix: earlier egg templates now move into the builder backup before replacement, preserving the documented reinstall flow. Final source audit includes diagonal support samples and a 4.2-stud clearance box covering the rotated nest.

QA: initial/final populations 8×6, deletion/refill at a different location observed, all three raised terraces reached by the actual avatar, no placement/coplanar-floor issues in scene audits. All six planet/island/arrival links confirmed. Late screenshots became globally gray, including home; user confirmed the actual Studio map remained visible. This is recorded as a screenshot-tool limitation, not a scene failure. Earlier island/player-height screenshots were inspected successfully.
