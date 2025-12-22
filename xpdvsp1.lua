-- SERVICES
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local cam = workspace.CurrentCamera
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Fix Icon ID (Jika ID terlalu besar, gunakan ID default Roblox atau string)
local ambatukam = 124796029670238 -- ID default (Shield/Hub Icon) jika 124796029670238 gagal load

-- Authentication Guard (Bypass Check)
local S = getgenv().__QUERYHUB_SESSION
if not S or S.verified ~= true or S.userid ~= lp.UserId then
    lp:Kick("[ SYSTEM ] Eits, kalo bypass mikir kidsss 🤭💦")
    return
end

-- TABLES & CACHE
local Connections = {}
getgenv().ED_AntiKick = getgenv().ED_AntiKick or {
    Enabled = true,
    SendNotifications = true
}

--========================================================--
-- STATE CORE (UPGRADED)
--========================================================--
local State = {
    ESP = false,
    AutoFling = false,
    FlingMode = "Normal",
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
    FlySpeed = 80,
    AntiEvade = false
}

--========================================================--
-- UTILITY FUNCTIONS
--========================================================--
local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function SaveState()
    pcall(function() writefile("ProjectJudol.json", HttpService:JSONEncode(State)) end)
end

local function LoadState()
    pcall(function()
        if isfile("ProjectJudol.json") then
            local data = HttpService:JSONDecode(readfile("ProjectJudol.json"))
            for k,v in pairs(data) do if State[k] ~= nil then State[k] = v end end
        end
    end)
end
LoadState()

--========================================================--
-- RAYFIELD UI FIX
--========================================================--
local Rayfield = nil
local success, err = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if success and err then
    Rayfield = err
else
    warn("Rayfield Critical Error: " .. tostring(err))
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Query HUB",
    LoadingTitle = "Universal Script • V1.2",
    LoadingSubtitle = "Developed By Rapp.site.vip",
    Theme = "Light",
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false }
})

-- TABS
local MainTab = Window:CreateTab("Main", 4483345998)
local TrollTab = Window:CreateTab("Troll", 4483345998)
local SystemTab = Window:CreateTab("Server", 4483345998)

-- SMART NOTIFY
local function Notify(t, d, s)
    Rayfield:Notify({
        Title = t,
        Content = d,
        Duration = s or 3,
        Image = ambatukam
    })
end

--====================== UPGRADED MOVEMENT CORE ===================--

local function PatchHumanoid(hum)
    if not hum then return end
    -- Memastikan Humanoid menggunakan JumpPower, bukan JumpHeight
    hum.UseJumpPower = true 
end

RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not hrp then return end

    -- UPGRADE: Bypass Network Owner (Memperhalus pergerakan agar tidak rubber-band)
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lp, "SimulationRadius", math.huge)
            sethiddenproperty(lp, "MaxSimulationRadius", math.huge)
        end
    end)

    -- SPEED LOGIC (UPGRADED)
    if State.Speedy then
        -- Jika menggunakan speed tinggi, kita paksa pergerakan di RootPart
        if State.Speed > 60 then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDir * (State.Speed / 100))
            end
        end
        hum.WalkSpeed = State.Speed
    else
        hum.WalkSpeed = 16
    end

    -- JUMP LOGIC (UPGRADED)
    if State.Jumpy then
        PatchHumanoid(hum)
        hum.JumpPower = State.Jump
    else
        -- Jika tidak aktif, kembalikan ke default game
        if hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end
    end
end)

-- AUTO FIX SAAT RESPAWN
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    PatchHumanoid(hum)
end)

--========================================================--
-- SMART NOCLIP V2 (SAFE & PERFORMANCE)
--========================================================--
local NoclipConn

local function ToggleNoclip(bool)
    State.Noclip = bool
    
    -- Bersihkan koneksi lama jika ada
    if NoclipConn then 
        NoclipConn:Disconnect() 
        NoclipConn = nil 
    end
    
    if not bool then
        -- Reset collision saat dimatikan
        local char = lp.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end

    -- UPGRADE: Menggunakan Stepped agar sinkron dengan physics engine
    NoclipConn = RunService.Stepped:Connect(function()
        if not State.Noclip then return end
        
        local char = lp.Character
        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                -- UPGRADE: Kecualikan HumanoidRootPart agar tidak jatuh ke void
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end)
end

