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
    Icon = ambatukam,
    Theme = "Light",
    ShowText = "QueryHub",
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false }
})

-- TABS
local MainTab = Window:CreateTab("Main", "home")
local TrollTab = Window:CreateTab("Troll", "skull")
local SystemTab = Window:CreateTab("Server", "database")

-- SMART NOTIFY
local function Notify(t, d, s)
    Rayfield:Notify({
        Title = t,
        Content = d,
        Duration = s or 3,
        Image = ambatukam
    })
end

--========================================================--
-- SPEED & JUMP
--========================================================--

-- Optimization: Local variables untuk kecepatan akses
local Vec3 = Vector3.new
local EnumState = Enum.HumanoidStateType

local function PatchHumanoid(hum)
    if not hum then return end
    hum.UseJumpPower = true 
    -- Disable states yang sering bikin karakter "nyangkut" atau jatuh saat speed tinggi
    local disabledStates = {
        EnumState.FallingDown,
        EnumState.Ragdoll,
        EnumState.PlatformStanding,
        EnumState.StrafingNoPhysics
    }
    for _, state in ipairs(disabledStates) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(EnumState.Running)
end

-- Task untuk Network Bypass (Tidak perlu setiap frame)
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(lp, "SimulationRadius", 1e308)
                sethiddenproperty(lp, "MaxSimulationRadius", 1e308)
            end
        end)
    end
end)

-- Core Movement Loop
RunService.PreSimulation:Connect(function(dt)
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp or hum.Health <= 0 then return end

    -- [ 1. SMART SPEED ENGINE ]
    if State.Speedy then
        local moveDir = hum.MoveDirection
        
        if moveDir.Magnitude > 0 then
            -- Kombinasi Velocity & Offset yang halus (Bypass Rubberband)
            -- Kita prioritaskan Velocity untuk fisik, dan sedikit CFrame untuk akurasi
            local targetVel = moveDir * State.Speed
            hrp.AssemblyLinearVelocity = Vec3(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z)
            
            -- Anti-Cheat Spoof: Menggeser CFrame sedikit ke depan untuk mencocokkan velocity
            -- Menggunakan task.defer atau lerp jika ingin lebih smooth
            hrp.CFrame = hrp.CFrame + (moveDir * (State.Speed * dt * 0.1)) 
        else
            -- Active Braking: Menghilangkan inersia agar tidak terpeleset
            hrp.AssemblyLinearVelocity = Vec3(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
        
        -- WalkSpeed Spoofing (Hanya untuk animasi)
        hum.WalkSpeed = 16 
    end

    -- [ 2. SMART JUMP ENGINE ]
    if State.Jumpy then
        if UIS:GetFocusedTextBox() == nil and UIS:IsKeyDown(Enum.KeyCode.Space) then
            -- Deteksi Ground dengan Raycast sederhana agar tidak bisa terbang (Infinite Jump kecuali diinginkan)
            -- Jika ingin Infinite Jump, hapus kondisi FloorMaterial
            if hum.FloorMaterial ~= Enum.Material.Air then
                if tick() - lastMoveTick > 0.15 then 
                    hrp.AssemblyLinearVelocity = Vec3(hrp.AssemblyLinearVelocity.X, State.Jump, hrp.AssemblyLinearVelocity.Z)
                    lastMoveTick = tick()
                end
            end
        end
    end
end)

-- [ 3. MASSLESS & COLLISION MANAGER ]
-- Diperbaiki agar tidak membebani CPU
local function ApplyMassless(char, bool)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = bool
            -- Memperbaiki bug karakter mental saat tabrakan kecepatan tinggi
            if bool then
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            else
                part.CustomPhysicalProperties = nil
            end
        end
    end
end

-- Auto-Update saat toggle berubah (Logic Trigger)
-- Pastikan di script utama Anda, saat toggle Speedy ON, panggil ApplyMassless(char, true)

-- AUTO FIX & FORCE PATCH
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    
    PatchHumanoid(hum)
    
    task.wait(0.2)
    if State.Speedy then
        ApplyMassless(char, true)
    end
end)

