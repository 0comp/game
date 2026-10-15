# ORBIT source and playable backup

Captured from the current ORBIT Studio Edit project on 2026-10-13, before release checks.

- StudioSources.json preserves all 16 gameplay scripts and their hierarchy, remote definitions and target experience metadata.
- src contains the same editable sources.
- ORBIT.rbxlx reconstructs a runnable place from these sources. Its 2D interface builds when Play starts.
- default.project.json uses this backup folder's source files.

This is a gameplay source backup and reconstructed place, not a byte-for-byte Studio file. Editor-only GUI previews, the baseplate, default PlayerModule copies and disabled Studio test harness are not included.

Original ORBIT target: universe 10770505196, start place 102040393131522, creator 849112694. Keep OrbitEnergyClicker_v1 and saved producer/world/research IDs unchanged when updating the existing game. Opening the reconstructed file does not attach it to the existing cloud place automatically.

The original source snapshot is retained even if release fixes are required. Release verification and publishing status are recorded separately in docs/release-checks.
