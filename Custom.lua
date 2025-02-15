local CustomTemplate = {}

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
    Base.Parent = game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Backpack.Hotbar
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