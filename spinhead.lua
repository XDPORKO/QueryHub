--// Spin + Fling + TP Player (Mobile)
--// Universal LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- CONFIG
local spinSpeed = 200
local spinning = false
local flingMode = false
local spinConn

-- ================= UI =================
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "QueryV0.1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,230,0,260)
frame.Position = UDim2.new(0,20,0.45,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local function makeBtn(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,36)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", b)
	return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "SPIN / FLING / TP"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local spinBtn = makeBtn("SPIN : OFF", 35)
local flingBtn = makeBtn("FLING : OFF", 80)
local speedBtn = makeBtn("SPEED : 15", 125)

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(1,-20,0,32)
nameBox.Position = UDim2.new(0,10,0,170)
nameBox.PlaceholderText = "Player Name"
nameBox.Text = ""
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 13
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
nameBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", nameBox)

local tpBtn = makeBtn("TP TO PLAYER", 210)

-- ================= LOGIC =================
local function startSpin()
	spinConn = RunService.RenderStepped:Connect(function()
		if flingMode then
			HRP.Velocity = Vector3.new(9e7,0,9e7)
			HRP.RotVelocity = Vector3.new(9e7,9e7,9e7)
		end
		HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
	end)
end

local function stopSpin()
	if spinConn then
		spinConn:Disconnect()
		spinConn = nil
	end
	HRP.Velocity = Vector3.zero
	HRP.RotVelocity = Vector3.zero
end

spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
	spinBtn.Text = spinning and "SPIN : ON" or "SPIN : OFF"
	if spinning then startSpin() else stopSpin() end
end)

flingBtn.MouseButton1Click:Connect(function()
	flingMode = not flingMode
	flingBtn.Text = flingMode and "FLING : ON" or "FLING : OFF"
end)

speedBtn.MouseButton1Click:Connect(function()
	spinSpeed = spinSpeed + 5
	if spinSpeed > 60 then spinSpeed = 5 end
	speedBtn.Text = "SPEED : "..spinSpeed
end)

tpBtn.MouseButton1Click:Connect(function()
	local targetName = nameBox.Text
	for _,plr in pairs(Players:GetPlayers()) do
		if string.lower(plr.Name):sub(1,#targetName) == string.lower(targetName) then
			if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				HRP.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
			end
		end
	end
end)

-- Respawn Fix
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	HRP = char:WaitForChild("HumanoidRootPart")
	stopSpin()
	spinning = false
	flingMode = false
	spinBtn.Text = "SPIN : OFF"
	flingBtn.Text = "FLING : OFF"
end)