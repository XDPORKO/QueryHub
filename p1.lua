--========================================================--
-- MOBILE COMBAT HUB v5 FULL (SAFE + NOTIFICATIONS + SAVE)
--========================================================--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- GLOBAL FLAGS
getgenv().AntiVoidHandle = true
getgenv().ED_AntiKick = getgenv().ED_AntiKick or {Enabled=true,SendNotifications=true,CheckCaller=true}

--========================================================--
-- STATE CORE (EXTENDED, PERSISTENT)
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
    ClickTP = false,
    Fly = false,
    Speed = 16,
    Jump = 50,
    CounterFling = false,
    BringLoop = false,
    SelectedTarget = nil,
    Notifications = true
}

--========================================================--
-- SAVE MANAGER
--========================================================--
local SaveFile = "MobileCombatHubV5.json"
local function SaveState()
    local data = HttpService:JSONEncode(State)
    pcall(function() writefile(SaveFile,data) end)
end
local function LoadState()
    if isfile(SaveFile) then
        local data = readfile(SaveFile)
        local success, decoded = pcall(HttpService.JSONDecode,HttpService,data)
        if success then
            for k,v in pairs(decoded) do
                if State[k] ~= nil then State[k] = v end
            end
        end
    end
end
LoadState()

--========================================================--
-- FLUENT UI LOADER
--========================================================--
local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/FluentUILibs/FluentUI/main/loader.lua"))()("Mobile Combat Hub V5")

local function Notify(title,text,duration)
    duration = duration or 3
    if Window and Window.Notify then
        Window:Notify({Title=title,Description=text,Duration=duration})
    end
end

--========================================================--
-- TAB CREATION
--========================================================--
local combatTab = Window:AddTab("COMBAT")
local rageTab   = Window:AddTab("RAGE")
local trollTab  = Window:AddTab("TROLL")
local systemTab = Window:AddTab("SYSTEM")

--========================================================--
-- COMBAT TAB
--========================================================--
combatTab:AddToggle("AimToggle",{Title="Aim",Default=State.Aim})
:OnChanged(function(v)
    State.Aim = v SaveState()
    Notify("Combat","Aim "..(v and "ON" or "OFF"))
end)

combatTab:AddToggle("ESPToggle",{Title="ESP",Default=State.ESP})
:OnChanged(function(v)
    State.ESP = v SaveState()
    Notify("Combat","ESP "..(v and "ON" or "OFF"))
end)

combatTab:AddToggle("TeamToggle",{Title="Team Check",Default=State.TeamCheck})
:OnChanged(function(v)
    State.TeamCheck = v SaveState()
    Notify("Combat","Team Check "..(v and "ON" or "OFF"))
end)

--========================================================--
-- RAGE TAB
--========================================================--
rageTab:AddToggle("AutoFling",{Title="Auto Fling",Default=State.AutoFling})
:OnChanged(function(v)
    State.AutoFling = v SaveState()
    Notify("Rage","Auto Fling "..(v and "ON" or "OFF"))
end)

rageTab:AddDropdown("FlingModeDD",{Title="Fling Mode",Values={"Normal","Orbit","Tornado"},Default=State.FlingMode})
:OnChanged(function(v)
    State.FlingMode = v SaveState()
    Notify("Rage","Fling Mode: "..v)
end)

rageTab:AddSlider("PowerSlider",{Title="Power",Min=200,Max=2000,Default=State.Power})
:OnChanged(function(v)
    State.Power = v SaveState()
    Notify("Rage","Power: "..v)
end)

rageTab:AddToggle("CounterFling",{Title="Counter Fling",Default=State.CounterFling})
:OnChanged(function(v)
    State.CounterFling = v SaveState()
    Notify("Rage","Counter Fling "..(v and "ON" or "OFF"))
end)

--========================================================--
-- SYSTEM TAB
--========================================================--
systemTab:AddToggle("AntiVoid",{Title="Anti Void",Default=State.AntiVoid})
:OnChanged(function(v)
    State.AntiVoid = v
    getgenv().AntiVoidHandle = v
    SaveState()
    Notify("System","Anti Void "..(v and "ON" or "OFF"))
end)

systemTab:AddToggle("AntiKick",{Title="Anti Kick",Default=getgenv().ED_AntiKick.Enabled})
:OnChanged(function(v)
    getgenv().ED_AntiKick.Enabled = v
    SaveState()
    Notify("System","Anti Kick "..(v and "ON" or "OFF"))
end)

systemTab:AddToggle("AntiAFK",{Title="Anti AFK",Default=State.AntiAFK})
:OnChanged(function(v)
    State.AntiAFK = v SaveState()
    Notify("System","Anti AFK "..(v and "ON" or "OFF"))
end)

systemTab:AddToggle("AutoRejoin",{Title="Auto Rejoin",Default=State.AutoRejoin})
:OnChanged(function(v)
    State.AutoRejoin = v SaveState()
    Notify("System","Auto Rejoin "..(v and "ON" or "OFF"))
end)

