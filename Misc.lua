local Misc = {}

local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()

local RunService = game:GetService("RunService")

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

function Misc.Hitbox(originCFrame, size, filterList, mode, time, onHit)
    local self = {}
    self._running = true
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType[mode]
    params.FilterDescendantsInstances = filterList or {}

    local hitCooldown = {}
    local startTime = tick()

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not self._running then
            connection:Disconnect()
            return
        end

        if time and tick() - startTime > time then
            self:Stop()
            return
        end

        local cframe = typeof(originCFrame) == 'function' and originCFrame() or originCFrame
        if not cframe then return end

        local parts = workspace:GetPartBoundsInBox(cframe, size, params)

        local found = {}

        for _, part in parts do
            local model = part:FindFirstAncestorOfClass('Model')
            local hum = model and model:FindFirstChildOfClass('Humanoid')
            if hum and hum.Health > 0 and not hitCooldown[model] then
                hitCooldown[model] = true
                table.insert(found, {
                    plr = game.Players:GetPlayerFromCharacter(model),
                    model = model,
                    humanoid = hum,
                    part = part
                })
            end
        end

        if #found > 0 and onHit then
            task.defer(onHit, found)
        end
    end)
    
    function self:Stop()
        self._running = false
        if connection then
            connection:Disconnect()
        end
    end

    return self
end

return Misc
 