# Publishing ORBIT and CRUMBLE

Each folder is a separate game package with a native place, standalone installer, listing images, description and suggested settings.

## Upload each game

1. Open Space/ORBIT.rbxlx in Roblox Studio.
2. Use File > Publish to Roblox. If Studio offers an existing destination, use Publish to Roblox As and create a new experience.
3. Use the title and description in Space/Publishing. Select Computer, Phone and Tablet.
4. Keep the first upload private. In the Creator Dashboard, configure the game's start place with a maximum of 12 players.
5. Upload Publishing/icon.png (512x512) and Publishing/thumbnail.png (1920x1080). The listing art is original and matches the game's 2D style.
6. Repeat for Bakery/CRUMBLE.rbxlx as another new experience, using its own Publishing folder.

Settings JSON files document choices; they do not change Creator Dashboard settings automatically.

## Saving before release

Both games use server-side DataStores, periodic saves, exit saves and session ownership. A published server refuses to start a player with a fresh profile if saved progress cannot be loaded. Studio can still preview with temporary progress when API access is unavailable.

Saving interruptions produce a player notification and are retried by the regular save loop. Restored saving is also announced.

Cloud persistence has not been verified from this workspace. Before opening the game to players, join the published experience, earn currency, buy a producer, leave, and rejoin. Confirm the balance, ownership, worlds and permanent upgrades return correctly. Repeat after a rebirth and an expedition.

Studio API access is needed only for DataStore access from Studio. Prefer a separate published test experience when enabling Studio API access, since Studio and live servers use the experience's same DataStores.

## Public availability

Complete the content maturity and compliance questionnaire using the current game's actual content. Current ORBIT has Robux passes for production, automatic clicking and cosmetics, plus developer products for Energy and timed boosts. Review its current content and dashboard configuration when completing the questionnaire. CRUMBLE is a separate package; verify its own configuration separately.

Meet the publishing requirements shown for your account and selected audience. Then change Audience to Public in the Creator Dashboard. The build does not answer identity, age, payment or account questions on your behalf.

For the existing ORBIT game, use the current Studio project and File > Publish to Roblox, targeting universe 10770505196 / place 102040393131522. Keep OrbitEnergyClicker_v1 and existing save IDs. The current source package is releases/ORBIT-Content-Expansion; games/Space/ORBIT.rbxlx also contains the content expansion. Earlier dated release packages and the original ZIP are older versions. Do not create a new experience for an update. Local settings and artwork files do not automatically change the Creator Dashboard.

## Official references

- Publishing and audience requirements: https://create.roblox.com/docs/production/publishing/publish-games-and-places
- DataStores and Studio access: https://create.roblox.com/docs/cloud-services/data-stores
- Icons: https://create.roblox.com/docs/production/publishing/experience-icons
- Thumbnails: https://create.roblox.com/docs/production/publishing/thumbnails
