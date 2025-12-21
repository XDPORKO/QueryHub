-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local ESPPlayers = {}

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
    ESP = false,
    AutoFling = false,
    FlingMode = "Normal",
    Power = 700,
    AntiVoid = true,
    AntiAFK = true,
    AutoRejoin = true,
    Speed = 16,
    Jump = 50,
    CounterFling = false,
    BringLoop = false,
    FPSBoost = false
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

local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--========================================================--
-- RAYFIELD UI
--========================================================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local crot = 71212053414568
local Window = Rayfield:CreateWindow({
    Name = "Query HUB",
    LoadingTitle = "Universal Script • V1.0",
    LoadingSubtitle = "Develope By Rapp.site.vip",
    Icon = crot,
    MinimizeButton = {
        Image = crot,
        Text = "QueryHUB"
    }
    ConfigurationSaving = {
    Enabled = false
    },
    Discord = {
    Enabled = false
    },
    KeySystem = false
})

local function Notify(t, d, s, i)
    Rayfield:Notify({
        Title = t,
        Content = d,
        Duration = s or 3,
        Image = i or crot
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
    Name = "ESP",
    CurrentValue = State.ESP,
    Callback = function(v)
        State.ESP = v
        SaveState()
        Notify("Combat","ESP "..(v and "ON" or "OFF"))
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

SystemTab:CreateToggle({
    Name = "FPS Booster",
    CurrentValue = State.FPSBoost,
    Callback = function(v)
        State.FPSBoost = v
        SaveState()

        if v then
            EnableFPSBoost()
            Notify("System","FPS Booster Enabled",2)
        else
            DisableFPSBoost()
            Notify("System","FPS Booster Disabled",2)
        end
    end
})

--========================================================--
-- TROLL
--========================================================--
TrollTab:CreateToggle({
    Name = "Auto Fling",
    CurrentValue = State.AutoFling,
    Callback = function(v)
        State.AutoFling = v
        SaveState()
    end
})

TrollTab:CreateDropdown({
    Name = "Fling Mode",
    Options = {"Normal","Orbit","Tornado"},
    CurrentOption = State.FlingMode,
    Callback = function(v)
        State.FlingMode = v
        SaveState()
    end
})

TrollTab:CreateSlider({
    Name = "Power",
    Range = {200,2000},
    Increment = 50,
    CurrentValue = State.Power,
    Callback = function(v)
        State.Power = v
        SaveState()
    end
})

TrollTab:CreateToggle({
    Name = "Counter Fling",
    CurrentValue = State.CounterFling,
    Callback = function(v)
        State.CounterFling = v
        SaveState()
    end
})

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
        local myChar = lp.Character
        local myHRP = GetHRP(myChar)
        if not myHRP then return end

        local nearest, dist = nil, math.huge

        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and IsAlive(p.Character) then
                local hrp = GetHRP(p.Character)
                if hrp then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = hrp
                    end
                end
            end
        end

        if nearest then
            nearest.CFrame = myHRP.CFrame * CFrame.new(0,0,-4)
            Notify("Troll","Nearest player brought",2)
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
local flingCooldown = 0

RunService.Heartbeat:Connect(function()
    if not State.AutoFling then return end
    if tick() - flingCooldown < 0.25 then return end

    local myChar = lp.Character
    local myHRP = GetHRP(myChar)
    if not myHRP then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and IsAlive(p.Character) then
            local tHRP = GetHRP(p.Character)
            if tHRP then
                flingCooldown = tick()

                if State.FlingMode == "Normal" then
                    myHRP.CFrame = tHRP.CFrame * CFrame.new(0,0,-2)
                    myHRP.AssemblyLinearVelocity =
                        (tHRP.Position - myHRP.Position).Unit * State.Power

                elseif State.FlingMode == "Orbit" then
                    myHRP.CFrame =
                        tHRP.CFrame *
                        CFrame.Angles(0, tick() * 5, 0) *
                        CFrame.new(0,0,6)

                elseif State.FlingMode == "Tornado" then
                    myHRP.AssemblyLinearVelocity =
                        Vector3.new(0, State.Power, 0)
                end

                break
            end
        end
    end
end)

local lastSafeCF

RunService.Heartbeat:Connect(function()
    if not State.CounterFling then return end

    local char = lp.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    local vel = hrp.AssemblyLinearVelocity.Magnitude

    if vel < 60 then
        lastSafeCF = hrp.CFrame
    elseif vel > 120 and lastSafeCF then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = lastSafeCF
    end
end)

--========================================================--
-- ESP
--========================================================--
local Camera = workspace.CurrentCamera

local function CreateESP(player)
    if player == lp then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "QueryESP"
    Billboard.Size = UDim2.new(0, 200, 0, 70)
    Billboard.AlwaysOnTop = true
    Billboard.StudsOffset = Vector3.new(0, 3, 0)

    local Frame = Instance.new("Frame", Billboard)
    Frame.Size = UDim2.fromScale(1,1)
    Frame.BackgroundTransparency = 1

    local Text = Instance.new("TextLabel", Frame)
    Text.Size = UDim2.fromScale(1,1)
    Text.BackgroundTransparency = 1
    Text.TextWrapped = true
    Text.TextYAlignment = Enum.TextYAlignment.Top
    Text.TextXAlignment = Enum.TextXAlignment.Center
    Text.Font = Enum.Font.GothamBold
    Text.TextSize = 13
    Text.TextColor3 = Color3.fromRGB(255,80,80)
    Text.RichText = true

    return Billboard, Text
end

RunService.RenderStepped:Connect(function()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if State.ESP and hrp and hum and hum.Health > 0 then
                if not ESPPlayers[plr] then
                    local gui, text = CreateESP(plr)
                    gui.Parent = hrp
                    ESPPlayers[plr] = {Gui = gui, Text = text}
                end

                local data = ESPPlayers[plr]
                local dist = math.floor((hrp.Position - lp.Character.HumanoidRootPart.Position).Magnitude)
                local hp = math.floor((hum.Health / hum.MaxHealth) * 100)

                data.Text.Text = string.format(
                    "<b>%s</b>\nNickname: %s\nHP: %d%% | Dist: %dm",
                    plr.Name,
                    plr.DisplayName,
                    hp,
                    dist
                )
            else
                if ESPPlayers[plr] then
                    ESPPlayers[plr].Gui:Destroy()
                    ESPPlayers[plr] = nil
                end
            end
        end
    end
end)

--====================== FPS BOOST ==============================--
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local FPSCache = {}

local function EnableFPSBoost()
    FPSCache = {
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        Brightness = Lighting.Brightness,
        Technology = Lighting.Technology
    }

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.Technology = Enum.Technology.Compatibility

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end
end

local function DisableFPSBoost()
    if not FPSCache then return end

    Lighting.GlobalShadows = FPSCache.GlobalShadows
    Lighting.FogEnd = FPSCache.FogEnd
    Lighting.FogStart = FPSCache.FogStart
    Lighting.Brightness = FPSCache.Brightness
    Lighting.Technology = FPSCache.Technology
end

--========================================================--
-- AUTO REJOIN
--========================================================--
lp.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed and State.AutoRejoin then
        TeleportService:Teleport(game.PlaceId, lp)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESPPlayers[plr] then
        ESPPlayers[plr].Gui:Destroy()
        ESPPlayers[plr] = nil
    end
end)

task.spawn(function()
    while task.wait(0.35) do
        if not State.BringLoop then continue end

        local myChar = lp.Character
        local myHRP = GetHRP(myChar)
        if not myHRP then continue end

        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and IsAlive(p.Character) then
                local hrp = GetHRP(p.Character)
                if hrp then
                    hrp.CFrame = myHRP.CFrame * CFrame.new(math.random(-4,4), 0, math.random(-4,-6))
                end
            end
        end
    end
end)

Notify("[ SYSTEM ] QueryHub","Loaded Script..!",4)
Notify("[ SYSTEM ] QueryHub","Initializing Executor",4)
Notify("[ SYSTEM ] QueryHub","Succes Loaded Script",5)
