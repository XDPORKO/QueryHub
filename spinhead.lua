--// PULL + AUTO LOCK + ANTI COUNTER FLING
--// Mobile Support | Client Abuse Version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

-- CONFIG (BRUTAL)
local PULL_FORCE = 8e7
local FLING_FORCE = 9e8
local SPIN_FORCE = 9e7
local LOCK_DISTANCE = 2.5

-- STATES
local lockedTarget = nil
local lockConn = nil

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,240)
frame.Position = UDim2.new(0,20,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local function btn(text,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Instance.new("UICorner", b)
	return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "PULL / LOCK / FLING"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,40)
nameBox.PlaceholderText = "Target Player"
nameBox.Text = ""
nameBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
nameBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", nameBox)

local lockBtn = btn("LOCK TARGET", 80)
local unlockBtn = btn("UNLOCK TARGET", 120)

-- ================= LOGIC =================
local function findPlayer(name)
	for _,p in pairs(Players:GetPlayers()) do
		if string.lower(p.Name):sub(1,#name) == string.lower(name) then
			return p
		end
	end
end

local function stopLock()
	if lockConn then
		lockConn:Disconnect()
		lockConn = nil
	end
	lockedTarget = nil
	lockBtn.Text = "LOCK TARGET"
end

local function startLock(target)
	stopLock()
	lockedTarget = target
	lockBtn.Text = "LOCKED : "..target.Name

	lockConn = RunService.RenderStepped:Connect(function()
		pcall(function()
			if not lockedTarget
			or not lockedTarget.Character
			or not lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
				stopLock()
				return
			end

			local tHRP = lockedTarget.Character.HumanoidRootPart

			-- ===== ANTI COUNTER FLING =====
			HRP.Velocity = Vector3.zero
			HRP.RotVelocity = Vector3.zero
			Humanoid.PlatformStand = false

			-- ===== PULL TARGET =====
			local dir = (HRP.Position - tHRP.Position)
			tHRP.Velocity = dir.Unit * PULL_FORCE

			-- ===== LOCK POS =====
			tHRP.CFrame = CFrame.new(
				HRP.Position + HRP.CFrame.LookVector * LOCK_DISTANCE
			)

			-- ===== BRUTAL FLING =====
			tHRP.Velocity = Vector3.new(
				math.random(-FLING_FORCE,FLING_FORCE),
				FLING_FORCE,
				math.random(-FLING_FORCE,FLING_FORCE)
			)

			-- ===== SPIN TARGET =====
			tHRP.RotVelocity = Vector3.new(
				SPIN_FORCE,
				SPIN_FORCE,
				SPIN_FORCE
			)
		end)
	end)
end

lockBtn.MouseButton1Click:Connect(function()
	local target = findPlayer(nameBox.Text)
	if not target or target == LocalPlayer then
		lockBtn.Text = "TARGET INVALID"
		task.delay(1,function()
			lockBtn.Text = "LOCK TARGET"
		end)
		return
	end
	startLock(target)
end)

unlockBtn.MouseButton1Click:Connect(function()
	stopLock()
end)

-- Respawn Safe
LocalPlayer.CharacterAdded:Connect(function(char)
	Char = char
	HRP = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
	stopLock()
end)