--!strict
local CustomTemplate = {}

local isfile = isfile or function(file)
	local success, result = pcall(readfile, file)
	return success and result~=nil and result~=''
end
--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PrimaryPart = Character.PrimaryPart
local Camera = workspace.CurrentCamera

--Custom Modules!!!!!!!!!!!!
local Trove = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ScriptPackages/main/Trove0_4_1.lua"))()

---idkss
local shitteryLock = true

local moves = {}
local animationFuncs = {}
local connections = {}

--- thing

local function DestroySignals()
	for i, v in connections do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		end
	end
	table.clear(connections); connections = nil
end

local function AddSignal(connection, name)
	connections[name or #connections + 1] = connection
	return connection
end


function CustomTemplate.Loop(type: RBXScriptSignal, func: (...any) -> (...any)): RBXScriptConnection
	local connection
	coroutine.wrap(function()
		connection = AddSignal(RunService[type]:Connect(func))
	end)()
	return connection
end

--Creation function

function CustomTemplate.CreateObject(className, properties): Instance
	local instance = Instance.new(className)
	for property, value in properties do
		instance[property] = value
	end
	return instance
end


function CustomTemplate.AddRbxasset(rbxasset, parent): Instance?
	local success, result = pcall(game.GetObjects, game, rbxasset)
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

function CustomTemplate.Download(repo: string, rawFile: string, customFolder: string)
	local filePath = customFolder .. "/" .. rawFile

	if not isfile(filePath) then
		if not isfolder(customFolder) then
			makefolder(customFolder)
		end
		writefile(filePath, game:HttpGet("https://raw.githubusercontent.com/" .. repo .. "/refs/heads/main/" .. rawFile))
		-- print("File written: " .. filePath)
	else
		-- print("File already exists: " .. filePath)
	end
end

local assets = {"Base", "LeftHotbar", "RightHotbar", "Cooldown"}

for _, name in assets do
	CustomTemplate.Download("ShizukuFuru/TSB", name..".rbxm", "TSBCustom")
end table.clear(assets); assets = nil

-- FeraFunction
function CustomTemplate.GetNearest()
	local closestModel = nil
	local shortestDistance = math.huge
	for _, model in workspace.Live:GetChildren() do
		
		if model ~= Character and model.PrimaryPart then
			local modelRootPart = model.HumanoidRootPart
			local distance = (PrimaryPart.Position - modelRootPart.Position).Magnitude
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
	for i, trove in moves do
		trove:Clean()
		print("are you sure this is happening")
	end
	table.clear(moves)
end
local clonedCharacter = nil
local isCloneFollowToggled = false
local shiftLockEnabled = false

function UpdateModelOrientation()
	if clonedCharacter and clonedCharacter:FindFirstChild("HumanoidRootPart") then
		local rootPart = clonedCharacter.HumanoidRootPart
		local _, ry, _ = Camera.CFrame:ToOrientation()
		PrimaryPart.CFrame = CFrame.new(PrimaryPart.CFrame.p) * CFrame.fromOrientation(0, ry, 0)
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
			for _, originalPart in Character:GetChildren() do
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
			clonedCharacter = Character:Clone()
			clonedCharacter.Parent = workspace

			for _, descendant in clonedCharacter:GetDescendants() do
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

			Camera.CameraSubject = clonedCharacter:FindFirstChild("Humanoid")
		end

		RunService.RenderStepped:Connect(UpdateClone)
	else
		if clonedCharacter then
			clonedCharacter:Destroy()
			clonedCharacter = nil

			Camera.CameraSubject = Humanoid
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
	local CurrentCameraCFrame = Camera.CFrame
	Humanoid.AutoRotate = false
	Camera.CameraType = Enum.CameraType.Scriptable

	Connection = CustomTemplate.Loop("RenderStepped", function(DT)
		FrameTime += DT * 60
		local NeededFrame = Cutscene.Frames:FindFirstChild(tostring(math.ceil(FrameTime)))

		if NeededFrame then
			Camera.CFrame = PrimaryPart.CFrame * NeededFrame.Value
			Camera.FieldOfView = NeededFrame.FieldOfView
		else
			Connection:Disconnect()
			Camera.FieldOfView = 70
			Humanoid.AutoRotate = true
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CFrame = CurrentCameraCFrame
		end
	end)
end

local Hotbar = {}
Hotbar.__index = Hotbar

function Hotbar.new(side)
	local self = setmetatable({}, Hotbar)
	self.trove = Trove.new()
	self.moves = {}
	table.insert(moves, self.trove)

	if side == "L" or side == "Left" then
		self.instance = game:GetObjects(getcustomasset("TSBCustom/LeftHotBar.rbxm"))[1]
	elseif side == "R" or side == "Right" then
		self.instance = game:GetObjects(getcustomasset("TSBCustom/RightHotBar.rbxm"))[1]
	else
		print("Choose a valid side! ('L' or 'R')")
		return nil
	end
	self.instance.Parent = LocalPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Backpack"):WaitForChild("Hotbar")
	self.trove:Add(self.instance)
	LocalPlayer.CharacterAdded:Connect(function(character)
		if not self.instance.Parent then
			self.instance.Parent = LocalPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Backpack"):WaitForChild("Hotbar")
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

	local mouseConnection
	if Base.Base:IsA("TextButton") then
		mouseConnection = self.trove:Connect(Base.Base.MouseButton1Click, triggerMove)
	end

	local isNumber = tonumber(Bind) ~= nil and #Bind == 1
	local keyCode = Enum.KeyCode[Bind]
	local keypadCode = nil
	if isNumber then
		keypadCode = Enum.KeyCode["Keypad" .. Bind]
	end

	local keyConnection = self.trove:Connect(game:GetService("UserInputService").InputBegan, function(input, gameProcessed)
		if not gameProcessed then
			if input.KeyCode == keyCode or (isNumber and input.KeyCode == keypadCode) then
				triggerMove()
			end
		end
	end)

	self.moves[Name] = {
		Base = Base,
		Bind = Bind,
		Size = Size,
		Side = Side,
		cooldownTime = cooldownTime,
		func = func,
		mouseConnection = mouseConnection,
		keyConnection = keyConnection,
		triggerFunction = triggerMove
	}
end

function Hotbar:EditMove(Name, options)
	local move = self.moves[Name]
	if not move then
		warn("Move '" .. Name .. "' not found!")
		return false
	end

	local Base = move.Base

	if options.Bind then
		move.Bind = options.Bind

		if Base.Base.Number then
			Base.Base.Number.Text = options.Bind
			if Base.Base.Number.Number then
				Base.Base.Number.Number.Text = options.Bind
			end
		end

		if move.keyConnection then
			move.keyConnection:Disconnect()
		end

		local isNumber = tonumber(options.Bind) ~= nil and #options.Bind == 1
		local keyCode = Enum.KeyCode[options.Bind]
		local keypadCode = nil
		if isNumber then
			keypadCode = Enum.KeyCode["Keypad" .. options.Bind]
		end

		move.keyConnection = self.trove:Connect(game:GetService("UserInputService").InputBegan, function(input, gameProcessed)
			if not gameProcessed then
				if input.KeyCode == keyCode or (isNumber and input.KeyCode == keypadCode) then
					move.triggerFunction()
				end
			end
		end)
	end

	if options.Name then
		self.moves[options.Name] = move
		self.moves[Name] = nil

		if Base.Base.ToolName then
			Base.Base.ToolName.Text = options.Name
		end

		Name = options.Name
	end

	if options.Size then
		move.Size = options.Size
		Base.Size = UDim2.new(table.unpack(options.Size))

		if Base.Size.X.Offset < 60 or Base.Size.Y.Offset < 60 then
			Base.Base.Number.Size = UDim2.new(0.2, 0, 0.2, 0)
		else
			Base.Base.Number.Size = UDim2.new(0.3, 0, 0.3, 0)
		end
	end

	if options.Side then
		move.Side = options.Side
		if options.Side == "Left" then
			Base.LayoutOrder = 0
		elseif options.Side == "Right" then
			Base.LayoutOrder = 2
		end
	end

	if options.cooldownTime then
		move.cooldownTime = options.cooldownTime
		Base:SetAttribute("CooldownTime", options.cooldownTime)
	end

	if options.func then
		move.func = options.func

		local function newTriggerMove()
			if not Base:GetAttribute("IsOnCooldown") then
				self:StartCooldown(Name)
				task.spawn(options.func)
			end
		end

		move.triggerFunction = newTriggerMove

		if move.mouseConnection then
			move.mouseConnection:Disconnect()
		end

		if Base.Base:IsA("TextButton") then
			move.mouseConnection = self.trove:Connect(Base.Base.MouseButton1Click, newTriggerMove)
		end

		if move.keyConnection then
			move.keyConnection:Disconnect()

			local isNumber = tonumber(move.Bind) ~= nil and #move.Bind == 1
			local keyCode = Enum.KeyCode[move.Bind]
			local keypadCode = nil
			if isNumber then
				keypadCode = Enum.KeyCode["Keypad" .. move.Bind]
			end

			move.keyConnection = self.trove:Connect(game:GetService("UserInputService").InputBegan, function(input, gameProcessed)
				if not gameProcessed then
					if input.KeyCode == keyCode or (isNumber and input.KeyCode == keypadCode) then
						newTriggerMove()
					end
				end
			end)
		end
	end

	return true
end

function Hotbar:GetMoveInfo(Name)
	local move = self.moves[Name]
	if not move then
		return nil
	end

	return {
		Name = Name,
		Bind = move.Bind,
		Size = move.Size,
		Side = move.Side,
		cooldownTime = move.cooldownTime,
		Base = move.Base
	}
end

function Hotbar:StartCooldown(moveName)
	task.spawn(function()
		local move = self.moves[moveName]
		if move and move.Base then
			local Base = move.Base
			local cooldownTime = Base:GetAttribute("CooldownTime")
			if not Base:GetAttribute("IsOnCooldown") and cooldownTime > 0 then
				Base:SetAttribute("IsOnCooldown", true)
				local CooldownIndicator = Base:FindFirstChild("Cooldown")
				if CooldownIndicator then
					CooldownIndicator.Transparency = .5
					CooldownIndicator.Size = UDim2.new(1, 0, 1, 0)
					local tweenInfo = TweenInfo.new(cooldownTime, Enum.EasingStyle.Linear)
					local tween = game:GetService("TweenService"):Create(
						CooldownIndicator,
						tweenInfo,
						{Size = UDim2.new(1, 0, 0, 0)}
					)
					tween:Play()

					tween.Completed:Connect(function()
						if CooldownIndicator and CooldownIndicator.Parent then
							CooldownIndicator.Transparency = 1
						end
					end)
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
		Humanoid.AnimationPlayed:Connect(function(animationTrack)
			local animId = animationTrack.Animation.AnimationId
			local callback = animationFuncs[animId]
			if callback then
				task.spawn(function() callback(animationTrack) end)
			end
		end)
	end
	setupAnimationDetection()
	LocalPlayer.CharacterAdded:Connect(setupAnimationDetection)
end

function CustomTemplate.AnimationEvents(animId, func)
	animationFuncs[animId] = func
end


local activeEntries = {}
local isInitialized = false

function CustomTemplate.SetUpAnimationEvents(animList)
	if not animList or type(animList) ~= "table" then
		warn("animList must be a table")
		return
	end

	if isInitialized then
		return
	end
	isInitialized = true

	local function setupHitDetection(character)
		if not character or not character:IsA("Model") then return end

		local characterName = character.Name
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then return end

		if connections["HitDetection_" .. characterName] then 
			return 
		end

		local healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if character:GetAttribute("LastHit") == LocalPlayer.Name then
				for i = 1, #activeEntries do
					local entry = activeEntries[i]
					if entry and entry.track and entry.hitEvent then
						task.spawn(entry.hitEvent, entry.track, character)
					end
				end
			end
		end)

		AddSignal(healthConnection, "HitDetection_" .. characterName)

		local cleanupConnection = character.AncestryChanged:Connect(function()
			if not character.Parent then
				if connections["HitDetection_" .. characterName] then
					connections["HitDetection_" .. characterName]:Disconnect()
					connections["HitDetection_" .. characterName] = nil
				end
			end
		end)

		AddSignal(cleanupConnection, "Cleanup_" .. characterName)
	end

	local function initializeExistingCharacters()
		local liveFolder = workspace.Live
		if not liveFolder then return end

		local characters = liveFolder:GetChildren()
		for i = 1, #characters do
			setupHitDetection(characters[i])
		end
	end

	local function setupCharacterMonitoring()
		local liveFolder = workspace.Live
		if not liveFolder then
			return
		end

		initializeExistingCharacters()

		AddSignal(liveFolder.ChildAdded:Connect(function(character)
			task.wait(0.1)
			setupHitDetection(character)
		end), "Child Groomed By Dream")
	end

	local function cleanupActiveEntry(targetEntry)
		for i = #activeEntries, 1, -1 do
			if activeEntries[i] == targetEntry then
				table.remove(activeEntries, i)
				break
			end
		end
	end

	local function setupAnimationDetection()Humanoid.Humanoid()
		if not Humanoid then
			warn("SetUpAnimationEvents: Humanoid not found")
			return
		end

		AddSignal(Humanoid.AnimationPlayed:Connect(function(animationTrack)
			local animId = animationTrack.Animation.AnimationId
			local animData = animList[animId]

			if not animData then return end

			if animData.Events then
				task.spawn(animData.Events, animationTrack, nil)
			end

			if animData.HitEvents then
				local entry = {
					track = animationTrack,
					hitEvent = animData.HitEvents
				}

				table.insert(activeEntries, entry)

				local stoppedConnection = animationTrack.Stopped:Connect(function()
					cleanupActiveEntry(entry)
				end)

				local uniqueKey = "AnimStopped_" .. tostring(animationTrack):gsub("%s+", "_")
				AddSignal(stoppedConnection, uniqueKey)

				local destroyedConnection = animationTrack.AncestryChanged:Connect(function()
					if not animationTrack.Parent then
						cleanupActiveEntry(entry)
					end
				end)

				AddSignal(destroyedConnection, uniqueKey .. "_Destroy")
			end
		end), "AnimationPlayed")
	end

	setupCharacterMonitoring()
	setupAnimationDetection()

	AddSignal(LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.1)
		setupAnimationDetection()
	end), "CharacterAdded")
end


function CustomTemplate.CleanupAnimationEvents()
	isInitialized = false
	table.clear(activeEntries)
end

function CustomTemplate.GetActiveConnections()
	--if not connections then
	--	return {
	--		totalConnections = 0,
	--		activeEntries = #activeEntries,
	--		connections = {}
	--	}
	--end

	local connectionInfo = {}
	local totalCount = 0

	for name, connection in connections do
		connectionInfo[name] = typeof(connection) == "RBXScriptConnection" and "Active" or "Invalid"
		totalCount += 1
	end

	return {
		totalConnections = totalCount,
		activeEntries = #activeEntries,
		connections = connectionInfo
	}
end

return CustomTemplate
