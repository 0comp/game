# ORBIT Linked Star Systems Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four connected star systems to ORBIT, with discovery resets, new planets, preserved travel progress and permanent upgrades that improve neighboring stars in both directions.

**Architecture:** One Version 3 account record contains four local economy runs, directional upgrade records and shared paid benefits. Pure account operations prepare proposed changes; one guarded account store commits them atomically under the existing lease. The client rebuilds configuration-scoped views when the active system or discovery generation changes.

**Tech Stack:** Roblox Studio MCP, Luau, existing 2D GUI and server Economy, Roblox DataStore UpdateAsync, PowerShell packaging. No new dependencies or experiences.

**Spec:** docs/superpowers/specs/2026-10-13-orbit-star-systems-design.md, approved 2026-10-14.

## Global Constraints

- Existing universe 10770505196 / place 102040393131522; DataStore OrbitEnergyClicker_v1; keys User_<UserId>.
- Sun -> Proxima Centauri -> Alpha Centauri A -> Alpha Centauri B; 13 local worlds per system, 19 producer roles and unchanged base progression values.
- Discovering the next star requires 13 owned worlds in its immediate predecessor and explicit confirmation. Reset all discovered ordinary runs exactly once. Normal travel preserves progress.
- Reset Energy, RunEarned, producers, ordinary Research, worlds, Ascensions, earned Stars, ordinary Ascension upgrades, running expeditions and pending offline Energy. Retain lifetime counters, achievement claims, daily state, discovered stars, interstellar levels, owned Auto Buy and all paid benefits.
- Auto Buy: separately earned at 8 worlds + 500M; retained through discovery, gated until 8 worlds are owned again; standard research only; preserve the preferred toggle while gated.
- Only active systems earn income. Rejoin offline income applies once to the last active run; ordinary travel grants none. Paid boost expiry is absolute and shared.
- Preserve all existing pass/product IDs. No actual Robux spending or real player save edits during verification.
- Keep MaximumCurrency = 1e18, account profile size limit 3800000 encoded characters and the existing receipt-ledger purchase guard at 3500000.
- Existing canvas scaling, six main navigation buttons and compact notification clearance remain. Viewports: 1280x800, 390x844, 375x667, 844x390.
- Develop under releases/ORBIT-Linked-Stars/src, populated from a fresh Studio source capture. Root src, Bakery and the original reusable template are separate baselines.
- Do not publish during implementation. Do not run old Version 2 servers against migrated Version 3 saves. A recovery build must understand and retain Version 3 accounts.
- Repository has no HEAD and .git is read-only. Use source snapshots/checkpoints instead of staging unrelated files or pretending commits were created.

## Review Focus

1. An eligible old save must remain intact on load: eligibility is not discovery. Pin migration and explicit confirmation in Tasks 3 and 7.
2. A committed write followed by response loss must not permit a later stale write or repeated reset. Pin commit resolution and duplicate operations in Tasks 4 and 6.
3. A delayed receipt or click response from a prior star/generation must never inflate the fresh run. Pin root receipt routing and client epoch handling in Tasks 5 and 7.
4. A late asynchronous pass-ownership query must not replace a new account/run or erase purchases. Pin guarded ownership application in Task 6.
5. Visiting several systems must not award inactive income, replay old expedition cargo after discovery or duplicate listeners/music. Pin timer behavior in Task 3 and repeated UI lifecycle checks in Task 7.

## File and responsibility map

All source paths below are relative to releases/ORBIT-Linked-Stars/src. The current baseline is releases/ORBIT-Content-Expansion, but capture Studio again before copying it.

| File | Responsibility |
| --- | --- |
| shared/StarSystemCatalog.luau | Ordered star IDs, adjacency, unique planet definitions and presentation |
| shared/SystemThemeFactory.luau | Pure per-star configuration, preserving Sun defaults |
| shared/StellarUpgradeCatalog.luau | Four directional upgrade tracks and exact costs/effects |
| server/StellarProgression.luau | Costs, valid directional purchases and bounded incoming bonuses |
| server/AccountProfile.luau | Version 3 shape, migration, run projection, reset/travel proposals and snapshots |
| server/AccountStore.luau | Lease/revision checks, idempotent writes and ambiguous-write resolution |
| server/AccountMonetization.luau | Whole-account product grants and receipt routing |
| server/StarAccountRuntime.luau | Operation guard, active ticking, committed-state adoption and ownership refresh |
| server/Economy.luau | Existing local loop plus explicit incoming stellar bonuses |
| server/MonetizationReceiptService.luau | Atomic account receipt delivery through AccountStore |
| server/ClickerServer.server.luau | Roblox lifecycle, remotes, Marketplace and runtime adapters |
| shared/Art.luau, shared/Interface.luau | Configuration-scoped factories and Star Map/upgrade panels |
| client/Effects.luau, client/ClickerClient.client.luau | Per-view theme, control lifecycle and epoch-aware snapshots |
| tools/tests/OrbitStarFixtures.luau | Isolated profiles, clocks and fake stores for this feature |
| tools/VerifyOrbitStarSystems.luau | Deterministic catalog, account, economy and transaction suite |
| tools/VerifyOrbitStarUI.luau | View controls, epoch handling and layout/animation lifecycle |

