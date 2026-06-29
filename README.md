# Liminal Kickstart

Editor plugin for Godot 4. Adds a **Quick Play** toolbar button that lets you pick any scene and launch it immediately, optionally spawning the player at the current 3D viewport camera position.
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/0cpyKXPXnno/0.jpg)](https://www.youtube.com/watch?v=0cpyKXPXnno)

---

## Installation

Enable the plugin under **Project -> Project Settings -> Plugins -> Liminal Kickstart**.


### Quick Play (right button)

Click to open a popup listing scenes to launch:

| Item | Launches |
|---|---|
| **Current Scene** | The scene currently open in the editor. |
| **Main Scene** | The project's main scene  |
| *(scene names)* | Scenes matched by the configured glob patterns (see Setup below). |

---

## Setup: scene globs

To populate the scene list with your levels, add glob patterns under:

**Project -> Project Settings -> Liminal Editor -> Kickstart -> Scene Globs**

Example patterns:

```
res://maps/*.tscn
res://levels/**/*.tscn
```


---

## Spawn override API

To consume the viewport camera spawn in your game code, use the `LiminalKickstart` static class:

```gdscript
# In your player spawn code (e.g. level.gd):
if LiminalKickstart.has_spawn_override():
    player.position = LiminalKickstart.get_spawn_position()
    player.rotation = LiminalKickstart.get_spawn_rotation()
```

Made by Liminal Team https://liminal.lv

