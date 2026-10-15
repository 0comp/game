# ORBIT: Beyond the Last Light

Content expansion for existing ORBIT, universe 10770505196 / place 102040393131522.

## Added content

- Pulsar: world 12, 120Qa Energy to unlock, x22 world production. Rotating cyan energy jets and a pulsing outer ring.
- Oblivion: world 13, 650Qa Energy to unlock, x28 world production. Moving pink and gold accretion rings around a dark event horizon.
- Sun prism: world 5, 200M base price, +1K Energy/click.
- Causality tap: world 8, 800B base price, +1M Energy/click.
- Pulsar array: world 12, 160Qa base price, +77.76B Energy/second.
- Oblivion engine: world 13, 550Qa base price, +466.56B Energy/second.
- Six expeditions: Ring salvage, Neptune dive, Rift survey, Aurora rescue, Pulsar relay and Last-light voyage. New trips range from 3 minutes to 1 hour and reward Energy that scales with production.
- Twelve achievements for clicks, producers, earnings, worlds, expeditions and Ascensions, with one-time Star rewards.
- Three daily goals: 1,000 clicks, 50 producer purchases and 3 expeditions, with scaling Energy rewards.

Totals: 13 worlds, 19 producers, 9 expeditions, 30 achievements and 6 daily goals. Motion: OFF stops the new world animations.

## Install and publish

The connected ORBIT Studio Edit project already contains these changes. Stop/restart Play to load changed modules. Publish that project using File > Publish to Roblox.

ORBIT.rbxlx is a reconstructed runnable place containing all 16 current gameplay scripts and 7 remotes. It excludes editor/default objects and is not a byte-for-byte Studio save. If opening it separately, explicitly select the existing ORBIT destination when publishing. Do not create a new experience for this update.

Install.luau updates the named scripts in the existing ORBIT experience and refuses another universe. Run the whole file from Studio's Command Bar while Play is stopped. It rebuilds the Edit preview; it does not publish.

Publishing/description.txt contains updated listing copy. It has not been submitted to Roblox automatically.

## Saves and monetization

All existing content definitions and IDs, DataStore name OrbitEnergyClicker_v1, paid offer IDs, prices/benefits, and Auto Buy's 8-world + 500M requirement are unchanged. The new content is added to existing catalogs. Unlocked new worlds and achievement claims persist through Ascend; new producers follow the existing producer reset rule. New daily goals use the existing midnight UTC reset.

This package contains ORBIT's configured paid offer IDs. Replace those IDs and use a distinct DataStore name before adapting it to another game.

The pre-expansion source/native backup is backups/ORBIT-before-content-expansion.

## Verification

- Nine expansion checks passed, including distinct animated art, reduced motion, all UI cards at desktop/phone sizes, costs and unlocks, timed expeditions, duplicate rewards and save/Ascend persistence.
- Twelve existing economy/monetization checks passed.
- Four notification layout checks passed.
- Existing-definition and old-save compatibility check passed.
- Desktop previews of both new worlds and the expanded expedition page were visually inspected.

Verification used isolated in-memory profiles; it did not spend Robux or modify real player saves. Actual live-client saving and paid transaction delivery were not retested in this content update. This update has not been published by the connected tools.
