--!strict
local CustomTemplate = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

local Trove = loadstring(game:HttpGet('https://raw.githubusercontent.com/skibiditoiletfan2007/ScriptPackages/main/Trove0_4_1.lua'))()

local LocalPlayer = Players.LocalPlayer
local mAbs = math.abs
local mHuge = math.huge
local mCeil = math.ceil
local tInsert = table.insert
local tRemove = table.remove
local tClear = table.clear
local tUnpack = table.unpack
local cfNew = CFrame.new
local cfOrientation = CFrame.fromOrientation
local u2New = UDim2.new
local v2New = Vector2.new

getgenv().moves = moves or {}
getgenv().animationFuncs = animationFuncs or {}
getgenv().connections = connections or {}

local function DestroySignals()
	if not connections then
		connections = {}
		return
	end
	for _, v in pairs(connections) do
		if typeof(v) == 'RBXScriptConnection' then
			v:Disconnect()
		end
	end
	connections = {}
end

local function SetupSignals()
	if connections then
		DestroySignals()
	else
		connections = {}
	end
end
SetupSignals()

local function AddSignal(connection, name)
	if connections then
		connections[name or #connections + 1] = connection
		return connection
	end
end

function CustomTemplate.Loop(type, func)
	local connection
	coroutine.wrap(function()
		connection = AddSignal(RunService[type]:Connect(func))
	end)()
	return connection
end

function CustomTemplate.Camera()
	return workspace.CurrentCamera
end

function CustomTemplate.Player()
	return LocalPlayer
end

function CustomTemplate.Character()
	return LocalPlayer and LocalPlayer.Character
end

function CustomTemplate.Humanoid()
	local char = LocalPlayer and LocalPlayer.Character
	return char and (char:FindFirstChildWhichIsA('Humanoid') or char:WaitForChild('Humanoid'))
end

function CustomTemplate.RootPart()
	local char = LocalPlayer and LocalPlayer.Character
	return char and (char:FindFirstChild('HumanoidRootPart') or char:WaitForChild('HumanoidRootPart'))
end

function CustomTemplate.CreateObject(sType, sProp)
	local obj = Instance.new(sType)
	for k, v in next, sProp do
		obj[k] = v
	end
	return obj
end

function CustomTemplate.AddCustomFunction(obj, index, funcs)
	obj[index] = obj[index] or {}
	for name, func in funcs or {} do
		obj[index][name] = func
	end
	return obj
end

function CustomTemplate.AddCustomMethod(obj, methods)
	for name, method in methods or {} do
		obj[name] = function(self, ...)
			return method(self, ...)
		end
	end
	return obj
end

function CustomTemplate.AddCustomEvent(obj, index, events)
	obj[index] = obj[index] or {}
	for name, callback in events or {} do
		local bindable = Instance.new('BindableEvent')
		bindable.Event:Connect(callback)
		obj[index][name] = bindable
	end
	return obj
end

function CustomTemplate.AddRbxasset(rbxasset, parent)
	local success, result = pcall(game.GetObjects, game, rbxasset)
	if not success then
		warn('Failed to load rbxasset: ' .. tostring(result))
		return nil
	end
	local asset = result[1]
	if not asset then
		warn('No asset found: ' .. rbxasset)
		return nil
	end
	if parent then
		asset.Parent = parent
	end
	return asset
end

local dlCache = {}

function CustomTemplate.Download(repo, rawFile, customFolder)
	local filePath = customFolder .. '/' .. rawFile
	if dlCache[filePath] then return end
	dlCache[filePath] = true
	if not isfile(filePath) then
		if not isfolder(customFolder) then
			makefolder(customFolder)
		end
		writefile(filePath, game:HttpGet('https://raw.githubusercontent.com/' .. repo .. '/refs/heads/main/' .. rawFile))
	end
end

CustomTemplate.Download('ShizukuFuru/TSB', 'Base.rbxm', 'TSBCustom')
CustomTemplate.Download('ShizukuFuru/TSB', 'LeftHotBar.rbxm', 'TSBCustom')
CustomTemplate.Download('ShizukuFuru/TSB', 'RightHotBar.rbxm', 'TSBCustom')
CustomTemplate.Download('ShizukuFuru/TSB', 'Cooldown.rbxm', 'TSBCustom')

local assetIdCache = {}

local function getAssetId(path)
	if not assetIdCache[path] then
		assetIdCache[path] = getcustomasset(path)
	end
	return assetIdCache[path]
end

local ASSET = {
	Base = 'TSBCustom/Base.rbxm',
	Left = 'TSBCustom/LeftHotBar.rbxm',
	Right = 'TSBCustom/RightHotBar.rbxm',
	Cooldown = 'TSBCustom/Cooldown.rbxm',
}

function CustomTemplate.GetNearest()
	local char = LocalPlayer and LocalPlayer.Character
	if not char then return nil end
	local root = char:FindFirstChild('HumanoidRootPart')
	if not root then return nil end
	local rootPos = root.Position
	local closest, shortest = nil, mHuge
	for _, model in pairs(workspace.Live:GetChildren()) do
		if model ~= char then
			local hrp = model:FindFirstChild('HumanoidRootPart')
			if hrp then
				local dist = (rootPos - hrp.Position).Magnitude
				if dist < shortest then
					closest, shortest = model, dist
				end
			end
		end
	end
	return closest
end

function CustomTemplate.CleanupMoves()
	for _, trove in pairs(moves) do
		trove:Clean()
	end
	moves = {}
end

 

local clonedCharacter
local isCloneFollowToggled = false
local shiftLockEnabled = false

function UpdateModelOrientation()
	if clonedCharacter and clonedCharacter:FindFirstChild('HumanoidRootPart') then
		local root = CustomTemplate.RootPart()
		if root then
			local _, ry, _ = workspace.CurrentCamera.CFrame:ToOrientation()
			root.CFrame = cfNew(root.CFrame.p) * cfOrientation(0, ry, 0)
		end
	end
end

function CustomTemplate.Cinematic(Cutscene)
	local FrameTime = 0
	local Connection
	local cam = workspace.CurrentCamera
	local savedCF = cam.CFrame
	local hum = CustomTemplate.Humanoid()
	local root = CustomTemplate.RootPart()
	if hum then hum.AutoRotate = false end
	cam.CameraType = Enum.CameraType.Scriptable

	Connection = CustomTemplate.Loop('RenderStepped', function(DT)
		FrameTime += DT * 60
		local frame = Cutscene.Frames:FindFirstChild(tostring(mCeil(FrameTime)))
		if frame then
			cam.CFrame = root.CFrame * frame.Value
			cam.FieldOfView = frame.FieldOfView
		else
			Connection:Disconnect()
			cam.FieldOfView = 70
			if hum then hum.AutoRotate = true end
			cam.CameraType = Enum.CameraType.Custom
			cam.CFrame = savedCF
		end
	end)
end

local Hotbar = {}
Hotbar.__index = Hotbar

local function resolveKeys(Bind)
	local isNum = tonumber(Bind) ~= nil and #Bind == 1
	local kc = Enum.KeyCode[Bind]
	local kp = isNum and Enum.KeyCode['Keypad' .. Bind] or nil
	return isNum, kc, kp
end

local function bindKey(trove, Bind, fn)
	local isNum, kc, kp = resolveKeys(Bind)
	return trove:Connect(UserInputService.InputBegan, function(input, gp)
		if not gp and (input.KeyCode == kc or (isNum and input.KeyCode == kp)) then
			fn()
		end
	end)
end

function Hotbar.new(side)
	local self = setmetatable({}, Hotbar)
	self.trove = Trove.new()
	self.moves = {}
	tInsert(moves, self.trove)

	local path
	if side == 'L' or side == 'Left' then
		path = ASSET.Left
	elseif side == 'R' or side == 'Right' then
		path = ASSET.Right
	else
		return nil
	end

	self.instance = game:GetObjects(getAssetId(path))[1]
	local hotbarParent = LocalPlayer.PlayerGui:WaitForChild('Hotbar'):WaitForChild('Backpack'):WaitForChild('Hotbar')
	self.instance.Parent = hotbarParent
	self.trove:Add(self.instance)

	LocalPlayer.CharacterAdded:Connect(function()
		if not self.instance.Parent then
			self.instance.Parent = LocalPlayer.PlayerGui:WaitForChild('Hotbar'):WaitForChild('Backpack'):WaitForChild('Hotbar')
		end
	end)

	return self
end

function Hotbar:NewMove(Bind, Name, Size, Side, cooldownTime, func)
	local Base = game:GetObjects(getAssetId(ASSET.Base))[1]
	Base.Parent = self.instance.Hotbar
	Base.Size = u2New(tUnpack(Size))

	local cd = game:GetObjects(getAssetId(ASSET.Cooldown))[1]
	cd.Parent = Base
	cd.AnchorPoint = v2New(0.5, 1)
	cd.Transparency = 1

	Base.LayoutOrder = Side == 'Left' and 0 or (Side == 'Right' and 2 or 1)

	if Base.Size.X.Offset < 60 or Base.Size.Y.Offset < 60 then
		Base.Base.Number.Size = u2New(0.2, 0, 0.2, 0)
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

	Base:SetAttribute('IsOnCooldown', false)
	Base:SetAttribute('CooldownTime', cooldownTime)

	local function trigger()
		if not Base:GetAttribute('IsOnCooldown') then
			self:StartCooldown(Name)
			task.spawn(func)
		end
	end

	local mouseConn
	if Base.Base:IsA('TextButton') then
		mouseConn = self.trove:Connect(Base.Base.MouseButton1Click, trigger)
	end

	self.moves[Name] = {
		Base = Base,
		Bind = Bind,
		Size = Size,
		Side = Side,
		cooldownTime = cooldownTime,
		func = func,
		mouseConnection = mouseConn,
		keyConnection = bindKey(self.trove, Bind, trigger),
		triggerFunction = trigger
	}
end

function Hotbar:_rebuildTrigger(Name, func)
	local move = self.moves[Name]
	local Base = move.Base

	local function newTrigger()
		if not Base:GetAttribute('IsOnCooldown') then
			self:StartCooldown(Name)
			task.spawn(func)
		end
	end

	move.triggerFunction = newTrigger

	if move.mouseConnection then
		move.mouseConnection:Disconnect()
		move.mouseConnection = nil
	end
	if Base.Base:IsA('TextButton') then
		move.mouseConnection = self.trove:Connect(Base.Base.MouseButton1Click, newTrigger)
	end

	if move.keyConnection then
		move.keyConnection:Disconnect()
	end
	move.keyConnection = bindKey(self.trove, move.Bind, newTrigger)
end

function Hotbar:EditMove(Name, options)
	local move = self.moves[Name]
	if not move then
		warn('Move ' .. Name .. ' not found!')
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
		move.keyConnection = bindKey(self.trove, options.Bind, move.triggerFunction)
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
		Base.Size = u2New(tUnpack(options.Size))
		local small = Base.Size.X.Offset < 60 or Base.Size.Y.Offset < 60
		Base.Base.Number.Size = small and u2New(0.2, 0, 0.2, 0) or u2New(0.3, 0, 0.3, 0)
	end

	if options.Side then
		move.Side = options.Side
		Base.LayoutOrder = options.Side == 'Left' and 0 or (options.Side == 'Right' and 2 or 1)
	end

	if options.cooldownTime then
		move.cooldownTime = options.cooldownTime
		Base:SetAttribute('CooldownTime', options.cooldownTime)
	end

	if options.func then
		move.func = options.func
		self:_rebuildTrigger(Name, options.func)
	end

	return true
end

function Hotbar:GetMoveInfo(Name)
	local move = self.moves[Name]
	if not move then return nil end
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
		if not move or not move.Base then return end
		local Base = move.Base
		local ct = Base:GetAttribute('CooldownTime')
		if Base:GetAttribute('IsOnCooldown') or ct <= 0 then return end
		Base:SetAttribute('IsOnCooldown', true)
		local indicator = Base:FindFirstChild('Cooldown')
		if indicator then
			indicator.Transparency = .5
			indicator.Size = u2New(1, 0, 1, 0)
			local tween = TweenService:Create(indicator, TweenInfo.new(ct, Enum.EasingStyle.Linear), {Size = u2New(1, 0, 0, 0)})
			tween:Play()
			tween.Completed:Connect(function()
				if indicator and indicator.Parent then
					indicator.Transparency = 1
				end
			end)
		end
		task.delay(ct, function()
			if Base and Base.Parent then
				Base:SetAttribute('IsOnCooldown', false)
			end
		end)
	end)