--========================================================--
-- ULTIMATE NOCLIP 
--========================================================--

local NoclipConn = nil
local CollisionCache = {} -- Menyimpan state asli part

local function ToggleNoclip(bool)
    State.Noclip = bool

    -- Bersihkan koneksi lama
    if NoclipConn then 
        NoclipConn:Disconnect() 
        NoclipConn = nil 
    end

    if not bool then
        -- RESTORE LOGIC: Mengembalikan collision ke semula tanpa merusak game
        local char = lp.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Kembalikan ke state asli (default true, kecuali memang part tertentu dari game)
                    part.CanCollide = true
                end
            end
        end
        Notify("[ SYSTEM ]", "Noclip Deactivated: Kembali ke fisik nyata.", 2)
        return
    end

    -- LOGIC UPGRADE: Menggunakan Stepped (Berjalan sebelum physics kalkulasi)
    NoclipConn = RunService.Stepped:Connect(function()
        local char = lp.Character
        if not char or not State.Noclip then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- 1. STATE LOCKING (Anti-Ragdoll/Physics Bug)
        -- RunningNoPhysics adalah state paling stabil untuk noclip
        if hum then
            local currentState = hum:GetState()
            if currentState ~= Enum.HumanoidStateType.RunningNoPhysics and 
               currentState ~= Enum.HumanoidStateType.Climbing and 
               currentState ~= Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end

        -- 2. EFFICIENT COLLISION BYPASS
        -- Kita tidak pakai GetDescendants tiap frame (Lag). Kita langsung hajar part utama.
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
            -- Aksesoris (Hat, Hair, dll) sering punya hit box yang bikin nyangkut
            if part:IsA("Accessory") and part:FindFirstChild("Handle") then
                part.Handle.CanCollide = false
            end
        end
        
        -- 3. SPECIFIC ROOTPART LOGIC (Anti-Falling)
        -- Masalah: Kalau semua false, kamu jatuh ke void.
        -- Solusi: Gunakan Raycast kecil ke bawah. Jika diam, aktifkan collision tipis.
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hum and hum.MoveDirection.Magnitude <= 0 then
                -- Cek apakah ada lantai di bawah kaki
                local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -3.5, 0))
                if ray then
                    hrp.CanCollide = true -- Tetap di atas lantai saat diam
                else
                    hrp.CanCollide = false -- Biarkan tetap noclip jika di udara
                end
            else
                hrp.CanCollide = false -- Saat bergerak, tembus semuanya
            end
        end
    end)
    
    Notify("[ SYSTEM ]", "Noclip Supreme: Ghost Mode Aktif!", 2)
end

--========================================================--
-- AUTO RECOVERY & CHARACTER HANDLER
--========================================================--

-- Masalah: Jika mati/respawn saat noclip ON, seringkali noclip mati sendiri
-- Solusi: Re-apply dengan delay halus agar karakter load sempurna
lp.CharacterAdded:Connect(function(char)
    if State.Noclip then
        task.wait(0.5) -- Tunggu part karakter ter-instantiate
        if State.Noclip then ToggleNoclip(true) end
    end
end)

-- INTEGRASI PENCEGAHAN TERJEBAK (Unstuck Logic)
-- Jika noclip dimatikan saat di dalam dinding, dorong karakter ke tempat aman
local function Unstuck()
    if not State.Noclip then
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            -- Cek apakah HRP bertabrakan dengan sesuatu (Internal Check)
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local check = workspace:Spherecast(pos, 1, Vector3.new(0, 0.1, 0), params)
            if check then
                -- Jika terjepit, naikkan ke atas atau geser sedikit
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 5, 0)
                Notify("[ SYSTEM ]", "Unstuck: Mengeluarkan kamu dari objek!", 2)
            end
        end
    end