--========================================================--
-- WALK ON WATER V3 (SMOOTH & ANTI-SLIP)
--========================================================--
local waterPart

RunService.Heartbeat:Connect(function()
    if not State.WalkOnWater then
        if waterPart then
            waterPart:Destroy()
            waterPart = nil
        end
        return
    end

    local char = lp.Character
    local hrp = GetHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end

    if not waterPart then
        waterPart = Instance.new("Part")
        waterPart.Name = "QueryWaterPlatform"
        waterPart.Anchored = true
        waterPart.CanCollide = true
        waterPart.Transparency = 1
        waterPart.Material = Enum.Material.Neon -- Memperbaiki collision detection
        waterPart.Size = Vector3.new(150, 1, 150)
        waterPart.Parent = workspace
    end

    -- UPGRADE: Hitung offset berdasarkan state humanoid (Duduk/Berdiri)
    local offset = (hum.RigType == Enum.HumanoidRigType.R6) and 3.2 or 3.5
    
    -- Lerp Position agar part tidak ketinggalan saat lari cepat
    local targetCF = CFrame.new(hrp.Position.X, hrp.Position.Y - offset, hrp.Position.Z)
    waterPart.CFrame = waterPart.CFrame:Lerp(targetCF, 0.5)
end)

--====================================================--
-- UPGRADED HARD ANTI-KICK (ULTIMATE BYPASS)
--====================================================--
if not getgenv().__ANTIKICK_LOADED then
    getgenv().__ANTIKICK_LOADED = true

    -- Menggunakan pcall agar script tidak crash jika executor tidak support metatable
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local oldIndex = mt.__index
        
        setreadonly(mt, false)

        -- UPGRADE 1: Namecall Bypass (Untuk Kick() method)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if getgenv().ED_AntiKick.Enabled and self == lp then
                if method:lower() == "kick" or method == "Kick" then
                    -- UPGRADE: Kirim notifikasi jika ada yang mencoba menendangmu
                    if getgenv().ED_AntiKick.SendNotifications then
                        Notify("[ SYSTEM ] ANTI-KICK", "Server mencoba menendangmu! Alasan: " .. tostring(args[1] or "No reason"), 5)
                    end
                    -- Mengembalikan nilai kosong (spoofing) agar script game mengira kick berhasil
                    return nil 
                end
            end
            return oldNamecall(self, ...)
        end)

        -- UPGRADE 2: Index Bypass (Mencegah deteksi LocalPlayer:Kick)
        mt.__index = newcclosure(function(self, key)
            if getgenv().ED_AntiKick.Enabled and self == lp and (key:lower() == "kick") then
                return newcclosure(function() 
                    print("[QueryHub] Blocked an internal Kick attempt.")
                    return nil 
                end)
            end
            return oldIndex(self, key)
        end)

        setreadonly(mt, true)
    end)

    if not success then
        warn("Anti-Kick failed to load: " .. tostring(err))
    end
end

--========================================================--
-- SMART ANTI-VOID V3 (RAYCAST GROUND DETECTION)
--========================================================--
local lastSafeCF_Void
local isRecovering = false

RunService.Heartbeat:Connect(function()
    if not State.AntiVoid then return end

    local char = lp.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    -- UPGRADE 1: Validasi posisi aman (Hanya catat jika di atas tanah padat)
    -- Menggunakan Raycast ke bawah sejauh 10 studs
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {char}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude

    local groundCheck = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), rayParam)

    -- Catat posisi hanya jika di atas tanah, tidak sedang ngebut, dan tidak sedang jatuh
    if groundCheck and hrp.Position.Y > 2 and hrp.AssemblyLinearVelocity.Magnitude < 50 then
        lastSafeCF_Void = hrp.CFrame
    end

    -- UPGRADE 2: Deteksi jatuh dengan sistem Recovery
    if hrp.Position.Y < -50 and lastSafeCF_Void and not isRecovering then
        isRecovering = true
        
        -- Berhentikan semua momentum fisik
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        -- Kembalikan ke posisi aman terakhir + sedikit di atasnya
        hrp.CFrame = lastSafeCF_Void + Vector3.new(0, 3, 0)
        
        Notify("[ SYSTEM ]", "Anti-Void: Kembali ke posisi aman terakhir.", 2)
        
        -- Delay singkat agar sistem tidak spam teleport
        task.wait(0.5)
        isRecovering = false
    end
