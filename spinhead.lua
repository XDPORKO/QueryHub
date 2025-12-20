--// PULL / LOCK / FLING ++
--// Smart Client Abuse | Mobile Optimized | Visual Lock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Char, HRP, Humanoid
local function setupChar(char)
	Char = char
	HRP = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
end
setupChar(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

-- ================= CONFIG =================
local CFG = {
	PULL_FORCE = 6e7,
	FLING_FORCE = 8e8,
	SPIN_FORCE = 7e7,
	LOCK_DISTANCE = 2.5,
	SMOOTHNESS = 0.18,
	MODE = "BRUTAL", -- PULL | LOCK | BRUTAL
}

-- ================= STATES =================
local lockedTarget
local lockConn
local highlight
local beam

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
title.Text = "LOCK / PULL / FLING ++"
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
local unlockBtn = btn("UNLOCK", 172)

-- ================= CORE =================
local function findPlayer(name)
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and string.lower(p.Name):sub(1,#name) == string.lower(name) then
			return p
		end
	end
end

local function clearVisual()
	if highlight then highlight:Destroy() end
	if beam then beam:Destroy() end
	highlight, beam = nil, nil
end

local function stopLock()
	if lockConn then lockConn:Disconnect() end
	lockConn = nil
	lockedTarget = nil
	clearVisual()
	lockBtn.Text = "LOCK TARGET"
end

local function applyVisual(tHRP)
	highlight = Instance.new("Highlight", tHRP.Parent)
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.OutlineTransparency = 1

	beam = Instance.new("Beam", HRP)
	local a0 = Instance.new("Attachment", HRP)
	local a1 = Instance.new("Attachment", tHRP)
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.15
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new(Color3.fromRGB(255,50,50))
end

local function startLock(target)
	stopLock()
	lockedTarget = target
	lockBtn.Text = "LOCKED : "..target.Name

	lockConn = RunService.RenderStepped:Connect(function()
		pcall(function()
			if not lockedTarget.Character
			or not lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
				stopLock()
				return
			end

			local tHRP = lockedTarget.Character.HumanoidRootPart

			-- visual
			if not highlight then
				applyVisual(tHRP)
			end

			-- anti counter
			HRP.AssemblyLinearVelocity = Vector3.zero
			HRP.AssemblyAngularVelocity = Vector3.zero
			Humanoid.PlatformStand = false

			-- smooth lock pos
			local desired = HRP.Position + HRP.CFrame.LookVector * CFG.LOCK_DISTANCE
			tHRP.CFrame = tHRP.CFrame:Lerp(CFrame.new(desired), CFG.SMOOTHNESS)

			if CFG.MODE ~= "LOCK" then
				local dir = (HRP.Position - tHRP.Position).Unit
				tHRP.AssemblyLinearVelocity = dir * CFG.PULL_FORCE
			end

			if CFG.MODE == "BRUTAL" then
				tHRP.AssemblyLinearVelocity = Vector3.new(
					math.random(-CFG.FLING_FORCE,CFG.FLING_FORCE),
					CFG.FLING_FORCE,
					math.random(-CFG.FLING_FORCE,CFG.FLING_FORCE)
				)
				tHRP.AssemblyAngularVelocity = Vector3.new(
					CFG.SPIN_FORCE,
					CFG.SPIN_FORCE,
					CFG.SPIN_FORCE
				)
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

unlockBtn.MouseButton1Click:Connect(stopLock)

-- Respawn Safe
LocalPlayer.CharacterAdded:Connect(function(char)
	setupChar(char)
	stopLock()
end)