## Verification convention

Implement the two verifier files as returning JSON with Total, Failures and named Checks. Test modules are loaded fresh in an isolated cloned ClickerKit/server container; fake stores are plain tables. Every failing-test step means execute the saved verifier through Roblox Studio execute_luau against the isolated clone and observe the named assertion fail for the intended missing behavior. Every passing-test step requires Failures = 0 and cleanup of temporary instances. Do not use real DataStore keys or player profiles for these suites.

### Task 1: Capture baseline and define star/upgrade catalogs

**Files:** Create shared/StarSystemCatalog.luau, shared/SystemThemeFactory.luau, shared/StellarUpgradeCatalog.luau, tools/tests/OrbitStarFixtures.luau and tools/VerifyOrbitStarSystems.luau.

**Interfaces:** StarSystemCatalog.Order = {Sun, Proxima, AlphaCentauriA, AlphaCentauriB}; Get(id) -> definition?; Previous(id) -> id?; Next(id) -> id?; AreAdjacent(sourceId,targetId) -> boolean. SystemThemeFactory.Get(id) -> independent theme config. StellarUpgradeCatalog.Get(section,id) -> track?.

- [ ] Capture every current Studio script/remotes and write backups/ORBIT-before-linked-stars/StudioSources.json plus reconstructed native place. If Play is running, read Server sources, then stop normally before applying any changes. Compare with the previous release and preserve any user edits.
- [ ] Populate the working release source folder from that capture. Create the isolated verifier fixture helpers without changing Studio production scripts.
- [ ] Write `catalogs_have_unique_planets_and_matching_balance` assertions: four destinations; 13 worlds each; distinct non-Sun IDs across destinations; original Sun IDs/costs/multipliers unchanged; all producer roles and base balance values match by index. Write `theme_configs_do_not_share_mutable_tables`: changing a Proxima returned config must not affect Sun or another returned config.
- [ ] Run the verifier and confirm the missing catalog/factory checks fail.
- [ ] Implement catalog/factory interfaces. Use IDs Proxima_01..13, AlphaCentauriA_01..13 and AlphaCentauriB_01..13, with these ordered names:
  - Proxima: Ember Haven, Ashmoon, Cinder, Twilight, Crimson Reach, Frostveil, Flarefall, Red Meridian, Glimmer, Nightglass, Corona, Far Lantern, Crown of Night.
  - Alpha A: Dawnshore, Pearlmoon, Azure, Goldhaven, Cloudsea, Halo, Solstice, Skygarden, Luminara, Highwater, Sunspire, Radiant Reach, Daybreak.
  - Alpha B: Amberfall, Basalt, Coppermoon, Saffron, Vesper, Violet Tide, Obsidian, Duskwind, Amethyst, Stormglass, Cinder Crown, Deep Lantern, Last Ember.
  - Preserve Sun art. Use rocky/Mars, Moon, Earth, Gas, Ice, Sun, Void and existing animated Pulsar/Oblivion art in mixed per-star sequences; define individual world colors rather than tinting every world identically. Preserve costs/multipliers from Sun by stage. Palette accents: Proxima RGB(255,132,102), Alpha A RGB(255,213,126), Alpha B RGB(194,154,255).
- [ ] Define Research SignalAmplifier (5 levels, 100M base, x10 cost, +10% target clicks/level), SupplyNetwork (5, 500M, x10, +10% target passive); Ascension StellarLegacy (10, 10 Stars, x1.6, +5% all production), VoyagerStorage (8, 5 Stars, x1.6, +900 offline seconds/level).
- [ ] Run all catalog/factory checks green; save a source checkpoint.

### Task 2: Directional upgrades and incoming economy bonuses

**Files:** Create server/StellarProgression.luau; modify server/Economy.luau; extend the system verifier.