end)

--========================================================--
-- ULTIMATE FLING & COUNTER CORE (FIXED)
--========================================================--

local function SetVelocity(part)
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lp, "SimulationRadius", math.huge)
            sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        end
        part.AssemblyLinearVelocity = Vector3.new(0, State.Power, 0)
        part.AssemblyAngularVelocity = Vector3.new(State.Power, State.Power, State.Power)
    end)
end

local function CleanForce(hrp)
    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyMover") or v:IsA("VectorForce") or v.Name:find("Fling") then
            v:Destroy()
        end
    end
end

-- UPGRADED: Fling Execution
local function ExecuteFling(targetHRP)
    local char = lp.Character
    local myHRP = GetHRP(char)
    if not myHRP or not targetHRP then return end

    CleanForce(myHRP)

    -- Create Forces
    local bv = Instance.new("BodyVelocity")
    bv.Name = "QueryFlingBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "QueryFlingBAV"
    bav.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

    -- Mode Logic
    if State.FlingMode == "Normal" then
        bv.Velocity = (targetHRP.Position - myHRP.Position).Unit * State.Power
        bav.AngularVelocity = Vector3.new(0, 1000, 0)
    elseif State.FlingMode == "Orbit" then
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
        bv.Velocity = myHRP.CFrame.RightVector * State.Power
        bav.AngularVelocity = Vector3.new(1000, 1000, 1000)
    elseif State.FlingMode == "Tornado" then
        bv.Velocity = Vector3.new(0, State.Power, 0)
        bav.AngularVelocity = Vector3.new(0, 5000, 0)
    end

    bv.Parent = myHRP
    bav.Parent = myHRP
    SetVelocity(myHRP)

    task.delay(0.2, function()
        CleanForce(myHRP)
    end)
end

-- UPGRADED: Counter Fling (Anti-Die)
RunService.Heartbeat:Connect(function()
    if not State.CounterFling or State.Fly then return end
    local char = lp.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    -- Deteksi kecepatan abnormal (biasanya saat kena hit player lain)
    if hrp.AssemblyLinearVelocity.Magnitude > 150 or hrp.AssemblyAngularVelocity.Magnitude > 150 then
        CleanForce(hrp)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        if lastSafeCF_Void then -- Menggunakan data dari Anti-Void fix sebelumnya
            hrp.CFrame = lastSafeCF_Void
        end
        Notify("[ SYSTEM ]", "Fling attempt blocked!", 1)
    end
end)

-- UPGRADED: Bring Loop (Safe Network)
task.spawn(function()
    while task.wait(0.3) do
        if not State.BringLoop then continue end
        local myHRP = GetHRP(lp.Character)
        if not myHRP then continue end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and IsAlive(p.Character) then
                local tHRP = GetHRP(p.Character)
                if tHRP then
                    -- Hanya tarik jika executor support sethiddenproperty
                    pcall(function()
                        sethiddenproperty(tHRP, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
                        tHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -5)
                    end)
                end
            end
        end
    end
end)

--========================================================--
-- ULTIMATE FLY V4 (OPTIMIZED & RESPONSIVE)
--========================================================--
local FlyConn, FlyBV, FlyBG

local function StopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        -- Reset state agar bisa jalan normal lagi
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function StartFly()
    if FlyConn then return end -- Mencegah double connection

    local char = lp.Character
    local hrp = GetHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Disable physics yang mengganggu terbang
    local states = {
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Swimming -- Biar bisa terbang di air
    }
    for _, state in ipairs(states) do
        hum:SetStateEnabled(state, false)
    end

    -- Create Forces
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "QueryFly_BV"
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = hrp

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "QueryFly_BG"
    FlyBG.P = 50000 -- Lebih kaku dan stabil
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp

    FlyConn = RunService.RenderStepped:Connect(function(dt)
        if not State.Fly or not hrp.Parent then 
            StopFly() 
            return 
        end

        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.zero

        -- Control Inputs
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

        -- Bergerak berdasarkan input atau Humanoid MoveDirection (Joystick Mobile)
        local finalVelocity = (moveDir.Magnitude > 0 and moveDir.Unit or Vector3.zero) * State.FlySpeed
        
        -- Tambahkan dukungan Joystick Mobile
        if hum.MoveDirection.Magnitude > 0 and moveDir.Magnitude == 0 then
            finalVelocity = hum.MoveDirection * State.FlySpeed
        end

        FlyBV.Velocity = finalVelocity
        FlyBG.CFrame = camCF
        
        -- Auto Heal saat terbang
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end

        -- Paksa mode physics
        hum.PlatformStand = true
    end)
