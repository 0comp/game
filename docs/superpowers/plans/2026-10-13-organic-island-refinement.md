# Organic Island Refinement

User request: make the egg-collection surfaces look like actual islands rather than blocky messes. Preserve exact world palettes, normal-size props, six-ship capacity, placeholder eggs and Studio-only debug travel.

- [x] Replace the square grid with fused rounded landforms, asymmetric shore outlines and coves.
- [x] Replace long straight terraces with three local contour hill groups and short access stairs.
- [x] Group vegetation/crystals into six groves and preserve engine, ruin gate and storm collector landmarks.
- [x] Rebuild Sprout's flower-ring nesting clearing after source review identified its omission.
- [x] Smooth the initially scalloped curved trail with more closely spaced fused segments.
- [x] Restore native studs using thin shadow-free top strips, preserving the underlying curved silhouette. CSG did not visually show native SurfaceType studs; a built-in texture loaded but did not produce the desired finish, so it was removed.
- [x] Inspect screenshots overhead and at player scale; inspect every biome, ship support, palette membership and linked anchors.
- [x] Regenerate standalone installer and update source records. No tests added/run, no publishing.

Backups: `ServerStorage.StarfallBeforeOrganicIslands.[ID]` retains the prior terrain, props, spawn zones and first scalloped trail. Existing orbital/surface/arrival references are retained.
