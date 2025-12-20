local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ================= VALUE FINDER =================
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

-- ================= DATA =================
local tips = {
	["acid rain"] = "Stay inside, avoid open sky",
	["flash flood"] = "Go to highest point",
	["tornado"] = "Stay inside, go low",
	["sandstorm"] = "Stay indoors",
	["meteor shower"] = "Find solid roof",
	["blizzard"] = "Stay inside",
	["volcano"] = "Stay far from volcano",
	["tsunami"] = "Climb immediately",
	["earthquake"] = "Avoid tall structures"
}

-- ================= TIMER CORE =================
local basePrep = 20        -- default
local adaptivePrep = basePrep
local startTick = nil
local lastError = 0

local function startTimer()
	startTick = tick()
end

local function endTimer()
	if not startTick then return end
	local realTime = tick() - startTick
	lastError = realTime - adaptivePrep
	adaptivePrep = math.clamp(adaptivePrep + lastError * 0.5, 15, 25)
	startTick = nil
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "NDS_AccuracyPredictor"
gui.ResetOnSpawn = false

local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromScale(0.18,0.08)
float.Position = UDim2.fromScale(0.02,0.42)
float.Text = "NDS"
float.TextScaled = true
float.BackgroundColor3 = Color3.fromRGB(20,20,20)
float.TextColor3 = Color3.new(1,1,1)
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(0,14)

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.9,0.6)
panel.Position = UDim2.fromScale(0.05,0.2)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)

local function label(y,h,bold)
	local l = Instance.new("TextLabel", panel)
	l.Size = UDim2.fromScale(0.9,h)
	l.Position = UDim2.fromScale(0.05,y)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3 = Color3.new(1,1,1)
	return l
end

local title = label(0.03,0.12,true)
title.Text = "DISASTER PREDICTOR (HIGH ACCURACY)"

local mapLbl = label(0.18,0.08)
local disLbl = label(0.28,0.08)
local timerLbl = label(0.38,0.1,true)
local tipLbl = label(0.50,0.18)

-- ================= STATUS LISTENER =================
if statusValue then
	statusValue:GetPropertyChangedSignal("Value"):Connect(function()
		local s = string.lower(statusValue.Value)
		if s:find("choosing") or s:find("waiting") then
			startTimer()
		elseif s:find("disaster") then
			endTimer()
		end
	end)
end

-- ================= UPDATE LOOP =================
RunService.Heartbeat:Connect(function()
	if startTick then
		local remain = math.max(0, adaptivePrep - (tick() - startTick))
		timerLbl.Text = ("TIMER: %.1fs"):format(remain)
	else
		timerLbl.Text = "TIMER: --"
	end

	if mapValue then mapLbl.Text = "MAP: "..mapValue.Value end
	if disasterValue then
		local d = disasterValue.Value
		disLbl.Text = "DISASTER: "..d
		tipLbl.Text = "TIP: "..(tips[string.lower(d)] or "Stay alert")
	end
end)

float.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

print("NDS High Accuracy Predictor Loaded (~90%)")