end

function Hotbar:DestroyTrove()
	if self.trove then
		self.trove:Clean()
	end
end

function CustomTemplate.Hotbar(side)
	return Hotbar.new(side)
end

function CustomTemplate.SetUpAnimation()
	local function setup()
		local hum = CustomTemplate.Humanoid()
		if not hum then return end
		hum.AnimationPlayed:Connect(function(track)
			local cb = animationFuncs[track.Animation.AnimationId]
			if cb then task.spawn(cb, track) end
		end)
	end
	setup()
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.1)
		setup()
	end)
end

function CustomTemplate.AnimationEvents(animId, func)
	animationFuncs[animId] = func
end

local activeEntries = {}
local isInitialized = false

function CustomTemplate.SetUpAnimationEvents(animList)
	if not animList or type(animList) ~= 'table' then
		warn('animList must be a table')
		return
	end
	if isInitialized then return end
	isInitialized = true

	local function setupHitDetection(character)
		if not character or not character:IsA('Model') then return end
		local cName = character.Name
		local humanoid = character:FindFirstChildOfClass('Humanoid')
		if not humanoid then return end
		if connections and connections['HitDetection_' .. cName] then return end
		AddSignal(humanoid:GetPropertyChangedSignal('Health'):Connect(function()
			if character:GetAttribute('LastHit') == LocalPlayer.Name then
				for i = 1, #activeEntries do
					local entry = activeEntries[i]
					if entry and entry.track and entry.hitEvent then
						task.spawn(entry.hitEvent, entry.track, character)
					end
				end
			end
		end), 'HitDetection_' .. cName)
	end

	local function initExisting()
		local live = workspace:FindFirstChild('Live')
		if not live then return end
		for _, child in pairs(live:GetChildren()) do
			setupHitDetection(child)
		end
	end

	local function setupMonitoring()
		local live = workspace:FindFirstChild('Live')
		if not live then return end
		initExisting()
		AddSignal(live.ChildAdded:Connect(function(character)
			task.wait(0.1)
			local key = 'HitDetection_' .. character.Name
			if connections and connections[key] then
				connections[key]:Disconnect()
				connections[key] = nil
			end
			setupHitDetection(character)
		end), 'ChildMonitor')
	end

	local function cleanupEntry(target)
		for i = #activeEntries, 1, -1 do
			if activeEntries[i] == target then
				tRemove(activeEntries, i)
				break
			end
		end
	end

	local function setupAnimDetection()
		local hum = CustomTemplate.Humanoid()
		if not hum then
			warn('SetUpAnimationEvents: Humanoid not found')
			return
		end
		AddSignal(hum.AnimationPlayed:Connect(function(track)
			local data = animList[track.Animation.AnimationId]
			if not data then return end
			if track:GetAttribute('Ignore') then return end
			if data.Events then
				task.spawn(data.Events, track, nil)
			end
			if data.HitEvents then
				local entry = { track = track, hitEvent = data.HitEvents }
				tInsert(activeEntries, entry)
				local uid = 'AnimStopped_' .. tostring(track):gsub('%s+', '_')
				AddSignal(track.Stopped:Connect(function()
					cleanupEntry(entry)
				end), uid)
				AddSignal(track.AncestryChanged:Connect(function()
					if not track.Parent then
						cleanupEntry(entry)
					end
				end), uid .. '_D')
			end
		end), 'AnimationPlayed')
	end

	setupMonitoring()
	setupAnimDetection()
	AddSignal(LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.1)
		setupAnimDetection()
	end), 'CharacterAdded')
