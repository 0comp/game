# ORBIT — Linked Stars

Four connected systems in the existing ORBIT game: Sun → Proxima Centauri → Alpha Centauri A → Alpha Centauri B. Each has 13 planets and the familiar 19-producer loop.

All 52 worlds have original, individually defined vector artwork. Each has a fixed palette, surface geometry and landmark recipe; travelling back restores the same design. Worlds-menu thumbnails show the corresponding artwork. Twilight has its own warm terminator, violet highlands and night lights rather than Earth continents. Sun's planets also have their own custom illustrations.

## Playing the update

Open **Star Map** in Worlds. Completing all 13 planets in the preceding system makes the next star eligible. Discovery requires confirmation and resets ordinary progress in every discovered system, including Sun. Ordinary travel preserves progress.

Research and Ascension each have Standard and Interstellar tabs. Interstellar purchases spend the active system's Energy or earned Stars to permanently improve an adjacent star. Returning to a prior star allows upgrades in the other direction. The header names the active system; cards name source and target and summarize incoming bonuses.

Every new star has distinct names and original GUI icons for all 19 producers, plus themed standard Research, Ascension and Interstellar upgrades. Proxima uses furnace machinery, Alpha A uses radiant optical technology, and Alpha B uses violet plasma technology. Returning to Sun restores its original presentation. These are display changes; saved IDs, prices and effects stay the same.

Discovery clears Energy, run earnings, producers, ordinary Research, worlds, Ascensions, earned Stars, ordinary Ascension upgrades, expeditions, pending offline Energy and temporary burst/charge. It keeps lifetime counters, achievement claims, daily state, discovered systems, directional upgrade levels, Auto Buy ownership/preference and all paid benefits. Each system earns Auto Buy separately at 8 worlds + 500M; retained ownership is gated again until 8 worlds return. Auto Buy only purchases standard Research.

Only the active system ticks. Offline income applies once to the last active system when rejoining. Travel creates no inactive-system income. Paid boosts use one global absolute expiry. Currency purchases go to the active system at delivery and record its discovery generation.

## Publishing the existing game

The connected ORBIT Studio Edit sources have been updated. Save the place, then use **File → Publish to Roblox** on the existing ORBIT place (universe 10770505196, place 102040393131522). Update the public description from Publishing/description.txt. Restart existing servers after publishing to prevent old Version 2 servers loading migrated accounts. Publishing was not performed by this task.

The native ORBIT.rbxlx is also included. Opening it as a local file does not identify it as the existing published place: choose the existing ORBIT destination when publishing. Install.luau updates only the existing ORBIT universe and refuses to run during Play. default.project.json points at this release's src folder. Keep the existing DataStore namespace and monetization IDs.

## Recovery

This release stores Version 3 accounts with all runs and one receipt ledger. **Do not restore a Version 2-only server after players have migrated.** The pre-change backup is for source reference, not a safe rollback server after migration.

For a compatible recovery mode, retain all this release's scripts and replace ClickerKit.ThemeConfig with RecoveryThemeConfig.luau. It disables travel, discovery and directional purchases, while retaining all four runs, ordinary active gameplay and schema-aware paid delivery. Publish the existing place. Restore the normal entry module to re-enable stars. The four-system recovery fixture passed with a fake product receipt.

## Verification scope

See Verification.md. Checks used isolated profiles, fake stores and previews; no real player saves were reset and no Robux was spent. Live cloud delivery and live receipt processing were not exercised by this update. Bakery and the reusable template remain their separate baselines.
