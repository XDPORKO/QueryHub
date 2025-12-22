local ahcrot = game:GetService("Players")
local lozer = ahcrot.LocalPlayer

local LOADER_URL =
"https://raw.githubusercontent.com/XDPORKO/QueryHub/main/main.lua"

local S = getgenv().__QUERYHUB_SESSION

if (not S)
or (S.verified ~= true)
or (S.userid ~= lozer.UserId)
or (not getgenv().__QUERYHUB_LOCK) then
        lozer:Kick("[ SYSTEM ] Eits, kalo bypass mikir kidsss 🤭💦")
        return
end

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

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
    FlingMode = "Normal", -- NORMAL/ORBIT/TORNADO
    Power = 700,
    AntiVoid = true,
    AntiAFK = true,
    AutoRejoin = true,
    CounterFling = false,
    BringLoop = false,
    FPSBoost = false,
    Speed = 16,
    Jump = 60,
    WalkOnWater = false,
    GodMode = false,
    Invisible = false,
    Speedy = false,
    Jumpy = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 80
}

--========================================================--
-- SAVE MANAGER
--========================================================--
local SaveFile = "ProjectJudol.json"

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
    Theme = "Ocean",
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
    Name = "Fly",
    CurrentValue = State.Fly,
    Callback = function(v)
        State.Fly = v
        SaveState()
        Notify("Main","Fly "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {30, 200},
    Increment = 5,
    CurrentValue = State.FlySpeed,
    Callback = function(v)
        State.FlySpeed = v
        SaveState()
    end
})

MainTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = State.Speedy,
    Callback = function(v)
        State.Speedy = v
        SaveState()
        Notify("Main","Speed "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = State.Speed,
    Callback = function(v)
        State.Speed = v
        SaveState()
        Notify("Main","Speed set to "..v)
    end
})

MainTab:CreateToggle({
    Name = "Enable Jump",
    CurrentValue = State.Jumpy,
    Callback = function(v)
        State.Jumpy = v
        SaveState()
        Notify("Main","Jump "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = State.Jump,
    Callback = function(v)
        State.Jump = v
        SaveState()
        Notify("Main","JumpPower set to "..v)
    end
})

MainTab:CreateToggle({
    Name = "Walk On Water",
    CurrentValue = State.WalkOnWater,
    Callback = function(v)
        State.WalkOnWater = v
        SaveState()
        Notify("Main","Walk On Water "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = State.GodMode,
    Callback = function(v)
        State.GodMode = v
        SaveState()
        Notify("Main","God Mode "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = State.Noclip,
    Callback = function(v)
        State.Noclip = v
        SaveState()
        Notify("Main","Noclip "..(v and "ON" or "OFF"))
    end
})

--========================================================--
-- INVISIBLE CORE V3 (PERSISTENT + SAFE)
--========================================================--
local InvisCache = {}

local function CacheChar(char)
    InvisCache = {}
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            InvisCache[v] = {
                LTM = v.LocalTransparencyModifier,
                Shadow = v.CastShadow
            }
        elseif v:IsA("Decal") then
            InvisCache[v] = {
                Transparency = v.Transparency
            }
        end
    end
end

local function ApplyInvisible(char)
    CacheChar(char)

    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 1
            v.CastShadow = false
        elseif v:IsA("Decal") then
            v.Transparency = 1
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.NameDisplayDistance = 0
        hum.HealthDisplayDistance = 0
    end
end

local function RemoveInvisible()
    for obj,data in pairs(InvisCache) do
        if obj and obj.Parent then
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = data.LTM or 0
                obj.CastShadow = data.Shadow ~= false
            elseif obj:IsA("Decal") then
                obj.Transparency = data.Transparency or 0
            end
        end
    end
    table.clear(InvisCache)
end

lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)

    if State.Invisible then
        task.wait(0.15)
        ApplyInvisible(char)
    end
end)

MainTab:CreateToggle({
    Name = "Invisible (Persistent)",
    CurrentValue = State.Invisible,
    Callback = function(v)
        State.Invisible = v
        SaveState()

        local char = lp.Character
        if not char then return end

        if v then
            ApplyInvisible(char)
            Notify("Main","Invisible ON")
        else
            RemoveInvisible()
            Notify("Main","Invisible OFF")
        end
    end
})

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
        if not myHRP then
    continue
end

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

--====================== WALK SPEED + JUMP POWER ===================--
RunService.Heartbeat:Connect(function()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- SPEED
    if State.Speedy then
        if hum.WalkSpeed ~= State.Speed then
            hum.WalkSpeed = State.Speed
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end

    -- JUMP
    if State.Jumpy then
        if hum.JumpPower ~= State.Jump then
            hum.JumpPower = State.Jump
        end
    else
        if hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
    end
end)
--========================================================--
-- WALK ON WATER V2 (STABLE)
--========================================================--
-- WALK ON WATER (UNIVERSAL FIX)
local waterPart

RunService.Heartbeat:Connect(function()
    if not State.WalkOnWater then
        if waterPart then waterPart:Destroy() waterPart=nil end
        return
    end

    local hrp = GetHRP(lp.Character)
    if not hrp then return end

    if not waterPart then
        waterPart = Instance.new("Part")
        waterPart.Anchored = true
        waterPart.CanCollide = true
        waterPart.Transparency = 1
        waterPart.Size = Vector3.new(120,1,120)
        waterPart.Parent = workspace
    end

    waterPart.CFrame = CFrame.new(
        hrp.Position.X,
        hrp.Position.Y - 3.2,
        hrp.Position.Z
    )
end)
--========================================================--
-- NOCLIP CORE (SAFE + TOGGLE)
--========================================================--
local NoclipConn
local CollisionCache = {}

local function CacheCollision(char)
    CollisionCache = {}
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            CollisionCache[v] = v.CanCollide
        end
    end
end

local function EnableNoclip()
    if NoclipConn then return end

    local char = lp.Character
    if char then CacheCollision(char) end -- PINDAH KE SINI

    NoclipConn = RunService.Stepped:Connect(function()
        if not State.Noclip then return end
        local char = lp.Character
        if not char then return end

        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end

    for part,old in pairs(CollisionCache) do
        if part and part.Parent then
            part.CanCollide = old
        end
    end

    table.clear(CollisionCache)
end

RunService.Heartbeat:Connect(function()
    if State.Noclip then
        EnableNoclip()
    else
        DisableNoclip()
    end
end)

lp.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    if State.Noclip then
        EnableNoclip()
    else
        DisableNoclip()
    end
end)
--========================================================--
-- HARD ANTI KICK (UPGRADED)
--========================================================--
if not getgenv().__ANTIKICK then
    getgenv().__ANTIKICK = true

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if getgenv().ED_AntiKick.Enabled then
            if self == lp and (
                method == "Kick" or
                method == "kick" or
                method == "Disconnect"
            ) then
                return task.wait(9e9)
            end
        end
        return oldNamecall(self, ...)
    end))

    local oldError
    oldError = hookfunction(error, function(...)
        if getgenv().ED_AntiKick.Enabled then
            return
        end
        return oldError(...)
    end)