end

-- Pantau perubahan toggle untuk Unstuck
task.spawn(function()
    local lastState = State.Noclip
    while task.wait(0.5) do
        if lastState == true and State.Noclip == false then
            Unstuck()
        end
        lastState = State.Noclip
    end
end)

--========================================================--
-- WALK ON WATER V3 (SMOOTH & ANTI-SLIP)
--========================================================--

local platformPart = nil
local lastWaterY = 0

-- Helper: Mendapatkan tinggi air yang akurat (Terrain vs Mesh Water)
local function GetWaterLevel(hrp, rayParam)
    -- Multi-Raycast: Tengah, Depan, Belakang (Biar presisi saat lari cepat)
    local offsets = {Vector3.new(0, 0, 0), hrp.CFrame.LookVector * 2}
    
    for _, offset in ipairs(offsets) do
        local result = workspace:Raycast(hrp.Position + offset + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), rayParam)
        if result then
            local mat = result.Material
            local name = result.Instance.Name:lower()
            if mat == Enum.Material.Water or name:find("water") or name:find("lava") or name:find("acid") then
                return result.Position.Y, true
            end
        end
    end
    return 0, false
end

RunService.PreRender:Connect(function()
    if not State.WalkOnWater then
        if platformPart then platformPart:Destroy() platformPart = nil end
        return
    end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then 
        if platformPart then platformPart.CanCollide = false end
        return 
    end

    -- 1. EFFICIENT POOLING
    if not platformPart or not platformPart.Parent then
        platformPart = Instance.new("Part")
        platformPart.Name = "Query_Water_Platform"
        platformPart.Anchored = true
        platformPart.Size = Vector3.new(15, 0.5, 15) -- Sedikit lebih tebal agar tidak tembus saat lag
        platformPart.Transparency = 1
        platformPart.CanTouch = false -- Biar tidak trigger touch interest yang bikin lag
        platformPart.Parent = workspace
    end

    -- 2. LOGIC UPGRADE: SMART RAYCASTING
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {char, platformPart, workspace.CurrentCamera}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    
    local waterY, isOverWater = GetWaterLevel(hrp, rayParam)
    
    -- 3. SNAP LOGIC (Menentukan posisi Y terbaik)
    -- Jika di atas air, kita paksa Platform ada di permukaan air tersebut
    local targetY = waterY - 0.1 -- Sedikit di bawah permukaan air agar kaki terlihat menginjak air
    
    -- 4. VELOCITY PREDICTION (Bypass Speedhack Lag)
    -- Semakin cepat lari, semakin jauh platform ditaruh di depan agar tidak 'jatuh' dari platform sendiri
    local horizontalVelocity = hrp.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
    local prediction = horizontalVelocity * 0.08 -- 80ms buffer

    -- 5. SMOOTH TRANSITION
    -- Jika kita sedang melompat atau menekan CTRL, platform pindah jauh ke bawah (Tenggelam)
    local isCrouching = UIS:IsKeyDown(Enum.KeyCode.LeftControl)
    local isJumping = hum.Jump or hrp.AssemblyLinearVelocity.Y > 5
    
    if isOverWater and not isCrouching and not isJumping then
        platformPart.CanCollide = true
        -- Lerp CFrame agar tidak patah-patah saat air bergerak
        platformPart.CFrame = CFrame.new(hrp.Position.X + prediction.X, waterY - 0.25, hrp.Position.Z + prediction.Z)
        
        -- Mencegah friction (biar gak ngerem mendadak saat di air)
        platformPart.Friction = 0
    else
        platformPart.CanCollide = false
        -- Taruh di bawah map jika tidak digunakan
        platformPart.CFrame = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z)
    end
end)

--====================================================--
-- UPGRADED HARD ANTI-KICK (ULTIMATE BYPASS)
--====================================================--