end

-- Integrasi ke State Loop Utama
RunService.Heartbeat:Connect(function()
    if State.Fly then
        StartFly()
    else
        StopFly()
    end
end)

-- Handling Respawn & Cleanup
lp.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.Fly then StartFly() end
end)

lp.CharacterRemoving:Connect(function()
    StopFly()
end)
--========================================================--
-- GODMODE V5 (SAFE / NO NIL / NO ERROR)
--========================================================--
local GodConn

local function ApplyGodmode(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    
    if not hum or not hrp then return end

    -- Mencegah kematian instan jika bagian tubuh (terutama kepala) diputus
    hum.RequiresNeck = false
    hum.BreakJointsOnDeath = false
    char.LevelOfDetail = Enum.ModelLevelOfDetail.StreamingMesh -- Optimasi physics

    -- Mengunci state Humanoid agar tidak bisa jatuh, pingsan, atau mati secara physics
    local function LockStates()
        local forbiddenStates = {
            Enum.HumanoidStateType.Dead,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Physics,
            Enum.HumanoidStateType.PlatformStanding
        }
        for _, state in ipairs(forbiddenStates) do
            hum:SetStateEnabled(state, false)
        end
        -- Paksa ke state Running agar selalu bisa bergerak
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    LockStates()

    -- Menggunakan Heartbeat (lebih cepat dari HealthChanged) untuk deteksi instan
    if GodConn then GodConn:Disconnect() end
    GodConn = RunService.Heartbeat:Connect(function()
        if not State.GodMode or not hum.Parent then 
            if GodConn then GodConn:Disconnect() GodConn = nil end
            return 
        end

        -- Anti-OneShot: Jika darah di bawah 0.1, paksa balik ke Max
        if hum.Health <= 0.1 then
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Running)
        elseif hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        
        -- Proteksi Ekstra: Pastikan tidak mati karena jatuh ke void (jika Anti-Void mati)
        if hrp.Position.Y < -2000 then -- Jika jatuh terlalu dalam
             hrp.AssemblyLinearVelocity = Vector3.zero
             hrp.CFrame = CFrame.new(0, 500, 0) -- Teleport balik ke langit map
        end
    end)
    
    -- Jika ada bagian tubuh yang lepas (misal karena ledakan), script mencoba menjaga HRP tetap aktif
    char.DescendantRemoving:Connect(function(desc)
        if State.GodMode and desc.Name == "Neck" or desc.Name == "RootJoint" then
            Notify("[ SYSTEM ] WARNING", "Neck/RootJoint Removed! Auto-Repairing...", 2)
            ApplyGodmode(char) -- Re-apply logic
        end
    end)
end

-- Jalankan otomatis jika sudah spawn
if lp.Character and State.GodMode then
    task.spawn(function() ApplyGodmode(lp.Character) end)
end

-- Jalankan setiap kali karakter baru muncul (Respawn)
lp.CharacterAdded:Connect(function(char)
    if State.GodMode then
        -- Tunggu sampai karakter benar-benar ter-load di workspace
        repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
        task.wait(0.1) -- Jeda mikro untuk stabilitas engine
        ApplyGodmode(char)
    end
end)

--========================================================--
-- ESP
--========================================================--

local ESPPlayers = {}
local ESPConn

local function CreateESP(plr)
    -- [ UPGRADE 1: HIGHLIGHT ESP (Bisa liat badan nembus tembok) ]
    local hl = Instance.new("Highlight")
    hl.Name = "QueryHighlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- [ UPGRADE 2: BILLBOARD OPTIMIZED ]
    local bb = Instance.new("BillboardGui")
    bb.Name = "QueryESP"
    bb.Size = UDim2.new(4, 0, 1.5, 0)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.MaxDistance = 500 -- Tidak render jika terlalu jauh (Hemat FPS)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.TextStrokeTransparency = 0
    tl.RichText = true
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.Parent = bb

    return hl, bb, tl