end
--========================================================--
-- SMART ANTI VOID (UPGRADED)
--========================================================--
local lastSafeCF_Void

RunService.Heartbeat:Connect(function()
    if not State.AntiVoid then return end

    local char = lp.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    if hrp.Position.Y > 5 and hrp.AssemblyLinearVelocity.Magnitude < 60 then
    lastSafeCF_Void = hrp.CFrame
    end

    if hrp.Position.Y < -50 and lastSafeCF_Void then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = lastSafeCF_Void + Vector3.new(0, 3, 0)
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
    if not myHRP then
    continue
end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and IsAlive(p.Character) then
            local tHRP = GetHRP(p.Character)
            if tHRP then
                flingCooldown = tick()

                if State.FlingMode == "Normal" then
    RealFling(tHRP)
   elseif State.FlingMode == "Orbit" then
    ApplyFling(myHRP, tHRP)
    elseif State.FlingMode == "Tornado" then
    SpinFling(myHRP, tHRP)
    end
                break
            end
        end
    end
end)

local lastSafeCF_Fling
local antiFlingBV

RunService.Heartbeat:Connect(function()
    if not State.CounterFling then return end

    local char = lp.Character
    local hrp = GetHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local vel = hrp.AssemblyLinearVelocity

    if vel.Magnitude < 35 then
        lastSafeCF_Fling = hrp.CFrame
    end

    if vel.Magnitude > 80 then
        -- HAPUS SEMUA FORCE ASING
        for _,v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyMover") or v:IsA("VectorForce") then
                v:Destroy()
            end
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        if lastSafeCF_Fling then
            hrp.CFrame = lastSafeCF_Fling
        end

        if not antiFlingBV then
            antiFlingBV = Instance.new("BodyVelocity")
            antiFlingBV.MaxForce = Vector3.new(9e9, 0, 9e9)
            antiFlingBV.Velocity = Vector3.zero
            antiFlingBV.Parent = hrp
        end
    else
        if antiFlingBV then
            antiFlingBV:Destroy()
            antiFlingBV = nil
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not State.BringLoop then continue end

        local myHRP = GetHRP(lp.Character)
        if not myHRP then
    continue
end

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
-- FLY CORE (STRONG + RESPAWN SAFE)
--========================================================--
local FlyConn
local FlyBV, FlyBG

local function StopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end

    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end

    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

local function StartFly()
    if FlyConn then return end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = hrp

    FlyBG = Instance.new("BodyGyro")
    FlyBG.P = 3e4
    FlyBG.MaxTorque = Vector3.new(5e6,5e6,5e6)
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp
    
    FlyConn = RunService.RenderStepped:Connect(function()
    if not State.Fly then
        StopFly()
        return
    end

    if hum:GetState() ~= Enum.HumanoidStateType.RunningNoPhysics then
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
    
    local camCF = workspace.CurrentCamera.CFrame
    local move = Vector3.zero

    -- PC (WASD)
    if UIS:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

    -- MOBILE JOYSTICK (FIXED, NO INVERT)
    local humMove = hum.MoveDirection
    if humMove.Magnitude > 0 then
        move += humMove
    end

    if move.Magnitude > 0 then
        move = move.Unit
    end

    FlyBV.Velocity = move * State.FlySpeed
    FlyBG.CFrame = camCF
end)
end

RunService.Heartbeat:Connect(function()
    if State.Fly then
        StartFly()
    else
        StopFly()
    end
end)

RunService.Heartbeat:Connect(function()
    if State.Fly then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.3)
    if State.Fly then
        StartFly()
    end
end)
--========================================================--
-- GODMODE V4 (NO DESYNC / NO JUMP DRAIN)
--========================================================--
local GodConn

