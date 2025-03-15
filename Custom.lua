local CustomTemplate = {}

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Custom Modules!!!!!!!!!!!!
local Trove = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ScriptPackages/main/Trove0_4_1.lua"))()

---idkss
local shitteryLock = true
getgenv().moves = getgenv().moves or {}
getgenv().animationFuncs = {}
--- thing
function CustomTemplate.Loop(type, func)
    local connection
    coroutine.wrap(function()
        connection = RunService[type]:Connect(func)
    end)()
    return connection
end

function CustomTemplate.Camera()
    return workspace.CurrentCamera
end

function CustomTemplate.Player()
    return Players.LocalPlayer
end

function CustomTemplate.Character()
    return CustomTemplate.Player() and CustomTemplate.Player().Character
end

function CustomTemplate.Humanoid()
    return CustomTemplate.Character() and CustomTemplate.Character():FindFirstChildWhichIsA("Humanoid")
end

function CustomTemplate.RootPart()
    return CustomTemplate.Character() and CustomTemplate.Character():FindFirstChild("HumanoidRootPart")
end

--Creation function

function CustomTemplate.CreateObject(sType, sProp)
	local NewObject = Instance.new(sType)
	for Property, Value in next, sProp do
		NewObject[Property] = Value
	end
	return NewObject
end


function CustomTemplate.AddRbxasset(rbxasset, parent)
    local success, result = pcall(function()
        return game:GetObjects(rbxasset)
    end)
    if not success then
        warn("Failed to load rbxasset: " .. tostring(result))
    end
    local asset = result[1]
    if not asset then
        warn("No asset found in rbxasset: " .. rbxasset)
    end
    if parent then
        asset.Parent = parent
    end
    return asset
end

