function equipKatanaAndSheath()
    local Katana = Katana:Clone()
    Katana.Parent = CustomTemplate.Character()
    unanchor(Katana)


    KatanaMotor = Instance.new("Motor6D", CustomTemplate.Character()["Torso"])
    KatanaMotor.Part0, KatanaMotor.Part1, KatanaMotor.Name = CustomTemplate.Character()["Right Arm"], Katana:WaitForChild("WeaponHold"), "Sigma"

    --Mirror(Character["#KatanaWEAPON"]["Main"]["Slash"], "Enabled", Katana.Main["Trail2"], "Enabled")

    Mirror(CustomTemplate.Character()["Right Arm"]:WaitForChild("WeaponHold"), "C0", KatanaMotor, "C0")
    Mirror(CustomTemplate.Character()["Right Arm"]:WaitForChild("WeaponHold"), "Part0", KatanaMotor, "Part0")
    MirrorAngle(CustomTemplate.Character()["Right Arm"]:WaitForChild("WeaponHold"), KatanaMotor)

    SetProperties(CustomTemplate.Character()["#KatanaWEAPON"], "Transparency", 1)
    SetProperties(CustomTemplate.Character()["Sheathe"], "Transparency", 1)

    print(KatanaMotor)
    if KatanaMotor.Part0 == CustomTemplate.Character()["Right Arm"] then
        --SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", true)
    else
        --SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", false)
    end
    CustomTemplate.Character()["#KatanaWEAPON"]:GetAttributeChangedSignal("LastFlames"):Connect(function(Value)
        if CustomTemplate.Character()["#KatanaWEAPON"]:GetAttribute("LastFlames") == true then
            PHandler.EnableParticle(Katana, true)
            PHandler.EnableParticleBeams(Katana, true)
            PHandler.EnableParticle(CustomTemplate.Character()["#KatanaWEAPON"], false)
            PHandler.EnableParticleBeams(CustomTemplate.Character()["#KatanaWEAPON"], false)
            SetPropertyOnce(Katana, "ParticleEmitter", "LockedToPart", true)
        else
            PHandler.EnableParticle(Katana, false)
            PHandler.EnableParticleBeams(Katana, false)
        end 
    end)
    KatanaMotor:GetPropertyChangedSignal("Part0"):Connect(function()
        if KatanaMotor.Part0 == CustomTemplate.Character()["Right Arm"] then
            --SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", true)
        else
            --SetPropertyOnce(Katana, "ParticleEmitter", "Enabled", false)
        end
    end)
end
local function equipKatanaAndSheath()
    local Character = CustomTemplate.Character()
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