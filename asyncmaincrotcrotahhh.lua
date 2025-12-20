local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
if not LP then return end

local Camera = Workspace.CurrentCamera
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Query Hub",
	Icon = "rbxassetid://71212053414568",
	LoadingTitle = "Query Hub Universal",
	LoadingSubtitle = "Loading Modules...",
	Theme = "Ocean",
	ConfigurationSaving = {
		Enabled = true,
		FileName = "QueryHub"
	}
})

local Tabs = {
	Movement = Window:CreateTab("Movement", 4483362458),
	Player   = Window:CreateTab("Player", 4483362458),
	Visual   = Window:CreateTab("Visual", 4483362458),
	Misc     = Window:CreateTab("Misc", 4483362458)
}

local State = {
	Fly = false,
	Noclip = false,
	Invisible = false,
	ESP = false,
	WaterWalk = false,
	AntiVoid = true,
	AntiFall = true,
	AntiFling = true,
	FlySpeed = 70,
	WalkSpeed = 16,
	JumpHold = false,
	Spectate = false
}

local Attach = Instance.new("Attachment", RootPart)

local LV = Instance.new("LinearVelocity", RootPart)
LV.Attachment0 = Attach
LV.MaxForce = math.huge
LV.RelativeTo = Enum.ActuatorRelativeTo.World
LV.Enabled = false

local AO = Instance.new("AlignOrientation", RootPart)
AO.Attachment0 = Attach
AO.MaxTorque = math.huge
AO.Responsiveness = 200
AO.RigidityEnabled = true
AO.Enabled = false

local Input = {X=0,Y=0,Z=0}
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function MoveDir()
	if IsMobile then
		local d = Humanoid.MoveDirection
		return Vector3.new(d.X, 0, d.Z)
	end
	return Camera.CFrame.LookVector * Input.Z
		+ Camera.CFrame.RightVector * Input.X
		+ Vector3.new(0, Input.Y, 0)
end

local function ToggleFly(v)
	State.Fly = v
	if v then
		Humanoid.AutoRotate = false
		LV.Enabled = true
		AO.Enabled = true
		State.Noclip = true
	else
		LV.Enabled = false
		AO.Enabled = false
		LV.VectorVelocity = Vector3.zero
		Humanoid.AutoRotate = true
	end
end

RunService.RenderStepped:Connect(function()
	if State.Fly then
		local dir = MoveDir()
		local vel = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
		LV.VectorVelocity = LV.VectorVelocity:Lerp(vel, 0.3)
		AO.CFrame = Camera.CFrame
	end
end)

Tabs.Movement:CreateToggle({
	Name = "Fly",
	Callback = ToggleFly
})

Tabs.Movement:CreateSlider({
	Name = "Fly Speed",
	Range = {30,150},
	Increment = 5,
	CurrentValue = 70,
	Callback = function(v) State.FlySpeed = v end
})

RunService.Stepped:Connect(function()
	if State.Noclip then
		for _,v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

Tabs.Movement:CreateToggle({
	Name = "Noclip",
	Callback = function(v) State.Noclip = v end
})

local function SetInvisible(on)
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.LocalTransparencyModifier = on and 1 or 0
		end
	end
end

Tabs.Player:CreateToggle({
	Name = "Invisible",
	Callback = function(v)
		State.Invisible = v
		SetInvisible(v)
	end
})

Tabs.Player:CreateSlider({
	Name = "WalkSpeed",
	Range = {16,60},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(v)
		State.WalkSpeed = v
		Humanoid.WalkSpeed = v
	end
})

Tabs.Player:CreateToggle({
	Name = "Hold Jump (No Rocket)",
	Callback = function(v)
		State.JumpHold = v
	end
})

RunService.Heartbeat:Connect(function()
	if State.JumpHold and Humanoid.Jump then
		RootPart.Velocity = Vector3.new(
			RootPart.Velocity.X,
			math.clamp(RootPart.Velocity.Y, -10, 35),
			RootPart.Velocity.Z
		)
	end
end)

local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "QueryESP"

local function ClearESP()
	for _,v in ipairs(ESPFolder:GetChildren()) do v:Destroy() end
end

local function CreateESP(plr)
	if plr == LP then return end

	local function Apply(char)
		if not State.ESP then return end
		local hrp = char:WaitForChild("HumanoidRootPart",5)
		if not hrp then return end

		local hl = Instance.new("Highlight", ESPFolder)
		hl.Adornee = char
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.4

		if plr.Team ~= LP.Team then
			hl.FillColor = Color3.fromRGB(255,80,80)
		else
			hl.FillColor = Color3.fromRGB(80,255,80)
		end
	end

	if plr.Character then Apply(plr.Character) end
	plr.CharacterAdded:Connect(Apply)
end

Tabs.Visual:CreateToggle({
	Name = "ESP (Team + Distance)",
	Callback = function(v)
		State.ESP = v
		ClearESP()
		if v then
			for _,p in ipairs(Players:GetPlayers()) do
				CreateESP(p)
			end
		end
	end
})

Players.PlayerAdded:Connect(function(p)
	if State.ESP then CreateESP(p) end
end)

local SelectedPlayer

local function RefreshPlayers()
	local t = {}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP then table.insert(t,p.Name) end
	end
	return t
end

Tabs.Player:CreateDropdown({
	Name = "Player List",
	Options = RefreshPlayers(),
	Callback = function(v)
		SelectedPlayer = Players:FindFirstChild(v)
	end
})

Tabs.Player:CreateButton({
	Name = "Teleport To Player",
	Callback = function()
		if SelectedPlayer and SelectedPlayer.Character then
			RootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
		end
	end
})

Tabs.Player:CreateButton({
	Name = "Spectate Player",
	Callback = function()
		if SelectedPlayer and SelectedPlayer.Character then
			Camera.CameraSubject = SelectedPlayer.Character:FindFirstChild("Humanoid")
		end
	end
})

Tabs.Player:CreateButton({
	Name = "Stop Spectate",
	Callback = function()
		Camera.CameraSubject = Humanoid
	end
})

local ClickTP = false
Tabs.Movement:CreateToggle({
	Name = "Click TP",
	Callback = function(v) ClickTP = v end
})

UserInputService.InputBegan:Connect(function(i,g)
	if g then return end
	if ClickTP and i.UserInputType == Enum.UserInputType.MouseButton1 then
		local ray = Camera:ScreenPointToRay(i.Position.X, i.Position.Y)
		local hit = Workspace:Raycast(ray.Origin, ray.Direction*800)
		if hit then
			RootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if State.AntiVoid and RootPart.Position.Y < -90 then
		RootPart.CFrame = CFrame.new(0,60,0)
	end
	if State.AntiFall and RootPart.AssemblyLinearVelocity.Y < -120 then
		RootPart.AssemblyLinearVelocity = Vector3.new(0,-25,0)
	end
end)

RunService.Heartbeat:Connect(function()
	if State.AntiFling then
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end
end)

LP.CharacterAdded:Connect(function(c)
	task.wait(0.3)
	Character = c
	Humanoid = c:WaitForChild("Humanoid")
	RootPart = c:WaitForChild("HumanoidRootPart")
	Attach.Parent = RootPart
	LV.Parent = RootPart
	AO.Parent = RootPart
	Humanoid.WalkSpeed = State.WalkSpeed
	if State.Invisible then SetInvisible(true) end
	if State.Fly then ToggleFly(true) end
end)

Rayfield:Notify({
	Title = "Query Hub",
	Content = "Loaded Successfully (Universal)",
	Duration = 4
})