function CustomTemplate.Download(repo, rawFile)
    local folderName = "TSBCustom"
    local filePath = folderName .. "/" .. rawFile

    if not isfile(filePath) then
        if not isfolder(folderName) then
            makefolder(folderName)
        end
        writefile(filePath, game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/refs/heads/main/" .. rawFile))
        -- print("File written: " .. filePath)
    else
        -- print("File already exists: " .. filePath)
    end
end

CustomTemplate.Download("ShizukuFuru/TSB", "Base.rbxm")
CustomTemplate.Download("ShizukuFuru/TSB", "LeftHotBar.rbxm")
CustomTemplate.Download("ShizukuFuru/TSB", "RightHotBar.rbxm")
CustomTemplate.Download("ShizukuFuru/TSB", "Cooldown.rbxm")

-- FeraFunction
function CustomTemplate.GetNearest()
    local closestModel = nil
    local shortestDistance = math.huge
    for _, model in pairs(workspace.Live:GetChildren()) do
        if model ~= CustomTemplate.Character() and model:FindFirstChild("HumanoidRootPart") then
            local modelRootPart = model.HumanoidRootPart
            local distance = (CustomTemplate.RootPart().Position - modelRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestModel = model
                shortestDistance = distance
            end
        end
    end
    return closestModel
end

function CustomTemplate.CleanupMoves()
    print("god damn it")
    for i, trove in pairs(getgenv().moves) do
        trove:Clean() 
        print("are you sure this is happening")
    end
    getgenv().moves = {} 
end
local clonedCharacter = nil
local isCloneFollowToggled = false
local shiftLockEnabled = false

function UpdateModelOrientation()
    if clonedCharacter and clonedCharacter:FindFirstChild("HumanoidRootPart") then
        local rootPart = clonedCharacter.HumanoidRootPart
        local _, ry, _ = CustomTemplate.Camera().CFrame:ToOrientation()
		CustomTemplate.RootPart().CFrame = CFrame.new(CustomTemplate.RootPart().CFrame.p) * CFrame.fromOrientation(0, ry, 0)
    end
end

function CustomTemplate.CloneFollow(state, shitLock)
    if state == nil then
        isCloneFollowToggled = not isCloneFollowToggled
    else
        isCloneFollowToggled = state
    end
    if shitLock == false then
        shitteryLock = false
    else
        shitteryLock = true
    end

    local function UpdateClone()
        if isCloneFollowToggled and clonedCharacter then
            for _, originalPart in pairs(CustomTemplate.Character():GetChildren()) do
                local clonePart = clonedCharacter:FindFirstChild(originalPart.Name)
                if clonePart and (clonePart:IsA("BasePart") or clonePart:IsA("Part")) then
                    clonePart.CFrame = originalPart.CFrame
                    clonePart.CanCollide = false
                elseif clonePart and clonePart:IsA("Humanoid") then
                    clonePart.Health = originalPart.Health
                    clonePart.WalkSpeed = originalPart.WalkSpeed
                    clonePart.JumpPower = originalPart.JumpPower
                end
            end
        end
    end
    if isCloneFollowToggled then
        if not clonedCharacter then
            clonedCharacter = CustomTemplate.Character():Clone()
            clonedCharacter.Parent = game.Workspace

            for _, descendant in pairs(clonedCharacter:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Transparency = 1
                    descendant.CanCollide = false
                elseif descendant:IsA("Accessory") or descendant:IsA("Hat") then
                    descendant:Destroy()
                end
            end

            if clonedCharacter:FindFirstChild("HumanoidRootPart") then
                clonedCharacter:FindFirstChild("HumanoidRootPart").Anchored = true
            end

            CustomTemplate.Camera().CameraSubject = clonedCharacter:FindFirstChild("Humanoid")
        end

        RunService.RenderStepped:Connect(UpdateClone)
    else
        if clonedCharacter then
            clonedCharacter:Destroy()
            clonedCharacter = nil

            CustomTemplate.Camera().CameraSubject = CustomTemplate.Humanoid()
        end
    end
end
UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        if not shiftLockEnabled then
            shiftLockEnabled = true
            task.spawn(function()
                while shiftLockEnabled and isCloneFollowToggled and shitteryLock do
                    UpdateModelOrientation()
					task.wait()
                end
            end)
        end
    else
        if shiftLockEnabled then
            shiftLockEnabled = false
        end
    end
end)

--Moveset function

function CustomTemplate.Cinematic(Cutscene)
    local FrameTime = 0
    local Connection
    local CurrentCameraCFrame = CustomTemplate.Camera().CFrame
    CustomTemplate.Humanoid().AutoRotate = false
    CustomTemplate.Camera().CameraType = Enum.CameraType.Scriptable

    Connection = CustomTemplate.Loop("RenderStepped", function(DT)
        FrameTime += DT * 60
        local NeededFrame = Cutscene.Frames:FindFirstChild(tostring(math.ceil(FrameTime)))

        if NeededFrame then
            CustomTemplate.Camera().CFrame = CustomTemplate.RootPart().CFrame * NeededFrame.Value
            CustomTemplate.Camera().FieldOfView = NeededFrame.FieldOfView
        else
            Connection:Disconnect()
            CustomTemplate.Camera().FieldOfView = 70
            CustomTemplate.Humanoid().AutoRotate = true
            CustomTemplate.Camera().CameraType = Enum.CameraType.Custom
            CustomTemplate.Camera().CFrame = CurrentCameraCFrame
        end
    end)
end
 
local Hotbar = {}
Hotbar.__index = Hotbar

function Hotbar.new(side)
    local self = setmetatable({}, Hotbar)
    self.trove = Trove.new()
    self.moves = {}
    table.insert(getgenv().moves, self.trove)

    if side == "L" or side == "Left" then
        self.instance = game:GetObjects(getcustomasset("TSBCustom/LeftHotBar.rbxm"))[1]
    elseif side == "R" or side == "Right" then
        self.instance = game:GetObjects(getcustomasset("TSBCustom/RightHotBar.rbxm"))[1]
    else
        print("Choose a valid side! ('L' or 'R')")
        return nil
    end
    self.instance.Parent = CustomTemplate.Player().PlayerGui:WaitForChild("Hotbar"):WaitForChild("Backpack"):WaitForChild("Hotbar")
    self.trove:Add(self.instance)
    CustomTemplate.Player().CharacterAdded:Connect(function(character)
        if not self.instance.Parent then
            self.instance.Parent = CustomTemplate.Player().PlayerGui:WaitForChild("Hotbar"):WaitForChild("Backpack"):WaitForChild("Hotbar")
        end
    end)
    return self
end

function Hotbar:NewMove(Bind, Name, Size, Side, cooldownTime, func)
    local Base = game:GetObjects(getcustomasset("TSBCustom/Base.rbxm"))[1]
    Base.Parent = self.instance.Hotbar
    Base.Size = UDim2.new(table.unpack(Size))
    local CooldownIndicator = game:GetObjects(getcustomasset("TSBCustom/Cooldown.rbxm"))[1]
    CooldownIndicator.Parent = Base
    CooldownIndicator.AnchorPoint = Vector2.new(0.5, 1)
    CooldownIndicator.Transparency = 1
    if Side == "Left" then
        Base.LayoutOrder = 0
    elseif Side == "Right" then
        Base.LayoutOrder = 2
    end
    
    if Base.Size.X.Offset < 60 or Base.Size.Y.Offset < 60 then
        Base.Base.Number.Size = UDim2.new(0.2, 0, 0.2, 0)
    end
    
    if Base.Base.ToolName then
        Base.Base.ToolName.Text = Name
    end
    
    if Base.Base.Number then
        Base.Base.Number.Text = Bind
        if Base.Base.Number.Number then
            Base.Base.Number.Number.Text = Bind
        end
    end
    

    Base:SetAttribute("IsOnCooldown", false)
    Base:SetAttribute("CooldownTime", cooldownTime)
    
    local function triggerMove()
        if not Base:GetAttribute("IsOnCooldown") then
            self:StartCooldown(Name) 
            task.spawn(func)                     
        end
    end

    if Base.Base:IsA("TextButton") then
        self.trove:Connect(Base.Base.MouseButton1Click, triggerMove)
    end
    self.moves[Name] = Base
    local isNumber = tonumber(Bind) ~= nil and #Bind == 1
    local keyCode = Enum.KeyCode[Bind]
    local keypadCode = nil
    if isNumber then
        keypadCode = Enum.KeyCode["Keypad" .. Bind]
    end
    
    self.trove:Connect(game:GetService("UserInputService").InputBegan, function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == keyCode or (isNumber and input.KeyCode == keypadCode) then
                triggerMove()
            end
        end
    end)
    
     
end

function Hotbar:StartCooldown(bind)
    task.spawn(function()
        local Base = self.moves[bind]
        if Base then
            local cooldownTime = Base:GetAttribute("CooldownTime")
            if not Base:GetAttribute("IsOnCooldown") and cooldownTime > 0 then
                Base:SetAttribute("IsOnCooldown", true)
                local CooldownIndicator = Base:FindFirstChild("Cooldown")
                CooldownIndicator.Transparency = .5
                if CooldownIndicator then
                    Base:SetAttribute("IsOnCooldown", true)
                    CooldownIndicator.Size = UDim2.new(1, 0, 1, 0)
                    local tweenInfo = TweenInfo.new(cooldownTime, Enum.EasingStyle.Linear)
                    local tween = game:GetService("TweenService"):Create(
                        CooldownIndicator,
                        tweenInfo,
                        {Size = UDim2.new(1, 0, 0, 0)}
                    )
                    tween:Play()
                end
                task.delay(cooldownTime, function()
                    if Base and Base.Parent then
                        Base:SetAttribute("IsOnCooldown", false)
                    end
                end)
            end
        end
    end)
end

function Hotbar:DestroyTrove()
    if self.trove then
        print("hola seniopr")
        self.trove:Clean()
    end
end
function CustomTemplate.Hotbar(side)
    return Hotbar.new(side)
end

function CustomTemplate.SetUpAnimation()
    local function setupAnimationDetection()
        CustomTemplate.Humanoid().AnimationPlayed:Connect(function(animationTrack)
            local animId = animationTrack.Animation.AnimationId
            local callback = animationFuncs[animId]
            if callback then
                task.spawn(function() callback(animationTrack) end)
            end
        end)
    end
    setupAnimationDetection()
    CustomTemplate.Player().CharacterAdded:Connect(setupAnimationDetection)
end
function CustomTemplate.AnimationEvents(animId, func)
    animationFuncs[animId] = func
end

return CustomTemplate