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
local troves = {}

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
    asset.Parent = parent
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
        print("File written: " .. filePath)
    else
        print("File already exists: " .. filePath)
    end
end

CustomTemplate.Download("ShizukuFuru/TSB", "Base.rbxm")

-- FeraFunction
function CustomTemplate.CleanupTrove()
    for _, trove in pairs(troves) do
        trove:Destroy() 
    end
    troves = {} 
end
local clonedCharacter = nil
local isCloneFollowToggled = false
local shiftLockEnabled = false

function updateModelOrientation()
    if clonedCharacter and clonedCharacter:FindFirstChild("HumanoidRootPart") then
        local rootPart = clonedCharacter.HumanoidRootPart
        local _, ry, _ = CustomTemplate.Camera().CFrame:ToOrientation()
		CustomTemplate.RootPart().CFrame = CFrame.new(CustomTemplate.RootPart().CFrame.p) * CFrame.fromOrientation(0, ry, 0)
    end
end

function CustomTemplate.CloneFollow(state)
    if state == nil then
        isCloneFollowToggled = not isCloneFollowToggled
    else
        isCloneFollowToggled = state
    end

    local function updateClone()
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

        RunService.RenderStepped:Connect(updateClone)
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
                while shiftLockEnabled and isCloneFollowToggled do
                    updateModelOrientation()
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

function CustomTemplate.NewMove(Bind, Name, Size, Side, func)
	local trove = Trove.new()
    local Base = game:GetObjects(getcustomasset("TSBCustom/Base.rbxm"))[1]
    Base.Parent = CustomTemplate.Player().PlayerGui.Hotbar.Backpack.Hotbar
    Base.Size = UDim2.new(table.unpack(Size))
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
    if func and Base.Base:IsA("TextButton") then
        trove:Connect(Base.Base.MouseButton1Click, func)

        trove:Connect(game:GetService("UserInputService").InputBegan, function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode[Bind] then
                func()
            end
        end)
    end

    table.insert(troves, trove)
end

return CustomTemplate