--========================================================--
-- TROLL TAB
--========================================================--
trollTab:AddToggle("BringAll",{Title="Bring All",Default=State.BringLoop})
:OnChanged(function(v)
    State.BringLoop = v SaveState()
    Notify("Troll","Bring All "..(v and "ON" or "OFF"))
    task.spawn(function()
        while State.BringLoop do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = lp.Character.HumanoidRootPart
                for _,p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character
                    and p.Character:FindFirstChild("HumanoidRootPart")
                    and p.Character:FindFirstChild("Humanoid")
                    and p.Character.Humanoid.Health > 0 then
                        p.Character.HumanoidRootPart.CFrame =
                            hrp.CFrame * CFrame.new(math.random(-6,6),0,math.random(-6,6))
                        task.wait(0.08)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

trollTab:AddButton("Bring Nearest",function()
    local t = nil
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local minDist = math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < minDist then minDist = d t = p.Character.HumanoidRootPart end
        end
    end
    if t then
        for i=1,5 do
            t.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
            task.wait(0.05)
        end
        Notify("Troll","Nearest player brought!")
    end
end)

--========================================================--
-- ANTI-KICK
--========================================================--
if not getgenv().__ANTIKICK_LOADED then
    getgenv().__ANTIKICK_LOADED = true
    local OldNamecall
    OldNamecall = hookmetamethod(game,"__namecall",newcclosure(function(self,...)
        local method = getnamecallmethod()
        if getgenv().ED_AntiKick.Enabled and method:lower()=="kick" and self==lp then
            Notify("Anti-Kick","Kick blocked!")
            return
        end
        return OldNamecall(self,...)
    end))
end

--========================================================--
-- ANTI-VOID
--========================================================--
RunService.Heartbeat:Connect(function()
    if State.AntiVoid and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        if lp.Character.HumanoidRootPart.Position.Y < -60 then
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(0,60,0)
            Notify("Anti-Void","Returned to safe zone!")
        end
    end
end)

--========================================================--
-- AUTOFLING / AIM / COUNTERFLING LOOP
--========================================================--
local lastSafeCFrame
RunService.Heartbeat:Connect(function()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = lp.Character.HumanoidRootPart
    lastSafeCFrame = lastSafeCFrame or hrp.CFrame

    -- Speed/Jump
    if lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = State.Speed
        lp.Character.Humanoid.JumpPower = State.Jump
    end

    -- Auto Fling
    if State.AutoFling then
        local target = nil
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                target = p.Character.HumanoidRootPart
                break
            end
        end
        if target then
            if State.FlingMode=="Normal" then
                hrp.CFrame = target.CFrame * CFrame.new(0,0,-2)
                hrp.AssemblyLinearVelocity = (target.Position-hrp.Position).Unit * (State.Power+300)
            elseif State.FlingMode=="Orbit" then
                hrp.CFrame = target.CFrame * CFrame.Angles(0,tick()*4,0)*CFrame.new(0,0,5)
            elseif State.FlingMode=="Tornado" then
                hrp.AssemblyLinearVelocity = Vector3.new(0,State.Power,0)
            end
        end
    end

    -- Counter Fling
    if State.CounterFling and hrp.AssemblyLinearVelocity.Magnitude>120 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = lastSafeCFrame
    end

    if hrp.AssemblyLinearVelocity.Magnitude < 60 then
        lastSafeCFrame = hrp.CFrame
    end
end)

--========================================================--
-- AIM
--========================================================--
local FOV, AimSmooth = 150, 0.15
RunService.RenderStepped:Connect(function()
    if not State.Aim then return end
    local target = nil
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local minDist = math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onscreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onscreen then
                local dist = (Vector2.new(pos.X,pos.Y) - UIS:GetMouseLocation()).Magnitude
                if dist < FOV and dist < minDist then
                    minDist = dist
                    target = p.Character.HumanoidRootPart
                end
            end
        end
    end
    if target then
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,target.Position),AimSmooth)
    end
end)

--========================================================--
-- ESP
--========================================================--
local ESPObjects = {}
local function addESP(plr)
    if plr==lp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,2)
    box.Color3 = Color3.new(1,0,0)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    ESPObjects[plr] = box
end
for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
RunService.RenderStepped:Connect(function()
    for plr,box in pairs(ESPObjects) do
        if State.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = plr.Character.HumanoidRootPart
            box.Parent = cam
        else
            box.Adornee = nil
        end
    end
end)

--========================================================--
-- AUTO REJOIN
--========================================================--
lp.OnTeleport:Connect(function(state)
    if state==Enum.TeleportState.Failed and State.AutoRejoin then
        TeleportService:Teleport(game.PlaceId,lp)
    end
end)

warn("🔥 MOBILE COMBAT HUB v5 FULLY LOADED (SAFE + NOTIFICATIONS + SAVE)")