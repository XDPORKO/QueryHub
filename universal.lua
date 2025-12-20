local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

local Config = {
	Fly = false,
	Noclip = false,
	InfiniteJump = false,
	WalkOnWater = false,
	SpeedSlide = false,
	FlySpeed = 80,
	WalkSpeed = 24,
	JumpPower = 75,
	MobileJoystick = true,
	MobileSensitivity = 1.2,
	MobileInvertX = false,
	MobileInvertZ = false,
	KeybindToggle = Enum.KeyCode.F, 
	Theme = {
		Primary = Color3.fromRGB(80, 180, 255),
		Secondary = Color3.fromRGB(30, 35, 55),
		Accent = Color3.fromRGB(0, 200, 255),
		Text = Color3.fromRGB(240, 245, 255)
	},
	GuiScale = 1.0,
	GuiTransparency = 0.9,
	AutoSave = true
}

local DEADZONE = 0.05
local Input = {X=0,Y=0,Z=0}
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local RootJoint
local Gui, Main, IconGui, Icon
local WaterPart

local Attach = Instance.new("Attachment", RootPart)

local Align = Instance.new("AlignOrientation")
Align.Attachment0 = Attach
Align.Responsiveness = 200
Align.MaxTorque = math.huge
Align.RigidityEnabled = true
Align.Enabled = false
Align.Parent = RootPart

local Velocity = Instance.new("LinearVelocity")
Velocity.Attachment0 = Attach
Velocity.RelativeTo = Enum.ActuatorRelativeTo.World
Velocity.MaxForce = math.huge
Velocity.Enabled = false
Velocity.Parent = RootPart

local function SetFly(state)
	Config.Fly = state
	if state then
		Humanoid.AutoRotate = false
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		Align.Enabled = true
		Velocity.Enabled = true
		Config.Noclip = true
	else
		Align.Enabled = false
		Velocity.Enabled = false
		Velocity.VectorVelocity = Vector3.zero
		Humanoid.AutoRotate = true
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		Config.Noclip = false
	end
end

local function Create(instanceType, props)
	local obj = Instance.new(instanceType)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function LerpVector(a, b, alpha)
	return Vector3.new(
		a.X + (b.X - a.X) * alpha,
		a.Y + (b.Y - a.Y) * alpha,
		a.Z + (b.Z - a.Z) * alpha
	)
end

local function LockBody()
	Humanoid.AutoRotate = false
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	RootPart.AssemblyAngularVelocity = Vector3.zero
	RootPart.AssemblyLinearVelocity = Vector3.zero
	RootJoint = Character:FindFirstChild("RootJoint", true) or Character:FindFirstChild("RootRigAttachment", true)
	if RootJoint and (RootJoint:IsA("Motor6D") or RootJoint:IsA("JointInstance")) then
		RootJoint.Enabled = false
	end
end

local function UnlockBody()
	Humanoid.AutoRotate = true
	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	if RootJoint then
		RootJoint.Enabled = true
	end
end

