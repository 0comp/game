# Reusable Space Clicker template

Open **SpaceClickerTemplate.rbxlx** in Roblox Studio. Use **Save to File As…** to create your game's working copy, keeping this template as your clean starting point.

The template contains the complete Space game's 2D art, animation, producers, worlds, research, expeditions, achievements, daily goals, offline earnings and rebirth system. It includes no player profiles, account credentials, place IDs or publishing credentials.

## Customize your copy

1. Open ReplicatedStorage > ClickerKit > ThemeConfig.
2. Set GameTitle and a distinct DataStoreName.
3. Edit Themes > Space for currency, colors, target art, world names and producer labels.
4. Edit UpgradeCatalog and ProgressionCatalog for balance and activities.
5. Stop and restart Play after changing configuration.
6. Publish the working copy as a new Roblox experience.

Keep saved producer/world/upgrade IDs stable after release. Change DataStoreName only when you intentionally want a new save namespace.

## Included

- SpaceClickerTemplate.rbxlx: self-contained place.
- Install.luau: self-contained Command Bar installer for a fresh place.
- src/: editable source copied into this package.
- default.project.json: Rojo project using this package's own source.
- RefreshPreview.luau: rebuilds the Studio Edit preview after customization.

The source snapshot is independent of the two release games. Rebuilding releases also refreshes this clean template; customize a separate working copy to preserve your changes.

For a public release, follow the publishing guide shipped with ORBIT or CRUMBLE and replace their listing artwork with your own branding. Cloud persistence must be confirmed in a published experience before inviting players.
