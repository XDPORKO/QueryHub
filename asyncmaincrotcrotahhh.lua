local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = WS.CurrentCamera

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()

local Window = Fluent:CreateWindow({
	Title = "Query Hub",
	SubTitle = "Universal Script",
	TabWidth = 120,
	Size = UDim2.fromOffset(540, 460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
	Movement = Window:AddTab({ Title = "Movement", Icon = "rocket" }),
	Player = Window:AddTab({ Title = "Player", Icon = "user" })
}

local State = {
	Fly = false,
	Noclip = false,
	Invisible = false,
	FlySpeed = 70,
	JumpHold = false
}

local Input = { X = 0, Y = 0, Z = 0 }
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local Attachment = Instance.new("Attachment", RootPart)

local LinearVelocity = Instance.new("LinearVelocity", RootPart)
LinearVelocity.Attachment0 = Attachment
LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
LinearVelocity.MaxForce = math.huge
LinearVelocity.Enabled = false

local AlignOrientation = Instance.new("AlignOrientation", RootPart)
AlignOrientation.Attachment0 = Attachment
AlignOrientation.MaxTorque = math.huge
AlignOrientation.Responsiveness = 200
AlignOrientation.RigidityEnabled = true
AlignOrientation.Enabled = false

local function GetMoveDirection()
	if IsMobile then
		local d = Humanoid.MoveDirection
		return Vector3.new(d.X, Input.Y, d.Z)
	else
		return Camera.CFrame.LookVector * Input.Z
			+ Camera.CFrame.RightVector * Input.X
			+ Vector3.new(0, Input.Y, 0)
	end
end

local function ToggleFly(v)
	State.Fly = v
	if v then
		Humanoid.AutoRotate = false
		LinearVelocity.Enabled = true
		AlignOrientation.Enabled = true
		State.Noclip = true
	else
		LinearVelocity.Enabled = false
		AlignOrientation.Enabled = false
		LinearVelocity.VectorVelocity = Vector3.zero
		Humanoid.AutoRotate = true
		State.Noclip = false
	end
end

RS.RenderStepped:Connect(function()
	if State.Fly then
		local dir = GetMoveDirection()
		local target = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
		LinearVelocity.VectorVelocity = LinearVelocity.VectorVelocity:Lerp(target, 0.25)
		AlignOrientation.CFrame = Camera.CFrame
	end

	if State.JumpHold and Humanoid.FloorMaterial == Enum.Material.Air then
		RootPart.AssemblyLinearVelocity += Vector3.new(0, 1.5, 0)
	end
end)

RS.Stepped:Connect(function()
	if State.Noclip then
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

local function ApplyInvisible(on)
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.LocalTransparencyModifier = on and 1 or 0
		end
	end
end

Tabs.Movement:AddToggle("FlyToggle", {
	Title = "Fly",
	Default = false,
	Callback = ToggleFly
})

Tabs.Movement:AddSlider("FlySpeed", {
	Title = "Fly Speed",
	Min = 30,
	Max = 100,
	Default = 70,
	Rounding = 0,
	Callback = function(v)
		State.FlySpeed = v
	end
})

Tabs.Player:AddToggle("InvisibleToggle", {
	Title = "Invisible",
	Default = false,
	Callback = function(v)
		State.Invisible = v
		ApplyInvisible(v)
	end
})

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.W then Input.Z = 1 end
	if i.KeyCode == Enum.KeyCode.S then Input.Z = -1 end
	if i.KeyCode == Enum.KeyCode.A then Input.X = -1 end
	if i.KeyCode == Enum.KeyCode.D then Input.X = 1 end
	if i.KeyCode == Enum.KeyCode.Space then State.JumpHold = true end
	if i.KeyCode == Enum.KeyCode.LeftControl then Input.Y = -1 end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.S then Input.Z = 0 end
	if i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.D then Input.X = 0 end
	if i.KeyCode == Enum.KeyCode.Space then State.JumpHold = false end
	if i.KeyCode == Enum.KeyCode.LeftControl then Input.Y = 0 end
end)

LP.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
	Attachment.Parent = RootPart
	LinearVelocity.Parent = RootPart
	AlignOrientation.Parent = RootPart
	if State.Invisible then ApplyInvisible(true) end
	if State.Fly then ToggleFly(true) end
end)

local ESP = {
	Enabled = false,
	Objects = {}
}

local PlayersList = {}
local SelectedPlayer = nil

local function ClearESP()
	for _, v in pairs(ESP.Objects) do
		if v then v:Destroy() end
	end
	table.clear(ESP.Objects)
end

local function CreateESP(player)
	if player == LP then return end

	local function Apply(char)
		if ESP.Objects[player] then
			ESP.Objects[player]:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Parent = game:GetService("CoreGui")
		ESP.Objects[player] = folder

		local highlight = Instance.new("Highlight")
		highlight.Adornee = char
		highlight.FillColor = Color3.fromRGB(0, 200, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = folder

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.fromOffset(160, 40)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = char:WaitForChild("Head", 3)
		billboard.Parent = folder

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = billboard

		RS.RenderStepped:Connect(function()
			if not ESP.Enabled then return end
			if RootPart and char:FindFirstChild("HumanoidRootPart") then
				local d = (RootPart.Position - char.HumanoidRootPart.Position).Magnitude
				label.Text = player.Name .. " | " .. math.floor(d) .. "m"
			end
		end)
	end

	if player.Character then
		Apply(player.Character)
	end

	player.CharacterAdded:Connect(Apply)
end

Tabs.Visual = Window:AddTab({ Title = "Visual", Icon = "eye" })

Tabs.Visual:AddToggle("ESP", {
	Title = "ESP",
	Default = false,
	Callback = function(v)
		ESP.Enabled = v
		if not v then
			ClearESP()
		else
			for _, p in ipairs(Players:GetPlayers()) do
				CreateESP(p)
			end
		end
	end
})

Players.PlayerAdded:Connect(function(p)
	if ESP.Enabled then
		CreateESP(p)
	end
end)

Players.PlayerRemoving:Connect(function(p)
	if ESP.Objects[p] then
		ESP.Objects[p]:Destroy()
		ESP.Objects[p] = nil
	end
end)

local function RefreshPlayers()
	table.clear(PlayersList)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP then
			table.insert(PlayersList, p.Name)
		end
	end
end

RefreshPlayers()

Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

Tabs.Player:AddDropdown("PlayerList", {
	Title = "Player List",
	Values = PlayersList,
	Callback = function(v)
		SelectedPlayer = Players:FindFirstChild(v)
	end
})

Tabs.Player:AddButton({
	Title = "Teleport To Player",
	Callback = function()
		if SelectedPlayer
			and SelectedPlayer.Character
			and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
			and RootPart then
			RootPart.CFrame =
				SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
		end
	end
})

local AntiVoid = true

Tabs.Movement:AddToggle("AntiVoid", {
	Title = "Anti Void",
	Default = true,
	Callback = function(v)
		AntiVoid = v
	end
})

RS.RenderStepped:Connect(function()
	if AntiVoid and RootPart then
		if RootPart.Position.Y < -60 then
			RootPart.CFrame = CFrame.new(0, 50, 0)
			RootPart.AssemblyLinearVelocity = Vector3.zero
		end
	end
end)

local WalkWater = false
local AntiFall = true

Tabs.Movement:AddToggle("WalkOnWater", {
	Title = "Walk On Water",
	Default = false,
	Callback = function(v)
		WalkWater = v
	end
})

Tabs.Movement:AddToggle("AntiFall", {
	Title = "Anti Fall",
	Default = true,
	Callback = function(v)
		AntiFall = v
	end
})

local WaterPart = nil

RS.RenderStepped:Connect(function()
	if WalkWater and RootPart then
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {Character}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

		local ray = WS:Raycast(RootPart.Position, Vector3.new(0, -6, 0), rayParams)
		if ray and ray.Material == Enum.Material.Water then
			if not WaterPart then
				WaterPart = Instance.new("Part")
				WaterPart.Anchored = true
				WaterPart.CanCollide = true
				WaterPart.Transparency = 1
				WaterPart.Size = Vector3.new(25, 1, 25)
				WaterPart.Parent = WS
			end
			WaterPart.CFrame = CFrame.new(
				RootPart.Position.X,
				ray.Position.Y + 0.9,
				RootPart.Position.Z
			)
		elseif WaterPart then
			WaterPart:Destroy()
			WaterPart = nil
		end
	end

	if AntiFall and RootPart then
		if RootPart.Velocity.Y < -80 then
			RootPart.AssemblyLinearVelocity =
				Vector3.new(RootPart.Velocity.X, -20, RootPart.Velocity.Z)
		end
	end
end)

LP.CharacterAdded:Connect(function(char)
	task.wait(0.25)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")

	if State.Invisible then
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				v.LocalTransparencyModifier = 1
			end
		end
	end

	if State.Fly then
		Humanoid.AutoRotate = false
		LinearVelocity.Enabled = true
		AlignOrientation.Enabled = true
	end
end)

local LastSafeCFrame = RootPart.CFrame
local SafetyTick = 0

RS.Heartbeat:Connect(function(dt)
	SafetyTick += dt
	if SafetyTick >= 0.25 then
		SafetyTick = 0
		if RootPart and RootPart.Position.Y > -20 then
			LastSafeCFrame = RootPart.CFrame
		end
	end
end)

RS.RenderStepped:Connect(function()
	if RootPart then
		if RootPart.Position.Y < -120 then
			RootPart.CFrame = LastSafeCFrame + Vector3.new(0, 6, 0)
			RootPart.AssemblyLinearVelocity = Vector3.zero
			RootPart.AssemblyAngularVelocity = Vector3.zero
		end
	end
end)

RS.Stepped:Connect(function()
	if State.Noclip and Character then
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

local function RebindCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")

	Attachment = Instance.new("Attachment", RootPart)
	LinearVelocity.Attachment0 = Attachment
	AlignOrientation.Attachment0 = Attachment

	if State.Fly then
		Humanoid.AutoRotate = false
		LinearVelocity.Enabled = true
		AlignOrientation.Enabled = true
	end

	if State.Invisible then
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				v.LocalTransparencyModifier = 1
			end
		end
	end
end

LP.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	RebindCharacter(char)
end)

Fluent:Notify({
	Title = "Query Hub",
	Content = "Loaded Successfully",
	Duration = 4
})
