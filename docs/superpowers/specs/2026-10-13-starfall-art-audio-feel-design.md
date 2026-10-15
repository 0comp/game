# Starfall Salvagers — art, audio and game feel

**Design brief, 13 October 2026.** Working title retained from the existing project.

## 1. Source of truth

Gameplay comes from [the complete game idea](../briefs/2026-10-13-complete-game-idea.txt), supplied by the user after the aesthetic brief. Presentation comes from [the art and feel brief](../briefs/2026-10-13-art-feel-brief.txt), the seven attached screenshots, and [Drop a Fruit](https://www.roblox.com/games/82132121666307/Drop-a-Fruit).

Drop a Fruit's published description emphasizes placing collectibles, earning coins, upgrading a plot and growing a collection. Use that visible sense of progress and the supplied screenshots' visual vocabulary as inspiration. The spaceship expeditions, eggs, hazards and bats follow our own complete game idea.

This is a design proposal for the complete game. The existing purple station in Studio is an earlier map prototype; it does not yet represent this grassy home island or implement this game's full loop. The older six-sector salvage-map specification is historical and does not override the complete game idea.

Visual development: [concept board](../design-assets/starfall-concept-board.png), [generation prompts](../design-assets/concept-board-prompts.md), and [preserved reference screenshots](../design-assets/references/). The rebirth screenshot informs interface styling only; this brief does not add a rebirth mechanic.

### Mechanics this design must preserve

- Prepare → fly out → collect eggs → load the ship → return → hatch → place or sell → upgrade → explore farther.
- Rarity rolls check Cosmic first and then lower rarities sequentially, with Common as fallback.
- Landing starts two independent timers: a short departure lock and a longer visit limit. Leaving is optional once the lock expires.
- Egg stacking is unlimited. Cargo equipment improves efficiently handled **weight**. Excess weight gradually reduces speed and acceleration; a minimum speed preserves movement.
- The specified proposed timeout outcome is automatic departure: loaded eggs leave with the ship, the player is recalled, and an egg still being carried is left behind. Present this outcome clearly; do not turn it into a total-haul loss.
- Hazards remain consistent. Danger ratings describe preparedness of the **equipped ship**, with explanations. Hard planets have no strict level gate.
- Planet competition uses bats and egg-stealing interactions informed by Steal an Egg. Exact swing, recovery and stealing behavior must be checked against the intended reference during development.
- Pets secured at home are safe. Placed pets generate income; selling gives immediate money. Plot space is limited. Selling never removes permanent collection-index progress.
- Planet family milestones advance bat progression. Ship upgrades begin at fixed sockets; free-layout snapping construction is a later expansion.

Art examples, palette values, music tempos and motion suggestions below are presentation proposals. They do not establish prices, timer lengths, drop odds, ship statistics, plot capacity or new rarity tiers.

## 2. Creative direction

**A colorful, brick-built space playground where every return makes your little spaceport feel more yours.**

The emotional rhythm is comfortable preparation, curious exploration, playful competition, an urgent escape, then relief and visible growth. The home island should immediately say "my pets and my ship live here." Space should invite another trip. A heavy stack of eggs should look amusing and valuable while its handling cost stays understandable.

### Visual priorities

1. Recognizable silhouettes: an egg, a pet, a ship and its engines must read at a glance.
2. Visible studs and chunky construction at player scale.
3. A friendly grassy home, with neighboring progress visible.
4. Planet identities carried into eggs and pet families.
5. Strong effects concentrated around information that matters.

Use soft light, simple faces, angular vegetation and flat plastic. Favor purposeful blocks, wedges and a small family of faceted meshes. Reserve smooth spheres for objects that benefit from a planet-like silhouette. Avoid uniformly glowing terrain, tiny industrial detail, soft shapeless ships and densely layered effects.

## 3. Shared visual vocabulary

### Shape and materials

- **Terrain:** thick floating landmasses with stepped or angular edges, a studded top and a substantial darker rock underside. Mix a few large masses with smaller broken layers; avoid a thin tray resting on scattered pebbles.
- **Architecture:** stacked brick proportions, thick posts, low roofs, visible supports and broad entrances. Buildings frame outdoor activity rather than dominating the island.
- **Vegetation:** square trunks, clustered faceted leaf masses, tiered wedge-like conifers, chunky mushrooms and simple flowers. Maintain open sight lines beside pads and paths.
- **Ships:** clear central hull, projecting engines, readable cockpit, solid wings or fins, separate cargo rack and obvious module sockets.
- **Pets:** one dominant body mass, a few expressive features and short readable legs. Recognize the species in silhouette before adding rarity details.
- **Materials:** predominantly matte plastic and studded surfaces. Glass is a small cockpit or shield detail. Metal remains a simple painted toy surface.
- **Detail scale:** use a common stud grid. Place studs on horizontal play surfaces and selected broad prop faces; keep faces, cockpit windows and small labels uncluttered.

### Color tokens

These are starting swatches, to be checked together under the game's lighting.

| Role | Proposed color | Application |
|---|---|---|
| Home grass | `#65B83E` | Main island and player plots |
| Leaf shadow | `#227A54` | Tree foliage, contrast beneath brighter leaves |
| Path | `#D4AC78` | Tan studded paths, plot entrances |
| Wood | `#8A5941` | Fences, crates, signs and benches |
| Turquoise | `#37C9C0` | Spaceport kiosks and useful machinery |
| Orange | `#F58A38` | Ship paint, engine housings and repair identity |
| Blue | `#4998E8` | Shields, spaceport trim and calm technical information |
| Purple | `#9954D7` | Strange biomes, alien motifs and selected rare accents |
| Reward gold | `#FFD45A` | Earnings and successful discoveries |
| Rock | `#505664` | Island undersides, meteors and structural separation |
| UI panel | `#19202C` | Dark menu bodies |
| UI text | `#F4F4E9` | Primary readable text |
| Space | `#121936` | Deep blue sky with restrained violet nebulae |

Separate **biome identity**, **rarity** and **danger**. A turquoise creature can be Common because it belongs to the crystal world; its rarity badge conveys rarity. Danger also uses a word and hazard icon, never just a pet-card color.

Common presentation uses simple materials and a neutral badge. Apply increasing green, blue, purple and gold treatments to the existing middle rarity ladder once its exact labels are finalized. Cosmic gets a distinctive star-pattern badge, a recognizable emblem and restrained orbital details. Reuse the same rarity lookup for egg labels, cards, reveals, pet displays and the index; do not add tiers through art.

## 4. Home: a garden spaceport

### Layout

The user's later layout sketch defines **exactly six player plots surrounding the public launch area**, with two robot shops flanking the launch pad. Neighboring entrances face inward toward the public center; keep fences low enough to see pets and parked ships. The concept board remains illustrative; the six-plot sketch determines the implemented home layout.

Each plot has three immediately legible spaces:

- **Pet garden:** fenced grass with limited placement spaces, a small nameplate, a few decorations and enough room to appreciate the collection.
- **Personal landing pad:** directly beside the garden, visible from the path. The ship is the plot's second hero object. Keep its nose or side angled toward passing players so module changes are visible.
- **Preparation corner:** a repair stand, module-fitting point and simple storage props. Its layout stays consistent as the player's equipment improves.

The shared plaza contains navigation, friendly robot shopkeepers and clear entrances to the loop. Use compact turquoise-and-orange kiosks, warm lanterns, simple signs and one recognizable navigation landmark. Avoid a huge central hangar hiding player plots.

Trees frame plot corners. Flower clusters and crates fill selected edges, while entrances, landing-pad approaches and the route to shops remain open. Height differences can shape the floating island, but important walking routes should be obvious and comfortable.

### Visible progression

A starting plot feels intentionally welcoming with its basic ship and a small collection. Progress fills the pet garden, changes installed modules and adds a more capable cargo rack. Keep the original silhouette recognizable. Neighbors should be able to distinguish a fast, armored or cargo-focused ship without reading a menu.

Returning reduces musical tension, softens engine sound, brings pets into focus and makes the next decision clear: hatch, place, sell or upgrade. Home pets and collection records never look exposed to planet theft.

## 5. Worlds and routes

Hazard regions are canonical; the biome names below are working art concepts. A biome can occur inside a hazard region without creating a new progression rule.

| Setting | Terrain and sky | Vegetation and props | Egg and pet family language |
|---|---|---|---|
| Starter meadow | Green studded terraces, warm tan rock, clear blue-violet space | Friendly block trees, rounded angular hills, small nests | Green/cream eggs with leaf-like plates; curious short-legged creatures with sprout or ear silhouettes |
| Asteroid belt / rusty world | Charcoal rocks and orange sand; blue space behind orange silhouettes | Chunky wreckage, low mineral shrubs, damaged machinery | Rust-and-cream banded eggs; sturdy pets with rock plates or small fins |
| Crystal world | Turquoise ledges, blue shadows, violet crystals and simple caves | Angular crystal clusters, sparse translucent leaves | Faceted turquoise eggs; crystal ears, tails or shell plates |
| Alien territory / violet world | Purple ground, lime foliage, unusual floating fragments | Crooked trees, geometric ruins and clearly distinct patrol ships | Lime/violet patterned eggs; odd antennae, asymmetric tufts and expressive faces |
| Storm region | Blue-gray terraces, dark violet horizon, brief readable lightning | Wind-shaped plants, pulsing towers and cover silhouettes | Storm-striped eggs; cloud-like tufts and small charged details |
| Distant mixed regions | More unusual silhouettes and combinations of existing hazards | Floating fragments, impossible vegetation, cosmic landmarks | Existing family shapes combined with exceptional star patterns and restrained orbital fragments |

Keep the route, ship nose, meteor edges and attack telegraphs brighter than the background. Planet silhouettes establish orientation. Small debris supplies depth without resembling a wall of enemies.

Starter routes retain sparse slow meteors and no aliens. Dense rock passages, alien attack warnings and storm disruptions each receive a distinct visual grammar. Distant routes combine those grammars; avoid making every hazard a bright purple explosion.

## 6. Ships and flight feel

### Fixed-socket construction

| Module | Visual signature | Upgrade should visibly change |
|---|---|---|
| Engine | Orange housing, blue/turquoise exhaust, clear rear direction | Thruster size, nozzle count, attached fins or exhaust character |
| Shield | Blue core or side emitter pair | Emitter assembly and a brief shield response when relevant |
| Weapon | Separate barrel and mounting base | Barrel shape, mount or firing silhouette |
| Cargo | Open rack, braces and handling equipment | Support frame and load-stabilizing hardware |
| Hull | Studded structural shell with clear cockpit | Armor plates, reinforcement and silhouette thickness |

Socket positions remain easy to recognize across upgrades. A new module should look attached, with a small installation motion and mechanical snap. Paint color and biome decorations must not obscure the difference between engines, shields and cargo equipment.

### Handling presentation

- Steering responds promptly. The ship banks gently into turns and returns smoothly to neutral.
- Acceleration and braking feel continuous rather than switching between idle and maximum speed.
- Boost adds a short exhaust expansion, a clearer engine layer and optional gentle camera pullback. Keep the forward route visible.
- Extra cargo progressively makes acceleration and cruising heavier according to gameplay weight rules. Add a lower engine strain layer and small secured cargo wobble.
- Cargo wobble is visual presentation; it must not imply that safely loaded eggs randomly fall off.
- Never suggest a hard egg limit, a completely immobilized overweight ship or a new inventory cap. A cargo upgrade's message is "handles more weight efficiently."

For very large hauls, preserve accurate count and weight while rendering distant repeated eggs in simplified clusters. Important eggs remain individually readable. This is a rendering strategy, not a cargo restriction.

## 7. Expedition atmosphere and timers

| Phase | Look and motion | Music and cues | Clear player information |
|---|---|---|---|
| Landing / departure lock | Engines settle; pad lights show a calm locked state | Landing thump, soft mechanical ticks | Separate visit timer and "Departure ready in…" countdown |
| Exploration | Clear nests and landmarks, steady ship marker | Light biome ambience and spacious rhythmic music | Visit time, carried egg state, cargo weight and route back |
| Departure available | Departure lights change once | Distinct two-note ready cue | "Departure ready" replaces the lock countdown |
| Time running low | Visit timer gains stronger contrast; ship lights pulse slowly | Add a percussion layer and occasional warning | Explicit "Auto-departure in…" and persistent ship direction/distance |
| Final return window | Shorter light pulses and focused directional emphasis | Tension layer builds; warnings take priority over decorative sounds | Loaded eggs versus currently carried egg remain distinguishable |
| Timeout | Ship departure and player recall match the actual rule | Departure cue followed by recall sound | Loaded haul retained; explain that an unboarded carried egg was left behind |
| Homecoming | Warm home colors, settled engines, pet activity | Tension resolves into the home motif | Haul and permanent discoveries are easy to inspect |

Warning thresholds and actual durations remain balancing values. Do not invent them through the art brief. Use one continuous musical cue with added layers, rather than restarting unrelated tracks whenever a timer state changes.

The ship marker stays visible near the screen edge when the ship is off-screen. It should help players escape without filling the center with arrows. Each player's timers and marker refer to their own visit and ship.

## 8. Cargo and danger communication

### Cargo

Show **egg count**, **total weight** and **efficient handling weight**. Label the threshold so it cannot be mistaken for maximum capacity. Beyond it, show a short explanation such as "Heavy load: slower acceleration and speed." Keep the number of loaded eggs distinct from an egg still in the player's hands.

Use the same three signals together: a readable cargo status, progressively heavier engine audio and a small stable wobble. Do not cover the view with a giant red overweight warning.

### Navigation risk

Route cards state "Danger for your equipped ship" and name relevant strengths or weaknesses. Examples of presentation copy:

- "Low shielding against alien attacks."
- "Heavy cargo will make narrow passages harder."
- "Your shield is vulnerable during storm disruption."

Only show an explanation that the actual equipment and route data support. Upgrading changes the assessment, not the hazards themselves. Difficult planets remain selectable; explain the risk rather than applying an invented level lock.

## 9. Bat combat and egg competition

Aim for readable slapstick. A swing has a clear anticipation, a quick contact motion and a visible recovery. A successful hit combines a short impact sound, a small burst of stars and a readable knockback response.

Keep the egg visible through the encounter. Give rival players, carried eggs and escape routes priority over particles. Avoid opaque smoke clouds, long camera shakes, ragdolls that conceal the egg, or full-screen flashes.

Alien attacks use a different silhouette and sound from bat hits. Patrol ships visibly telegraph before firing. A danger cue should show direction and timing without being confused with a pet discovery.

Exact bat reach, hit windows, knockback, recovery and egg transfer/drop rules belong to the intended Steal an Egg reference and gameplay tuning. This document specifies how those actions should read and sound; it does not silently replace their behavior.

## 10. Eggs, pets and permanent collection

### Family cohesion

Each family uses one recognizable motif across terrain, nest, egg pattern, pet silhouette and index icon. For example, a crystal world's angular blue ledges repeat in the egg's faceted panels and the pet's ears. Treat example species as concepts, not a finalized content roster.

Faces use a small set of eyes and mouths with high contrast. Idle actions include blinking, a tiny hop, looking toward a nearby player and curling into a simple sleeping pose. Offset idle timing so a collection feels lively rather than synchronized.

Rarity increases distinctiveness through patterns, accessories and material accents. Cosmic presentation adds star-filled surfaces or a few orbiting fragments while preserving the species silhouette. Avoid a permanent effect cloud larger than the pet.

### Discovery rhythm

Make ordinary collection quick and satisfying. A rare discovery adds a short border flourish, clear rarity word and distinctive sound while the player keeps moving. At home, hatching can give the new pet a slightly longer introduction without forcing every repeated hatch into a long cinematic.

Only reveal rarity when the gameplay system makes it known. Do not preview an outcome before its sequential RNG roll. If probabilities are displayed, they must represent the actual resulting chance, not a misleading conditional roll value.

Separate "found this visit" from "secured in collection." Permanent index credit occurs for collectibles successfully brought home. Selling a secured pet never changes that record. Duplicate pets still support the canonical sell-or-place choice; they do not reset family progress.

## 11. Interface system

### Shared components

- Studded colored header strip, hard dark outline and a clear close button.
- Dark panel body with enough opacity for readable text over the world.
- Pixel-style display lettering and icons; clean readable sans-serif text for descriptions, timers and numbers.
- Reusable pet card with portrait, species, rarity badge, quantity and equipped/placed state.
- Green primary purchase/equip actions, clearly labeled red sell actions and neutral navigation controls.
- Identical rarity labels, icons and color mapping everywhere.

Use chunky square or lightly beveled corners rather than the earlier rounded space-dashboard style. Decorative studs belong on headers and broad buttons, never behind small paragraphs or timer digits.

Starting typography targets are 24–32 UI pixels for menu headings, 16–18 for body text and 14–16 for compact labels. Judge them on actual devices rather than shrinking text to preserve a desktop layout.

### Screen responsibilities

| Screen | Primary task | Presentation |
|---|---|---|
| Active HUD | Fly, collect and return safely | Ship health, cargo, visit timer, navigation; center remains open |
| Pets | Choose what to place or sell | Large cards, visible selected state, clear action and money outcome |
| Collection index | Understand family completion | Planet/family groups, unknown silhouettes, secured progress and milestone rewards |
| Ship upgrades | Compare and install modules | Ship preview plus engine/shield/weapon/cargo/hull hex branches |
| Navigation | Choose a route intelligently | Planet identity, family preview, relative danger and specific equipment advice |
| Homecoming | Appreciate a successful haul | Compact new-discovery summary, hatch/placement/sell next steps |

The hex layout organizes fixed-socket upgrade categories. Do not imply freeform grid construction or prerequisite locks unless the gameplay data actually supports them. Preview a replacement on the ship so its physical improvement is visible before installation.

The index's silhouette cards preserve a species outline without revealing its full appearance. Family milestones show current progress and the bat reward they unlock. Locked milestone rewards are different from planet access: they must not suggest that planets require levels.

### HUD placement

- **Upper left:** ship health while relevant, with cargo weight and egg count immediately below. Keep the carried-egg state visually separate from loaded cargo.
- **Upper edge:** a compact visit timer and separate departure-lock/ready state. The timer can become more prominent near departure without dropping into the aiming or steering area.
- **Navigation:** a small route heading and an edge-clamped ship marker, with a label and distance when returning on foot.
- **Lower corners:** movement and action areas on mobile; collection and navigation menu access outside those thumb zones.
- **Home:** replace expedition urgency with earnings and plot/collection access. Avoid a permanently flashing danger HUD at home.

Full menus are for inspecting and managing. Short discoveries, cargo updates and combat feedback remain small enough to preserve active play.

### Mobile

Use generous touch targets, safe-area spacing and short labeled controls; start with at least 48×48 UI pixels for major touch actions. Inventory cards reflow to fewer columns; detailed panels stack. The hex branches can become category tabs with the same icons and information on narrow screens.

Keep the movement thumb area and combat/interaction controls clear. Put the persistent timers where the player's hand does not cover them. Confirmations and rare celebrations cannot hide a departure warning. Color is always paired with a label, pattern or icon; offer reduced camera motion and restrained flashing while retaining the same warning information.

## 12. Audio direction

Home, travel and departure share a small melodic motif, making return feel like resolution. Music should be warm and lightly electronic, with toy-like percussion and soft synths rather than cinematic military soundtracks.

| State | Musical palette | Spatial ambience |
|---|---|---|
| Home | Relaxed, cheerful electronic loop; approximately 76–92 BPM as an art target | Quiet machinery, soft lantern buzz, occasional pet chirps and gentle landing activity |
| Travel | Steadier rhythm; approximately 106–120 BPM as an art target | Engine hum follows the ship, boosts add a bright layer, passing rocks have brief directional swishes |
| Planet exploration | Travel motif adapted to the biome with room for interaction sounds | Crystal chimes, wind, alien clicks or soft electrical storm textures |
| Urgent departure | Additional percussion and a rising rhythmic layer | Warning pulses and the player's ship readiness sounds remain distinct |
| Return | Short resolved phrase leading back into home music | Engines settle, unloading clicks and pet sounds become audible again |

Tempos are musical suggestions, not expedition durations or required playback assets.

### Event sound signatures

| Event | Sound design |
|---|---|
| Pick up egg | Short soft pop with a small bright click |
| Load egg | Distinct socket-like clack, a little lower than pickup |
| Normal hatch | Shell crack, springy pop and a species voice |
| Rare discovery | Brief rising arpeggio; higher rarity changes timbre and flourish rather than only loudness |
| Earn coins | Short grouped chime; combine repeated payouts instead of constant overlapping coin noise |
| Install module | Mechanical seat, solid clunk and short power-on confirmation |
| Complete family | Recognizable celebratory version of the home motif |
| Bat hit | Soft woody impact with a toy percussion accent |
| Shield hit / disruption | Rounded electric response / clearly different broken tone |
| Attack warning | Directional, brief and distinct from discovery audio |
| Departure unlock | Calm two-note ready signal |
| Automatic departure / recall | Launch sound followed by a short recall effect |

Mix warnings above decorative rewards when they coincide. Keep an egg-load confirmation audible under engine strain. Limit overlapping pet voices and bat impacts during crowded scenes. Music, effects and pet ambience should have separate volume controls; no essential mechanic depends on hearing a cue.

## 13. Motion and effects language

- **Good progress:** quick upward hop, small outward sparkle and a warm gold accent.
- **Installed machinery:** short physical seat/snap, then a stable operating state.
- **Danger:** directional lines, a readable symbol and focused pulses; avoid whole-screen saturation.
- **Shield:** a localized response around the hit, with a brief clear boundary.
- **Cargo strain:** a little slower body settling and secured egg wobble, with a clear HUD explanation.
- **Cosmic rarity:** small orbiting motion and stars contained within the pet's silhouette.

Most of the world stays still enough that important motion is noticed. Camera shake and boost pullback are mild and optional. Combat, collecting and returning remain controllable during celebrations.

## 14. Cohesion review before implementation approval

Review the concept at player height as well as from above. A beautiful overview is insufficient if a player sees only walls, clutter or unreadable labels.

- Home reads as a grassy social spaceport, with pets beside each personal ship.
- The basic and upgraded ship share an identity, while modules visibly differ.
- Every planet, egg and pet family shares a coherent motif.
- Rarity, biome color and danger cannot be confused.
- Important glow is readable because ordinary scenery is softly lit.
- Departure lock and visit limit are independently understandable.
- Unlimited stacking and efficient weight are communicated without a false capacity cap.
- Timeout presentation preserves loaded eggs and explains the carried-egg consequence.
- Risk cards use current equipment and permit early attempts at hard routes.
- Index progress remains permanent after selling; family bat rewards are visible.
- Busy combat leaves players, eggs and escape directions visible.
- Mobile layouts preserve the same information and clear interaction targets.
- A successful trip visibly improves the collection, earning choices or ship.

## 15. Production handoff

First build a representative slice: one finished home plot beside a neighbor, a basic ship and one visible module upgrade, a small matching planet/egg/pet family, a timer/cargo HUD, one bat impact and the home/travel/urgent audio transition. Approve the visual vocabulary from that playable slice before multiplying plots, pets and planets.

ForgeGUI may be used for interface authoring if available. The connected Studio plugin list did not expose a ForgeGUI panel during this design pass. The component specification remains usable in ForgeGUI or Studio's native UI workflow.

The concept image is a generated visual target, not a screenshot of completed gameplay. Actual music, sound assets, pet animations, flight, economy and progression still require implementation. This design pass does not publish or replace the open Studio place.
