local ahcrot = game:GetService("Players")
local lozer = ahcrot.LocalPlayer

local LOADER_URL =
"https://raw.githubusercontent.com/XDPORKO/QueryHub/main/main.lua"

local S = getgenv().__QUERYHUB_SESSION

local function BackToGateway()
    getgenv().__QUERYHUB_SESSION = nil
    getgenv().__QUERYHUB_LOCK = nil
    task.wait(0.15)
    loadstring(game:HttpGet(LOADER_URL))()
end

if not S
	or S.verified ~= true
	or not S.userid ~= lozer.UserId
then
	lozer:Kick("[ SYSTEM ] Eits, kalo bypass mikir kidsss 🤭💦")
	return
end

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
local SaveFile = "MobileHubV5.json"

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
local MainTab = Window:CreateTab("Main", 6031071053)
local TrollTab  = Window:CreateTab("Troll", 6031075929)
local SystemTab = Window:CreateTab("Server", 6031075928)

--========================================================--
-- Main
--========================================================--

MainTab:CreateToggle({
    Name = "ESP",
    CurrentValue = State.ESP,
    Callback = function(v)
        State.ESP = v
        SaveState()
        Notify("Main","ESP "..(v and "ON" or "OFF"))
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
        Notify("System","Anti Void "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Anti Kick",
    CurrentValue = getgenv().ED_AntiKick.Enabled,
    Callback = function(v)
        getgenv().ED_AntiKick.Enabled = v
        SaveState()
        Notify("System","Anti Kick "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = State.AntiAFK,
    Callback = function(v)
        State.AntiAFK = v
        SaveState()
        Notify("System","Anti AFK "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = State.AutoRejoin,
    Callback = function(v)
        State.AutoRejoin = v
        SaveState()
        Notify("System","Auto Rejoin "..(v and "ON" or "OFF"))
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
        Notify("Troll","Auto Fling "..(v and "ON" or "OFF"))
    end
})

TrollTab:CreateDropdown({
    Name = "Fling Mode",
    Options = {"Normal","Orbit","Tornado"},
    CurrentOption = {State.FlingMode},
    Callback = function(v)
        State.FlingMode = v[1]
        SaveState()
        Notify("Troll", "Fling Mode "..State.FlingMode)
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
        Notify("Troll", "Power set to "..v)
    end
})

TrollTab:CreateToggle({
    Name = "Counter Fling",
    CurrentValue = State.CounterFling,
    Callback = function(v)
        State.CounterFling = v
        SaveState()
        Notify("Troll","Counter Fling "..(v and "ON" or "OFF"))
    end
})

TrollTab:CreateToggle({
    Name = "Bring All",
    CurrentValue = State.BringLoop,
    Callback = function(v)
        State.BringLoop = v
        SaveState()
        Notify("Troll","Bring All "..(v and "ON" or "OFF"))
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
local function RealFling(targetHRP)
    local myHRP = GetHRP(lp.Character)
    if not myHRP or not targetHRP then return end

    -- paksa ownership (executor wajib support)
    pcall(function()
        sethiddenproperty(myHRP, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        sethiddenproperty(myHRP, "NetworkOwner", lp)
    end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = (targetHRP.Position - myHRP.Position).Unit * State.Power
    bv.Parent = myHRP

    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bav.AngularVelocity = Vector3.new(0,60,0)
    bav.Parent = myHRP

    task.delay(0.25,function()
        bv:Destroy()
        bav:Destroy()
    end)
end

local flingCooldown = 0
local activeForces = {}
local spinForces = {}

local function ClearSpin(hrp)
    if spinForces[hrp] then
        for _,v in ipairs(spinForces[hrp]) do
            if v and v.Parent then v:Destroy() end
        end
        spinForces[hrp] = nil
    end
end

local function SpinFling(myHRP, targetHRP)
    ClearSpin(myHRP)

    -- paksa ownership (kalau executor support)
    pcall(function()
        sethiddenproperty(myHRP, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        sethiddenproperty(myHRP, "NetworkOwner", lp)
    end)

    -- tempel ke target (biar konsisten)
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity =
        (myHRP.CFrame.RightVector * State.Power) +
        Vector3.new(0, State.Power * 0.35, 0)
    bv.Parent = myHRP

    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bav.AngularVelocity = Vector3.new(0, 120, 0) -- KECEPATAN MUTER
    bav.Parent = myHRP

    spinForces[myHRP] = {bv, bav}

    task.delay(0.35, function()
        ClearSpin(myHRP)
    end)
end

local function ClearForces(hrp)
    if activeForces[hrp] then
        for _,v in ipairs(activeForces[hrp]) do
            if v and v.Parent then
                v:Destroy()
            end
        end
        activeForces[hrp] = nil
    end
end

local function ApplyFling(myHRP, targetHRP)
    ClearForces(myHRP)

    -- paksa ownership (kalau executor support)
    pcall(function()
        sethiddenproperty(myHRP, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        sethiddenproperty(myHRP, "NetworkOwner", lp)
    end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

    if State.FlingMode == "Normal" then
        bv.Velocity =
            (targetHRP.Position - myHRP.Position).Unit * State.Power
        bav.AngularVelocity = Vector3.new(0, 50, 0)

    elseif State.FlingMode == "Orbit" then
        bv.Velocity =
            (myHRP.CFrame.RightVector * State.Power)
        bav.AngularVelocity = Vector3.new(0, 80, 0)

    elseif State.FlingMode == "Tornado" then
        bv.Velocity = Vector3.new(0, State.Power, 0)
        bav.AngularVelocity = Vector3.new(0, 100, 0)
    end

    bv.Parent = myHRP
    bav.Parent = myHRP

    activeForces[myHRP] = {bv, bav}

    task.delay(0.25, function()
        ClearForces(myHRP)
    end)
end

RunService.Heartbeat:Connect(function()
    if not State.AutoFling then return end
    if tick() - flingCooldown < 0.25 then return end

    local myHRP = GetHRP(lp.Character)
    if not myHRP then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and IsAlive(p.Character) then
            local tHRP = GetHRP(p.Character)
            if tHRP then
                flingCooldown = tick()

                SpinFling(myHRP, tHRP)
                break
            end
        end
    end
end)

local lastSafeCF

RunService.Heartbeat:Connect(function()
    if not State.CounterFling then return end

    local hrp = GetHRP(lp.Character)
    if not hrp then return end

    local vel = hrp.AssemblyLinearVelocity.Magnitude

    if vel < 50 then
        lastSafeCF = hrp.CFrame
    elseif vel > 120 and lastSafeCF then
        ClearForces(hrp)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = lastSafeCF
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not State.BringLoop then continue end

        local myHRP = GetHRP(lp.Character)
        if not myHRP then continue end

        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and IsAlive(p.Character) then
                local hrp = GetHRP(p.Character)
                if hrp then
                    pcall(function()
                        sethiddenproperty(hrp, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
                        sethiddenproperty(hrp, "NetworkOwner", lp)
                    end)

                    hrp.CFrame =
                        myHRP.CFrame *
                        CFrame.new(math.random(-3,3), 0, math.random(-6,-8))
                end
            end
        end
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

task.wait(0.35)
Notify("[ SYSTEM ] QueryHub","Loaded Script..!",4)
task.wait(4)
Notify("[ SYSTEM ] QueryHub","Initializing Executor",4)
task.wait(7)
Notify("[ SYSTEM ] QueryHub","Succes Loaded Script",5)
