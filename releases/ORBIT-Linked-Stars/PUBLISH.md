# Publish the ORBIT Linked Stars update

This package updates the existing ORBIT game: universe **10770505196**, place **102040393131522**. It contains four linked star systems, paid passes/products and Version 3 account saves.

1. Save the updated ORBIT place in Studio and use **File → Publish to Roblox** for the existing destination. If opening the local ORBIT.rbxlx, select the existing ORBIT place when publishing.
2. Update the public description from Publishing/description.txt. Existing icon/thumbnail files are also in Publishing.
3. Restart the game's existing servers after publishing so players receive the new code and old Version 2 servers do not load migrated Version 3 profiles.
4. Join the published game, earn currency, buy an upgrade, leave and rejoin to check live persistence. Check travel and discovery on a suitable test account. Live paid delivery was not exercised by the isolated verification; use the platform's supported purchase checks for the existing ORBIT offers.

Do not change the DataStore namespace or paid offer IDs. Do not replace the game with a new experience if you intend to preserve its listing, passes and player data.

## Recovery

Never restore the old Version 2-only server after accounts migrate. Keep all Linked Stars code and use RecoveryThemeConfig.luau from releases/ORBIT-Linked-Stars to disable transitions and interstellar purchases while preserving Version 3 saves and paid delivery. See that release's README and Verification.md.

## Scope

The source has been applied to Studio Edit and packaged locally. Publishing, public listing changes, live DataStore roundtrips and real purchases have not been performed by this update.
