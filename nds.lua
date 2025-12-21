--// BRUTAL TORNADO DISASTER
--// Affects Parts + Other Players
--// Modern UI | Mobile Support
--// CLIENT SIDE

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- PLAYER
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ================== SETTINGS ==================
local Settings = {
	Enabled = false,
	Radius = 25,
	Height = 45,
	OrbitSpeed = 3,
	PullForce = 55,
	PlayerLiftForce = 90,
	Damage = 10,
	MaxParts = 120,
	GrabRange = 120
}

-- ================== STORAGE ==================
local DebrisParts = {}
local TornadoModel = Instance.new("Model", Workspace)
TornadoModel.Name = "BrutalClientTornado"

-- ================== UI (MODERN) ==================
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "TornadoUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromScale(0.28, 0.38)
Main.Position = UDim2.fromScale(0.36, 0.3)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0.15,0)
Title.Text = "🌪️ Brutal Tornado"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1

local function makeButton(text, yPos)
	local b = Instance.new("TextButton", Main)
	b.Size = UDim2.new(0.85,0,0.13,0)
	b.Position = UDim2.new(0.075,0,yPos,0)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	return b
end

local ToggleBtn = makeButton("TORNADO : OFF", 0.22)
local BrutalBtn = makeButton("MODE : BRUTAL", 0.38)
local CloseBtn  = makeButton("CLOSE UI", 0.72)

-- ================== TORNADO VISUAL ==================
for i = 1, 35 do
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(2.5,2.5,2.5)
	p.Material = Enum.Material.SmoothPlastic
	p.Color = Color3.fromRGB(110,110,110)
	p.Transparency = 0.35
	p.Anchored = true
	p.CanCollide = false
	p.Parent = TornadoModel
end

-- ================== FUNCTIONS ==================
local function grabParts()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if #DebrisParts >= Settings.MaxParts then break end

		if obj:IsA("BasePart")
			and not obj.Anchored
			and not obj:IsDescendantOf(Char)
			and (obj.Position - HRP.Position).Magnitude <= Settings.GrabRange
		then
			obj:BreakJoints()
			obj.CanCollide = false

			table.insert(DebrisParts,{
				Part = obj,
				Angle = math.random() * math.pi * 2,
				Height = math.random(5, Settings.Height)
			})
		end
	end
end

local function affectPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if hum and root then
				local dist = (root.Position - HRP.Position).Magnitude
				if dist <= Settings.Radius * 2 then
					local dir = (HRP.Position - root.Position).Unit
					root.Velocity = dir * Settings.PlayerLiftForce + Vector3.new(0, Settings.PlayerLiftForce, 0)
					hum:TakeDamage(Settings.Damage)
				end
			end
		end
	end
end

-- ================== MAIN LOOP ==================
RunService.RenderStepped:Connect(function(dt)
	if not Settings.Enabled then return end

	grabParts()
	affectPlayers()

	local basePos = HRP.Position

	-- Tornado visual
	for i, v in ipairs(TornadoModel:GetChildren()) do
		local angle = tick() * Settings.OrbitSpeed + i
		local height = (i / #TornadoModel:GetChildren()) * Settings.Height
		local radius = Settings.Radius * (height / Settings.Height)

		v.Position = basePos + Vector3.new(
			math.cos(angle) * radius,
			height,
			math.sin(angle) * radius
		)
	end

	-- Debris orbit
	for _, d in ipairs(DebrisParts) do
		if d.Part and d.Part.Parent then
			d.Angle += Settings.OrbitSpeed * dt
			d.Height += dt * 10
			if d.Height > Settings.Height then
				d.Height = 5
			end

			local radius = Settings.Radius * (d.Height / Settings.Height)
			local target = basePos + Vector3.new(
				math.cos(d.Angle) * radius,
				d.Height,
				math.sin(d.Angle) * radius
			)

			d.Part.Velocity = (target - d.Part.Position) * Settings.PullForce
		end
	end
end)

-- ================== UI ACTIONS ==================
ToggleBtn.MouseButton1Click:Connect(function()
	Settings.Enabled = not Settings.Enabled
	ToggleBtn.Text = Settings.Enabled and "TORNADO : ON" or "TORNADO : OFF"
end)

BrutalBtn.MouseButton1Click:Connect(function()
	Settings.Radius = 40
	Settings.Height = 70
	Settings.OrbitSpeed = 6
	Settings.Damage = 25
	Settings.PlayerLiftForce = 160
end)

CloseBtn.MouseButton1Click:Connect(function()
	Gui.Enabled = false
end)