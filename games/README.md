# Two separate games

Packages are saved in **releases/ORBIT-Publish.zip** and **releases/CRUMBLE-Publish.zip**. ORBIT's current update is **releases/ORBIT-Linked-Stars/**; see **Space/PUBLISH.md** for updating its existing experience. Bakery and the reusable Space template retain their separate baselines.

The Space version is also saved as a reusable template in **templates/SpaceClicker/SpaceClickerTemplate.rbxlx**, with an independent source snapshot and ZIP at **releases/SpaceClicker-Template.zip**.

## ORBIT — Space

Open **Space/ORBIT.rbxlx** in Roblox Studio and press Play.

- Four connected star systems, each with 13 planets, energy, drones and space producers.
- Save namespace: OrbitEnergyClicker_v1.
- Alternative installation: run Space/Install.luau in the existing ORBIT experience's Command Bar while stopped.
- Rojo project: Space/default.project.json.

## CRUMBLE — Bakery

Open **Bakery/CRUMBLE.rbxlx** in Roblox Studio and press Play.

- Fixed Bakery theme: cookies, bakers, ovens and bakery locations.
- Save namespace: CrumbleClicker_v1.
- Alternative installation: run Bakery/Install.luau in a different fresh place.
- Rojo project: Bakery/default.project.json.

These are independent place files. There is no player-facing theme switch. Each includes the complete animated clicker, research, expeditions, achievements, daily goals, rebirths and permanent upgrades.

## Publish separately

Publish ORBIT's update to its existing experience using Space/PUBLISH.md. For a new Bakery game, use **File > Publish to Roblox As…** and create a separate experience. Creating two places inside one experience does not give you two separate game listings.

The files are local builds; they have not been uploaded or published automatically. Cloud-save availability still depends on Roblox and the experience's settings.

## Future updates

The native place files and installers are self-contained. ORBIT's Rojo project uses releases/ORBIT-Linked-Stars/src. Bakery and the original template use their own baseline source.

Rebuild the current ORBIT release:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/BuildOrbitLinkedRelease.ps1 -UpdateCurrent
```

The original BuildGames.ps1 rebuilds the older game/template baselines and must not be used to overwrite the current ORBIT update. Edit maintained release source rather than generated installers or XML.
