
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===== MAP INFO =====
local mapName = "Unknown"
pcall(function()
	mapName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- ===== SCAN REMOTES =====
local keywords = {"bring","teleport","tp","summon","pull","grab","warp"}
local remotes = {}

for _,v in ipairs(game:GetDescendants()) do
	if v:IsA("RemoteEvent") then
		table.insert(remotes, v)
	end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "AUTO_BRING_GUI"
gui.ResetOnSpawn = false

-- Floating Button
local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromScale(0.18,0.08)
float.Position = UDim2.fromScale(0.02,0.45)
float.Text = "AUTO"
float.TextScaled = true
float.BackgroundColor3 = Color3.fromRGB(20,20,20)
float.TextColor3 = Color3.new(1,1,1)
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(0,14)

-- Panel
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.92,0.6)
panel.Position = UDim2.fromScale(0.04,0.2)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

local function label(text,y,h)
	local l = Instance.new("TextLabel", panel)
	l.Size = UDim2.fromScale(0.9,h)
	l.Position = UDim2.fromScale(0.05,y)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = Color3.new(1,1,1)
	l.Text = text
	return l
end

label("AUTO REMOTE BRING",0.03,0.12)
label("MAP: "..mapName,0.17,0.08)
label("REMOTES FOUND: "..#remotes,0.25,0.08)

local status = label("STATUS: IDLE",0.35,0.1)
local activeRemoteLabel = label("ACTIVE REMOTE: NONE",0.47,0.08)

-- ===== AUTO TEST LOGIC =====
local activeRemote = nil

local function scoreRemote(remote)
	local score = 0
	local name = string.lower(remote.Name)
	for _,k in ipairs(keywords) do
		if string.find(name,k) then
			score += 3
		end
	end
	if string.find(name,"event") then score += 1 end
	return score
end

local function autoDetect()
	status.Text = "STATUS: SCANNING..."
	local bestScore = 0
	local bestRemote = nil

	for _,r in ipairs(remotes) do
		local s = scoreRemote(r)
		if s > bestScore then
			bestScore = s
			bestRemote = r
		end
	end

	if not bestRemote then
		status.Text = "STATUS: NO REMOTE"
		return
	end

	-- SAFE TEST
	local ok = pcall(function()
		bestRemote:FireServer()
	end)

	if ok then
		activeRemote = bestRemote
		status.Text = "STATUS: SUPPORTED"
		status.TextColor3 = Color3.fromRGB(0,255,0)
		activeRemoteLabel.Text = "ACTIVE: "..bestRemote:GetFullName()
	else
		status.Text = "STATUS: TEST FAILED"
		status.TextColor3 = Color3.fromRGB(255,0,0)
	end
end

-- ===== BUTTONS =====
local function btn(text,y,cb)
	local b = Instance.new("TextButton", panel)
	b.Size = UDim2.fromScale(0.9,0.1)
	b.Position = UDim2.fromScale(0.05,y)
	b.Text = text
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.BackgroundColor3 = Color3.fromRGB(55,55,55)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	b.MouseButton1Click:Connect(cb)
end

btn("AUTO DETECT REMOTE",0.58,function()
	autoDetect()
end)

btn("BRING ALL PLAYERS",0.72,function()
	if not activeRemote then return end
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			activeRemote:FireServer("player", plr.Name)
			task.wait(0.15)
		end
	end
end)

-- ===== TOGGLE =====
float.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

print("AUTO BRING LOADED | Remotes:",#remotes)