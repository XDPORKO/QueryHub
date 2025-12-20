local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ================= FIND VALUES =================
local mapValue, disasterValue, statusValue

local function findValues()
	for _,v in ipairs(game:GetDescendants()) do
		if v:IsA("StringValue") then
			local n = string.lower(v.Name)
			if n:find("map") then mapValue = mapValue or v end
			if n:find("disaster") then disasterValue = disasterValue or v end
			if n:find("status") then statusValue = statusValue or v end
		end
	end
end
findValues()

-- ================= DISASTER TYPE DATA =================
local tips = {
	["acid rain"] = "Stay inside, avoid open sky",
	["flash flood"] = "Get to high ground",
	["tornado"] = "Go low, stay inside",
	["sandstorm"] = "Stay indoors, avoid windows",
	["thunderstorm"] = "Avoid metal & open areas",
	["volcano"] = "Stay far from volcano",
	["meteor shower"] = "Stay under solid roof",
	["blizzard"] = "Stay indoors",
	["tsunami"] = "Climb highest point",
	["earthquake"] = "Stay away from tall structures"
}

-- ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "NDS_Predictor_Timer"
gui.ResetOnSpawn = false

-- Floating Button
local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromScale(0.18,0.08)
float.Position = UDim2.fromScale(0.02,0.42)
float.Text = "PREDICT"
float.TextScaled = true
float.BackgroundColor3 = Color3.fromRGB(20,20,20)
float.TextColor3 = Color3.new(1,1,1)
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(0,14)

-- Panel
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.9,0.55)
panel.Position = UDim2.fromScale(0.05,0.22)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

local function mkLabel(y, h, bold)
	local l = Instance.new("TextLabel", panel)
	l.Size = UDim2.fromScale(0.9,h)
	l.Position = UDim2.fromScale(0.05,y)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3 = Color3.new(1,1,1)
	return l
end

local title = mkLabel(0.03,0.12,true); title.Text = "DISASTER PREDICTOR"
local mapLbl = mkLabel(0.18,0.1); mapLbl.Text = "MAP: ?"
local disLbl = mkLabel(0.30,0.1); disLbl.Text = "DISASTER: ?"
local timerLbl = mkLabel(0.42,0.1,true); timerLbl.Text = "TIMER: --"
local tipLbl = mkLabel(0.54,0.18); tipLbl.TextWrapped = true; tipLbl.Text = "TIP: ?"

-- ================= TIMER LOGIC =================
local countdown = nil
local startTick = nil
local PREP_TIME = 20 -- umumnya ~20 detik sebelum disaster aktif

local function resetTimer()
	startTick = tick()
	countdown = PREP_TIME
end

-- Update on value change
local function updateUI()
	if mapValue then mapLbl.Text = "MAP: "..mapValue.Value end
	if disasterValue then
		local d = string.lower(disasterValue.Value)
		disLbl.Text = "DISASTER: "..disasterValue.Value
		tipLbl.Text = "TIP: "..(tips[d] or "No specific tip, stay alert")
	end
end

if statusValue then
	statusValue:GetPropertyChangedSignal("Value"):Connect(function()
		local s = string.lower(statusValue.Value)
		if s:find("waiting") or s:find("choosing") then
			resetTimer()
		end
	end)
end

if mapValue then mapValue:GetPropertyChangedSignal("Value"):Connect(updateUI) end
if disasterValue then disasterValue:GetPropertyChangedSignal("Value"):Connect(updateUI) end
updateUI()

-- Heartbeat timer
RunService.Heartbeat:Connect(function()
	if startTick then
		local elapsed = tick() - startTick
		local remain = math.max(0, PREP_TIME - math.floor(elapsed))
		timerLbl.Text = "TIMER: "..remain.."s"
		if remain <= 0 then
			startTick = nil
		end
	end
end)

-- Toggle
float.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

print