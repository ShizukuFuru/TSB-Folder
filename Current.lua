local CT = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Custom.lua"))()
local Misc = loadstring(game:HttpGet("https://raw.githubusercontent.com/ShizukuFuru/TSB-Folder/refs/heads/main/Misc.lua"))()
local PHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ScriptPackages/main/ParticleHandlerAUT.lua"))()

local RunService = game:GetService("RunService")
 
CT.CleanupMoves() 

local MKatana = CT.AddRbxasset("rbxassetid://107205958891711", game.ReplicatedStorage)
MKatana.Name = "Katana"

local isKatanaEquipped = false

local function EquipKatana(state)
    isKatanaEquipped = state
    
    local Character = CT.Character()
    local RightArm = Character:FindFirstChild("Right Arm")
    local Torso = Character:FindFirstChild("Torso")
    
    local KatanaWeapon = Character:FindFirstChild("#KATANAWEAPON")
    local Sheathe = Character:FindFirstChild("Sheathe")
    local lastFlames = KatanaWeapon:GetAttribute("LastFlames")
    
    local Katana = nil or Character:FindFirstChild("Katana")
    local KatanaMotor = nil or Torso:FindFirstChild("KatanaMotor")
    
    if not (RightArm and Torso and KatanaWeapon and Sheathe) then
        warn("Missing required Character parts or accessories.")
        return
    end
    if not CT.Character():FindFirstChild("Katana") then
        Katana = MKatana:Clone()
        Katana.Parent = Character
        Misc.unanchor(Katana)

        KatanaMotor = Instance.new("Motor6D")
        KatanaMotor.Name = "KatanaMotor"  
        KatanaMotor.Part0 = RightArm
        KatanaMotor.Part1 = Katana:WaitForChild("WeaponHold")
        KatanaMotor.Parent = Torso

        KatanaMotor.C0 = CFrame.fromMatrix(
        Vector3.new(0.00293731689, -1.02682793, -0.0126781464),
        Vector3.new(0, -1, 0),  
        Vector3.new(0, 0, -1),  
        Vector3.new(1, 0, 0)   
        )
    end
    if state == true then
        print(Katana)
        Misc.SetProperties(Katana, "Transparency", 0, {"Main", "WeaponHold"})
        PHandler.EnableParticle(Katana, lastFlames)
        PHandler.EnableParticleBeams(Katana, lastFlames)
    else
        Misc.SetProperties(Katana, "Transparency", 1)
        PHandler.EnableParticle(Katana, false)
        PHandler.EnableParticleBeams(Katana, false)
    end

    Misc.SetProperties(KatanaWeapon, "Transparency", 1)
    Misc.SetProperties(Sheathe, "Transparency", 1)


    KatanaWeapon:GetAttributeChangedSignal("LastFlames"):Connect(function()
        if not isKatanaEquipped then 
            return
        end
        PHandler.EnableParticle(Katana, lastFlames)
        PHandler.EnableParticleBeams(Katana, lastFlames)
        PHandler.EnableParticle(KatanaWeapon, false)
        PHandler.EnableParticleBeams(KatanaWeapon, false)
        if lastFlames then
            Misc.SetPropertyOnce(Katana, "ParticleEmitter", "LockedToPart", true)
        end
    end)

    KatanaMotor:GetPropertyChangedSignal("Part0"):Connect(function()
        local isEquipped = KatanaMotor.Part0 == RightArm
        --Misc.SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", isEquipped)
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
EquipKatana(true)
--hotbar:StartCooldown("R")
CT.SetUpAnimation()
CT.AnimationEvents("rbxassetid://13380255751", function(anim)
    hotbar:StartCooldown("Switch Mode")
    EquipKatana(not isKatanaEquipped)
    anim:Stop()
    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = "rbxassetid://140164642047188"
    local newAnimTrack = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(newAnim)
    newAnimTrack:Play()
    newAnimTrack.TimePosition = 7
    task.wait(1)
    newAnimTrack:Stop(.5)
end)