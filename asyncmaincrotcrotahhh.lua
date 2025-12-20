--================ SAFE SERVICES =================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")

local LP = Players.LocalPlayer
if not LP then return end

local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local Camera = WS:FindFirstChildOfClass("Camera") or WS:WaitForChild("Camera")

--================ UI LOADER =================
local Fluent
do
	local ok, lib = pcall(function()
		return loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"
		))()
	end)
	if not ok then
		warn("Fluent gagal load (HttpGet blocked)")
		return
	end
	Fluent = lib
end

--================ WINDOW =================
local Window = Fluent:CreateWindow({
	Title = "Query Hub",
	SubTitle = "Universal | All Executor",
	Size = UDim2.fromOffset(540,460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
	Move   = Window:AddTab({Title="Movement",Icon="rocket"}),
	Player = Window:AddTab({Title="Player",Icon="user"}),
	Visual = Window:AddTab({Title="Visual",Icon="eye"})
}

--================ CHARACTER =================
local Character, Humanoid, RootPart

local function BindCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
end

BindCharacter(LP.Character or LP.CharacterAdded:Wait())

LP.CharacterAdded:Connect(function(char)
	task.wait(0.25)
	BindCharacter(char)
end)

--================ STATE =================
local State = {
	Fly=false, Noclip=false, Invisible=false,
	FlySpeed=70, JumpHold=false,
	AntiVoid=true, WalkWater=false, AntiFall=true
}

--================ FLY CORE =================
local Attach = Instance.new("Attachment")
local LV = Instance.new("LinearVelocity")
local AO = Instance.new("AlignOrientation")

local function SetupFly()
	Attach.Parent = RootPart

	LV.Attachment0 = Attach
	LV.MaxForce = math.huge
	LV.RelativeTo = Enum.ActuatorRelativeTo.World
	LV.Enabled = false
	LV.Parent = RootPart

	AO.Attachment0 = Attach
	AO.MaxTorque = math.huge
	AO.Responsiveness = 200
	AO.RigidityEnabled = true
	AO.Enabled = false
	AO.Parent = RootPart
end

SetupFly()

local Input={X=0,Y=0,Z=0}
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function MoveDir()
	if IsMobile then
		local d = Humanoid.MoveDirection
		return Vector3.new(d.X, Input.Y, d.Z)
	end
	return Camera.CFrame.LookVector*Input.Z
		+ Camera.CFrame.RightVector*Input.X
		+ Vector3.new(0,Input.Y,0)
end

local function ToggleFly(v)
	State.Fly=v
	if v then
		Humanoid.AutoRotate=false
		LV.Enabled=true
		AO.Enabled=true
		State.Noclip=true
	else
		LV.Enabled=false
		LV.VectorVelocity=Vector3.zero
		AO.Enabled=false
		Humanoid.AutoRotate=true
		State.Noclip=false
	end
end

RS.RenderStepped:Connect(function()
	if State.Fly and RootPart then
		local d=MoveDir()
		local t=d.Magnitude>0 and d.Unit*State.FlySpeed or Vector3.zero
		LV.VectorVelocity=LV.VectorVelocity:Lerp(t,0.25)
		AO.CFrame=Camera.CFrame
	end
end)

--================ NOCLIP =================
RS.Stepped:Connect(function()
	if State.Noclip and Character then
		for _,p in ipairs(Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide=false end
		end
	end
end)

--================ INVISIBLE =================
local function SetInvisible(on)
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.LocalTransparencyModifier = on and 1 or 0
		end
	end
end

--================ UI BINDS =================
Tabs.Move:AddToggle("Fly",{Title="Fly",Default=false,Callback=ToggleFly})
Tabs.Move:AddSlider("FlySpeed",{Title="Fly Speed",Min=30,Max=100,Default=70,
	Callback=function(v) State.FlySpeed=v end})

Tabs.Player:AddToggle("Invisible",{Title="Invisible",Default=false,
	Callback=function(v) State.Invisible=v SetInvisible(v) end})

Tabs.Move:AddToggle("AntiVoid",{Title="Anti Void",Default=true,
	Callback=function(v) State.AntiVoid=v end})

--================ ANTI VOID =================
RS.RenderStepped:Connect(function()
	if State.AntiVoid and RootPart and RootPart.Position.Y<-80 then
		RootPart.CFrame=CFrame.new(0,60,0)
		RootPart.AssemblyLinearVelocity=Vector3.zero
	end
end)

--================ NOTIFY =================
Fluent:Notify({
	Title="Query Hub",
	Content="Loaded Successfully",
	Duration=4
})
