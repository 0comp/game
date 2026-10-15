# Six-player Home Island Implementation Plan

**Goal:** fix the protruding floor geometry and rebuild a normal-avatar-scale home with six plots around the public launch area.

**Architecture:** build geometry in `HomeIsland.luau`, keeping the existing navigation-console path; a separate `PlotService.server.luau` assigns and releases session ownership. Regenerate `InstallMap.luau` from the editable sources. Preserve the prior hub in ServerStorage.

**Tech stack:** Roblox Studio, Luau, native Parts/Wedges/SurfaceGuis, existing star-chart modules.

**Spec:** `docs/superpowers/specs/2026-10-13-starfall-art-audio-feel-design.md`, plus the user's six-plot sketch and scale/geometry corrections.

User-approved layout reference: six player plots surround a public launch area, with two shops flanking the launch pad. Use the existing full-game art brief and current open Studio place. Work locally; do not publish.

## Scope and scale

- Replace the oversized station hub with a grassy floating home island and six inward-facing plots around its public center.
- Each plot has a personal ship display, pet garden, clear entrance and dedicated spawn. Assign one plot per player and release it on leaving.
- Center: compact public launch pad/ship anchor, navigation console and two avatar-scale robot shops.
- Counters approximately 3 studs high, fences approximately 3, robots approximately 5, ships approximately 14×20, with open paths and comfortably reachable signs.
- Foundation geometry must remain strictly below walking surfaces; no decorative wedges may intrude into the ground.
- Preserve the previous hub and art pass in ServerStorage; retain existing outer-space scenery and star-chart interface as prototypes.

## Tasks

- [x] Diagnose and immediately lower the foundation rocks crossing the current floor. Fix their source bounds as well.
- [x] Build HomeIsland.luau offline in small model batches: central island, six outer plot lobes, connecting walks, launch plaza, shops, plot gardens, ships, trees and fences. Parent completed batches with yields.
- [x] Add PlotService.server.luau for six exclusive ownership slots, player respawns, nameplates and release on leave. Keep the existing navigation-console path for the client.
- [x] Install both in the open Edit session and include them in the standalone installer. Update recovery/readme documentation.
- [x] Inspect avatar-height and overview screenshots in Play. Check structural bounds, all six accessible entrances and the public navigation interaction. Improve any visibly wrong geometry or scale.

This task builds the map and plot assignment. It does not implement flight, pet economy, published server settings or the entire expedition loop. Actual ship/egg gameplay remains the next development scope.

## Verification and review

The original floor fault was traced to nine rotated foundation rocks whose world bounds exceeded the 30.4-stud deck height. The old source now clamps rotated bounds below the floor. The new island's decorative cliff fragments top out below Y=19 while its lawn is at Y=30.

Observed the actual Studio avatar at 5.325 studs tall; the new counters are roughly 3.15 studs to their top. Single-client Play assigned Plot01 to the correct UserId and selected its respawn. The public navigation prompt opened the chart. Thirty-six terrain samples across all approaches have no missing ground or unexpected heights after stitching small seam tolerances. All six routes return successful non-jumping pathfinding. No application console errors were reported.

Fresh read-only review reported no Important/Critical findings in geometry, ownership/respawns, navigation or the regenerated installer. No unit tests were added or run. Six simultaneous network clients were not exercised; server player-cap configuration is deferred until publishing.
