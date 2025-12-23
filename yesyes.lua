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

local function PatchHumanoid(hum)
    if not hum then return end
    hum.UseJumpPower = true 
    -- Menghilangkan delay state agar bisa spam jump tanpa delay animasi
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
end

-- Optimization: Cache service untuk speed eksekusi
local lastMoveTick = tick()

-- Menggunakan PreSimulation: Tahap paling awal sebelum physics engine menghitung collision
RunService.PreSimulation:Connect(function(dt)
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then return end

    -- [ 1. ABSOLUTE NETWORK BYPASS ]
    -- Memaksa server untuk menerima posisi kita tanpa validasi (Client-Authoritative)
    pcall(function()
        settings().Physics.AllowSleep = false
        if sethiddenproperty then
            sethiddenproperty(lp, "SimulationRadius", 1e308) -- Max Double
            sethiddenproperty(lp, "MaxSimulationRadius", 1e308)
        end
    end)

    -- [ 2. MASSLESS ENFORCEMENT ]
    -- Membuat karakter tidak berbobot agar tidak terpengaruh gravitasi saat lari
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Massless = State.Speedy
        end
    end

    -- [ 3. SUPREME SPEED ENGINE ]
    if State.Speedy then
        local moveDir = hum.MoveDirection
        
        if moveDir.Magnitude > 0 then
            -- METODE A: Linear Velocity Injection (Anti-Rubberband)
            -- Kita bypass gesekan lantai dengan mengisi velocity langsung
            local vel = moveDir * State.Speed
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
            
            -- METODE B: CFrame Micro-Warping
            -- Melakukan teleportasi super kecil setiap frame untuk bypass Anti-Cheat berbasis speed
            local warpSpeed = dt * (State.Speed * 0.95)
            hrp.CFrame = hrp.CFrame + (moveDir * warpSpeed)
        else
            -- Instant Brake: Berhenti total tanpa terpeleset sedikitpun
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
        
        -- Spoofing WalkSpeed agar animasi kaki tetap sinkron
        hum.WalkSpeed = math.clamp(State.Speed, 16, 120)
    else
        hum.WalkSpeed = 16
    end

    -- [ 4. SUPREME JUMP ENGINE ]
    if State.Jumpy then
        PatchHumanoid(hum)
        hum.JumpPower = State.Jump
        
        -- METODE C: Reactive Impulse Jump
        -- Memaksa karakter naik ke atas tanpa peduli sedang dalam state apapun
        if UIS:GetFocusedTextBox() == nil and UIS:IsKeyDown(Enum.KeyCode.Space) then
            -- Mencegah velocity bertumpuk berlebihan (Anti-Skyrocket)
            if tick() - lastMoveTick > 0.1 then 
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, State.Jump, hrp.AssemblyLinearVelocity.Z)
                lastMoveTick = tick()
            end
        end
    else
        hum.JumpPower = 50
    end
end)

-- AUTO FIX & FORCE PATCH
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    PatchHumanoid(hum)
    
    -- Force Re-apply: Pastikan Massless aktif saat respawn
    task.wait(0.5)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then v.Massless = State.Speedy end
    end
end)

--========================================================--
-- ULTIMATE NOCLIP 
--========================================================--

local NoclipConn = nil

