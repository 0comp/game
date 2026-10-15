# ORBIT monetization metadata review — 2026-10-13

Universe: 10770505196. Place: 102040393131522. Creator: 0o046 (849112694).

## Current Roblox prices

| Offer | Type | Roblox ID | Robux | For sale | Association |
| --- | --- | --- | ---: | --- | --- |
| Double Production | Pass | 2025543255 | 149 | Yes | Confirmed ORBIT Dashboard |
| Auto Tap / Auto Click | Pass | 2028704251 | 199 | Yes | Confirmed ORBIT Dashboard |
| Supporter Orbit | Pass | 2025951241 | 79 | Yes | Confirmed ORBIT Dashboard |
| Nebula Palette | Pass | 2025585272 | 49 | Yes | Confirmed ORBIT Dashboard |
| Aurora Palette | Pass | 2026383217 | 49 | Yes | Confirmed ORBIT Dashboard |
| Energy Cache | Developer product | 3718202097 | 15 | Yes | Confirmed ORBIT |
| Energy Crate | Developer product | 3718202127 | 49 | Yes | Confirmed ORBIT |
| Energy Vault | Developer product | 3718202156 | 99 | Yes | Confirmed ORBIT |
| 15-Minute Boost | Developer product | 3718202184 | 29 | Yes | Confirmed ORBIT |
| 30-Minute Boost | Developer product | 3718202204 | 49 | Yes | Confirmed ORBIT |

All configured IDs resolve. Prices above are the values Roblox returned to this Studio session, not a separately supplied target price list. Developer product UniverseId values all match ORBIT. All five passes match ORBIT's creator and were subsequently confirmed on ORBIT's signed-in Dashboard pass listing.

## Mismatch to correct

Auto Tap's Roblox listing says: "Adds one server-authorized click every second while you play." Its in-game benefit and server rules grant ten clicks per second. The listing should describe ten clicks per second if that is the intended benefit.

Updated through the signed-in ORBIT Creator Dashboard at 21:50 Stockholm time: "Automatically clicks 10 times per second while you play." The current public pass name is Auto Click; it was preserved. The page showed a new Last Updated time and disabled Save Changes after saving. Evidence: auto-click-description-saved.jpg. All five configured pass IDs and prices were also confirmed on ORBIT's own Dashboard pass listing.

## Live purchase availability

The initial Studio shop showed SAVE REQUIRED because that session had temporary progress. A later rejoin showed CLOUD SAVING and available developer product prices. Another restart encountered a profile lease renewed by a different session and returned to temporary mode. See 2026-10-13-update-checks.md. Verify saving and actual transaction delivery in the published Roblox game before release.

Follow-up diagnosis: the server logged that the initial saved-profile load failed. A later read-only GetAsync succeeded and found no active session lease. The original load failure reason was not logged, so it cannot be attributed conclusively to API access or a competing session. This play session retains its original non-writable profile status; rejoining retries profile acquisition. No saved profile was changed during this diagnosis.
