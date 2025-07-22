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



