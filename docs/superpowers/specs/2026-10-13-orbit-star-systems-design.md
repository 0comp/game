# ORBIT: linked star systems and discovery resets

Status: revised written design approved by the user on 2026-10-14. The user's discovery-reset and cross-system upgrade requirements supersede the earlier independent-save proposal. Product implementation has not started; implementation-plan review is next.

## Intent and confirmed requirements

The player wants one ORBIT game with discoverable stars and an almost identical game loop at each star. The latest user instructions require:

- The current Sun run also resets when a new star is discovered.
- Each new star has its own new planets.
- Discovery opens new upgrades within both Research and Ascension, allowing the previous star to improve the new star and the new star to improve the previous one and, after further discovery, the next one.
- Normal progression resets only on discovery. Later travel between discovered stars preserves each star's current progress.

Retain the previously agreed destination order: Sun, Proxima Centauri, Alpha Centauri A, Alpha Centauri B. Existing saves first migrate intact into Sun; migration itself never triggers a reset.

The user approved this revised written design, including the detailed reset contract, retained upgrades and initial upgrade balance below, on 2026-10-14.

This is an architectural change spanning discovery resets, interconnected upgrades, persistence, atomic receipts, server state and client themes.

## Current baseline

ORBIT universe 10770505196, place 102040393131522. Current release: releases/ORBIT-Content-Expansion. Current content: 13 worlds, 19 producers, 9 expeditions, 30 achievements and 6 daily goals.

The save namespace is OrbitEnergyClicker_v1, with keys User_<UserId>, schema Version 2 and a root session lease. Economy exposes New, Normalize, Serialize, Action, Tick and Snapshot for one run. ClickerServer owns authoritative profiles and saving. Developer product commits use UpdateAsync, a root ProcessedReceipts ledger and session ownership. Interface, Art and Effects currently capture a single theme at module load.

The root template and Bakery package are separate baselines; this change targets ORBIT. At design inspection the connected ORBIT Studio instance was in Play mode. No gameplay code or player save was modified during design work.

## Architecture choice

Three approaches were considered:

1. **One account record containing independent system saves — selected.** One existing place, one account lease and one receipt ledger. Travel commits the complete account atomically. The four bounded runs add modest profile size and preserve the existing experience and ownership model.
2. **Separate DataStore keys per system.** Smaller individual records, but travel, discovery and paid delivery span multiple keys without a cross-key transaction. This makes partial failures and migration harder.
3. **Separate Roblox places per system.** Allows different maps, but adds teleport/load behavior and cross-server coordination to a deliberately almost-identical 2D loop.

Use the first approach. Do not create new experiences, teleports, Robux offers or a new save namespace.

## Player flow

### Discovery and reset

Sun starts discovered. Owning all 13 local worlds makes its immediate successor eligible for discovery. The player must choose DISCOVER and accept a clear reset summary; meeting the requirement or loading an eligible old save never automatically resets anything.

Discovering Proxima resets Sun's ordinary run and starts Proxima fresh. Discovering Alpha Centauri A resets ordinary runs in all discovered stars, including Sun and Proxima, and starts Alpha A fresh. Alpha B follows the same rule. Later travel never repeats the discovery reset. Discovery costs no additional Energy or Robux.

Approved reset contract:

| Reset on discovery in every discovered star | Retained |
| --- | --- |
| Spendable Energy and RunEarned | Discovered stars and permanent directional upgrade links |
| Producers and ordinary Research levels | Purchased interstellar Research and interstellar Ascension upgrades |
| Owned worlds and selected world: back to the first planet | Per-system purchased Auto Buy unlock and preferred toggle |
| Ascensions, earned Stars and ordinary Ascension upgrades | All Robux pass ownership, cosmetics, receipt history and paid boost expiry |
| Running expedition and its unclaimed cargo; runtime burst/charge | One-time achievement claim flags and lifetime counters |
| Pending offline Energy bonus and offline earning baseline | Daily claim state and progress, with the normal UTC day rollover |

A newly discovered star has no Auto Buy unlock, earned upgrades, currency, achievement history or local progress. Prior stars keep an already purchased Auto Buy unlock, but it operates only after that run again owns 8 worlds. The saved toggle preference is retained while gated; do not charge 500M again for a retained unlock.

