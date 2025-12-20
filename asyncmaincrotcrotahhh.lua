--================ DELTA SAFE =================
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end

local function WaitChar()
	local c = LP.Character or LP.CharacterAdded:Wait()
	return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local Character, Humanoid, RootPart = WaitChar()

local Camera
repeat
	Camera = WS:FindFirstChildOfClass("Camera")
	task.wait()
until Camera

--================ UI =================
local Fluent = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"
))()

local Window = Fluent:CreateWindow({
	Title = "Query Hub",
	SubTitle = "Delta Stable",
	Size = UDim2.fromOffset(500,420),
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
	Movement = Window:AddTab({Title="Movement",Icon="rocket"}),
	Player = Window:AddTab({Title="Player",Icon="user"}),
	Visual = Window:AddTab({Title="Visual",Icon="eye"})
}

--================ STATE =================
local State = {
	Fly = false,
	Speed = 55,
	Invisible = false
}

--================ FLY =================
local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e8,1e8,1e8)

local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e8,1e8,1e8)
BG.P = 8e4

local function ToggleFly(v)
	State.Fly = v
	if v then
		BV.Parent = RootPart
		BG.Parent = RootPart
		Humanoid.AutoRotate = false
	else
		BV.Parent = nil
		BG.Parent = nil
		Humanoid.AutoRotate = true
	end
end

RS.RenderStepped:Connect(function()
	if State.Fly then
		local md = Humanoid.MoveDirection
		BV.Velocity =
			(Camera.CFrame.LookVector * md.Z +
			 Camera.CFrame.RightVector * md.X) * State.Speed
		BG.CFrame = Camera.CFrame
	end
end)

Tabs.Movement:AddToggle("Fly",{
	Title="Fly",
	Default=false,
	Callback=ToggleFly
})

Tabs.Movement:AddSlider("Speed",{
	Title="Fly Speed",
	Min=30,
	Max=100,
	Default=55,
	Callback=function(v)
		State.Speed = v
	end
})

--================ INVISIBLE =================
local function Invisible(v)
	for _,p in ipairs(Character:GetDescendants()) do
		if p:IsA("BasePart") or p:IsA("Decal") then
			p.LocalTransparencyModifier = v and 1 or 0
		end
	end
end

Tabs.Player:AddToggle("Invisible",{
	Title="Invisible",
	Default=false,
	Callback=function(v)
		State.Invisible = v
		Invisible(v)
	end
})

--================ ESP =================
local ESPFolder = Instance.new("Folder")
ESPFolder.Parent = game:GetService("CoreGui")

local function ClearESP()
	for _,v in ipairs(ESPFolder:GetChildren()) do v:Destroy() end
end

local function AddESP(plr)
	if plr == LP then return end
	local function apply(char)
		local hl = Instance.new("Highlight")
		hl.Adornee = char
		hl.FillColor = Color3.fromRGB(0,255,180)
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = ESPFolder
	end
	if plr.Character then apply(plr.Character) end
	plr.CharacterAdded:Connect(apply)
end

Tabs.Visual:AddToggle("ESP",{
	Title="ESP",
	Default=false,
	Callback=function(v)
		ClearESP()
		if v then
			for _,p in ipairs(Players:GetPlayers()) do
				AddESP(p)
			end
		end
	end
})

--================ RESPAWN =================
LP.CharacterAdded:Connect(function()
	task.wait(0.3)
	Character, Humanoid, RootPart = WaitChar()
	if State.Fly then ToggleFly(true) end
	if State.Invisible then Invisible(true) end
end)

Fluent:Notify({
	Title="Query Hub",
	Content="Loaded (Delta Safe)",
	Duration=3
})