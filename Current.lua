local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()
local RunService = game:GetService("RunService")
 
CT.CleanupMoves() 

local Katana = CT.AddRbxasset("rbxassetid://107205958891711", game.ReplicatedStorage)
Katana.Name = "Katana"

local function equipKatanaAndSheath()
    local Character = CT.Character()
    local RightArm = Character:FindFirstChild("Right Arm")
    local Torso = Character:FindFirstChild("Torso")
    local KatanaWeapon = Character:FindFirstChild("#KatanaWEAPON")
    local Sheathe = Character:FindFirstChild("Sheathe")

    if not (RightArm and Torso and KatanaWeapon and Sheathe) then
        warn("Missing required character parts or accessories.")
        return
    end

    local Katana = Katana:Clone()
    Katana.Parent = Character
    unanchor(Katana)

    local KatanaMotor = Instance.new("Motor6D")
    KatanaMotor.Name = "KatanaMotor" -- More descriptive than "Sigma"
    KatanaMotor.Part0 = RightArm
    KatanaMotor.Part1 = Katana:WaitForChild("WeaponHold")
    KatanaMotor.Parent = torso

    local WeaponHold = RightArm:WaitForChild("WeaponHold")

    Mirror(WeaponHold, "C0", KatanaMotor, "C0")
    Mirror(WeaponHold, "Part0", KatanaMotor, "Part0")
    MirrorAngle(WeaponHold, KatanaMotor)

    SetProperties(KatanaWeapon, "Transparency", 1)
    SetProperties(Sheathe, "Transparency", 1)

    KatanaWeapon:GetAttributeChangedSignal("LastFlames"):Connect(function()
        local lastFlames = KatanaWeapon:GetAttribute("LastFlames")
        PHandler.EnableParticle(Katana, lastFlames)
        PHandler.EnableParticleBeams(Katana, lastFlames)
        PHandler.EnableParticle(KatanaWeapon, not lastFlames)
        PHandler.EnableParticleBeams(KatanaWeapon, not lastFlames)
        if lastFlames then
            SetPropertyOnce(Katana, "ParticleEmitter", "LockedToPart", true)
        end
    end)

    KatanaMotor:GetPropertyChangedSignal("Part0"):Connect(function()
        local isEquipped = KatanaMotor.Part0 == RightArm
        SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", isEquipped)
    end)
end


function FalseTeleport(CFrame, enable)
    if enable then
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end

        local originalCFrame = CT.RootPart().CFrame

        teleportConnection = RunService.Heartbeat:Connect(function()
			CT.RootPart().CFrame = CFrame
            RunService.RenderStepped:Wait()
            CT.RootPart().CFrame = originalCFrame
        end)
    else
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
end
 

local hotbar = CT.Hotbar("Right")
hotbar:NewMove("R", "Switch Mode", {0, 50, 0, 50}, "Right", 5, function()
    FalseTeleport(CFrame.new(-100, -100, 0), true)
    CT.CloneFollow(true, false)
    task.wait(.1)
    CT.Character().Communicate:FireServer({
                Dash = Enum.KeyCode.W,
                Key = Enum.KeyCode.Q,
                Goal = "KeyPress"
            })
    task.wait(.3)
    if CT.RootPart():FindFirstChild("moveme") then CT.RootPart():FindFirstChild("moveme"):Destroy() end
    FalseTeleport(CT.RootPart().CFrame * CFrame.new(0, -50, 0), false)
    CT.CloneFollow(false)
end)
task.wait(1)
--hotbar:StartCooldown("R")
CT.SetUpAnimation()
CT.AnimationEvents("rbxassetid://13380255751", function(anim)
    anim:Stop()
    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = "rbxassetid://140164642047188"
    local newAnimTrack = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(newAnim)
    newAnimTrack:Play()
    newAnimTrack.TimePosition = 7
    task.wait(1)
    newAnimTrack:Stop(.5)
end)