All reset Energy includes unspent developer-product Energy in that wallet. The discovery confirmation explicitly names balances, ordinary Ascension upgrades and active expeditions that will be cleared. It also names the interstellar upgrades and purchased account benefits that remain. The action is voluntary and cannot run silently.

One-time achievement claims and daily state are retained to prevent repeated discovery farming. Lifetime counters remain per star; they do not flow to another star. No pre-reset offline production or expired expedition reward can be applied to a newly reset run.

Completing Alpha B shows that all four destinations are discovered. Do not add an extra reset button or fifth destination in this release. Keep existing free-choice local world unlock semantics.

### Star Map

Add a Star Map button in the Worlds panel header and compact Worlds tab equivalent. It opens a full activity panel with Back, retaining the existing six main navigation buttons and responsive canvas scale.

Show four scrollable destination cards with illustration, name, discovery state, local planets owned out of 13, and a clear action:

- Current destination: CURRENT.
- Discovered destination: TRAVEL, preserving its post-discovery progress.
- Eligible next destination: DISCOVER, opening the reset confirmation.
- Ineligible destination: LOCKED, showing the preceding star's planet requirement.

During a discovery or travel commit show a busy state and prevent duplicate actions. A failed confirmed commit leaves the current progression intact. Normal travel requires no reset confirmation because it preserves progression.

Always show the active star name. Use 'Star system' for destinations and 'Ascend Stars' where needed for the existing spendable Stars currency.

### Same loop, new planets

Keep 13 local planets per star and the same 19 producer roles, basic prices, production values, world multiplier sequence, ordinary research, missions, daily goals and Ascend rules. Cross-system bonuses described below are the intentional extension to this otherwise nearly identical loop.

Sun keeps its existing planet IDs, names and art. Each new star receives 13 distinct planet IDs and names, its own palette and a designed sequence of art appearances. These are actual destination-specific planet definitions, not Sun planets shown under a different star label. Maintain explicit index-based mapping for shared cost and unlock formulas.

Proxima's worlds use red-dwarf frontiers with ember, rocky, twilight and ice appearances; Alpha A uses golden light, oceans, clouds and ringed worlds; Alpha B uses amber skies, volcanic, violet and dark outer worlds. Use code-drawn art and existing animated phenomena where appropriate. The extra planets are fictional game worlds, not claims about known exoplanets.

Catalog-driven themes share economy code. Do not add ship crafting, another currency, paid offers or separate experiences.

### Directional interstellar upgrades

Discovery permanently opens a link between neighboring stars. Both directions can be upgraded independently: Sun -> Proxima and Proxima -> Sun; later Proxima -> Alpha A and Alpha A -> Proxima; then Alpha A <-> Alpha B.

In each star's existing Research page, add an INTERSTELLAR RESEARCH section. Spend that star's Energy to boost a discovered adjacent star. In its Ascension page, add an INTERSTELLAR ASCENSION section. Spend that star's earned Stars for stronger lasting support of a discovered adjacent star. Cards clearly name the source, beneficiary, current level, next effect and cost.

Approved initial tracks for each directed link:

| Section | Track | Effect on target | Levels | Base cost / growth |
| --- | --- | --- | --- | --- |
| Research | Signal amplifier | +10% click production per level | 5 | 100M Energy / x10 |
| Research | Supply network | +10% passive production per level | 5 | 500M Energy / x10 |
| Ascension | Stellar legacy | +5% click and passive production per level | 10 | 10 Stars / x1.6 |
| Ascension | Voyager storage | +15 minutes offline capacity per level | 8 | 5 Stars / x1.6 |

Incoming research bonuses add within their click or passive channel. Incoming Stellar Legacy levels add into their shared all-production channel. Multiply these channels into the target's existing production calculation; they do not modify base costs or create bonuses from source output. Offline capacity adds to the target's existing capacity. Thus upgrading two neighboring stars cannot cause a recursive production feedback loop.

Interstellar levels are account-persistent directional records, even though the source star pays for them. They survive ordinary Ascend, discovery resets, travel and rejoin. This is distinct from ordinary Research and ordinary Ascension upgrades. Label the distinction explicitly in both tabs.

An undiscovered neighbor is shown locked; it cannot receive upgrades until discovery opens the link. A middle star can select its previous or next discovered neighbor. The four-star chain has no upgrade route to an arbitrary unrelated star.

