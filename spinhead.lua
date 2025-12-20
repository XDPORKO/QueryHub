--// Spin Body Mobile Support
--// Universal LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- ===== CONFIG =====
local spinSpeed = 10 -- default speed
local spinning = false
local spinConnection
-- ==================

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "SpinMobileUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0, 20, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Text = "SPIN BODY"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Toggle Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Position = UDim2.new(0,10,0,40)
toggle.Text = "SPIN : OFF"
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle)

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,0,0,20)
speedLabel.Position = UDim2.new(0,0,0,85)
speedLabel.Text = "Speed: "..spinSpeed
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.Parent = frame

-- Minus Button
local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0.45,0,0,30)
minus.Position = UDim2.new(0.05,0,0,110)
minus.Text = "-"
minus.BackgroundColor3 = Color3.fromRGB(60,60,60)
minus.TextColor3 = Color3.new(1,1,1)
minus.Font = Enum.Font.GothamBold
minus.TextSize = 20
minus.Parent = frame
Instance.new("UICorner", minus)

-- Plus Button
local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0.45,0,0,30)
plus.Position = UDim2.new(0.5,0,0,110)
plus.Text = "+"
plus.BackgroundColor3 = Color3.fromRGB(60,60,60)
plus.TextColor3 = Color3.new(1,1,1)
plus.Font = Enum.Font.GothamBold
plus.TextSize = 20
plus.Parent = frame
Instance.new("UICorner", plus)

-- ===== LOGIC =====
local function startSpin()
	spinConnection = RunService.RenderStepped:Connect(function()
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
	end)
end

local function stopSpin()
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end

toggle.MouseButton1Click:Connect(function()
	spinning = not spinning
	toggle.Text = spinning and "SPIN : ON" or "SPIN : OFF"

	if spinning then
		startSpin()
	else
		stopSpin()
	end
end)

plus.MouseButton1Click:Connect(function()
	spinSpeed = math.clamp(spinSpeed + 2, 0, 100)
	speedLabel.Text = "Speed: "..spinSpeed
end)

minus.MouseButton1Click:Connect(function()
	spinSpeed = math.clamp(spinSpeed - 2, 0, 100)
	speedLabel.Text = "Speed: "..spinSpeed
end)

-- Respawn Fix
player.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
	stopSpin()
	spinning = false
	toggle.Text = "SPIN : OFF"
end)