end

local function ClearESP()
    for plr, v in pairs(ESPPlayers) do
        if v.Highlight then v.Highlight:Destroy() end
        if v.Gui then v.Gui:Destroy() end
    end
    table.clear(ESPPlayers)
end

local function StartESP()
    if ESPConn then return end

    ESPConn = RunService.RenderStepped:Connect(function()
        if not State.ESP then 
            StopESP()
            return 
        end

        local myChar = lp.Character
        local myHRP = GetHRP(myChar)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                local char = plr.Character
                local hrp = GetHRP(char)
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    -- Perbarui atau Buat ESP
                    if not ESPPlayers[plr] then
                        local hl, gui, text = CreateESP(plr)
                        hl.Parent = char
                        gui.Parent = hrp
                        ESPPlayers[plr] = {Highlight = hl, Gui = gui, Text = text}
                    end

                    -- [ UPGRADE 3: SMART INFO ]
                    local dist = myHRP and math.floor((hrp.Position - myHRP.Position).Magnitude) or 0
                    local hp = math.floor((hum.Health / hum.MaxHealth) * 100)
                    
                    -- Warna Text Berubah sesuai HP
                    local hpColor = Color3.fromHSV(math.clamp(hp/100, 0, 0.35) * 0.38, 1, 1)
                    
                    -- Team Check (Warna Highlight berubah sesuai tim)
                    if plr.TeamColor == lp.TeamColor then
                        ESPPlayers[plr].Highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Hijau untuk teman
                    else
                        ESPPlayers[plr].Highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Merah untuk musuh
                    end

                    ESPPlayers[plr].Text.TextColor3 = hpColor
                    ESPPlayers[plr].Text.Text = string.format(
                        "<b>%s</b>\n<font size='10'>%d%% | %dm</font>",
                        plr.DisplayName, hp, dist
                    )
                else
                    -- Bersihkan jika player mati/keluar char
                    if ESPPlayers[plr] then
                        pcall(function()
                            ESPPlayers[plr].Highlight:Destroy()
                            ESPPlayers[plr].Gui:Destroy()
                        end)
                        ESPPlayers[plr] = nil
                    end
                end
            end
        end
    end)
end

local function StopESP()
    if ESPConn then
        ESPConn:Disconnect()
        ESPConn = nil
    end
    ClearESP()
end

--========================================================--
-- EXTREME FPS BOOSTER V10 (POTATO MODE)
-- FIX + UPGRADE MENTOK TOTAL (LOW-END OPTIMIZED)
--========================================================--
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local FPSCache = { Enabled = false, OriginalMaterials = {} }

