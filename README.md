**CustomTemplate Module**

A specialized Roblox Luau module for creating "Movesets" for *The Strongest Battleground*.

---

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Usage](#usage)
   - [Setup](#setup)
   - [Basic API Examples](#basic-api-examples)
   - [Hotbar Creation and Moves](#hotbar-creation-and-moves)
   - [Custom Animations and Events](#custom-animations-and-events)
4. [API Reference](#api-reference)
5. [Examples](#examples)
6. [License](#license)

---

## Features

- Signal management (connect, disconnect, cleanup)
- Looping functions on `RunService` events
- Player and Character shortcuts
- UI object creation and asset loading
- File download utilities for caching assets
- Nearest‐model detection in workspace
- Cooldown system for move execution
- Custom hotbar UI with keybind support
- Animation playing detection and event hooks
- Block‐reaction event callbacks

---

## Requirements

- A script executor that supports `getgenv()`, `isfile`, `makefolder`, and `writefile`
- Internet access to fetch custom modules (e.g., Trove)

---

## Usage

### Setup

To use the Moveset Library, you need to assign the components to constants:

```lua
local Misc = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Misc.lua"))()
local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()
```

### Basic API Examples

```lua
-- Loop a function every RenderStepped
local conn = CT.Loop("RenderStepped", function(delta)
    print("Render stepped: ", delta)
end)

-- Get local player and character parts
local player = CT.Player()
local root = CT.RootPart()
```

---

### Methods

| Method | Description |
| --- | --- |
| `CT.Camera()` | Returns Current Camera |
| `CT.Player()` | Returns LocalPlayer |
| `CT.Character()` | Returns LocalPlayers Character |
| `CT.Humanoid()` | Returns LocalPlayers Characters Humanoid |
| `CT.RootPart()` | Returns LocalPlayers Characters HumanoidRootPart |
### Hotbar Creation and Moves


---

```lua
-- Create left-side hotbar
local hotbarL = CT.Hotbar("Left")

-- Add a new move bound to key "Q"
hotbarL:NewMove(
    "R",               -- Bind key
    "Dash",           -- Move name
    {0, 50, 0, 50},    -- Size
    "Left",           -- Side on bar
    2,                 -- Cooldown (seconds)
    function()         -- Action
        print("Lettuce Dash.")
    end
)
```

Start cooldown automatically handled. To edit or retrieve move info:

```lua
hotbarL:EditMove("Dash", { Bind = "E", cooldownTime = 1.5 })
local info = hotbarL:GetMoveInfo("Dash")
print(info.Bind, info.cooldownTime)
```

---

### Custom Animations and Events

---

```lua
-- For hit detection during animations
CT.SetUpAnimationEvents({
    ["rbxassetid://987654321"] = {
      	Events = function(track) 
            print("Callback on track's play")
	      end, 
        HitEvents = function(track, target)
            print("Hit event during " .. track.Name .. " on " .. target.Name)
        end
    }
})
```

---

## API Reference

Below is a complete list of CustomTemplate’s functions, organized by category, each with a brief description and example usage.

### Signal Management

- `CT.GetActiveConnections()` → Returns a table containing:

  - `totalConnections`: (number) count of RBXScriptConnections
  - `activeEntries`: (number) count of animation hit entries
  - `connections`: (table) mapping names to status (`"Active"` or `"Invalid"`)

  ```lua
  local info = CT.GetActiveConnections()
  print("Total connections:", info.totalConnections)
  for name, status in pairs(info.connections) do
      print(name, status)
  end
  ```

- `CT.CleanupMoves()` → Disconnects and clears all stored move Troves.

  ```lua
  CT.CleanupMoves()
  ```

- `CT.CleanupAnimationEvents()` → Resets animation event tracking and clears all related connections.

  ```lua
  CT.CleanupAnimationEvents()
  ```

- `CT.CleanupBlockDetection()` → Clears all registered block reaction callbacks.

  ```lua
  CT.CleanupBlockDetection()
  ```

### Utility Functions

- `CT.DownloadFile(repo: string, rawFile: string, folder: string)` → Downloads a file from a GitHub repo into a local folder (caches if exists).

  ```lua
  CT.DownloadFile("MyUser/MyRepo", "Module.rbxm", "MyAssets")
  ```

- `CT.GetNearest()` → Returns the nearest Model in `workspace.Live` to the player (skips own Character).

  ```lua
  local nearest = CT.GetNearest()
  print("Nearest target:", nearest.Name)
  ```


### Hotbar

- `CT.Hotbar(side: "Left" | "Right")` → Returns a new Hotbar instance on the given side.

  ```lua
  local hotbarR = CT.Hotbar("Right")
  ```

- `hotbar:NewMove(bind: string, name: string, size: table, side: string, cooldown: number, func: function)` → Adds a move button.

  ```lua
  hotbarR:NewMove("T", "Test", {0,50,0,50}, "Right", 3, function()
      print("Casting Supreme Aura Ultimate: Test")
  end)
  ```

- `hotbar:EditMove(name: string, options: table)` → Edit existing move properties (Bind, Name, Size, Side, cooldownTime, func).

  ```lua
  hotbarR:EditMove("Test", { Bind = "E", cooldownTime = 2 })
  ```

- `hotbar:GetMoveInfo(name: string)` → Returns a table of move properties.

  ```lua
  local moveInfo = hotbarR:GetMoveInfo("Test")
  print(moveInfo.Bind, moveInfo.cooldownTime)
  ```

- `hotbar:StartCooldown(moveName: string)` → Manually trigger the cooldown

  ```lua
  hotbarR:StartCooldown("Test")
  ```

- `hotbar:DestroyTrove()` → Cleans up all connections and UI belonging to this hotbar instance.

  ```lua
  hotbarR:DestroyTrove()
  ```

### Animation Detection

- `CT.SetUpAnimationEvents(animList: table)` → Sets up hit and custom events for multiple animations using a table keyed by asset IDs.

  ```lua
  CT.SetUpAnimationEvents({
      ["rbxassetid://123123123123"] = {
          Events = function(track) 
              print("Callback on track's play")
          end, 
          HitEvents = function(track, target)
              print("Hit event during " .. track.Name .. " on " .. target.Name)
          end
      }
  })
  ```

### Block Detection

- `CT.OnBlock(func: function)` → Registers a callback fired when you sucessfully block
  ```lua
  CT.OnBlock(function()
      print("Block detected!")
  end)
  ```

## Examples

### Complete example combining hotbar, animations, and block detection:

```lua
local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()


CT.SetUpAnimation()
CT.SetUpAnimationEvents({
    ["rbxassetid://12312312312323333333"] = {
      	Events = function(track) 
            print("Callback on track's play")
	      end, 
        HitEvents = function(track, target)
            print("Hit event during " .. track.Name .. " on " .. target.Name)
        end
    }
})

-- Dash move
local hotbar = CT.Hotbar("Left")
hotbar:NewMove("R", "Detect nearest", {0,50,0,50}, "Left", 1.5, function()
    local nearest = CT.GetNearest()
    if nearest then
        print(nearest.Parent.Name)
    end
end)

-- Block callback
CT.OnBlock(function()
    print("Block detected!")
end)
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

**OSAO License**\
**Version 1.0 — July 22, 2025**

Copyright (C) 2025 ShizukuFuru

Everyone is permitted to copy, distribute, modify, and use this software for any purpose, subject to the following conditions:

### 1. Definitions

- **“You”** means any person or entity using, copying, modifying, or distributing the Software.
- **“Software”** means the original work as well as any modifications or derivative works.
- **“Original Author”** means the person or entity named above.

### 2. Grant of Rights

Subject to these terms, the Original Author grants you a worldwide, royalty‑free, non‑exclusive, irrevocable license to:

1. **Use** the Software for any purpose.
2. **Modify** the Software and create derivative works.
3. **Distribute** the original or modified Software, in source or binary form, under the same terms.

### 3. Conditions of Redistribution

If you distribute the Software (original or modified), you must:

1. **Retain** this license text and copyright notice in all copies.
2. **Include** a prominent notice stating:
   > “This product includes software originally authored by ShizukuFuru. \
   > See: Discord user  handle **furatears**.”
3. **Not** remove, obscure, or alter any existing copyright, trademark, or attribution notices in the Software.

### 4. Attribution‑Only Clause

You must **not**:

- Claim authorship, ownership, or credit for the Original Author’s unmodified portions of the Software.
- Use the Original Author’s name, trademarks, or logos to promote or imply endorsement of derivative works, without explicit permission.

### 5. No Warranty

The Software is provided “as is,” without warranty of any kind. In no event shall the Original Author be liable for any damages arising out of the use of or inability to use the Software.

### 6. Limitation of Liability

Under no circumstances and under no legal theory shall the Original Author be liable to you for any special, incidental, consequential, or punitive damages arising out of your use of the Software.

---

**Summary of Permissions and Requirements**

| PermissionRequirement                                                  |                                                                                  |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| ✅ Use, copy, modify, and distribute (commercially or non‑commercially) | 🔴 Must retain this license and include attribution to the Original Author       |
|                                                                        | 🔴 Must state “includes software originally authored by furatears (ShizukuFuru)” |
|                                                                        | 🔴 Must not remove or obscure credits                                            |
|                                                                        | 🔴 Must not claim credit or ownership of the Original Author’s work              |

---