**Interfaces:** StellarProgression.Cost(section,trackId,level) -> integer; Incoming(account,targetId) -> {ClickMultiplier,PassiveMultiplier,ProductionMultiplier,OfflineSeconds}; Purchase(account,sourceId,targetId,section,trackId) -> proposedAccount?, error?. Account records use Systems[id] for wallets and StellarLinks[source][target][section][trackId] for levels. Economy reads bounded bonuses from run.Runtime.StellarBonuses; missing bonuses mean multipliers 1 and seconds 0.

- [ ] Write `directional_purchase_deducts_only_source_wallet`, `neighbors_only_and_caps`, `incoming_bonuses_are_additive_not_recursive`, and `ordinary_autobuy_never_buys_interstellar` using plain account fixtures. Assert SignalAmplifier level 1 costs exactly 100000000; StellarLegacy level 1 costs 10 Stars; SignalAmplifier level 5 cannot be bought again; a Sun -> Alpha B request changes nothing.
- [ ] Write exact bonus assertions: one SignalAmplifier level gives target ClickMultiplier 1.1, one StellarLegacy gives ProductionMultiplier 1.05, one VoyagerStorage gives OfflineSeconds 900. Two incoming sources add levels in each channel; do not multiply source production into target bonuses.
- [ ] Run and observe expected missing behavior failures.
- [ ] Implement pure proposals, track/currency validation and capped cost rounding. Extend existing click/passive/offline formulas once at their common calculation points so expeditions/rewards use the same bonuses without double application. Auto Buy still iterates only ordinary ProgressionCatalog.Research.
- [ ] Run these checks and existing economy/monetization verifiers green; save a checkpoint.

### Task 3: Version 3 account, migration and discovery reset proposals

**Files:** Create server/AccountProfile.luau; extend fixtures/verifier.

**Interfaces:** New(now) -> Account; Normalize(saved,now) -> Account?, error?; Serialize(account,now) -> plain record; Project(account,systemId,now) -> EconomyRun; Snapshot(account,now,saveMode,writable) -> client snapshot; ProposeTravel(account,targetId,now) -> proposed?, error?; ProposeDiscovery(account,targetId,now) -> proposed?, error?. Account fields follow the spec. Add Revision = 0 and LastOperationId? as store metadata; use receipt Effect.Generation for the value of DiscoveryGeneration.

- [ ] Write `legacy_load_preserves_eligible_sun_without_discovery`: a full old Sun save stays active Sun with all its balances and only Sun unlocked; Proxima is eligible but not discovered. Assert all legacy receipt IDs remain and migration is idempotent. Reject unsupported/newer schemas and malformed Version 3 records without producing a replacement save. Treat nil/empty lease-only new records as genuinely new.
- [ ] Write `each_discovery_resets_all_runs_once` for all three discoveries. Assert the complete reset/retention table in the spec field by field. New target starts at zero with its own first planet; prior Auto Buy ownership/preference remains; links and paid fields are unchanged. Duplicate discovery cannot increment generation or reset again.
- [ ] Write `ordinary_travel_preserves_progress`, `local_ascend_preserves_directional_levels`, `inactive_system_never_gets_offline_income`, `expedition_survives_travel_but_not_discovery`, `daily_claims_cannot_be_farmed_by_discovery`, and `owned_autobuy_is_gated_until_eight_worlds_return`.
- [ ] Run and observe expected failures.
- [ ] Implement explicit per-run serialization allowlist stripping shared ledger/ownership/boost fields. Normalize every run with its own theme; preserve root metadata and reject destructive malformed-data recovery. Implement pure travel/discovery proposals; only discovery increments DiscoveryGeneration and clears the specified ordinary fields. Normalize UTC daily state on activation; reset LastSeen to prevent inactive-time earnings. Store Auto Buy preference at the root even while the local engine gate disables operation.
- [ ] Add eligible/card data and incoming/outgoing upgrade snapshots. Project shared paid state and stellar bonuses into active runs without copying them into serialized local records.
- [ ] Run account/migration/timer/reset suites green and compare original definitions; save a checkpoint.

### Task 4: Atomic account writes and response-loss recovery

**Files:** Create server/AccountStore.luau; extend fake stores and verifier.

**Interfaces:** Commit(store,key,sessionId,baseRevision,proposed,operationId,leaseNow,leaseSeconds) -> status, saved?; Resolve(store,key,sessionId,baseRevision,operationId,rollbackSnapshot,leaseNow,leaseSeconds) -> status, saved?. Statuses: Committed, NotCommitted, Retry, Conflict, Capacity. Serialized metadata: Revision, LastOperationId and transition marker from AccountProfile. Profile limit 3800000 encoded characters; preserve existing ledger purchase guard at 3500000.

