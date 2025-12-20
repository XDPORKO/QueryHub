local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ================= CLEAN =================
pcall(function()
    if lp.PlayerGui:FindFirstChild("NDS_GUI") then
        lp.PlayerGui.NDS_GUI:Destroy()
    end
end)

-- ================= VALUE SCAN =================
local mapValue, disasterValue, statusValue
local lastScan = 0

local function scan()
    if tick() - lastScan < 2 then return end
    lastScan = tick()

    for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("StringValue") then
            local n = v.Name:lower()
            if not mapValue and n:find("map") then mapValue = v end
            if not disasterValue and n:find("disaster") then disasterValue = v end
            if not statusValue and (n:find("status") or n:find("state")) then statusValue = v end
        end
    end
end

scan()

-- ================= DATA =================
local Data = { maps = {} }
local prepStart

local function startPrep()
    prepStart = tick()
end

local function record()
    if not (mapValue and disasterValue and prepStart) then return end

    local map = mapValue.Value
    local dis = disasterValue.Value
    local prep = tick() - prepStart
    prepStart = nil

    Data.maps[map] = Data.maps[map] or {
        total = 0,
        avgPrep = prep,
        disasters = {}
    }

    local m = Data.maps[map]
    m.total += 1
    m.avgPrep = (m.avgPrep * (m.total - 1) + prep) / m.total
    m.disasters[dis] = (m.disasters[dis] or 0) + 1
end

local function predict(map)
    local m = Data.maps[map]
    if not m then return "?", 0 end

    local best, count = "?", 0
    for d,c in pairs(m.disasters) do
        if c > count then
            best, count = d, c
        end
    end

    return best, math.floor((count / m.total) * 100)
end

-- ================= STATUS HOOK =================
local function hook()
    if not statusValue then return end
    statusValue:GetPropertyChangedSignal("Value"):Connect(function()
        local s = statusValue.Value:lower()
        if s:find("wait") or s:find("choose") then
            startPrep()
        elseif s:find("disaster") or s:find("event") then
            record()
        end
    end)
end

hook()

-- ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "NDS_GUI"
gui.ResetOnSpawn = false

-- FLOAT BUTTON
local float = Instance.new("TextButton", gui)
float.Size = UDim2.fromScale(0.17,0.08)
float.Position = UDim2.fromScale(0.03,0.45)
float.Text = "NDS"
float.TextScaled = true
float.BackgroundColor3 = Color3.fromRGB(30,30,30)
float.TextColor3 = Color3.new(1,1,1)
float.Active = true
float.Draggable = true
Instance.new("UICorner", float).CornerRadius = UDim.new(0,16)

-- PANEL
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.9,0.65)
panel.Position = UDim2.fromScale(0.05,0.18)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,20)

-- HEADER
local header = Instance.new("TextLabel", panel)
header.Size = UDim2.fromScale(1,0.12)
header.BackgroundTransparency = 1
header.Text = "AUTO DISASTER PREDICTOR"
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.TextColor3 = Color3.new(1,1,1)

-- LABEL MAKER
local function label(y,h,bold)
    local l = Instance.new("TextLabel", panel)
    l.Size = UDim2.fromScale(0.9,h)
    l.Position = UDim2.fromScale(0.05,y)
    l.BackgroundTransparency = 1
    l.TextWrapped = true
    l.TextScaled = true
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextColor3 = Color3.new(1,1,1)
    return l
end

local mapLbl  = label(0.14,0.07)
local predLbl = label(0.23,0.09,true)
local confLbl = label(0.34,0.06)
local prepLbl = label(0.42,0.06)
local statLbl = label(0.50,0.22)

-- ================= UPDATE =================
RunService.Heartbeat:Connect(function()
    scan()

    local map = mapValue and mapValue.Value or "Detecting..."
    mapLbl.Text = "MAP : "..map

    if Data.maps[map] then
        local p,c = predict(map)
        predLbl.Text = "PREDICT : "..p
        confLbl.Text = "CONFIDENCE : "..c.."%"
        prepLbl.Text = ("AVG PREP : %.1fs"):format(Data.maps[map].avgPrep)
        statLbl.Text =
            "LEARNING STATUS\n"..
            "Rounds : "..Data.maps[map].total.."\n"..
            "Patterns : "..tostring(#(function()
                local t=0 for _ in pairs(Data.maps[map].disasters) do t+=1 end return {t}
            end)())
    else
        predLbl.Text = "PREDICT : ?"
        confLbl.Text = "CONFIDENCE : 0%"
        prepLbl.Text = "AVG PREP : --"
        statLbl.Text = "LEARNING STATUS\nNo data yet"
    end
end)

float.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

print("NDS Auto Predictor + GUI Loaded")