if not getgenv().__ANTIKICK_ULTIMATE then
    getgenv().__ANTIKICK_ULTIMATE = true

    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local oldIndex = mt.__index
        local oldNewIndex = mt.__newindex
        
        setreadonly(mt, false)

        -- [ 1. NAME CALL BYPASS (DIRECT METHOD) ]
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if getgenv().ED_AntiKick.Enabled and self == lp then
                -- Memblokir Kick, Destroy, dan Remove (Metode umum untuk membuang player)
                if method == "Kick" or method == "kick" or method == "Destroy" or method == "Remove" then
                    local reason = args[1] or "No specific reason provided"
                    
                    if getgenv().ED_AntiKick.SendNotifications then
                        Notify("[ SYSTEM ] ANTI-KICK", "Blocked " .. method:upper() .. " Attempt!\nReason: " .. tostring(reason), 10)
                    end
                    
                    return coroutine.yield() 
                end
            end
            return oldNamecall(self, ...)
        end)

        -- [ 2. INDEX BYPASS (PROPERTY ACCESS) ]
        mt.__index = newcclosure(function(self, key)
            if getgenv().ED_AntiKick.Enabled and self == lp then
                if key == "Kick" or key == "kick" then
                    return newcclosure(function() 
                        print("[SHIELD] Internal Kick Script Blocked.")
                        return coroutine.yield() 
                    end)
                end
            end
            return oldIndex(self, key)
        end)

        mt.__newindex = newcclosure(function(self, key, value)
            if getgenv().ED_AntiKick.Enabled and self == lp and key == "Parent" and value == nil then
                Notify("[ SYSTEM ] ANTI KICK", "Blocked Parent-Nulling attempt (Silent Kick)", 5)
                return nil -- Menolak perubahan parent ke nil
            end
            return oldNewIndex(self, key, value)
        end)

        local CoreGui = game:GetService("CoreGui")
        CoreGui.DescendantAdded:Connect(function(v)
            if getgenv().ED_AntiKick.Enabled then
                if v.Name == "ErrorPrompt" or v.Name == "RobloxPromptGui" then
                    v.Visible = false
                    -- Klik tombol "Leave" secara otomatis tapi tidak keluar (Bypass internal)
                    local leaveBtn = v:FindFirstChild("LeaveButton", true)
                    if leaveBtn then leaveBtn:Destroy() end
                end
            end
        end)

        setreadonly(mt, true)
    end)

    if setfflag then
        pcall(function()
            setfflag("AbuseReportScreenshot", "False")
            setfflag("CrashPadUploadToS3", "False")
        end)
    end

    if not success then
        warn("Anti-Kick CRITICAL FAILURE: " .. tostring(err))
    end
end

--========================================================--
-- SMART ANTI-VOID V3 (RAYCAST GROUND DETECTION)
--========================================================--

local lastSafeCF_Void = nil
local isRecovering = false
local lastGroundPos = tick()

--// Configuration
local DETECTION_SETTINGS = {
    VOID_LEVEL = -100,        -- Batas Y terendah
    CHECK_DEPTH = 150,        -- Jarak cek ke bawah (Lubang biasa vs Void)
    RAY_RADIUS = 3.5,         -- Luas jangkauan kaki (biar gak baper pas di pinggir lubang)
    FALL_TIME_MAX = 1.6,      -- Detik jatuh sebelum dianggap void
}