- [ ] Write `discovery_commit_is_whole_account`, `lost_lease_or_revision_cannot_write`, `duplicate_operation_is_idempotent`, `write_then_throw_resolves_committed`, and `uncommitted_resolution_invalidates_late_write`. Fake stores must exercise retrying UpdateAsync callbacks and a callback commit followed by a thrown response error.
- [ ] Run and observe failures.
- [ ] Implement Commit: verify live same-session lease; return an already committed matching operation; otherwise require expected Revision, encode/check capacity, increment Revision once and write the complete proposed account with LastOperationId. Never execute gameplay rewards inside retryable callbacks.
- [ ] Implement Resolve under the same lease. A matching marker confirms commit. If the base revision remains, atomically persist the unchanged gameplay rollbackSnapshot with an incremented revision and a cancellation marker, invalidating any delayed original proposal. A later conflicting revision cannot be overwritten. If no authoritative resolution is possible, return Retry/Conflict and keep mutations blocked until rejoin.
- [ ] Run all store failure/idempotency checks green; save a checkpoint.

### Task 5: Shared purchases and receipt generations

**Files:** Create server/AccountMonetization.luau; modify server/MonetizationReceiptService.luau; extend verifier.

**Interfaces:** AccountMonetization.ApplyProduct(account,offer,purchaseId,now,maxCurrency) -> proposed, receipt; ReconcileReceipt(account,receipt) -> account. Receipt service retains a single ProcessReceipt entry path and commits complete account proposals through Task 4. Currency effects carry SystemId and Generation; paid boost effects are global.

- [ ] Write `currency_grant_targets_active_star_at_delivery`, `duplicate_after_travel_or_reset_never_regrants`, `legacy_receipt_belongs_to_sun_generation_zero`, `paid_boost_expiry_is_shared`, `receipt_commit_retains_other_systems_and_links`, and capacity/lease/revision failure tests. Assert exact existing product quantities and durations; receipt IDs remain unique account-wide.
- [ ] Run and observe failures.
- [ ] Reuse existing MonetizationRules for a bounded active-run/root-ledger projection; map results back to the whole account. Persist receipt/effect/account atomically. Reconcile to the recorded star/generation; never resurrect an effect already recorded before a reset. Full wallets/storage defer delivery; never return Granted before durable commit.
- [ ] Run legacy and account receipt suites green; save a checkpoint.

### Task 6: Authoritative runtime and Roblox integration

**Files:** Create server/StarAccountRuntime.luau; modify server/ClickerServer.server.luau; extend verifier using fake store/clock/ownership callbacks.

**Interfaces:** Runtime.new(account,context) -> runtime; Tick(now,dt); Action(kind,id,quantity,now) -> boolean, message?; Transition(kind,targetId,operationId,now) -> status; ApplyOwnership(owned,identityToken) -> boolean; Snapshot(now) -> table; Save(release) -> status. Context supplies Store, UserKey, SessionId, game/lease clocks, save status, writable flag and TransitionsEnabled (default true). Identity token contains the account identity and generation. TransitionsEnabled = false rejects discovery/travel and directional purchases while retaining all account records, ordinary gameplay and schema-aware paid delivery; this is the recovery configuration verified in Task 8.

- [ ] Write `only_active_run_ticks`, `busy_blocks_all_mutations`, `late_ownership_response_cannot_replace_new_run`, `discovery_failure_preserves_source`, and `committed_state_adoption_preserves_runtime_on_normal_save`. Preserve charge/burst and accumulators on an ordinary save; clear them on travel/discovery according to the spec.
- [ ] Run and observe failures.
- [ ] Implement the operation guard around saves, receipts, transitions and directional purchases. Apply late ownership updates through the same guard only to the current account identity; query results must not replace progression. On successful commit adopt the durable fields/revision while retaining valid same-generation runtime state. Resolve ambiguous results before accepting further mutations.
- [ ] Adapt join/load/save/exit/BindToClose to whole accounts. Keep old remotes routed to the active run. Add DiscoverSystem, TravelSystem and StellarResearch/StellarAscension server actions, rejecting forged data. Include system ID/generation in feedback. Gate transitions and directional purchases on Cloud saving and checkout busy state. Do not introduce a second receipt callback.
- [ ] Run integration fixtures for all four systems, repeated save/reload, and queued ownership refresh. Confirm no real player save is touched; save a checkpoint.

### Task 7: Star Map, upgrade tabs and client view lifecycle