local function SetCollision(state)
	for _, descendant in ipairs(Character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = state
		end
	end
end

local function GetMoveDirection()
	if IsMobile and Config.MobileJoystick then
		local dir = Humanoid.MoveDirection
		return Vector3.new(
			dir.X * Config.MobileSensitivity,
			Input.Y,
			dir.Z * Config.MobileSensitivity
		)
	else
		return Camera.CFrame.LookVector * Input.Z
		     + Camera.CFrame.RightVector * Input.X
		     + Vector3.new(0, Input.Y, 0)
	end
end

local function CreatePremiumGUI()
	Gui = Create("ScreenGui", {
		Name = "QFlyPremium",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = CoreGui
	})
	
	Main = Create("Frame", {
		Size = UDim2.fromOffset(320 * Config.GuiScale, 520 * Config.GuiScale),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Config.Theme.Secondary,
		BackgroundTransparency = 1 - Config.GuiTransparency,
		Parent = Gui
	})
	Create("UICorner", {CornerRadius = UDim.new(0, 12 * Config.GuiScale), Parent = Main})
	Create("UIStroke", {
		Color = Config.Theme.Primary,
		Thickness = 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = Main
	})

	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40 * Config.GuiScale),
		Text = "⚡ QFLY PREMIUM",
		Font = Enum.Font.GothamBlack,
		TextSize = 22 * Config.GuiScale,
		TextColor3 = Config.Theme.Accent,
		BackgroundTransparency = 1,
		Parent = Main
	})
	
	local CloseBtn = Create("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -34, 0, 6),
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255,120,120),
		BackgroundColor3 = Color3.fromRGB(45,50,75),
		Parent = Main
	})
	Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = CloseBtn})

	CloseBtn.MouseButton1Click:Connect(function()
		Main.Visible = false
	end)
	
	local function CreateToggle(text, yPos, callback)
		local frame = Create("Frame", {
			Size = UDim2.new(0.9, 0, 0, 36 * Config.GuiScale),
			Position = UDim2.new(0.05, 0, 0, yPos * 44 * Config.GuiScale),
			BackgroundTransparency = 1,
			Parent = Main
		})

		local btn = Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Config.Theme.Secondary,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = "",
			Parent = frame
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 8 * Config.GuiScale), Parent = btn})
		Create("UIStroke", {Color = Color3.fromRGB(60, 60, 90), Parent = btn})

		local label = Create("TextLabel", {
			Size = UDim2.new(0.7, 0, 1, 0),
			Text = text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 16 * Config.GuiScale,
			TextColor3 = Config.Theme.Text,
			BackgroundTransparency = 1,
			Parent = btn
		})

		local stateLabel = Create("TextLabel", {
			Size = UDim2.new(0.3, 0, 1, 0),
			Position = UDim2.new(0.7, 0, 0, 0),
			Font = Enum.Font.GothamBold,
			TextSize = 16 * Config.GuiScale,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			BackgroundTransparency = 1,
			Parent = btn
		})

		local state = false
		local function update()
			stateLabel.Text = state and "ON" or "OFF"
			stateLabel.TextColor3 = state and Config.Theme.Accent or Color3.fromRGB(200, 200, 200)
		end

		btn.MouseButton1Click:Connect(function()
			state = not state
			update()
			callback(state)
		end)
		update()
	end

	local function CreateStepper(title, yPos, min, max, step, getter, setter)
		local frame = Create("Frame", {
			Size = UDim2.new(0.9, 0, 0, 36 * Config.GuiScale),
			Position = UDim2.new(0.05, 0, 0, yPos * 44 * Config.GuiScale),
			BackgroundTransparency = 1,
			Parent = Main
		})

		local label = Create("TextLabel", {
			Size = UDim2.new(0.6, 0, 1, 0),
			Text = title .. ": " .. getter(),
			Font = Enum.Font.GothamSemibold,
			TextSize = 15 * Config.GuiScale,
			TextColor3 = Config.Theme.Text,
			BackgroundTransparency = 1,
			Parent = frame
		})

		local dec = Create("TextButton", {
			Size = UDim2.new(0.18, 0, 0.8, 0),
			Position = UDim2.new(0.62, 0, 0.1, 0),
			Text = "−",
			Font = Enum.Font.GothamBold,
			TextSize = 20 * Config.GuiScale,
			BackgroundColor3 = Color3.fromRGB(50, 55, 75),
			Parent = frame
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = dec})

		local inc = Create("TextButton", {
			Size = UDim2.new(0.18, 0, 0.8, 0),
			Position = UDim2.new(0.82, 0, 0.1, 0),
			Text = "+",
			Font = Enum.Font.GothamBold,
			TextSize = 20 * Config.GuiScale,
			BackgroundColor3 = Color3.fromRGB(50, 55, 75),
			Parent = frame
		})
		Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = inc})

		local function refresh()
			label.Text = title .. ": " .. getter()
		end

		dec.MouseButton1Click:Connect(function()
			setter(math.clamp(getter() - step, min, max))
			refresh()
		end)
		inc.MouseButton1Click:Connect(function()
			setter(math.clamp(getter() + step, min, max))
			refresh()
		end)
	end

	CreateToggle("✨ Fly", 2, function(v)
		Config.Fly = v
		if v then
			LockBody()
			Align.Enabled = true
			Velocity.Enabled = true
			Config.Noclip = true
		else
			Align.Enabled = false
			Velocity.Enabled = false
			Velocity.VectorVelocity = Vector3.zero
			SetCollision(true)
			UnlockBody()
		end
	end)

	CreateToggle("👻 Noclip", 3, function(v)
		Config.Noclip = v
	end)

	CreateToggle("♾️ Infinite Jump", 4, function(v)
		Config.InfiniteJump = v
	end)

	CreateToggle("💧 Walk on Water", 5, function(v)
		Config.WalkOnWater = v
	end)

	CreateToggle("🚀 Speed Slide", 6, function(v)
		Config.SpeedSlide = v
	end)

	CreateStepper("Fly Speed", 8, 20, 200, 5, function() return Config.FlySpeed end, function(v) Config.FlySpeed = v end)
	CreateStepper("Walk Speed", 9, 10, 100, 2, function() return Config.WalkSpeed end, function(v) Config.WalkSpeed = v Humanoid.WalkSpeed = v end)
	CreateStepper("Jump Power", 10, 30, 200, 5, function() return Config.JumpPower end, function(v) Config.JumpPower = v Humanoid.JumpPower = v end)

	if IsMobile then
		CreateToggle("📱 Mobile Joystick", 12, function(v) Config.MobileJoystick = v end)
		CreateStepper("Sensitivity", 13, 0.3, 3, 0.1, function() return Config.MobileSensitivity end, function(v) Config.MobileSensitivity = v end)
		CreateToggle("↔️ Invert X", 14, function(v) Config.MobileInvertX = v end)
		CreateToggle("↕️ Invert Z", 15, function(v) Config.MobileInvertZ = v end)

		local upBtn = Create("TextButton", {
			Size = UDim2.fromOffset(50, 30),
			Position = UDim2.fromScale(0.92, 0.6),
			Text = "▲",
			Font = Enum.Font.GothamBlack,
			BackgroundColor3 = Config.Theme.Primary,
			Parent = Gui
		})
		local downBtn = upBtn:Clone()
		downBtn.Text = "▼"
		downBtn.Position = UDim2.fromScale(0.92, 0.67)
		downBtn.Parent = Gui

		upBtn.MouseButton1Down:Connect(function() Input.Y = 1 end)
		upBtn.MouseButton1Up:Connect(function() Input.Y = 0 end)
		downBtn.MouseButton1Down:Connect(function() Input.Y = -1 end)
		downBtn.MouseButton1Up:Connect(function() Input.Y = 0 end)
	end

	IconGui = Create("ScreenGui", {
		ResetOnSpawn = false,
		Parent = CoreGui
	})
	Icon = Create("ImageButton", {
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.fromScale(0.02, 0.88),
		BackgroundColor3 = Color3.fromRGB(25, 30, 45),
		Image = "rbxassetid://71212053414568", 
		Parent = IconGui
	})
	