local function ApplyGodmode(char)
    local hum = char:WaitForChild("Humanoid")

    hum.BreakJointsOnDeath = false
    local max = hum.MaxHealth
    hum.Health = max

    if GodConn then GodConn:Disconnect() end
    GodConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if State.GodMode and hum.Health < 1 then
            hum.Health = hum.MaxHealth
        end
    end)

    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
end

-- APPLY
if lp.Character and State.GodMode then
    ApplyGodmode(lp.Character)
end

lp.CharacterAdded:Connect(function(char)
    if State.GodMode then
        task.wait(0.2)
        ApplyGodmode(char)
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
            local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            if State.ESP and hrp and hum.Health > 0 then
            local dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
    
            if State.ESP and hrp and hum and hum.Health > 0 then
                if not ESPPlayers[plr] then
                    local gui, text = CreateESP(plr)
                    gui.Parent = hrp
                    ESPPlayers[plr] = {Gui = gui, Text = text}
                end

                local data = ESPPlayers[plr]
                local max = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local hp = math.clamp(math.floor((hum.Health / max) * 100), 0, 100)
                
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

--========================================================--
-- FPS BOOST V2 (OPTIMIZED)
--========================================================--
local Lighting = game:GetService("Lighting")
local FPSCache = { Enabled = false }
local FPSObjects = {}

local function EnableFPSBoost()
    table.clear(FPSObjects)
    if FPSCache.Enabled then return end
    FPSCache.Enabled = true

    FPSCache.Settings = {
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Technology = Lighting.Technology
    }

    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    
    FPSCache.DescendantConn = workspace.DescendantAdded:Connect(function(v)
    if not FPSCache.Enabled then return end
    if v:IsA("ParticleEmitter")
    or v:IsA("Trail")
    or v:IsA("Fire")
    or v:IsA("Smoke")
    or v:IsA("Sparkles") then
        FPSObjects[v] = v.Enabled
        v.Enabled = false
        end
    end)

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Fire")
        or v:IsA("Smoke")
        or v:IsA("Sparkles") then
            FPSObjects[v] = v.Enabled
            v.Enabled = false
        end
    end
end

local function DisableFPSBoost()
    if not FPSCache.Enabled then return end
    FPSCache.Enabled = false

    if FPSCache.Settings then
        Lighting.FogEnd = FPSCache.Settings.FogEnd
        Lighting.GlobalShadows = FPSCache.Settings.GlobalShadows
        Lighting.Technology = FPSCache.Settings.Technology
    end
    
    if FPSCache.DescendantConn then
    FPSCache.DescendantConn:Disconnect()
    FPSCache.DescendantConn = nil
end

    for v,old in pairs(FPSObjects) do
        if v and v.Parent then
            v.Enabled = old
        end
    end
    table.clear(FPSObjects)
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
	while task.wait(30) do
		if State.AntiAFK then
			VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
			task.wait(0.1)
			VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
		end
	end
end)
task.wait(3.5)
Notify("[ SYSTEM ] QueryHub","Succesfully Load Scripts..",4)