RunService.Heartbeat:Connect(function()
    if not State.AntiVoid then return end

    local char = lp.Character
    local hrp = GetHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then return end

    -- [ 1. ADVANCED MULTI-RAY SCANNER ]
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {char, workspace:FindFirstChild("Universal_Surface_Platform")}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude

    -- Array posisi pengecekan (Tengah, Depan, Belakang, Kiri, Kanan)
    local offsets = {
        Vector3.new(0, 0, 0),
        Vector3.new(DETECTION_SETTINGS.RAY_RADIUS, 0, 0),
        Vector3.new(-DETECTION_SETTINGS.RAY_RADIUS, 0, 0),
        Vector3.new(0, 0, DETECTION_SETTINGS.RAY_RADIUS),
        Vector3.new(0, 0, -DETECTION_SETTINGS.RAY_RADIUS)
    }

    local isOverSomething = false
    local hitsCloseGround = false

    for _, offset in ipairs(offsets) do
        local origin = hrp.Position + offset
        local result = workspace:Raycast(origin, Vector3.new(0, -DETECTION_SETTINGS.CHECK_DEPTH, 0), rayParam)
        
        if result then
            isOverSomething = true -- Menandakan ada lantai di kedalaman tertentu (bukan void)
            if (hrp.Position.Y - result.Position.Y) < 20 then
                hitsCloseGround = true -- Tanah dekat (aman untuk disave sebagai SafePoint)
            end
        end
    end

    -- Update posisi aman jika menapak di area solid (bukan di atas udara/lubang)
    if hitsCloseGround and hrp.AssemblyLinearVelocity.Magnitude < 65 then
        lastSafeCF_Void = hrp.CFrame
        lastGroundPos = tick()
    end

    -- [ 2. SMART VOID DECISION ]
    -- Karakter dianggap jatuh ke Void jika:
    -- A. Di bawah koordinat Y kritis.
    -- B. Melayang di area yang BENAR-BENAR kosong (isOverSomething == false) selama lebih dari batas waktu.
    local tooDeep = hrp.Position.Y < DETECTION_SETTINGS.VOID_LEVEL
    local fallingInAbyss = (not isOverSomething) and (tick() - lastGroundPos > DETECTION_SETTINGS.FALL_TIME_MAX) and (hrp.AssemblyLinearVelocity.Y < -40)

    if (tooDeep or fallingInAbyss) and not isRecovering then
        isRecovering = true

        -- Stabilisasi Total
        hrp.Anchored = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        task.wait(0.2) -- Buffer frame untuk physics engine

        if lastSafeCF_Void then
            -- Teleport dengan offset sedikit ke atas agar tidak stuck di lantai
            hrp.CFrame = lastSafeCF_Void + Vector3.new(0, 2, 0)
            Notify("[ ANTI-VOID ]", "Deep Void Terdeteksi. Posisi dipulihkan!", 3)
        else
            -- FAILSAFE: Platform darurat jika history posisi belum tercatat
            local backupPart = Instance.new("Part")
            backupPart.Size = Vector3.new(20, 1, 20)
            backupPart.Anchored = true
            backupPart.CFrame = hrp.CFrame - Vector3.new(0, 4, 0)
            backupPart.BrickColor = BrickColor.new("Neon orange")
            backupPart.Material = Enum.Material.Neon
            backupPart.Parent = workspace
            
            hrp.CFrame = backupPart.CFrame + Vector3.new(0, 4, 0)
            Notify("[ WARNING ]", "Void terdeteksi! Posisi aman belum tercatat, membuat pijakan darurat.", 5)
            task.delay(5, function() backupPart:Destroy() end)
        end

        task.wait(0.5)
        hrp.Anchored = false
        
        -- Cooldown agar tidak trigger beruntun
        task.wait(1)
        isRecovering = false
        lastGroundPos = tick()
    end
end)

--========================================================--
-- ULTIMATE FLING & COUNTER CORE (FIXED)
--========================================================--

local function SetVelocity(part)
    pcall(function()
        if sethiddenproperty then
            -- MENTOK: Memaksa Network Radius ke angka absolut terbesar yang bisa ditampung memori
            sethiddenproperty(lp, "SimulationRadius", 1e308)
            sethiddenproperty(lp, "MaxSimulationRadius", 1e308)
            sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        end
        -- Menggunakan math.huge untuk rotasi agar tidak bisa dihitung (NaN/Infinity bypass)
        part.AssemblyLinearVelocity = Vector3.new(State.Power * 5, State.Power * 5, State.Power * 5)
        part.AssemblyAngularVelocity = Vector3.new(9e9, 9e9, 9e9)
    end)
