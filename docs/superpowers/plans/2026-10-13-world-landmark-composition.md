# World Landmark Composition

**Goal:** Improve the six destination designs using recognizable toy-like landmarks, varied hill silhouettes and more deliberate scenery composition.

Evidence at start: the live overhead view shows three similar concentric hills and a large empty arrival area. The previous turn made verified progress by replacing square shorelines, but visual identity remains incomplete.

Constraints: exact supplied palettes, exposed studs, normal-size ordinary props, six unobstructed ship envelopes per world, placeholder eggs, linked arrival anchors. Studio-only debug travel remains gated and excluded from release. No rarity, flight, publishing or tests.

- [x] Vary hill heights and offset upper contours, retaining half-stud access routes.
- [x] Add one clear focal landmark per world: hollow woodland tree, crashed scout ship, ice arch, giant mushroom family, ruined temple gate, storm beacon.
- [x] Add low scenery in the gaps between ship envelopes; keep open takeoff space and walking routes.
- [x] Inspect all six overhead and at player scale, inspect support, colors and runtime eggs; update sources and installer.

## Completion evidence

- Current Studio models contain six unique WorldLandmark attributes, with the corresponding authored models under Props. Inspected close screenshots of all six and overhead views of every world.
- Hills now vary between one, two and three levels, with offsets in their upper contours; lower scenery remains avatar-scale. Cleared nearby old plants from monument entrances.
- Corrected a rendered defect: default CSG collision hulls filled coves during stud-surface generation. All authoring booleans now use PreciseConvexDecomposition. Rebuilt native stud surfaces against those hulls; the Frost screenshot confirms the smooth cove remains open.
- Scene inspection: all 36 ship envelopes have supported sample points and zero prop obstructions; all six globe/surface/arrival links intact. Rust has at most 0.050004 studs of top-skin height variation, other arrival samples agree within 0.000005 studs.
- Exact palette inventory: zero out-of-palette BasePart colors in all six island models. Six home plots and the removed navigation-console state remain intact.
- Play observation: eight placeholder eggs on each world; no rarity attributes or eggs inside ship envelopes. Debug interface and Studio-only remote present.
- Independent source review found no major defects. Installer regenerated with OrganicIslands → WorldLandmarks → IslandStudSkin → WorldPalettes; final source contents checked against the generated installer. No tests added/run, no publishing.

Completion requires current-state evidence for all six designs and preserved constraints. A source review complements rendered inspection; neither replaces it.
