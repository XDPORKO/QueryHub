--==================================================
-- QUERY HUB | UNIVERSAL SCRIPT
-- Rayfield | No Loading | Delta Safe
--==================================================

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")

local LP = Players.LocalPlayer
if not LP then return end

local Camera = WS.CurrentCamera
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

--==================================================
-- UI (NO LOADING / NO ICON)
--==================================================

local Rayfield = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"
))()

pcall(function()
	if Rayfield.Loading then
		Rayfield.Loading:Destroy()
	end
end)

local Window = Rayfield:CreateWindow({
	Name = "Query Hub",
	LoadingTitle = "",
	LoadingSubtitle = "",
	ConfigurationSaving = { Enabled = false }
})

local Tabs = {
	Movement = Window:CreateTab("Movement"),
	Player   = Window:CreateTab("Player"),
	Visual   = Window:CreateTab("Visual"),
	Misc     = Window:CreateTab("Misc")
}

--==================================================
-- STATE
--==================================================

local State = {
	Fly=false,
	Noclip=false,
	Invisible=false,
	Speed=false,
	Spectate=false,
	AntiVoid=true,
	AntiFall=true,
	AntiFling=true,
	WalkWater=false
}

--==================================================
-- INPUT
--==================================================

local Input = {X=0,Y=0,Z=0}
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

UIS.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode==Enum.KeyCode.W then Input.Z=1 end
	if i.KeyCode==Enum.KeyCode.S then Input.Z=-1 end
	if i.KeyCode==Enum.KeyCode.A then Input.X=-1 end
	if i.KeyCode==Enum.KeyCode.D then Input.X=1 end
	if i.KeyCode==Enum.KeyCode.LeftControl then Input.Y=-1 end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode==Enum.KeyCode.W or i.KeyCode==Enum.KeyCode.S then Input.Z=0 end
	if i.KeyCode==Enum.KeyCode.A or i.KeyCode==Enum.KeyCode.D then Input.X=0 end
	if i.KeyCode==Enum.KeyCode.LeftControl then Input.Y=0 end
end)

--==================================================
-- FLY (STABLE)
--==================================================

local Attach = Instance.new("Attachment", HRP)

local LV = Instance.new("LinearVelocity", HRP)
LV.Attachment0 = Attach
LV.MaxForce = math.huge
LV.Enabled = false

local AO = Instance.new("AlignOrientation", HRP)
AO.Attachment0 = Attach
AO.MaxTorque = math.huge
AO.Responsiveness = 200
AO.RigidityEnabled = true
AO.Enabled = false

local FlySpeed = 70

local function GetDir()
	if IsMobile then
		local d = Humanoid.MoveDirection
		return Vector3.new(d.X, Input.Y, d.Z)
	end
	return Camera.CFrame.LookVector*Input.Z
		+ Camera.CFrame.RightVector*Input.X
		+ Vector3.new(0,Input.Y,0)
end

RS.RenderStepped:Connect(function(dt)
	if State.Fly then
		local d = GetDir()
		LV.VectorVelocity = LV.VectorVelocity:Lerp(
			d.Magnitude>0 and d.Unit*FlySpeed or Vector3.zero,0.25)
		AO.CFrame = Camera.CFrame
	end
end)

Tabs.Movement:CreateToggle({
	Name="Fly",
	CurrentValue=false,
	Callback=function(v)
		State.Fly=v
		LV.Enabled=v
		AO.Enabled=v
		Humanoid.AutoRotate=not v
		State.Noclip=v
	end
})

Tabs.Movement:CreateSlider({
	Name="Fly Speed",
	Range={30,120},
	Increment=5,
	CurrentValue=70,
	Callback=function(v) FlySpeed=v end
})

--==================================================
-- SPEED BYPASS
--==================================================

local SpeedValue = 28

Tabs.Movement:CreateToggle({
	Name="Speed Bypass",
	CurrentValue=false,
	Callback=function(v) State.Speed=v end
})

Tabs.Movement:CreateSlider({
	Name="Speed Value",
	Range={20,60},
	Increment=1,
	CurrentValue=28,
	Callback=function(v) SpeedValue=v end
})

RS.RenderStepped:Connect(function(dt)
	if State.Speed then
		local d = Humanoid.MoveDirection
		if d.Magnitude>0 then
			HRP.CFrame += d*SpeedValue*dt
		end
	end
end)

--==================================================
-- NOCLIP
--==================================================

RS.Stepped:Connect(function()
	if State.Noclip then
		for _,v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide=false end
		end
	end
end)

--==================================================
-- INVISIBLE
--==================================================

local function SetInvisible(on)
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.LocalTransparencyModifier = on and 1 or 0
		end
	end
