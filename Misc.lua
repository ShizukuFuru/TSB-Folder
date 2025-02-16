local Misc = {}

local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()
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

function AddHat(Hat)
    Hat.Parent = CT.Character()
    local Handle = Hat:FindFirstChild("Handle")
    if Handle then
        local Attachment = Handle:FindFirstChildOfClass("Attachment")
        if Attachment then
            local CharacterAttachment = FindAttachment(CT.Character(), Attachment.Name)
            if CharacterAttachment then
                CreateWeld(CharacterAttachment.Parent, Attachment.Parent, CharacterAttachment.CFrame, Attachment.CFrame, CharacterAttachment.Parent)
            end
        else
            local Head = CT.Character():FindFirstChild("Head")
            if Head then
                CreateWeld(Head, Handle, CFrame.new(0, 0, 0), Hat.AttachmentPoint, Head)
            end
        end
    end
end

function Misc.AddHatter(id)
    local success, Hat = pcall(function() return CT.AddRbxasset(id)[1] end)
    if success then
        AddHat(Hat)
    else
        warn("Failed to add hat, invalid assetId or other")
    end
end

return Misc
 