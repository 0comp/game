# ORBIT update checks — 2026-10-13

Target: universe 10770505196 / place 102040393131522.

## Completed

- Preserved pre-check sources, previous local native place and previous ZIP in backups/ORBIT-2026-10-13-release-check.
- Exported all 16 gameplay sources into releases/ORBIT-2026-10-13, with reconstructed runnable native place and listing files. The reconstruction excludes editor/default objects; it is not a byte-for-byte Studio save.
- Ran tools/VerifyOrbitRelease.luau in Studio: 12 checks, zero failures. Covers 8-world/500M unlock, duplicate unlock, research-only buying, limits, pause, Ascend persistence, serialization, paid badges/multipliers, 10-click Auto Tap, duplicate receipts and boost stacking. Test profiles are plain tables; no real DataStore writes or Robux prompts.
- Reproduced mobile toast overlap with tools/VerifyOrbitLayout.luau before fixing it. Updated Interface Layout to reserve room above mobile Play tabs while keeping the desktop bottom-right margin. All four layout checks now pass: 390x844, 844x390, 375x667, 1280x800. Visually checked portrait preview before and after; bottom tabs are now visible. This is a virtual viewport harness, not a physical phone test.
- A Studio cloud rejoin showed CLOUD SAVING and an active owned lease. Saved data retained 8 Ascensions, 7,414 Stars, research and 10 unlocked worlds. Currency increased with normal game/offline production.
- Confirmed all five configured passes on ORBIT's own Creator Dashboard with prices 149/199/79/49/49 Robux.
- Saved public pass 2028704251 description: "Automatically clicks 10 times per second while you play." Current public name Auto Click preserved. Screenshot auto-click-description-saved.jpg.

## Persistence limitation observed

A rapid later Studio restart could not acquire the still-active 180-second session lease and used temporary progress. A read-only lookup confirmed the lock was active. The session was stopped without changing the saved profile. A subsequent read showed the same lease expiry advancing by another 180 seconds while this Studio was stopped, indicating another running session is renewing it. Close other ORBIT sessions before a final Studio rejoin. Do not clear a live lock or overwrite the saved profile to make a preview work. This does not prove live-client leave/rejoin behavior; that remains a manual check.

## Publishing

AssetService SavePlaceAsync from Studio Edit returned an error requiring a server script. The rejected API call did not publish. Never publish the Play runtime to work around this restriction. Publish the current Edit project using Studio File > Publish to Roblox.

Actual paid transaction delivery and a published Roblox client rejoin still require a live client check. No Robux was spent during these checks.