**Files:** Modify shared/Art.luau, shared/Interface.luau, client/Effects.luau, client/ClickerClient.client.luau; create tools/VerifyOrbitStarUI.luau.

**Interfaces:** Art.ForConfig(config,catalog) -> art API; Interface.ForConfig(config,catalog,progression) -> UI API; default Sun API stays valid. View exposes StarMapButton, StarCards[id], DiscoveryConfirmation and StellarCards[section][targetId][trackId]. Effects.new(view,config?) -> effect instance; Destroy() cleans its connections and sound. Client has one persistent remote/input listener and a disposable per-view connection group.

- [ ] Write `star_map_shows_current_travel_discover_locked`, `discovery_requires_confirmation`, `new_star_has_its_own_planets`, `stellar_cards_name_source_target_cost_effect`, `stale_epoch_feedback_is_ignored`, `twenty_switches_leave_one_listener_and_music`, and viewport/notification checks. Verify reduced-motion preference survives all switches and discovery resets.
- [ ] Run and observe missing UI/lifecycle failures.
- [ ] Add Star Map through the Worlds header, retaining six main menu buttons. Add distinct Interstellar sections within Research and Ascension, with neighbor selection and manual purchases. Show locked future links and incoming effects. Keep ordinary/interstellar reset copy explicit and label Auto Buy as standard research only.
- [ ] Discovery modal copy must explain that every discovered ordinary run resets, including Energy, producers, ordinary Research/Ascension upgrades, worlds, earned Stars and expeditions. It lists retained interstellar upgrades, Auto Buy ownership and Robux benefits. The confirm button sends only the server-validated target/action; ordinary travel does not open this modal.
- [ ] Refactor helpers into per-config closures without mutating shared themes. Rebuild/dispose views on system ID or generation change, reset interpolation, retain Motion: OFF and filter late feedback. Show active star name and shared paid badge. Mark checkout busy while a purchase dialog is open; shop copy says Energy applies to the active system when delivered.
- [ ] Run UI tests green at all four viewport sizes. Visually inspect every star's first/middle/final planets, map, reset modal and both directional upgrade sections; save a checkpoint.

### Task 8: Full verification, independent review and release package

**Files:** Update tools/BuildOrbitSnapshot.ps1 if hierarchy export needs new modules; create releases/ORBIT-Linked-Stars/README.md and Verification.md; update games/Space/Publishing/description.txt, games/Space/ORBIT.rbxlx, games/Space/Install.luau and current-release pointers only after the new package is verified.

- [ ] Run complete new system/transaction/UI suites and all existing economy, expansion, paid-status, receipt and notification checks against fresh modules. Review each named assertion against the 16 spec acceptance criteria; a green subset is insufficient.
- [ ] Capture current Studio Edit sources after applying the approved working code in bounded batches. Compare every source exactly with the working release. Use isolated GUI/table tests for previews; do not reset the user's real Sun profile. Confirm all temporary test instances and overlays are removed.
- [ ] Request one independent read-only review covering schema migration, reset retention, bidirectional bonus arithmetic, receipt routing, ambiguous writes and client lifecycle. Fix blocking/important findings, rerun the affected suite and whole suite, and record any remaining minor findings.
- [ ] Build native place, existing-ORBIT installer and ZIP from the current source manifest, including all new modules. Verify all source and embedded scripts match; verify globals/paid IDs/namespace and account limits. Update local listing copy and reset/permanence descriptions accurately.
- [ ] Document the Version 3 recovery constraint: never restore the old Version 2-only server against migrated accounts. Preserve a Version 3-compatible recovery mode/build that disables transitions but keeps all saves and paid delivery schema-aware. Verification includes loading an account with all four runs while transitions are disabled.
- [ ] Deliver the package and evidence. State that source/isolated test completion is not publication or live paid-delivery verification. Publish only through an authorized supported release path; no Play-runtime publishing workaround.

## Plan self-review and handoff

Coverage mapping: spec criteria 1-5 -> Tasks 1/3/4/6; 6-9 -> Tasks 2/3/7; 10 -> Tasks 3/6; 11-12 -> Tasks 5/6; 13 -> Tasks 4/6; 14 -> Task 7; 15-16 -> Task 8. Each Review Focus line has a named test in its owning task. Tasks share exact interfaces listed above; test files and fake stores are development artifacts, not published runtime scripts.

Recommended execution: Native, with the same implementer carrying account/schema interfaces through dependent tasks and one independent review before delivery. Subagent-driven execution remains an option if the user explicitly chooses it. Implementation begins only after the user reviews this plan and selects the execution method, as required by the brainstorming/writing-plans workflow.