Auto Buy keeps its existing ordinary-research catalog loop. Interstellar upgrades are manual purchases because the player selects which star benefits. Update its helper copy to state 'standard research' and avoid implying it buys directional upgrades.

## Persistence model

Keep OrbitEnergyClicker_v1 and User_<UserId>. Introduce schema Version 3:

```text
Account
  Version = 3
  ActiveSystemId
  UnlockedSystems { systemId: true }
  DiscoveryGeneration
  StellarLinks { sourceId: { targetId: { Research, Ascension } } }
  AutoBuyOwnership { systemId: { Owned, PreferredEnabled } }
  Systems { systemId: serialized local run }
  OwnedPasses
  EquippedCosmetic
  PaidBoostEndsAt
  ProcessedReceipts
  LastTransition { Id, Kind, FromSystemId, ToSystemId, Generation } (when needed)
  _Session { Id, ExpiresAt }
```

The root account is the single owner of shared entitlements, boost expiry, directional interstellar upgrades, retained Auto Buy ownership and receipt history. System records contain only progression fields, not duplicate account ledgers or ownership caches.

| Per-system fields | Shared fields |
| --- | --- |
| Currency, LifetimeCurrency, RunEarned | Pass ownership cache; Roblox remains authoritative |
| TotalClicks, LifetimePurchases, TotalExpeditions | Equipped owned cosmetic |
| Upgrades, ordinary Research and ordinary Permanent levels | PaidBoostEndsAt, StellarLinks, AutoBuyOwnership |
| Prestiges, Stars, ClaimedAchievements | ProcessedReceipts, discovered systems, active system |
| UnlockedZones, CurrentZone | Account lease, discovery generation and transition marker |
| Daily, Expedition, LastSeen, PendingOfflineDoubleProductionBonus | |

Keep runtime charge, active burst, notices and accumulators outside serialized system records as today. Runtime shared fields can be projected onto the active economy run for existing calculations, but serialization must explicitly strip them from the stored run and keep the account root authoritative.

### Migration

Recognize the legacy flat Version 2 save and normalize its progression into Systems.Sun. Preserve all current valid progression values and IDs, daily claim flags, an existing expedition and any pending offline Double Production bonus. Move the original shared fields to the root. Set ActiveSystemId to Sun and discover only Sun. If Sun already owns all 13 worlds, mark Proxima eligible in the snapshot without discovering it or resetting the save. Extract an existing Auto Buy purchase and toggle into Sun's retained ownership record; initialize StellarLinks empty and DiscoveryGeneration to zero.

Keep every valid receipt entry and purchase ID. Legacy currency receipts without a system identifier belong to Sun generation zero; annotate their effects with SystemId = Sun and Generation = 0 without regranting anything. Paid boost receipts remain global. Preserve the existing absolute boost expiry; migration neither restarts nor extends it.

Normalization and migration are idempotent. Never migrate a Version 3 account as though it were an empty legacy profile. Reject an unsupported newer schema and fail closed rather than saving an empty replacement. Validate known system IDs and bounds; reject malformed Version 3 structures that would require dropping an existing run or ledger. A genuinely new player is distinct from an existing malformed profile.

Migration is saved only after obtaining the account lease and through the normal checked UpdateAsync path. Back up current Studio sources and reconstructed place before implementation. Do not modify a real player's save to test migration.

### Inactive systems and timers

Only the active run receives Tick, Auto Tap, Auto Buy and click actions. On departure serialize it at the departure time. Returning does not award offline production for time spent playing another star. At account rejoin, apply existing offline income only to the last active run, once.

Between discoveries an expedition continues toward its absolute arrival time while its system is inactive and can be collected once on return. Discovery cancels active expeditions in every reset run; it never preserves pre-reset cargo for a fresh wallet. Local daily goals use the existing midnight UTC boundary and are normalized on activation. Runtime burst charge and transient effects reset on travel. Shared paid boost time continues to count down in real time regardless of destination or whether the player is online.

## Server boundaries

Add a shared StarSystemCatalog with distinct planet definitions, SystemThemeFactory, and StellarUpgradeCatalog. Add server AccountProfile and StellarProgression modules to own Version 3 normalization, migration, run serialization, discovery/reset proposals, directional purchases, incoming bonuses and snapshots. Keep Economy as the pure local-run engine, with explicit bounded incoming-bonus inputs and the shared base balance catalogs.