local function SetFPSOptimized(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1 -- Sembunyikan tekstur tanpa menghapusnya (biar bisa restore)
    elseif v:IsA("BasePart") or v:IsA("MeshPart") then
        -- Simpan material asli untuk Restore
        if not FPSCache.OriginalMaterials[v] then
            FPSCache.OriginalMaterials[v] = {v.Material, v.Reflectance}
        end
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
    elseif v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
    end
end

EnableFPSBoost = function()
    if FPSCache.Enabled then return end
    FPSCache.Enabled = true

    -- [ UPGRADE 1: LIGHTING & TERRAIN ]
    FPSCache.Settings = {
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Technology = Lighting.Technology
    }

    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Technology = Enum.Technology.Compatibility
    
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
    end

    -- [ UPGRADE 2: MASSIVE OBJECT OPTIMIZATION ]
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsDescendantOf(workspace) or v:IsDescendantOf(Lighting) then
            SetFPSOptimized(v)
        end
    end

    -- [ UPGRADE 3: DYNAMIC ADAPTIVE BOOST ]
    FPSCache.Conn = workspace.DescendantAdded:Connect(function(v)
        if FPSCache.Enabled then
            task.wait() -- Tunggu instance siap
            SetFPSOptimized(v)
        end
    end)
    
end

DisableFPSBoost = function()
    if not FPSCache.Enabled then return end
    FPSCache.Enabled = false

    -- Restore Lighting
    if FPSCache.Settings then
        Lighting.FogEnd = FPSCache.Settings.FogEnd
        Lighting.GlobalShadows = FPSCache.Settings.GlobalShadows
        Lighting.OutdoorAmbient = FPSCache.Settings.OutdoorAmbient
        Lighting.Technology = FPSCache.Settings.Technology
    end

    -- [ UPGRADE 4: SMART RESTORE ]
    if FPSCache.Conn then FPSCache.Conn:Disconnect() end

    for obj, data in pairs(FPSCache.OriginalMaterials) do
        if obj and obj.Parent then
            obj.Material = data[1]
            obj.Reflectance = data[2]
            obj.CastShadow = true
        end
    end
    
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 0
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = true
        elseif v:IsA("PostEffect") then
            v.Enabled = true
        end
    end
    
    table.clear(FPSCache.OriginalMaterials)
    Notify("[ SYSTEM ]", "FPS Boost Disabled. Visuals Restored.", 3)
end

if State.FPSBoost then
    task.spawn(EnableFPSBoost)
end

--========================================================--
-- ULTRA ANTI-STAFF & SERVER HOP V12 (STEALH MODE)
-- FIX + UPGRADE MENTOK (BADGE & GROUP BYPASS)
--========================================================--
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local hopping = false
local lastHop = 0
local suspiciousNames = {"admin", "mod", "staff", "helper", "owner", "dev", "developer", "system"}

-- [ UPGRADE 1: ADVANCED STAFF DETECTION ]
local function IsStaff(plr)
    if not State.AntiEvade or not plr then return false end
    if plr.UserId <= 0 then return false end -- Filter NPC

    -- 1. Check Creator / Owner
    if game.CreatorType == Enum.CreatorType.User then
        if plr.UserId == game.CreatorId then return true end
    elseif game.CreatorType == Enum.CreatorType.Group then
        -- Cek Rank Group secara efisien
        local success, rank = pcall(function() return plr:GetRankInGroup(game.CreatorId) end)
        if success and rank >= 200 then return true end
    end

    -- 2. Check Badge (Banyak admin punya badge khusus dev)
    -- Badge ID 2124413180 biasanya adalah Official Roblox Staff
    local hasStaffBadge = pcall(function() return game:GetService("BadgeService"):UserHasBadgeAsync(plr.UserId, 2124413180) end)
    if hasStaffBadge then return true end

    -- 3. Check Name & DisplayName (Suspicious)
    local combinedName = (plr.Name .. " " .. plr.DisplayName):lower()
    for _, keyword in ipairs(suspiciousNames) do
        if combinedName:find(keyword) then return true end
    end

    -- 4. Check for Admin Character Parts (Legacy Check)
    local char = plr.Character
    if char then
        if char:FindFirstChild("AdminPanel") or char:FindFirstChild("StaffGUI") then
            return true
        end
    end

    return false
end

-- [ UPGRADE 2: SMART SERVER HOPPER ]
local function AutoHop()
    if hopping or (tick() - lastHop < 5) then return end
    hopping = true
    lastHop = tick()

    Notify("[ SYSTEM ] ANTI-STAFF", "Staff/Admin detected! Hopping to safe server...", 5)

    -- Mencegah Kick saat Teleport Gagal
    lp:OnTeleport(function(state)
        if state == Enum.TeleportState.Failed then
            hopping = false
            Notify("[ SYSTEM ] ERROR", "Teleport failed, retrying...", 2)
        end
    end)

    -- Teknik Server Hop via API Roblox
    local function GetSafeServer()
        local sf = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        end)
        
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if type(s) == "table" and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(sf, s.id)
                end
            end
        end
        return sf
    end

    local availableServers = GetSafeServer()
    if #availableServers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, availableServers[math.random(1, #availableServers)], lp)
    else
        -- Fallback: Teleport biasa jika list tidak ditemukan
        TeleportService:Teleport(game.PlaceId, lp)
    end
end

-- [ UPGRADE 3: INSTANT JOIN & PERIODIC SCAN ]
Players.PlayerAdded:Connect(function(p)
    if State.AntiEvade then
        task.wait(0.5) -- Beri waktu server load data player
        if IsStaff(p) then
            AutoHop()
        end
    end
end)