end

-- CLEANER MENTOK: Menghapus semua constraint yang bisa menahan gerakan kita
local function CleanForce(hrp)
    if not hrp then return end
    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyMover") or v:IsA("VectorForce") or v:IsA("RocketPropulsion") or v:IsA("BodyPosition") or v.Name:find("Fling") then
            v:Destroy()
        end
    end
end

-- EXECUTE FLING MENTOK (V-SYNC OVERLOAD)
local function ExecuteFling(targetHRP)
    local char = lp.Character
    local myHRP = GetHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetHRP then return end

    CleanForce(myHRP)
    
    -- MENTOK: Mematikan animasi agar tidak menghambat rotasi HRP
    if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end

    -- Create Forces dengan High-Frequency Velocity
    local bv = Instance.new("BodyVelocity")
    bv.Name = "QueryFling_BV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Kekuatan absolut

    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "QueryFling_BAV"
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

    -- MENTOK: Fling Mode Logic dengan Predictive Positioning
    if State.FlingMode == "Normal" then
        bv.Velocity = (targetHRP.Position - myHRP.Position).Unit * (State.Power * 2)
        bav.AngularVelocity = Vector3.new(9e9, 9e9, 9e9)
    elseif State.FlingMode == "Orbit" then
        -- Orbit secepat kilat di sekitar target
        myHRP.CFrame = targetHRP.CFrame * CFrame.Angles(0, math.rad(tick()*720), 0) * CFrame.new(0, 0, 1.5)
        bv.Velocity = myHRP.CFrame.lookVector * State.Power
        bav.AngularVelocity = Vector3.new(0, 9e9, 0)
    elseif State.FlingMode == "Tornado" then
        -- Rotasi 3 sumbu secara acak agar target tidak bisa menghindar
        bv.Velocity = Vector3.new(0, State.Power, 0)
        bav.AngularVelocity = Vector3.new(9e5, 9e5, 9e5)
    end

    bv.Parent = myHRP
    bav.Parent = myHRP
    
    -- Injeksi Velocity Fisika
    SetVelocity(myHRP)

    -- Auto-Cleanup agar kita tidak ikut terlempar selamanya
    task.delay(0.25, function()
        CleanForce(myHRP)
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- COUNTER FLING MENTOK (ABSOLUTE REFLECTION)
-- Menggunakan Heartbeat untuk deteksi instan sebelum frame render
RunService.Heartbeat:Connect(function()
    if not State.CounterFling or State.Fly then return end
    local char = lp.Character
    local hrp = GetHRP(char)
    if not hrp then return end

    -- Deteksi Kecepatan: Jika kita didorong lebih dari 100 studs/sec, reset instan
    if hrp.AssemblyLinearVelocity.Magnitude > 100 or hrp.AssemblyAngularVelocity.Magnitude > 100 then
        -- MENTOK: Instant Anchor & Momentum Kill
        hrp.Anchored = true
        CleanForce(hrp)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        task.wait() -- Stabilisasi 1 frame
        
        if lastSafeCF_Void then
            hrp.CFrame = lastSafeCF_Void
        end
        
        hrp.Anchored = false
        Notify("[ SYSTEM ] COUNTER FLING", "Ada yg mau usil wok, udah gw amankan", 2)
    end
end)

-- BRING LOOP MENTOK (PHYSICS STEALER)
task.spawn(function()
    while task.wait(0.2) do -- Frekuensi lebih cepat
        if not State.BringLoop then continue end
        local myHRP = GetHRP(lp.Character)
        if not myHRP then continue end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and IsAlive(p.Character) then
                local tHRP = GetHRP(p.Character)
                if tHRP then
                    -- MENTOK: Memaksa Network Ownership agar kita bisa mengontrol posisi mereka
                    pcall(function()
                        if sethiddenproperty then
                            sethiddenproperty(tHRP, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
                        end
                        -- Teleportasi target tepat di depan kita dengan offset sedikit agar bisa di-fling/hit
                        tHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -4)
                        tHRP.AssemblyLinearVelocity = Vector3.zero -- Mematikan gerakan mereka
                    end)
                end
            end
        end
    end
end)

--========================================================--
-- THE FLY INFINITY (NO-BUG / ANTI-DAMAGE / NO-JITTER)
--========================================================--
local FlyConn, FlyBV, FlyBG, HeartbeatConn
local Vec3 = Vector3.new
local ZeroVec = Vector3.zero

-- [ 1. BYPASS & STATE MANAGEMENT ]
local function SetRigidStatus(status)
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if status then
        -- Mencegah animasi falling/ragdoll yang memicu anti-cheat
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function StopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if HeartbeatConn then HeartbeatConn:Disconnect() HeartbeatConn = nil end
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end

    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    SetRigidStatus(false)
    if hum then hum.PlatformStand = false end
    if hrp then 
        hrp.AssemblyLinearVelocity = ZeroVec
        hrp.AssemblyAngularVelocity = ZeroVec
    end

    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanTouch = true end
        end
    end
end

local function StartFly()
    if FlyConn then return end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera

    if not hrp or not hum then return end

    -- [ 2. PHYSICS INJECTION ]
    SetRigidStatus(true)
    
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "SUPREME_FLY_BV"
    FlyBV.MaxForce = Vec3(math.huge, math.huge, math.huge)
    FlyBV.Velocity = ZeroVec
    FlyBV.Parent = hrp

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "SUPREME_FLY_BG"
    FlyBG.MaxTorque = Vec3(math.huge, math.huge, math.huge)
    FlyBG.P = 9e4
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp

    -- [ 3. CORE FLY ENGINE ]
    FlyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly or not hrp.Parent or hum.Health <= 0 then 
            StopFly() 
            return 
        end

        local camCF = cam.CFrame
        local moveDir = hum.MoveDirection
        local flyVec = ZeroVec

        -- Arah pergerakan 3D (Relative to Camera)
        if moveDir.Magnitude > 0 then
            -- Logic: LookVector menangani arah Forward/Backward, RightVector menangani Left/Right
            local look = camCF.LookVector
            local right = camCF.RightVector
            flyVec = (look * (moveDir.Z * -1)) + (right * moveDir.X)
        end

        -- Kontrol Vertikal (Space = Naik, L-CTRL = Turun)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            flyVec = flyVec + Vec3(0, 1, 0)
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyVec = flyVec + Vec3(0, -1, 0)
        end

        -- Aplikasi Velocity & Gyro
        if flyVec.Magnitude > 0 then
            FlyBV.Velocity = flyVec.Unit * State.FlySpeed
        else
            FlyBV.Velocity = ZeroVec -- Instant Brake
        end

        FlyBG.CFrame = camCF
        hum.PlatformStand = true
        
        -- Bypass: Memaksa state swimming (Sangat penting untuk NDS)
        if hum:GetState() ~= Enum.HumanoidStateType.Swimming then
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end)

    -- [ 4. BYPASS LOOP (ANTI-DAMAGE & NOCLIP) ]
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not State.Fly or not char then return end
        
        -- Noclip Logic (Dijalankan di Heartbeat agar lebih stabil dari Stepped)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false -- Noclip
                v.CanTouch = false -- Anti-Damage (Lava/Acid)
                v.Velocity = Vec3(0, 0.05, 0) -- Velocity Spoofing
            end
            -- Handle Aksesoris agar tidak nyangkut
            if v:IsA("Accessory") and v:FindFirstChild("Handle") then
                v.Handle.CanCollide = false
            end
        end
    end)
