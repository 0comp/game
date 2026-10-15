# Starfall Salvagers Sector Map Design

## Goal

Add a 3D Starfall Salvagers map as a new place under the Roblox experience currently open in Studio. The map should present a central orbital salvage station and a readable radial star chart that leads players toward increasingly unusual sectors.

## Current Studio State

The connected Studio instance is in Edit mode and contains a default `Place1` with a baseplate and spawn. Studio reports `PlaceId = 0` and `UniverseId = 0`, so the current place is not yet attached to a published experience. An experience must exist before a child place can be added under it.

## Map Direction

- Keep the current start place intact; create a separate child place named `StarfallMap` for the new 3D game map.
- Build a compact, walkable orbital station hub around a central navigation console.
- The console opens a responsive star-chart GUI. The chart has a central station node and six sector nodes arranged in expanding rings, connected by visible route lines.
- Sectors: Scrap Belt, Ice Graveyard, Derelict Field, Nebula Current, Ancient Ruins, and Singularity Edge.
- Show progression through distance, route color, labels, and locked/available state; do not rely on color alone.
- The first milestone covers the hub, map presentation, and sector selection preview. Probe RNG, loot, travel destinations, and economy are later gameplay work.

## Interaction

Players walk up to the console and use a `ProximityPrompt` to open the star chart. Selecting a sector displays its name, risk tier, distance, and loot theme. Closing the chart returns input to the hub. Sector selection is a visual prototype in this milestone and does not award loot or teleport players.

## Visual Direction

Use a clean, low-poly space style with a bright central station, colored route lines, small sector dioramas, planets, asteroid clusters, and stronger color contrast toward the outer ring. Build with anchored Roblox parts and a small number of MeshParts; keep decoration secondary to route readability and mobile performance.

## Scope Boundary

This design adds one child place and a navigable map prototype. It does not replace the existing start place, create six separate destination places, implement probe RNG, or change the existing game's economy or saved data.