-- Scan player yang sudah ada saat script baru dijalankan
task.spawn(function()
    while task.wait(5) do
        if not State.AntiEvade then continue end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and IsStaff(p) then
                AutoHop()
                break
            end
        end
    end
end)

--========================================================--
-- AUTO REJOIN
--========================================================--

local function SafeRejoin()
    local success, err = pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, lp)
        else
            -- Cari server baru yang bukan server ini
            local sf = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=10"))
            for _, s in ipairs(sf.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                    break
                end
            end
        end
    end)
    if not success then TeleportService:Teleport(game.PlaceId, lp) end
end

lp.OnTeleport:Connect(function(state)
    if not State.AutoRejoin then return end
    
    if state == Enum.TeleportState.Failed then
        Notify("[ SYSTEM ]", "Teleport Gagal! Mencoba Rejoin dalam 3 detik...", 3)
        task.wait(3)
        SafeRejoin()
    elseif state == Enum.TeleportState.InProgress then
        -- Mencegah script berhenti saat transisi server
        print("[QueryHub] Server Shifting...")
    end
end)

-- [ UPGRADE 2: MEMORY LEAK PROTECTION (CLEANUP) ]
-- Menghapus sisa-sisa objek ESP dan Highlight agar FPS tidak drop
Players.PlayerRemoving:Connect(function(plr)
    if ESPPlayers[plr] then
        pcall(function()
            if ESPPlayers[plr].Gui then 
                ESPPlayers[plr].Gui:Destroy() 
            end
            if ESPPlayers[plr].Highlight then 
                ESPPlayers[plr].Highlight:Destroy() 
            end
        end)
        ESPPlayers[plr] = nil
    end
end)

-- [ UPGRADE 3: SILENT ANTI-AFK BYPASS ]
-- Tidak menggunakan simulasi mouse yang terlihat oleh server
-- Menggunakan VirtualUser untuk mengirim signal "Idled" palsu
if getgenv().AntiAFKConn then getgenv().AntiAFKConn:Disconnect() end
getgenv().AntiAFKConn = lp.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
            print("[QueryHub] Anti-AFK Triggered: Prevented Kick.")
        end)
    end
end)

-- [ UPGRADE 4: KICK TO REJOIN ]
-- Jika kamu di-kick, script akan otomatis memindahkan kamu ke server lain
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if State.AutoRejoin then
        task.wait(0.5)
        SafeRejoin()
    end
end)

--========================================================--
-- Main
--========================================================--
MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = State.Fly,
    Callback = function(v)
        State.Fly = v
        SaveState()
        Notify("Main","Fly : "..(v and "ON" or "OFF"))
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
        Notify("Main","Speed : "..(v and "ON" or "OFF"))
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
        Notify("Main","Speed set to : "..v)
    end
})

MainTab:CreateToggle({
    Name = "Enable Jump",
    CurrentValue = State.Jumpy,
    Callback = function(v)
        State.Jumpy = v
        SaveState()
        Notify("Main","Jump : "..(v and "ON" or "OFF"))
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
        Notify("Main","JumpPower set to : "..v)
    end
})

