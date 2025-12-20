local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local lp = Players.LocalPlayer

-- ================= MAP INFO =================
local mapName = "Unknown"
pcall(function()
	mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- ================= REMOTE SCAN =================
local Remotes = {}

local function scanRemotes()
	for _,v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") then
			table.insert(Remotes, v)
		end
	end
end
scanRemotes()

-- ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "RemoteBringGUI"
gui.ResetOnSpawn = false

-- Floating Button
local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromScale(0.18,0.08)
float.Position = UDim2.fromScale(0.02,0.5)
float.Text = "REMOTE"
float.TextScaled = true
float.BackgroundColor3 = Color3.fromRGB(20,20,20)
float.TextColor3 = Color3.new(1,1,1)
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(0,14)

-- Panel
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.9,0.7)
panel.Position = UDim2.fromScale(0.05,0.15)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

-- Title
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.fromScale(1,0.08)
title.BackgroundTransparency = 1
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Text = "REMOTE EVENT SCANNER"

-- Info
local info = Instance.new("TextLabel", panel)
info.Size = UDim2.fromScale(1,0.06)
info.Position = UDim2.fromScale(0,0.08)
info.BackgroundTransparency = 1
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.new(1,1,1)
info.Text = "MAP: "..mapName.." | "..game.PlaceId

-- Selected Remote
local selectedRemote
local selectedLabel = Instance.new("TextLabel", panel)
selectedLabel.Size = UDim2.fromScale(1,0.06)
selectedLabel.Position = UDim2.fromScale(0,0.14)
selectedLabel.BackgroundTransparency = 1
selectedLabel.TextScaled = true
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextColor3 = Color3.fromRGB(0,255,0)
selectedLabel.Text = "REMOTE: NONE"

-- Scroll
local list = Instance.new("ScrollingFrame", panel)
list.Size = UDim2.fromScale(0.9,0.4)
list.Position = UDim2.fromScale(0.05,0.22)
list.CanvasSize = UDim2.new(0,0,0,#Remotes*45)
list.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,6)

-- Remote Buttons
for _,remote in ipairs(Remotes) do
	local b = Instance.new("TextButton", list)
	b.Size = UDim2.new(1,0,0,40)
	b.Text = remote:GetFullName()
	b.TextScaled = true
	b.Font = Enum.Font.Gotham
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

	b.MouseButton1Click:Connect(function()
		selectedRemote = remote
		selectedLabel.Text = "REMOTE: "..remote.Name
	end)
end

-- Input
local box = Instance.new("TextBox", panel)
box.Size = UDim2.fromScale(0.9,0.08)
box.Position = UDim2.fromScale(0.05,0.65)
box.PlaceholderText = "Nama Player"
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

-- Bring Buttons
local function makeBtn(text,x,callback)
	local b = Instance.new("TextButton", panel)
	b.Size = UDim2.fromScale(0.42,0.08)
	b.Position = UDim2.fromScale(x,0.76)
	b.Text = text
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	b.MouseButton1Click:Connect(callback)
end

makeBtn("BRING PLAYER",0.05,function()
	if selectedRemote and box.Text ~= "" then
		selectedRemote:FireServer("player", box.Text)
	end
end)

makeBtn("BRING ALL",0.53,function()
	if not selectedRemote then return end
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			selectedRemote:FireServer("player", plr.Name)
		end
	end
end)

-- Toggle
float.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

print("Loaded | Remotes:", #Remotes)