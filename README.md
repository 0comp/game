# Animated 2D Roblox Clicker Template

An entirely 2D, server-authoritative clicker. There are now **two standalone games**: **games/Space/ORBIT.rbxlx** and **games/Bakery/CRUMBLE.rbxlx**. Open either in Roblox Studio and press Play. Each has its own fixed theme, installer and saved progress. See **games/README.md** for publishing them as separate experiences.

Publishing packages with original listing art, descriptions and setup guides are in **releases/**. The Space version is saved as an independent reusable template at **templates/SpaceClicker/SpaceClickerTemplate.rbxlx**, with editable source in the same folder.

## Current ORBIT linked star systems

The current ORBIT build is in **releases/ORBIT-Linked-Stars/**, packaged as **releases/ORBIT-Linked-Stars.zip**. Four connected star systems each have 13 planets and the same 19-producer loop. Discovery resets all ordinary runs; travel preserves progress; permanent directional upgrades improve neighboring stars. See that folder's README and Verification.md for migration, recovery and verification details. **games/Space/ORBIT.rbxlx**, its installer and Rojo project match this build. The reusable template and Bakery package retain their separate baseline content. Use **tools/BuildOrbitLinkedRelease.ps1 -UpdateCurrent** to rebuild ORBIT; the original BuildGames.ps1 builds the older template baselines.

## Original template play loop

Click the target or press Space. Buy your first amplifier, add automated producers, then invest in research and new worlds.

- 20 accepted clicks charge a six-second x3 production boost.
- Moving collectors appear as you buy passive producers.
- A timed bonus appears after 20 seconds, then every 55 seconds; collect it within 10 seconds.
- Twelve producer tiers, eight worlds, and buy-one, buy-ten and buy-max controls.
- Six research tracks improve clicks, production, discounts, expeditions, boosts and offline capacity.
- Three repeatable expeditions take 30 seconds, two minutes and ten minutes. One crew travels at a time; rewards are calculated when launched.
- Sixteen achievements and three daily goals have explicit, duplicate-safe reward claims. Daily goals reset at midnight UTC.
- Rebirth earns 1–100 stars based on run earnings and permanently adds 25% production per rebirth. Spend stars across six permanent upgrade tracks.
- Rebirth resets currency, producers and research; unlocked worlds, stars, permanent upgrades, achievements, daily progress and an active expedition remain.
- Offline producers earn 50% of normal production for up to two hours by default. Research and permanent upgrades extend capacity.
- Animated target, orbit, stars, collectors, click impacts, reward text, smooth counters, travel progress and celebrations. A reduced-motion button is included.

The first run's late worlds are paced for a longer session. An automated simulation with four clicks per second during its first 30 minutes, occasional later clicks, immediate reward claims and a simple purchase strategy reached worlds seven and eight around 55 and 155 minutes. This is a balancing estimate, not a promised player completion time. Rebirth decisions change progression substantially.

## Template customization

The standalone games already select their own theme. The instructions below apply to the reusable root template when creating additional games.

In **ReplicatedStorage > ClickerKit > ThemeConfig**:

```lua
local ACTIVE_THEME = "Space" -- or "Bakery"
```

Stop and restart Play after changing modules. Duplicate an existing theme, name it, then select its name to create another game.

| Change | Location |
| --- | --- |
| Title, currency, colors, copy, producer names and icons | Selected module in ClickerKit.Themes |
| Target image | Theme.TargetImageId or zone.ImageId |
| Built-in illustration | Zone.Art: Earth, Moon, Mars, Gas, Ice, Sun, Void or Cookie |
| World names, unlock costs and multipliers | Selected theme's Zones |
| Producer balance and world requirements | ClickerKit.UpgradeCatalog |
| Research, permanent upgrades, goals, expeditions and timer balance | ClickerKit.ProgressionCatalog |
| Rebirth requirements and production bonus | Selected theme's Prestige |
| Separate player progress between games | Selected theme's DataStoreName |
| Responsive interface / original art | ClickerKit.Interface / Art |
| Motion and visual feedback | StarterPlayerScripts.Effects |

Use transparent uploaded Roblox assets as image overrides, for example `rbxassetid://YOUR_ASSET_ID`. Included art uses UI shapes and requires no uploads. Keep saved IDs stable after launch. Give separate games a distinct DataStoreName.

## Install in another place

1. Open a place in Roblox Studio and stop Play.
2. Paste the entire contents of **tools/InstallTemplate.luau** into the Command Bar and run it.
3. The installer creates the scripts, remotes and a visible StarterGui preview.
4. Press Play. Phones have Collect, Upgrades and Worlds tabs, plus the five main activity pages.

The installer updates the template's named scripts and GUI. It removes the template's obsolete ClickerWorld, WorldBuilder and lighting effects if present. Existing player data is kept in DataStore.

For Rojo, use **default.project.json**. Run **tools/RefreshPreview.luau** in the Command Bar to rebuild the Edit preview after theme changes. Runtime UI always rebuilds from the selected theme.

## Publishing and saving

Publish a copy using Roblox Studio. See [Roblox publishing](https://create.roblox.com/docs/production/publishing/publish-games-and-places).

The server uses session leases, periodic saves and exit saves. Studio can preview with temporary progress. Published servers refuse to start a player session when saved progress cannot be loaded, protecting existing profiles. Saving interruptions and recovery produce notifications.

**Cloud persistence remains unverified:** the connected published place has Studio API access disabled. Gameplay runs with temporary progress in Studio. Serialization, restore, offline caps and retention were checked against the actual economy module.

For a full persistence check, use a separate published test experience with Studio API access enabled, then play, leave and rejoin. Roblox Studio accesses the same data stores as live servers; see [Data stores](https://create.roblox.com/docs/cloud-services/data-stores).

## Verification performed

- Real input: 100 clicks, charged boosts, producer purchase, moving collector, research purchase, expedition launch, early-claim rejection and completed-cargo claim.
- A burst of 100 remote click requests accepted only one request under the server cooldown.
- A live timed bonus awarded 25 cookies; its duplicate claim was rejected with the balance still 25.
- Actual economy checks: invalid IDs, insufficient funds, bulk buys, research limits, duplicate achievements/dailies/expeditions/bonuses, boost expiry integration, daily rollover, save JSON roundtrip, invalid saved numbers, offline cap and repeated rebirth retention.
- Desktop and iPhone 17 Pro portrait/landscape inspected in Play, including both presets and activity layouts.
- All eight world illustrations and rebirth celebration exercised in the live client. Reduced motion stayed still; animation stress stayed within the 70-object particle cap and connections cleaned up after GUI destruction.
- Extended progression simulation used the same economy implementation.

## Source layout

```text
src/shared/
  ThemeConfig, Themes/Space, Themes/Bakery
  UpgradeCatalog, ProgressionCatalog, UIBuilder, Interface, Art
src/server/
  ClickerServer.server, Economy
src/client/
  ClickerClient.client, Effects
tools/
  InstallTemplate, RefreshPreview
```

All reward calculations and purchases run on the server. Clients send actions and display confirmed snapshots. Animation uses a bounded particle budget and a capped update rate.