MainTab:CreateToggle({
    Name = "Walk On Water",
    CurrentValue = State.WalkOnWater,
    Callback = function(v)
        State.WalkOnWater = v
        SaveState()
        Notify("Main","Walk On Water : "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = State.GodMode,
    Callback = function(v)
        State.GodMode = v
        SaveState()
        Notify("Main","God Mode : "..(v and "ON" or "OFF"))
    end
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = State.Noclip,
    Callback = function(v)
        State.Noclip = v
        SaveState()
        Notify("Main","Noclip : "..(v and "ON" or "OFF"))
    end
})

--========================================================--
-- ULTIMATE INVISIBLE V20 (GOD-STEALTH MODE)
-- FIX + UPGRADE MENTOK (SERVER-SPOOF & NAME HIDE)
--========================================================--
local InvisCache = {}
local InvisConn

local function ApplyInvisible(char)
    if not char then return end
    
    -- [ UPGRADE 1: NAMETAG & UI HIDING ]
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        hum.NameOcclusion = Enum.NameOcclusion.NoOcclusion
    end

    -- [ UPGRADE 2: CONTINUOUS LOCKING ]
    -- Menggunakan RenderStepped agar transparansi tidak di-reset oleh Engine
    if InvisConn then InvisConn:Disconnect() end
    InvisConn = RunService.RenderStepped:Connect(function()
        
        if not State.Invisible or not char.Parent then 
            if InvisConn then InvisConn:Disconnect() InvisConn = nil end
            return 
        end
        
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                -- Simpan data asli jika belum ada di cache
                if not InvisCache[v] then
                    InvisCache[v] = {LTM = v.LocalTransparencyModifier, Shadow = v.CastShadow}
                end
                v.LocalTransparencyModifier = 1
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                if not InvisCache[v] then
                    InvisCache[v] = {Transparency = v.Transparency}
                end
                v.Transparency = 1
            end
        end
    end)
    
    Notify("👻 STEALTH", "Invisibility Active (Client-Side Optimized)", 3)
end

local function RemoveInvisible()
    if InvisConn then InvisConn:Disconnect() InvisConn = nil end
    
    local char = lp.Character
    if char then
        -- Restore Nametag
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
        
        -- Restore Parts from Cache
        for obj, data in pairs(InvisCache) do
            if obj and obj.Parent then
                pcall(function()
                    if obj:IsA("BasePart") then
                        obj.LocalTransparencyModifier = data.LTM or 0
                        obj.CastShadow = data.Shadow
                    elseif obj:IsA("Decal") then
                        obj.Transparency = data.Transparency or 0
                    end
                end)
            end
        end
    end
    table.clear(InvisCache)
    Notify("👻 STEALTH", "Invisibility Disabled.", 2)
end

-- [ UPGRADE 3: AUTO-STATE REFRESH ]
lp.CharacterAdded:Connect(function(char)
    if State.Invisible then
        task.wait(0.5) -- Beri waktu karakter load sempurna
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

        if v then
            StartESP()
        else
            StopESP()
        end

        Notify("Main","ESP : "..(v and "ON" or "OFF"))
    end
})
--========================================================--
-- SYSTEM
--========================================================--
SystemTab:CreateToggle({
    Name = "Anti Evade",
    CurrentValue = State.AntiEvade,
    Callback = function(v)
        State.AntiEvade = v
        SaveState()
        Notify("System","Anti Evade : "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = State.AntiVoid,
    Callback = function(v)
        State.AntiVoid = v
        getgenv().AntiVoidHandle = v
        SaveState()
        Notify("System","Anti Void : "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Anti Kick",
    CurrentValue = getgenv().ED_AntiKick.Enabled,
    Callback = function(v)
        getgenv().ED_AntiKick.Enabled = v
        SaveState()
        Notify("System","Anti Kick : "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = State.AntiAFK,
    Callback = function(v)
        State.AntiAFK = v
        SaveState()
        Notify("System","Anti AFK : "..(v and "ON" or "OFF"))
    end
})

SystemTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = State.AutoRejoin,
    Callback = function(v)
        State.AutoRejoin = v
        SaveState()
        Notify("System","Auto Rejoin : "..(v and "ON" or "OFF"))
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
        Notify("Troll","Auto Fling : "..(v and "ON" or "OFF"))
    end
})

TrollTab:CreateDropdown({
    Name = "Fling Mode",
    Options = {"Normal","Orbit","Tornado"},
    CurrentOption = {State.FlingMode},
    Callback = function(v)
        State.FlingMode = v[1]
        SaveState()
        Notify("Troll", "Fling Mode : "..State.FlingMode)
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
        Notify("Troll", "Power set to : "..v)
    end
})

TrollTab:CreateToggle({
    Name = "Counter Fling",
    CurrentValue = State.CounterFling,
    Callback = function(v)
        State.CounterFling = v
        SaveState()
        Notify("Troll","Counter Fling : "..(v and "ON" or "OFF"))
    end
})

TrollTab:CreateToggle({
    Name = "Bring All",
    CurrentValue = State.BringLoop,
    Callback = function(v)
        State.BringLoop = v
        SaveState()
        Notify("Troll","Bring All : "..(v and "ON" or "OFF"))
    end
})

TrollTab:CreateButton({
    Name = "Bring Nearest",
    Callback = function()
        local myChar = lp.Character
        local myHRP = GetHRP(myChar)
        if not myHRP then
    return
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

task.wait(3.5)
Notify("[ SYSTEM ] QueryHub","Succesfully Load Scripts..",4)