local function ToggleNoclip(bool)
    State.Noclip = bool

    if NoclipConn then 
        NoclipConn:Disconnect() 
        NoclipConn = nil 
    end

    if not bool then
        -- Reset total collision
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

    -- MENTOK: Menggunakan PreSimulation + Stepped secara bersamaan
    -- PreSimulation untuk menghapus tabrakan sebelum dihitung engine
    -- Stepped untuk memastikan karakter tidak "nyangkut" di dalam objek static
    NoclipConn = RunService.Stepped:Connect(function()
        if not State.Noclip then return end

        local char = lp.Character
        if not char then return end

        -- 1. State Enforcement
        -- Memaksa Humanoid agar tidak masuk ke state 'Physics' yang bisa bikin mental
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            end
        end

        -- 2. Recursive Collision Disable
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- MENTOK: Hanya matikan collision jika part tersebut bersentuhan dengan objek lain
                -- Ini mencegah "Falling to Void" karena HRP tetap memiliki kalkulasi raycast ke bawah
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                else
                    -- Spesifik untuk RootPart: Matikan collision hanya jika sedang bergerak menembus dinding
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        part.CanCollide = false
                    else
                        -- Tetap aktifkan sedikit agar tidak jatuh menembus lantai saat diam
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
    
    Notify("[ SYSTEM ]", "Noclip Supreme Activated: Menembus batas!", 2)
end

-- AUTO-RECOVERY: Jika karakter terjebak di dalam part saat noclip dimatikan
lp.CharacterAdded:Connect(function(char)
    if State.Noclip then
        ToggleNoclip(true)
    end
end)

--========================================================--
-- WALK ON WATER V3 (SMOOTH & ANTI-SLIP)
--========================================================--

local platformPart = nil

RunService.PreRender:Connect(function()
    if not State.WalkOnWater then
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
        return
    end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then 
        if platformPart then platformPart.CanCollide = false end
        return 
    end

    -- 1. POOLING & OPTIMIZATION
    if not platformPart or not platformPart.Parent then
        platformPart = Instance.new("Part")
        platformPart.Name = "Universal_Surface_Platform"
        platformPart.Anchored = true
        platformPart.Size = Vector3.new(12, 0.2, 12) -- Ukuran lebih efisien
        platformPart.Transparency = 1
        platformPart.CastShadow = false
        platformPart.Material = Enum.Material.Glass
        platformPart.Friction = 0
        platformPart.Parent = workspace
    end

    -- 2. SMART RAYCASTING (Multi-Detect)
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {char, platformPart, workspace.CurrentCamera}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    
    -- Cek material di bawah kaki
    local groundRay = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), rayParam)
    
    local shouldCollide = false
    local targetY = hrp.Position.Y - ((hum.RigType == Enum.HumanoidRigType.R6) and 3 or (hum.HipHeight + 1.5))

    if groundRay and groundRay.Instance then
        local mat = groundRay.Material
        local name = groundRay.Instance.Name:lower()
        
        -- Aktivasi hanya jika di atas Air atau objek "Lava/Acid/Water"
        if mat == Enum.Material.Water or name:find("water") or name:find("lava") or name:find("acid") then
            shouldCollide = true
            -- Snap ke permukaan air agar presisi
            targetY = groundRay.Position.Y 
        end
    end

    -- 3. DYNAMIC POSITIONING
    -- Jika sedang jatuh bebas (Velocity Y negatif besar), lebarkan platform agar menangkap kaki lebih cepat
    if hrp.AssemblyLinearVelocity.Y < -50 then
        platformPart.Size = Vector3.new(25, 0.2, 25)
    else
        platformPart.Size = Vector3.new(12, 0.2, 12)
    end

    -- 4. VELOCITY PREDICTION (Biar gak ketinggalan pas Speedhack)
    local moveDir = hrp.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
    local prediction = moveDir * 0.05 -- Prediksi posisi 50ms ke depan
    
    platformPart.CFrame = CFrame.new(hrp.Position.X + prediction.X, targetY, hrp.Position.Z + prediction.Z)

    -- 5. USER OVERRIDE (CTRL to Sink)
    -- Jika tahan CTRL atau sedang melompat, matikan collision agar bisa berenang/naik
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or hum.Jump then
        platformPart.CanCollide = false
    else
        platformPart.CanCollide = shouldCollide
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
local LastCamCF = workspace.CurrentCamera.CFrame

-- [ HELPER: Mencegah Deteksi Sentuhan & Animasi ]
local function SetRigidStatus(status)
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if status then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
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
    
    SetRigidStatus(false)
    if hum then hum.PlatformStand = false end
    
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then 
                v.CanTouch = true 
                -- Reset Velocity agar tidak mental saat berhenti
                v.Velocity = Vector3.zero 
                v.RotVelocity = Vector3.zero
            end
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

    -- Initial Rigidity
    hum.PlatformStand = true
    SetRigidStatus(true)

    -- [ BODY CONTROL INJECTION ]
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "SUPREME_FLY_BV"
    FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = hrp

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "SUPREME_FLY_BG"
    FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyBG.P = 2e6 -- Power extra kaku
    FlyBG.D = 100
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp

    -- [ CORE FLY LOOP ]
    FlyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly or not hrp.Parent or hum.Health <= 0 then 
            StopFly() 
            return 
        end

        local camCF = cam.CFrame
        local direction = Vector3.zero
        local moveDir = hum.MoveDirection

        -- 1. FIXED JOYSTICK LOGIC (Relative to Camera)
        if moveDir.Magnitude > 0 then
            -- Joystick/Mobile Support
            direction = moveDir
        else
            -- PC/Keyboard Support
            if UIS:IsKeyDown(Enum.KeyCode.W) then direction += camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then direction += camCF.RightVector end
        end

        -- 2. VERTICAL MOVEMENT
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end

        -- 3. APPLY VELOCITY & STABILITY
        if direction.Magnitude > 0 then
            FlyBV.Velocity = direction.Unit * State.FlySpeed
        else
            -- Friction aktif: Karakter langsung berhenti, tidak hanyut
            FlyBV.Velocity = Vector3.new(0, 0, 0)
        end

        -- Rotasi kaku mengikuti arah kamera
        FlyBG.CFrame = camCF
        
        -- Override Animasi (Force Idle/Rigid)
        hum.PlatformStand = true
    end)

    -- [ ANTI-DAMAGE & TOUCH BYPASS LOOP ]
    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not State.Fly or not char then return end
        
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                -- Mematikan CanTouch agar tidak terkena trap/lava (Anti-Damage)
                v.CanTouch = false
                -- Menghilangkan Velocity jatuh agar tidak mati karena fall damage
                v.Velocity = (FlyBV and FlyBV.Velocity) or Vector3.zero
            end
        end
        
        -- Memaksa State agar tidak bisa Ragdoll atau mati mendadak
        if hum:GetState() ~= Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end