end

function CustomTemplate.CleanupAnimationEvents()
	isInitialized = false
	tClear(activeEntries)
end

local blockCallbacks = {}
local prevBlockVal = 0

function CustomTemplate.OnBlock(func)
	if type(func) ~= 'function' then
		error('CustomTemplate.OnBlock: Expected function', 2)
	end
	if not connections['BlockReactor'] then
		local char = CustomTemplate.Character()
		if char then
			AddSignal(char:GetAttributeChangedSignal('BlockReact'):Connect(function()
				local cur = mAbs(char:GetAttribute('BlockReact') or 0)
				if cur > prevBlockVal or mAbs(cur - prevBlockVal) > 1 then
					for i = 1, #blockCallbacks do
						local ok, err = pcall(blockCallbacks[i])
						if not ok then
							warn(('Block callback #%d failed: %s'):format(i, tostring(err)))
						end
					end
				end
				prevBlockVal = cur
			end), 'BlockReactor')
		end
	end
	tInsert(blockCallbacks, func)
end

function CustomTemplate.CleanupBlockDetection()
	blockCallbacks = {}
	prevBlockVal = 0
end

function CustomTemplate.GetActiveConnections()
	if not connections then
		return { totalConnections = 0, activeEntries = #activeEntries, connections = {} }
	end
	local info = {}
	local total = 0
	for name, conn in pairs(connections) do
		info[name] = typeof(conn) == 'RBXScriptConnection' and 'Active' or 'Invalid'
		total += 1
	end
	return { totalConnections = total, activeEntries = #activeEntries, connections = info }
end

return CustomTemplate