local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
if not LP then return end

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Query Hub",
 Icon = "rbxassetid://71212053414568",
	LoadingTitle = "Query Hub",
	LoadingSubtitle = "Universal Script",
	ConfigurationSaving = {
		Enabled = true,
		FileName = "QueryHub"
	},
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
	  KeySystem = false
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
	FlySpeed = 70
}

local Attach = Instance.new("Attachment", RootPart)

local LV = Instance.new("LinearVelocity", RootPart)
LV.Attachment0 = Attach
LV.RelativeTo = Enum.ActuatorRelativeTo.World
LV.MaxForce = math.huge
LV.Enabled = false

local AO = Instance.new("AlignOrientation", RootPart)
AO.Attachment0 = Attach
AO.Responsiveness = 200
AO.MaxTorque = math.huge
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
		State.Noclip = false
	end
end

RunService.RenderStepped:Connect(function()
	if State.Fly then
		local dir = MoveDir()
		local vel = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
		LV.VectorVelocity = LV.VectorVelocity:Lerp(vel, 0.25)
		AO.CFrame = Camera.CFrame
	end
end)

Tabs.Movement:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = ToggleFly
})

Tabs.Movement:CreateSlider({
	Name = "Fly Speed",
	Range = {30,120},
	Increment = 5,
	CurrentValue = 70,
	Callback = function(v) State.FlySpeed = v end
})

RunService.Stepped:Connect(function()
	if State.Noclip and Character then
		for _,v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

Tabs.Movement:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
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
	CurrentValue = false,
	Callback = function(v)
		State.Invisible = v
		SetInvisible(v)
	end
})

local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "QueryESP"

local function ClearESP()
	for _,v in pairs(ESPFolder:GetChildren()) do v:Destroy() end
end

local function CreateESP(plr)
	if plr == LP then return end

	local function Apply(char)
		if not State.ESP then return end

		local hl = Instance.new("Highlight", ESPFolder)
		hl.Adornee = char
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

		if plr.Team ~= LP.Team then
			hl.FillColor = Color3.fromRGB(255,80,80)
		else
			hl.FillColor = Color3.fromRGB(80,255,80)
		end

		hl.FillTransparency = 0.5
	end

	if plr.Character then Apply(plr.Character) end
	plr.CharacterAdded:Connect(Apply)
end

Tabs.Visual:CreateToggle({
	Name = "ESP (Team Color)",
	CurrentValue = false,
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

local SelectedPlayer = nil

local function GetPlayers()
	local t = {}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LP then table.insert(t, p.Name) end
	end
	return t
end

Tabs.Player:CreateDropdown({
	Name = "Player List",
	Options = GetPlayers(),
	Callback = function(v)
		SelectedPlayer = Players:FindFirstChild(v)
	end
})

Tabs.Player:CreateButton({
	Name = "Teleport To Player",
	Callback = function()
		if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
			RootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
		end
	end
})

local ClickTP = false

Tabs.Movement:CreateToggle({
	Name = "Click TP",
	CurrentValue = false,
	Callback = function(v) ClickTP = v end
})

UserInputService.InputBegan:Connect(function(i,g)
	if g then return end
	if ClickTP and i.UserInputType == Enum.UserInputType.MouseButton1 then
		local ray = Camera:ScreenPointToRay(i.Position.X, i.Position.Y)
		local hit = Workspace:Raycast(ray.Origin, ray.Direction*500)
		if hit then
			RootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
		end
	end
end)

local WaterPart

RunService.RenderStepped:Connect(function()
	if State.WaterWalk then
		local ray = Workspace:Raycast(RootPart.Position, Vector3.new(0,-6,0))
		if ray and ray.Material == Enum.Material.Water then
			if not WaterPart then
				WaterPart = Instance.new("Part", Workspace)
				WaterPart.Anchored = true
				WaterPart.Size = Vector3.new(25,1,25)
				WaterPart.Transparency = 1
			end
			WaterPart.CFrame = CFrame.new(ray.Position + Vector3.new(0,1,0))
		elseif WaterPart then
			WaterPart:Destroy()
			WaterPart = nil
		end
	end
end)

Tabs.Movement:CreateToggle({
	Name = "Walk On Water",
	CurrentValue = false,
	Callback = function(v) State.WaterWalk = v end
})

RunService.RenderStepped:Connect(function()
	if State.AntiVoid and RootPart.Position.Y < -80 then
		RootPart.CFrame = CFrame.new(0,50,0)
	end

	if State.AntiFall and RootPart.AssemblyLinearVelocity.Y < -120 then
		RootPart.AssemblyLinearVelocity = Vector3.new(0,-30,0)
	end
end)

RunService.Heartbeat:Connect(function()
	if State.AntiFling then
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end
end)

pcall(function()
	local mt = getrawmetatable(game)
	setreadonly(mt,false)
	local old = mt.__namecall
	mt.__namecall = newcclosure(function(self,...)
		local m = getnamecallmethod()
		if tostring(m) == "Kick" then
			return
		end
		return old(self,...)
	end)
end)

UserInputService.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.W then Input.Z = 1 end
	if i.KeyCode == Enum.KeyCode.S then Input.Z = -1 end
	if i.KeyCode == Enum.KeyCode.A then Input.X = -1 end
	if i.KeyCode == Enum.KeyCode.D then Input.X = 1 end
	if i.KeyCode == Enum.KeyCode.Space then Input.Y = 1 end
	if i.KeyCode == Enum.KeyCode.LeftControl then Input.Y = -1 end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.S then Input.Z = 0 end
	if i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.D then Input.X = 0 end
	if i.KeyCode == Enum.KeyCode.Space or i.KeyCode == Enum.KeyCode.LeftControl then Input.Y = 0 end
end)

LP.CharacterAdded:Connect(function(c)
	task.wait(0.3)
	Character = c
	Humanoid = c:WaitForChild("Humanoid")
	RootPart = c:WaitForChild("HumanoidRootPart")
	Attach.Parent = RootPart
	LV.Parent = RootPart
	AO.Parent = RootPart
	if State.Invisible then SetInvisible(true) end
	if State.Fly then ToggleFly(true) end
end)

Rayfield:Notify({
	Title = "Query Hub",
	Content = "Succesfully Loaded Scripts",
	Duration = 4
})