Profiles[player] becomes an account runtime containing the authoritative account, active run and selected Economy instance. Session ownership and save status apply to the whole account. Leaderstats display active-run Energy and Ascensions.

Reuse RequestAction with TravelSystem and DiscoverSystem actions whose only destination argument is a known system ID. Directional upgrade requests carry only validated target ID, track ID and section. The server determines eligibility, progress, fresh-run contents, ownership and save effects. A client never supplies a wallet, system record, unlock flag or currency grant.

Serialize account mutations with a per-player operation guard covering travel, discovery resets, directional purchases, periodic/exit saves and receipt commits. While a travel or receipt transaction is in flight, block further mutations to prevent a snapshot from overwriting an intervening click or purchase. Do not yield inside the locked mutation path except the intended persistence operation and its bounded resolution.

### Atomic travel and discovery

1. Require a loaded writable Cloud account and no conflicting operation. Validate a discovered travel target or the immediate eligible discovery target.
2. Tick and serialize the source run up to the operation time. Clone the account. For ordinary travel, activate the target without resetting any run.
3. For confirmed discovery, create the new system fresh, reset all existing ordinary runs according to the contract, preserve retained fields, increment DiscoveryGeneration, discover the target and open its bidirectional neighbor link. Set the new star active.
4. Commit the entire account through checked UpdateAsync under the same live lease and revision. Store one unique LastTransition ID and generation. The new unlock, all resets, retained upgrade links and active-star choice must become durable together.
5. Only after confirmed success replace runtime state and send the new snapshot. On confirmed failure keep the original progression.
6. Resolve an ambiguous write using the same transition ID and an authoritative guarded operation. Do not resume mutations against a possibly obsolete account. If resolution is unavailable, require rejoin instead of overwriting either version.

Directional purchases validate the source as the server's active star, both destination discovery and adjacency, the track, cap and exact source-wallet cost. Apply deduction and persistent link upgrade together under the operation guard; refresh target bonuses immediately when that target is active. Never accept client-supplied levels, costs or effects.

Travel, discovery and interstellar purchases are unavailable for temporary or disconnected-save profiles. UI explains the saving requirement. Pure proposals and fake-store tests exercise these actions without changing real player saves.

## Paid benefits and receipts

All five existing pass IDs and five developer product IDs remain unchanged. Double Production, Auto Tap and equipped cosmetics apply in whichever system is active. Pass ownership must not be purchased separately per system. Paid x2 time is one global expiry and stacks with the permanent pass and local Overdrive exactly as today.

Developer product Energy applies to the system active when the receipt is first successfully granted. State this in the Energy section of the shop. Travel and discovery are blocked while the purchase dialog is open and while a receipt commit is actually in flight; a delayed delivery after rejoin still follows the stated active-at-delivery rule.

AccountProfile's product adapter can reuse the existing pure MonetizationRules against a projection of the active run with the root receipt ledger and shared boost expiry. Return an updated account whose currency grant changes only the targeted system. Add SystemId and DiscoveryGeneration to currency receipt effects before persisting them to the root ledger. PaidBoost effects remain global.

Commit the account, effect and root receipt ledger together under the existing session lease. Reconciliation uses the recorded SystemId and generation, and duplicates never grant into another system or into a later reset generation. Never resurrect a pre-reset currency effect that is already durably recorded in the root ledger. Legacy currency effects route to Sun. Preserve existing deferral when the wallet has insufficient capacity and the existing profile/ledger size limits; never report PurchaseGranted before durable commit.

## Client structure and appearance

Client theme selection comes from the server's ActiveSystemId, not local preference. Refactor Interface and Art to create configuration-scoped factories, retaining default Sun APIs for existing preview/test callers. Effects receives or derives the view's configuration instead of capturing one immutable module-level theme. Avoid mutating shared ThemeConfig tables; different players may be in different systems on the same server.

When the authoritative system or discovery generation changes, destroy the old Effects instance, GUI-specific event connections and sounds, build one new view with the target configuration, rebind controls and render the snapshot. Keep the remote listener and input listener singular. Preserve the user's reduced-motion preference through travel, and continue to show the shared paid multiplier badge.

Snapshots include active star identity, discovery generation, server-computed eligibility/card data, directional upgrade sections, incoming bonuses and local progression. If feedback from the previous system arrives late, ignore it using the system identity and discovery generation attached to click feedback. Reset client currency interpolation and previous-state comparison on system changes so old balances, rewards and celebrations do not bleed into a new run.

