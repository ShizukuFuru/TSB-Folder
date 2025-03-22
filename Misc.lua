local Misc = {}

local CT = loadfile("TSB Folder/Custom.lua")()

local RunService = game:GetService("RunService")

local hiddenfling = false 
local flingActive = false 
local flingValue

local rootPart = CT.RootPart()
local character = CT.Character()
local player = CT.Player()

function fling(FlingValue, useLookVector)
    flingValue = FlingValue
    task.spawn(function()
        while true do
            RunService.Heartbeat:Wait()
            if hiddenfling then
                flingActive = true
                local hrp, c, vel, movel = rootPart, character, nil, 0.1
                while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
                    RunService.Heartbeat:Wait()
                    c = player.Character
                    hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                end

                if hiddenfling then
                    local closestModel = CT.GetNearest()
                    if closestModel and closestModel:FindFirstChild("HumanoidRootPart") then
                        local targetRootPart = closestModel.HumanoidRootPart
                        vel = hrp.Velocity

                        -- Determine the direction based on the useLookVector parameter
                        local direction
                        if useLookVector then
                            direction = hrp.CFrame.LookVector -- Use LookVector
                        else
                            direction = (targetRootPart.Position - hrp.Position).unit -- Use direction to target
                        end
                        hrp.Velocity = direction * flingValue

                        RunService.RenderStepped:Wait()
                        if c and c.Parent and hrp and hrp.Parent then
                            hrp.Velocity = vel
                        end

                        RunService.Stepped:Wait()
                        if c and c.Parent and hrp and hrp.Parent then
                            hrp.Velocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                end
            else
                if flingActive then
                    flingActive = false
                end
            end
        end
    end)
end

function Misc.ToggleFling(state, value, useLookVector)
    hiddenfling = state
    if hiddenfling and not flingActive then
        fling(value, useLookVector) 
    end
end

function Misc.AimStabilizer(isEnabled, offset)
    if not isEnabled then return end  
    local vChar = CT.GetNearest() 
    if not vChar or not vChar:FindFirstChild("HumanoidRootPart") then
        return  
    end
    if not character:FindFirstChild('Ragdoll') then
        CT.Humanoid().AutoRotate = false
        pcall(function()
            local Vector
                Vector = Vector3.new(vChar.HumanoidRootPart.Position.X, rootPart.Position.Y, vChar.HumanoidRootPart.Position.Z) + (Vector3.new(vChar.HumanoidRootPart.Velocity.X, 0, vChar.HumanoidRootPart.Velocity.Z) / offset)
            CT.RootPart().CFrame = CFrame.lookAt(rootPart.CFrame.Position, Vector)
        end)
    end
end

function CreateWeld(Part0, Part1, C0, C1, parent)
    local Weld = Instance.new("Weld")
    Weld.Part0 = Part0
    Weld.Part1 = Part1
    Weld.C0 = C0
    Weld.C1 = C1
    Weld.Parent = parent
    return Weld
end

function FindAttachment(Model, AttachmentName)
    for _, Child in ipairs(Model:GetChildren()) do
        if Child:IsA("Attachment") and Child.Name == AttachmentName then
            return Child
        elseif not Child:IsA("Accoutrement") and not Child:IsA("Tool") then
            local found = FindAttachment(Child, AttachmentName)
            if found then
                return found
            end
        end
    end
end

function AddAccessory(Accessory, AttachmentPoint)
    local character = CT.Character()
    local Handle = Accessory:FindFirstChild("Handle")

    if Handle then
        local Attachment = Handle:FindFirstChildOfClass("Attachment")
        Accessory.Parent = character
        if Attachment then
            local CharacterAttachment = FindAttachment(character, Attachment.Name)
            if CharacterAttachment then
                CreateWeld(CharacterAttachment.Parent, Attachment.Parent, CharacterAttachment.CFrame, Attachment.CFrame, CharacterAttachment.Parent)
            end
        else
            local TargetPart = character:FindFirstChild(AttachmentPoint)
            if TargetPart then
                CreateWeld(TargetPart, Handle, CFrame.new(0, 0, 0), Accessory.AttachmentPoint, TargetPart)
            end
        end
    elseif Accessory:IsA("Shirt") or Accessory:IsA("Pants") then
        for _, obj in pairs(character:GetChildren()) do
            if (Accessory:IsA("Shirt") and obj:IsA("Shirt")) or (Accessory:IsA("Pants") and obj:IsA("Pants")) then
                obj:Destroy()
            end
        end
        task.wait()
        Accessory.Parent = character
    end
end


function Misc.AddAccessory(id, AttachmentPoint)
    local success, Accessory = pcall(function() return game:GetObjects("rbxassetid://" .. id)[1] end)
    if success then
        AddAccessory(Accessory, AttachmentPoint)
    else
        warn("Failed to add accessory, invalid assetId or other")
    end
end

function Misc.unanchor(instance)
    for _, desc in ipairs(instance:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
        end
    end
end

function Misc.Mirror(source, sourceProp, target, targetProp)
    if not (source and target and source[sourceProp] ~= nil and target[targetProp] ~= nil) then return end
    target[targetProp] = source[sourceProp]
    source:GetPropertyChangedSignal(sourceProp):Connect(function()
        target[targetProp] = source[sourceProp]
    end)
end

function Misc.MirrorAngle(source, target)  
    return Promise.new(function(resolve, reject)
		local ok, result = pcall(function()
            task.spawn(function()
                while source and target and source.Parent do
                    target.CurrentAngle = source.CurrentAngle
                    task.wait()
                end
            end)
        end)
		if ok then
			resolve(result)
		else
			reject(result)
		end
	end)
end
function Misc.SetProperties(Model, prop, value, exclusion)
    local ok, result = pcall(function()
        for _, desc in ipairs(Model:GetDescendants()) do
            if desc:IsA("BasePart") then  -- Part is a subclass of BasePart
                local shouldExclude = false
                if type(exclusion) == "table" then
                    for _, exclude in ipairs(exclusion) do
                        if desc == exclude or desc.Name == exclude then
                            shouldExclude = true
                            break  
                        end
                    end
                elseif exclusion then 
                    if desc == exclusion or desc.Name == exclusion then
                        shouldExclude = true
                    end
                end
                if not shouldExclude then
                    task.spawn(function()
                        while task.wait() do
                            desc[prop] = value  
                        end
                    end)
                end
            end
        end
    end)
    if not ok then
        warn("Error in SetProperties: " .. result)
    end
end

function Misc.SetPropertyOnce(Model, descendantType, propertyName, value)
    for _, descendant in ipairs(Model:GetDescendants()) do
        if descendant:IsA(descendantType) and descendant[propertyName] ~= nil then
            descendant[propertyName] = value
        end
    end
end

return Misc
 