# World Palettes

User request: use the six supplied palette screenshots for the worlds, with each world owning one palette. Match the existing planet themes; use exact swatches across each surface, scenery, orbital globe and placeholder egg. Preserve geometry, six-ship clearance, and all gameplay behavior. Home and shared space sky retain their existing art direction.

| World | Image | Exact swatches |
|---|---|---|
| Sprout Moon | 5 | 5BBA6F, 3FA34D, 2A9134, 137547, 0C6038, 054A29 |
| Rust Crater | 3 | CFCFEA, A89B9D, 816C61, 575A4B, 2A2C24 |
| Frost Cove | 2 | 363732, 53D8FB, 66C3FF, DCE1E9, D4AFB9 |
| Violet Wilds | 1 | 420039, 932F6D, E07BE0, DCCCFF, F6F2FF |
| Relic Grove | 4 | 0E7C7B, 17BEBB, D4F4DD, D62246, 4B1D3F |
| Storm Reach | 6 | 0091AD, 6AFEFF, FFF4E4, FFED9C, FF57BB |

The sixth image has no printed hex values; sampled the center of each stripe in the original attachment using System.Drawing. Other palettes use their printed values.

Implementation: `games/StarfallMap/WorldPalettes.luau` is an idempotent recoloring pass after ExpandPlanetIslands. Named roles distinguish floors, terraces, cliffs, vegetation, mechanical parts and accents without blending swatches. Original Color3 values remain in each part's PrePaletteColor attribute. Chart catalog descriptions and colors match the resulting worlds.

Evidence: live Studio color inventory found zero out-of-palette BasePart colors across all six surface/globe/template groups. Inspected screenshots of every world. Standalone installer regenerated with the palette pass and updated catalog. No tests added/run; no publishing.
