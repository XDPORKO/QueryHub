 --========================================================--
-- MOBILE COMBAT HUB v5 (RAYFIELD EDITION)
-- SAFE + SAVE + MOBILE + NOTIFY
--========================================================--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- GLOBAL FLAGS
getgenv().AntiVoidHandle = true
getgenv().ED_AntiKick = getgenv().ED_AntiKick or {
    Enabled = true,
    SendNotifications = true,
    CheckCaller = true
}

--========================================================--
-- STATE CORE
--========================================================--
local State = {
    Aim = false,
    ESP = false,
    TeamCheck = true,
    AutoFling = false,
    FlingMode = "Normal",
    Power = 700,
    AntiVoid = true,
    AntiAFK = true,
    AutoRejoin = true,
    Speed = 16,
    Jump = 50,
    CounterFling = false,
    BringLoop = false
}

--========================================================--
-- SAVE MANAGER
--========================================================--
local SaveFile = "MobileCombatHubV5.json"

local function SaveState()
    pcall(function()
        writefile(SaveFile, HttpService:JSONEncode(State))
    end)
end

local function LoadState()
    if isfile(SaveFile) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SaveFile))
        end)
        if success then
            for k,v in pairs(decoded) do
                if State[k] ~= nil then
                    State[k] = v
                end
            end
        end
    end
end
LoadState()

--========================================================--
-- RAYFIELD UI
--========================================================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Query HUB",
    LoadingTitle = "Universal Script • V1.0",
    LoadingSubtitle = "Develope By Rapp.site.vip",
    Icon = 71212053414568,
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

local function Notify(t, d, s, i)
    Rayfield:Notify({
        Title = t,
        Content = d,
        Duration = s or 3,
        Image = i
    })
end

--========================================================--
-- TABS
--========================================================--
local CombatTab = Window:CreateTab("Main", 137778793211272)
local RageTab   = Window:CreateTab("Troll", 6031075938)
local TrollTab  = Window:CreateTab("IDK", 6031071053)
local SystemTab = Window:CreateTab("Server", 6031075931)

--========================================================--
-- COMBAT
--========================================================--
CombatTab:CreateToggle({
    Name = "Aim Assist",
    CurrentValue = State.Aim,
    Callback = function(v)
        State.Aim = v
        SaveState()
        Notify("Combat","Aim "..(v and "ON" or "OFF"))
    end
})

CombatTab:CreateToggle({
    Name = "ESP",
    CurrentValue = State.ESP,
    Callback = function(v)
        State.ESP = v
        SaveState()
        Notify("Combat","ESP "..(v and "ON" or "OFF"))
    end
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = State.TeamCheck,
    Callback = function(v)
        State.TeamCheck = v
        SaveState()
    end
})

--========================================================--
-- RAGE
--========================================================--
RageTab:CreateToggle({
    Name = "Auto Fling",
    CurrentValue = State.AutoFling,
    Callback = function(v)
        State.AutoFling = v
        SaveState()
    end
})

RageTab:CreateDropdown({
    Name = "Fling Mode",
    Options = {"Normal","Orbit","Tornado"},
    CurrentOption = State.FlingMode,
    Callback = function(v)
        State.FlingMode = v
        SaveState()
    end
})

RageTab:CreateSlider({
    Name = "Power",
    Range = {200,2000},
    Increment = 50,
    CurrentValue = State.Power,
    Callback = function(v)
        State.Power = v
        SaveState()
    end
})

RageTab:CreateToggle({
    Name = "Counter Fling",
    CurrentValue = State.CounterFling,
    Callback = function(v)
        State.CounterFling = v
        SaveState()
    end
})

--========================================================--
-- SYSTEM
--========================================================--
SystemTab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = State.AntiVoid,
    Callback = function(v)
        State.AntiVoid = v
        getgenv().AntiVoidHandle = v
        SaveState()
    end
})

SystemTab:CreateToggle({
    Name = "Anti Kick",
    CurrentValue = getgenv().ED_AntiKick.Enabled,
    Callback = function(v)
        getgenv().ED_AntiKick.Enabled = v
        SaveState()
    end
})

SystemTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = State.AntiAFK,
    Callback = function(v)
        State.AntiAFK = v
        SaveState()
    end
})

SystemTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = State.AutoRejoin,
    Callback = function(v)
        State.AutoRejoin = v
        SaveState()
    end
})

--========================================================--
-- TROLL
--========================================================--
TrollTab:CreateToggle({
    Name = "Bring All",
    CurrentValue = State.BringLoop,
    Callback = function(v)
        State.BringLoop = v
        SaveState()
    end
})

TrollTab:CreateButton({
    Name = "Bring Nearest",
    Callback = function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local target, dist = nil, math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    target = p.Character.HumanoidRootPart
                end
            end
        end
        if target then
            target.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
            Notify("Troll","Nearest player brought!")
        end
    end
})

--========================================================--
-- ANTI KICK
--========================================================--
if not getgenv().__ANTIKICK then
    getgenv().__ANTIKICK = true
    local old
    old = hookmetamethod(game,"__namecall",newcclosure(function(self,...)
        if getnamecallmethod():lower()=="kick"
        and self==lp
        and getgenv().ED_AntiKick.Enabled then
            Notify("Anti Kick","Kick blocked!")
            return
        end
        return old(self,...)
    end))
end

--========================================================--
-- ANTI VOID
--========================================================--
RunService.Heartbeat:Connect(function()
    if State.AntiVoid and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        if lp.Character.HumanoidRootPart.Position.Y < -60 then
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(0,60,0)
        end
    end
end)

--========================================================--
-- AUTO FLING + COUNTER
--========================================================--
local lastSafe
RunService.Heartbeat:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    hum.WalkSpeed = State.Speed
    hum.JumpPower = State.Jump

    if State.AutoFling then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local t = p.Character.HumanoidRootPart
                if State.FlingMode=="Normal" then
                    hrp.CFrame = t.CFrame * CFrame.new(0,0,-2)
                    hrp.AssemblyLinearVelocity =
                        (t.Position-hrp.Position).Unit * (State.Power+300)
                elseif State.FlingMode=="Orbit" then
                    hrp.CFrame = t.CFrame * CFrame.Angles(0,tick()*4,0) * CFrame.new(0,0,6)
                elseif State.FlingMode=="Tornado" then
                    hrp.AssemblyLinearVelocity = Vector3.new(0,State.Power,0)
                end
                break
            end
        end
    end

    if State.CounterFling and hrp.AssemblyLinearVelocity.Magnitude > 120 and lastSafe then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = lastSafe
    end

    if hrp.AssemblyLinearVelocity.Magnitude < 60 then
        lastSafe = hrp.CFrame
    end
end)

--========================================================--
-- AIM
--========================================================--
local FOV, Smooth = 150, 0.15
RunService.RenderStepped:Connect(function()
    if not State.Aim then return end
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local target, dist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onscreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onscreen then
                local d = (Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
                if d < FOV and d < dist then
                    dist = d
                    target = p.Character.HumanoidRootPart
                end
            end
        end
    end

    if target then
        cam.CFrame = cam.CFrame:Lerp(
            CFrame.new(cam.CFrame.Position, target.Position),
            Smooth
        )
    end
end)

--========================================================--
-- ESP
--========================================================--
local ESP = {}
local function addESP(p)
    if p==lp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,2)
    box.Color3 = Color3.new(1,0,0)
    box.AlwaysOnTop = true
    ESP[p] = box
end

for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)

RunService.RenderStepped:Connect(function()
    for p,b in pairs(ESP) do
        if State.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            b.Adornee = p.Character.HumanoidRootPart
            b.Parent = cam
        else
            b.Adornee = nil
        end
    end
end)

--========================================================--
-- AUTO REJOIN
--========================================================--
lp.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed and State.AutoRejoin then
        TeleportService:Teleport(game.PlaceId, lp)
    end
end)

Notify("QueryHUB","Loaded Successfully!",4, 71212053414568)
warn("🔥 MOBILE COMBAT HUB v5 (RAYFIELD) LOADED")