local dragging = false
local dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	Icon.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Icon.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Icon.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Icon.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateDrag(input)
	end
end)

	Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Icon})
	Create("UIStroke", {Color = Config.Theme.Accent, Thickness = 2, Parent = Icon})

	local guiVisible = true
	Icon.MouseButton1Click:Connect(function()
		guiVisible = not guiVisible
		Main.Visible = guiVisible
	end)
	
	Main:TweenPosition(
		UDim2.fromScale(0.5, 0.5),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.3,
		true,
		nil
	)
end

UserInputService.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode==Enum.KeyCode.W then Input.Z=1 end
	if i.KeyCode==Enum.KeyCode.S then Input.Z=-1 end
	if i.KeyCode==Enum.KeyCode.A then Input.X=-1 end
	if i.KeyCode==Enum.KeyCode.D then Input.X=1 end
	if i.KeyCode==Enum.KeyCode.Space then Input.Y=1 end
	if i.KeyCode==Enum.KeyCode.LeftControl then Input.Y=-1 end
	if i.KeyCode == Config.KeybindToggle then
	SetFly(not Config.Fly)
end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode==Enum.KeyCode.W or i.KeyCode==Enum.KeyCode.S then Input.Z=0 end
	if i.KeyCode==Enum.KeyCode.A or i.KeyCode==Enum.KeyCode.D then Input.X=0 end
	if i.KeyCode==Enum.KeyCode.Space or i.KeyCode==Enum.KeyCode.LeftControl then Input.Y=0 end
end)

RunService.RenderStepped:Connect(function()
	if Config.Fly then
		local dir = GetMoveDirection()
		local target = dir.Magnitude > 0 and dir.Unit * Config.FlySpeed or Vector3.zero
		Velocity.VectorVelocity = Velocity.VectorVelocity:Lerp(target, 0.25)
		Align.CFrame = Camera.CFrame
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end

	if Config.WalkOnWater and RootPart then
		local ray = Workspace:Raycast(RootPart.Position, Vector3.new(0, -12, 0))
		if ray and ray.Material == Enum.Material.Water then
			if not WaterPart then
				WaterPart = Create("Part", {
					Anchored = true,
					CanCollide = true,
					Transparency = 1,
					Size = Vector3.new(20, 1, 20),
					Parent = Workspace
				})
			end
			WaterPart.CFrame =
				CFrame.new(RootPart.Position.X, ray.Position.Y + 0.8, RootPart.Position.Z)
		elseif WaterPart then
			WaterPart:Destroy()
			WaterPart = nil
		end
	end

	if Humanoid then
		Humanoid.WalkSpeed = Config.WalkSpeed
		Humanoid.JumpPower = Config.JumpPower
	end
end)

RunService.Stepped:Connect(function()
	if Config.Noclip then
		for _,p in ipairs(Character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if Config.InfiniteJump and Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.4)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")

	if Attach then Attach:Destroy() end
	Attach = Instance.new("Attachment", RootPart)
	Align.Attachment0 = Attach
	Velocity.Attachment0 = Attach

	if Config.Fly then
		SetFly(true)
	end
end)

spawn(function()
	wait(0.2)
	CreatePremiumGUI()
	local title = Main:FindFirstChildWhichIsA("TextLabel")
	if title then
		title.Text = "Loading Script.."
		wait(1)
		title.Text = "Develope By rappnotdev.proto.site.vip"
	end
end)

spawn(function()
	while true do
		wait(30)
		if LocalPlayer and LocalPlayer.Parent then
			pcall(function()
				local ping = tick()
			end)
		end
	end
end)