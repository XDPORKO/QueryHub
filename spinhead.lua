--// PULL / LOCK / FLING +++
--// Infinite Spin | Auto Release | Silent | Head/Root Selector
--// Client Abuse Version | Mobile Safe

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= CHARACTER =================
local Char, HRP, Humanoid
local function setupChar(char)
	Char = char
	HRP = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
end
setupChar(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

-- ================= CONFIG =================
local CFG = {
	PULL_FORCE = 7e7,
	BASE_FLING = 9e8,
	MAX_FLING = 3e9,
	SPIN_FORCE = 1.6e8,
	LOCK_DISTANCE = 2.5,
	SMOOTHNESS = 0.2,

	SPIN_MULTIPLIER = 1.15,
	FLING_CHARGE_RATE = 0.8,
	MAX_CHARGE = 100,

	AUTO_RELEASE = true,
	SILENT = true,          -- no beam / highlight
	TARGET_PART = "Root",   -- "Root" | "Head"

	MODE = "BRUTAL"         -- LOCK | PULL | BRUTAL
}

-- ================= STATES =================
local lockedTarget = nil
local lockConn = nil
local flingCharge = 0
local spinPower = CFG.SPIN_FORCE

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,270,0,280)
frame.Position = UDim2.new(0,20,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

local function btn(txt,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,36)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Instance.new("UICorner", b)
	return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,32)
title.Text = "LOCK / PULL / FLING +++"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(1,-20,0,32)
nameBox.Position = UDim2.new(0,10,0,42)
nameBox.PlaceholderText = "Target Name"
nameBox.Text = ""
nameBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
nameBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", nameBox)

local lockBtn   = btn("LOCK TARGET", 84)
local modeBtn   = btn("MODE : BRUTAL", 128)
local partBtn   = btn("TARGET : ROOT", 172)
local unlockBtn = btn("UNLOCK", 216)

-- ================= CORE =================
local function findPlayer(name)
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and string.lower(p.Name):sub(1,#name) == string.lower(name) then
			return p
		end
	end
end

local function getTargetPart(char)
	if CFG.TARGET_PART == "Head" then
		return char:FindFirstChild("Head")
	end
	return char:FindFirstChild("HumanoidRootPart")
end

local function stopLock()
	if lockConn then lockConn:Disconnect() end
	lockConn = nil
	lockedTarget = nil
	flingCharge = 0
	spinPower = CFG.SPIN_FORCE
	lockBtn.Text = "LOCK TARGET"
end

local function startLock(target)
	stopLock()
	lockedTarget = target
	lockBtn.Text = "LOCKED : "..target.Name

	lockConn = RunService.RenderStepped:Connect(function(dt)
		pcall(function()
			if not lockedTarget.Character then
				stopLock()
				return
			end

			local char = lockedTarget.Character
			local tPart = getTargetPart(char)
			if not tPart then
				stopLock()
				return
			end

			-- anti counter
			HRP.AssemblyLinearVelocity = Vector3.zero
			HRP.AssemblyAngularVelocity = Vector3.zero
			Humanoid.PlatformStand = false

			-- lock position
			local desired = HRP.Position + HRP.CFrame.LookVector * CFG.LOCK_DISTANCE
			tPart.CFrame = tPart.CFrame:Lerp(CFrame.new(desired), CFG.SMOOTHNESS)

			-- charge system
			flingCharge = math.clamp(
				flingCharge + (CFG.FLING_CHARGE_RATE * 60 * dt),
				0,
				CFG.MAX_CHARGE
			)

			local ratio = flingCharge / CFG.MAX_CHARGE
			local flingPower = CFG.BASE_FLING + (CFG.MAX_FLING * ratio)

			-- infinite spin
			spinPower = spinPower * CFG.SPIN_MULTIPLIER
			tPart.AssemblyAngularVelocity += Vector3.new(
				spinPower * math.random(-1,1),
				spinPower,
				spinPower * math.random(-1,1)
			)

			-- pull
			if CFG.MODE ~= "LOCK" then
				local dir = (HRP.Position - tPart.Position).Unit
				tPart.AssemblyLinearVelocity = dir * CFG.PULL_FORCE
			end

			-- brutal fling
			if CFG.MODE == "BRUTAL" then
				tPart.AssemblyLinearVelocity += Vector3.new(
					math.random(-flingPower, flingPower),
					flingPower * 1.2,
					math.random(-flingPower, flingPower)
				)
			end

			-- auto release
			if CFG.AUTO_RELEASE and flingCharge >= CFG.MAX_CHARGE then
				stopLock()
			end
		end)
	end)
end

-- ================= BUTTONS =================
lockBtn.MouseButton1Click:Connect(function()
	local t = findPlayer(nameBox.Text)
	if not t then
		lockBtn.Text = "INVALID TARGET"
		task.delay(1,function() lockBtn.Text="LOCK TARGET" end)
		return
	end
	startLock(t)
end)

modeBtn.MouseButton1Click:Connect(function()
	if CFG.MODE == "BRUTAL" then
		CFG.MODE = "PULL"
	elseif CFG.MODE == "PULL" then
		CFG.MODE = "LOCK"
	else
		CFG.MODE = "BRUTAL"
	end
	modeBtn.Text = "MODE : "..CFG.MODE
end)

partBtn.MouseButton1Click:Connect(function()
	if CFG.TARGET_PART == "Root" then
		CFG.TARGET_PART = "Head"
		partBtn.Text = "TARGET : HEAD"
	else
		CFG.TARGET_PART = "Root"
		partBtn.Text = "TARGET : ROOT"
	end
end)

unlockBtn.MouseButton1Click:Connect(stopLock)

-- ================= RESPAWN SAFE =================
LocalPlayer.CharacterAdded:Connect(function(char)
	setupChar(char)
	stopLock()
end)