--========================================================--
-- NOCLIP INTEGRATION (SUPREME COLLISION BYPASS)
--========================================================--
RunService.Stepped:Connect(function()
    if not State.Fly then return end
    local char = lp.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- INTEGRASI HEARTBEAT (FORCE PERSISTENCE)
RunService.Heartbeat:Connect(function()
    if State.Fly then
        if not FlyBV or not FlyBV.Parent or not FlyBG or not FlyBG.Parent then
            StartFly()
        end
    end
end)

--========================================================--
-- GODMODE V5 (SAFE / NO NIL / NO ERROR)
--========================================================--

local FinalGodConn = nil
local CollisionFix = nil

local function OmegaGod(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 20)
    local hrp = char:WaitForChild("HumanoidRootPart", 20)
    local head = char:WaitForChild("Head", 20)

    -- [ 1. INSTANCE NULLIFICATION ]
    -- Menghancurkan sensor damage bawaan Roblox (TouchTransmitter) di seluruh tubuh
    local function StripSensors(target)
        for _, v in ipairs(target:GetDescendants()) do
            if v:IsA("TouchTransmitter") then
                v:Destroy()
            end
        end
    end
    StripSensors(char)

    -- [ 2. METATABLE SPOOFING (SANGAT EKSTRA) ]
    -- Membuat server percaya darah Anda SELALU Max dan tidak pernah berubah
    local raw_mt = getrawmetatable(game)
    setreadonly(raw_mt, false)
    local old_index = raw_mt.__index
    local old_newindex = raw_mt.__newindex

    raw_mt.__index = newcclosure(function(self, key)
        if State.GodMode and self == hum then
            if key == "Health" then return hum.MaxHealth end
            if key == "Sit" then return false end
        end
        return old_index(self, key)
    end)

    raw_mt.__newindex = newcclosure(function(self, key, value)
        if State.GodMode and self == hum and (key == "Health" or key == "Jump") then
            return -- Memblokir semua upaya server untuk mengubah darah (Set Health to 0 diblokir)
        end
        return old_newindex(self, key, value)
    end)
    setreadonly(raw_mt, true)

    -- [ 3. BEYOND IMMORTALITY LOOP ]
    if FinalGodConn then FinalGodConn:Disconnect() end
    
    FinalGodConn = RunService.PreSimulation:Connect(function() -- Tahap paling awal fisika
        if not State.GodMode or not hum.Parent then return end

        -- Reset Health di tingkat tercepat (Engine Level)
        hum.Health = hum.MaxHealth
        
        -- MENTOK: Fix Kepala Putus / Neck Glitch
        hum.RequiresNeck = false
        
        -- MENTOK: Anti-Void Absolute
        if hrp.Position.Y < -500 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(hrp.Position.X, 500, hrp.Position.Z)
        end

        -- MENTOK: Ghost Body (Mencegah terdeteksi oleh Raycast musuh/NPC)
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanTouch = false -- Tidak bisa disentuh lava/peluru
                part.CanQuery = false -- Tidak bisa dideteksi Raycast (Ghost Mode)
            end
        end
    end)

    -- [ 4. JOINT ANCHORING (ANTI-EXPLOSION) ]
    -- Jika tubuh diledakkan, sendi tidak akan lepas karena kita paksa Parent-nya
    char.DescendantRemoving:Connect(function(desc)
        if State.GodMode and desc:IsA("Motor6D") then
            local p0, p1, name, parent = desc.Part0, desc.Part1, desc.Name, desc.Parent
            local c0, c1 = desc.C0, desc.C1
            task.delay(0, function()
                local n = Instance.new("Motor6D")
                n.Name = name n.Part0 = p0 n.Part1 = p1
                n.C0 = c0 n.C1 = c1 n.Parent = parent
            end)
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if State.GodMode then
            local char = lp.Character
            if char and char:FindFirstChild("Humanoid") then
                if not char.Humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                    -- Sudah aktif
                else
                    OmegaGod(char)
                end
            end
        end
    end
end)

lp.CharacterAdded:Connect(function(char)
    if State.GodMode then
        task.wait(0.1)
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