Maintain current canvas scaling, scrolling, desktop layout and compact notification clearance. The Star Map must work at 1280x800, 390x844, 375x667 and 844x390.

## Verification and acceptance criteria

Implementation must include isolated checks before any publication:

1. Migrate a legacy Sun profile intact, including all local progress, paid benefits, receipt IDs and Auto Buy ownership. Migration is idempotent and never discovers/reset stars automatically.
2. Validate four destinations with distinct planet IDs/names, 13 stages each and matching base economy values by stage.
3. Verify eligibility requires all 13 worlds in the immediate predecessor. Unknown, locked or out-of-order discovery requests cannot change any save.
4. Discover Proxima, Alpha A and Alpha B. For each, verify all specified ordinary fields reset in every discovered run, the new star starts fresh, retained fields and directional links remain, and the reset occurs once per discovery.
5. Switch repeatedly between discovered stars and serialize/reload. Preserve post-discovery local progress; never reset on normal travel.
6. Purchase every interstellar Research and Ascension track using source-star wallets. Enforce adjacency, discovery, cost and level caps; target the correct recipient and reject forged targets, amounts and levels.
7. Verify incoming click/passive multipliers and offline capacity, additive incoming channels, stacking with ordinary upgrades/paid bonuses, and no recursive source/target feedback.
8. Interstellar upgrades and their exact levels survive local Ascend, each subsequent discovery reset and account reload. Ordinary Research and ordinary Ascension follow the explicit reset contract.
9. Auto Buy remains separately earned at 8 worlds + 500M per star, survives Ascend, preserves an existing purchase/preference through discovery and remains gated until 8 worlds are owned again. It buys only ordinary research, never directional upgrades.
10. Only the active run ticks. Returning grants no away-system offline income; account rejoin grants offline income only to the last active run, once. Test UTC daily rollover, expedition arrival between resets, cancellation on discovery and global boost expiry.
11. Shared pass ownership, cosmetics and paid multipliers survive travel and resets. Root receipt history is neither copied into each run nor discarded.
12. Fake-store tests cover full-account receipts, recorded-star/generation reconciliation, legacy effects, duplicates across travel/reset, wallet/storage limits and lost leases. Never spend real Robux in automated checks.
13. Discovery commits all resets, unlocks and links atomically. Test concurrent saves/actions/receipts, failure before commit, commit followed by response loss, repeat confirmation and resolution by transition ID.
14. UI shows each system's own planets, correct incoming/outgoing upgrade effects, reset warning, discovery eligibility and non-resetting travel at 1280x800, 390x844, 375x667 and 844x390. Repeated switches/resets leave one input listener/view and no stale interpolation or orphaned effects. Motion: OFF remains off.
15. Existing economy, expansion, paid-status, receipt and notification checks remain covered; adapt schema-specific assertions only alongside equivalent Version 3 coverage.
16. Inspect desktop/phone previews; confirm packaged native place, installer and source snapshot match Studio, and state live-save/paid-delivery limitations.

Success is one ORBIT game with fresh ordinary progression on star discovery, unique local planets, preserved progress between discoveries and meaningful two-way Research/Ascension links. A plain separate-save selector or a cosmetic-only star rename would not satisfy the revised request. Publication is a later release action.

## Release and recovery

Create a new versioned release package and pre-change backup. Update local listing copy to explain discovery resets, distinct planets, persistent directional upgrades, non-resetting travel, shared paid benefits and per-system Auto Buy. Update ordinary Ascension copy to distinguish 'survives Ascend' from discovery-reset retention. Leave Bakery and the original reusable template untouched.

Version 3 is a real save-format change: do not republish the old Version 2-only server after migration, because it could interpret the account as a new empty run. Release notes must identify this constraint. A recovery build must understand Version 3 and retain all system records even if its travel UI is disabled. Do not implement a destructive down-migration or tell the user that restoring the old place alone is a safe rollback.

## Design review checkpoint

No product implementation is authorized by this document's existence. After the user reviews and approves this written design, create the implementation plan using the writing-plans skill and present that plan and its execution choice for review. The repository currently has no HEAD commit, and this environment gives read-only access to .git; this design is saved as a workspace document without staging unrelated files or creating a commit.