end

Tabs.Player:CreateToggle({
	Name="Invisible",
	CurrentValue=false,
	Callback=function(v)
		State.Invisible=v
		SetInvisible(v)
	end
})

--==================================================
-- PLAYER LIST + TP + SPECTATE
--==================================================

local SelectedPlayer
local SpectateTarget

local Drop = Tabs.Player:CreateDropdown({
	Name="Player List",
	Options={},
	Callback=function(v)
		SelectedPlayer = Players:FindFirstChild(v)
		if State.Spectate and SelectedPlayer and SelectedPlayer.Character then
			Camera.CameraSubject = SelectedPlayer.Character:FindFirstChild("Humanoid")
		end
	end
})

local function RefreshPlayers()
	local t={}
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then table.insert(t,p.Name) end
	end
	Drop:Set(t)
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

Tabs.Player:CreateButton({
	Name="Teleport To Player",
	Callback=function()
		if SelectedPlayer and SelectedPlayer.Character then
			local r=SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
			if r then HRP.CFrame=r.CFrame*CFrame.new(0,0,3) end
		end
	end
})

Tabs.Player:CreateToggle({
	Name="Spectate Player",
	CurrentValue=false,
	Callback=function(v)
		State.Spectate=v
		if not v then
			Camera.CameraSubject=Humanoid
		elseif SelectedPlayer and SelectedPlayer.Character then
			Camera.CameraSubject=SelectedPlayer.Character.Humanoid
		end
	end
})

--==================================================
-- ESP (TEAM COLOR + DISTANCE)
--==================================================

local ESP = {On=false,Objs={}}

local function TeamColor(p)
	if p.Team and p.Team.TeamColor then
		return p.Team.TeamColor.Color
	end
	return Color3.fromRGB(0,200,255)
end

local function AddESP(p)
	if p==LP then return end
	local function apply(char)
		if ESP.Objs[p] then ESP.Objs[p]:Destroy() end
		local f=Instance.new("Folder",CG)
		ESP.Objs[p]=f

		local hl=Instance.new("Highlight",f)
		hl.Adornee=char
		hl.FillColor=TeamColor(p)
		hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop

		local bb=Instance.new("BillboardGui",f)
		bb.Size=UDim2.fromOffset(150,40)
		bb.AlwaysOnTop=true
		bb.Adornee=char:WaitForChild("Head",3)

		local t=Instance.new("TextLabel",bb)
		t.Size=UDim2.fromScale(1,1)
		t.BackgroundTransparency=1
		t.TextScaled=true
		t.Font=Enum.Font.GothamBold

		RS.RenderStepped:Connect(function()
			if ESP.On and HRP and char:FindFirstChild("HumanoidRootPart") then
				local d=(HRP.Position-char.HumanoidRootPart.Position).Magnitude
				t.Text=p.Name.." | "..math.floor(d).."m"
			end
		end)
	end
	if p.Character then apply(p.Character) end
	p.CharacterAdded:Connect(apply)
end

Tabs.Visual:CreateToggle({
	Name="ESP",
	CurrentValue=false,
	Callback=function(v)
		ESP.On=v
		for _,o in pairs(ESP.Objs) do o:Destroy() end
		table.clear(ESP.Objs)
		if v then
			for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
		end
	end
})

--==================================================
-- WATER WALK / ANTI VOID / ANTI FLING
--==================================================

Tabs.Movement:CreateToggle({
	Name="Walk On Water",
	CurrentValue=false,
	Callback=function(v) State.WalkWater=v end
})

Tabs.Movement:CreateToggle({
	Name="Anti Void",
	CurrentValue=true,
	Callback=function(v) State.AntiVoid=v end
})

Tabs.Misc:CreateToggle({
	Name="Anti Fling",
	CurrentValue=true,
	Callback=function(v) State.AntiFling=v end
})

RS.RenderStepped:Connect(function()
	if State.AntiVoid and HRP.Position.Y<-80 then
		HRP.CFrame=CFrame.new(0,50,0)
	end
	if State.AntiFling and HRP.AssemblyLinearVelocity.Magnitude>120 then
		HRP.AssemblyLinearVelocity=Vector3.zero
	end
end)

--==================================================
-- SAFE ANTI KICK
--==================================================

pcall(function()
	local mt=getrawmetatable(game)
	setreadonly(mt,false)
	local old=mt.__namecall
	mt.__namecall=newcclosure(function(self,...)
		if getnamecallmethod()=="Kick" then return end
		return old(self,...)
	end)
	setreadonly(mt,true)
end)

Rayfield:Notify({
	Title="Query Hub",
	Content="Loaded Successfully",
	Duration=4
})