end

--========================================================--
-- PERSISTENCE & AUTO-FIX
--========================================================--

-- Menangani Respawn (Jika mati, Fly otomatis menyala lagi jika State.Fly true)
lp.CharacterAdded:Connect(function(char)
    if State.Fly then
        task.wait(0.5) -- Jeda agar karakter load sempurna
        if State.Fly then StartFly() end
    end
end)

-- Health Checker: Mencegah karakter "nyangkut" saat HP 0
task.spawn(function()
    while task.wait(0.5) do
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 and State.Fly then
            StopFly()
        end
    end
end)

--========================================================--
-- GODMODE V5 (SAFE / NO NIL / NO ERROR)
--========================================================--

local FinalGodConn = nil
local JointConn = nil

-- [ HELPER: RE-JOINT SYSTEM ]
-- Mencegah tubuh hancur saat terkena ledakan besar (Anti-Mutilation)
local function SecureJoints(char)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Motor6D") then
            v.Name = "SECURE_" .. v.Name -- Mengganti nama agar script game tidak bisa menemukan joint untuk dilepas
        end
    end
end

local function OmegaGod(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum then return end

    -- [ 1. SENSOR & RE-JOINT PROTECTION ]
    local function Cleanse()
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("TouchTransmitter") then
                v:Destroy() -- Menghancurkan sensor sentuh (Lava, Trap, Peluru)
            elseif v:IsA("Motor6D") and not v.Name:find("SECURE_") then
                v.Name = "SECURE_" .. v.Name
            end
        end
    end
    Cleanse()

    -- [ 2. ADVANCED METATABLE BYPASS ]
    -- Menggunakan hookmetamethod agar lebih modern dan sulit dideteksi anti-cheat
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and State.GodMode and self == hum then
            if key == "Health" then return hum.MaxHealth end
            if key == "Sit" then return false end
        end
        return oldIndex(self, key)
    end)

    -- [ 3. CORE IMMORTALITY LOOP ]
    if FinalGodConn then FinalGodConn:Disconnect() end
    FinalGodConn = RunService.PreSimulation:Connect(function()
        if not State.GodMode or not hum.Parent then return end

        -- Force Health: Mengunci HP di tingkat engine (Client-Side)
        hum.Health = hum.MaxHealth
        
        -- Bypass Death: Mematikan state mati agar karakter tidak hancur saat HP 0 (Server-Side)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.RequiresNeck = false -- Anti kepala putus
        
        -- Anti-Void Absolute
        if hrp and hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 10) then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
            hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
        end

        -- Ghost Body Physics
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanTouch = false -- Bypass Touched Events
                part.CanQuery = false -- Bypass Raycasts (Sangat OP untuk game tembak-tembakan)
            end
        end
    end)

    -- [ 4. DYNAMIC REPAIR SYSTEM ]
    -- Jika ada part tubuh yang dihapus paksa oleh script game, script ini akan menghentikannya
    if JointConn then JointConn:Disconnect() end
    JointConn = char.DescendantRemoving:Connect(function(desc)
        if State.GodMode and (desc:IsA("Motor6D") or desc:IsA("BasePart")) then
            -- Jika joint dilepas, kita paksa karakter untuk tidak hancur
            task.delay(0.1, function()
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end)
        end
    end)
    
    Notify("[ SYSTEM ]", "Omega God Mode: Immortality Overloaded!", 2)
end

--========================================================--
-- AUTO-RECOVERY & PERSISTENCE
--========================================================--

-- Monitoring Loop (Memastikan GodMode tidak mati saat script game mencoba mereset Humanoid)
task.spawn(function()
    while task.wait(2) do
        if State.GodMode then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                OmegaGod(char)
            end
        end
    end
end)

lp.CharacterAdded:Connect(function(char)
    if State.GodMode then
        task.wait(0.5) -- Menunggu karakter load sempurna
        OmegaGod(char)
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
