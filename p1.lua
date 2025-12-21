--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

--// PLAYER
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

--// GLOBAL FLAGS (DONT REMOVE)
getgenv().AntiVoidHandle = true
getgenv().ED_AntiKick = getgenv().ED_AntiKick or {
    Enabled = true,
    SendNotifications = true,
    CheckCaller = true
}

--========================================================--
-- STATE CORE (EXTENDED, NO REMOVAL)
--========================================================--
local State = {
    Aim = false,
    ESP = false,
    TeamCheck = true,

    AutoFling = false,
    FlingMode = "Normal", -- Normal / Orbit / Tornado
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

local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "MobileCombatHubV5"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000

-- SERVICES
local TweenService = game:GetService("TweenService")

--================ OPEN BUTTON =========================--
local open = Instance.new("TextButton", gui)
open.Size = UDim2.fromScale(0.15,0.08)
open.Position = UDim2.fromScale(0.02,0.45)
open.Text = "RAGE"
open.TextScaled = true
open.BackgroundColor3 = Color3.fromRGB(30,30,30)
open.TextColor3 = Color3.fromRGB(255,50,50)
open.AutoButtonColor = false
open.Active = true
open.Draggable = true
local openUIC = Instance.new("UICorner", open)
openUIC.CornerRadius = UDim.new(0,20)

-- Hover + Press Effects
open.MouseEnter:Connect(function()
    TweenService:Create(open, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
end)
open.MouseLeave:Connect(function()
    TweenService:Create(open, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
end)
open.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    local goal = {Position = main.Visible and UDim2.fromScale(0.175,0.1) or UDim2.fromScale(-0.7,0.1)}
    TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), goal):Play()
end)

--================ MAIN FRAME ========================--
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.65,0.8)
main.Position = UDim2.fromScale(-0.7,0.1) -- start hidden offscreen
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
local mainUIC = Instance.new("UICorner", main)
mainUIC.CornerRadius = UDim.new(0,25)

-- Shadow + Blur Effect
local mainShadow = Instance.new("UIShadow", main)
mainShadow.Blur = 5
mainShadow.Color = Color3.fromRGB(0,0,0)
mainShadow.Transparency = 0.5

--================ TAB BAR ============================--
local bar = Instance.new("Frame", main)
bar.Size = UDim2.fromScale(1,0.12)
bar.Position = UDim2.fromScale(0,0)
bar.BackgroundColor3 = Color3.fromRGB(35,35,35)
local barUIC = Instance.new("UICorner", bar)
barUIC.CornerRadius = UDim.new(0,15)

local tabs = {"COMBAT","RAGE","TROLL","SYSTEM"}
local frames = {}

for i,name in ipairs(tabs) do
    local b = Instance.new("TextButton", bar)
    b.Size = UDim2.fromScale(0.25,1)
    b.Position = UDim2.fromScale((i-1)*0.25,0)
    b.Text = name
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.AutoButtonColor = false
    local bUIC = Instance.new("UICorner", b)
    bUIC.CornerRadius = UDim.new(0,12)

    -- Gradient Neon Effect
    local grad = Instance.new("UIGradient", b)
    grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,100,100))}
    grad.Rotation = 45

    -- Hover + Press Tween
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
    end)

    local f = Instance.new("ScrollingFrame", main)
    f.Size = UDim2.fromScale(1,0.88)
    f.Position = UDim2.fromScale(0,0.12)
    f.BackgroundTransparency = 1
    f.ScrollBarThickness = 10
    f.CanvasSize = UDim2.new(0,0,2,0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.Visible = (i==1)
    frames[name] = f

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(frames) do v.Visible = false end
        f.Visible = true
    end)
end

--================ BUTTON CREATOR =====================--
local function btn(parent,y,text,iconId)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.Position = UDim2.fromScale(0.05,y)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    b.AutoButtonColor = false
    local uic = Instance.new("UICorner", b)
    uic.CornerRadius = UDim.new(0,16)

    -- Gradient + Neon Shadow
    local grad = Instance.new("UIGradient", b)
    grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,120,120))}
    grad.Rotation = 45

    local shadow = Instance.new("UIShadow", b)
    shadow.Blur = 6
    shadow.Color = Color3.fromRGB(0,0,0)
    shadow.Transparency = 0.6

    -- Icon if provided
    if iconId then
        local img = Instance.new("ImageLabel", b)
        img.Size = UDim2.fromScale(0.12,0.8)
        img.Position = UDim2.fromScale(0.02,0.1)
        img.Image = iconId
        img.BackgroundTransparency = 1
    end

    b.Text = text

    -- Hover effect
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70,70,70)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,50)}):Play()
    end)

    return b
end

--========================================================--
-- TABS
--========================================================--
local tabs = {"COMBAT","RAGE","TROLL","SYSTEM"}
local frames = {}

local bar = Instance.new("Frame", main)
bar.Size = UDim2.fromScale(1,0.1)
bar.BackgroundColor3 = Color3.fromRGB(30,30,30)

for i,name in ipairs(tabs) do
    local b = Instance.new("TextButton", bar)
    b.Size = UDim2.fromScale(0.25,1)
    b.Position = UDim2.fromScale((i-1)*0.25,0)
    b.Text = name
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)

    local f = Instance.new("Frame", main)
    f.Size = UDim2.fromScale(1,0.9)
    f.Position = UDim2.fromScale(0,0.1)
    f.Visible = (i==1)
    f.BackgroundTransparency = 1
    frames[name] = f

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(frames) do v.Visible = false end
        f.Visible = true
    end)
end

local function btn(parent,y,text)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.fromScale(0.9,0.09)
    b.Position = UDim2.fromScale(0.05,y)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
    return b
end

--========================================================--
-- ANTI KICK (FULL – UNTOUCHED + SAFE)
--========================================================--
local getnamecallmethod = getnamecallmethod
local hookmetamethod = hookmetamethod
local hookfunction = hookfunction
local newcclosure = newcclosure
local checkcaller = checkcaller
local gsub = string.gsub

local cloneref = cloneref or function(v) return v end
local clonefunction = clonefunction or function(v) return v end

local SetCore = clonefunction(StarterGui.SetCore)
local FindFirstChild = clonefunction(game.FindFirstChild)

local function CanCastToSTDString(...)
    return pcall(FindFirstChild, game, ...)
end

if not getgenv().__ANTIKICK_LOADED then
    getgenv().__ANTIKICK_LOADED = true

    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local self, msg = ...
        local method = getnamecallmethod()

        if getgenv().ED_AntiKick.Enabled
        and gsub(method, "^%l", string.upper) == "Kick"
        and self == lp
        and ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true)
        and CanCastToSTDString(msg) then
            if getgenv().ED_AntiKick.SendNotifications then
                SetCore(StarterGui,"SendNotification",{Title="Anti-Kick",Text="Kick Blocked",Duration=2})
            end
            return
        end
        return OldNamecall(...)
    end))

    local OldKick
    OldKick = hookfunction(lp.Kick,function(self,msg)
        if getgenv().ED_AntiKick.Enabled and self==lp then
            return
        end
        return OldKick(self,msg)
    end)
end

--========================================================--
-- ANTI VOID HANDLE (UNCHANGED + SAFE)
--========================================================--
local function toolMatch(handle)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local arm = plr.Character:FindFirstChild("Right Arm") or plr.Character:FindFirstChild("RightHand")
            if arm then
                local grip = arm:FindFirstChild("RightGrip")
                if grip and grip.Part1 == handle then
                    return plr
                end
            end
        end
    end
end

local function antiVoidCharacter(char)
    local arm = char:WaitForChild("Right Arm",5) or char:WaitForChild("RightHand",5)
    if not arm then return end

    arm.ChildAdded:Connect(function(child)
        if not getgenv().AntiVoidHandle then return end
        if child:IsA("Weld") and child.Name=="RightGrip" then
            local h = child.Part1
            if h and toolMatch(h) then
                h.Parent:Destroy()
            end
        end
    end)
end

if lp.Character then antiVoidCharacter(lp.Character) end
lp.CharacterAdded:Connect(antiVoidCharacter)

--========================================================--
-- COMBAT BUTTONS (NO REMOVAL)
--========================================================--
local aimBtn  = btn(frames.COMBAT,0.05,"AIM : OFF")
local espBtn  = btn(frames.COMBAT,0.16,"ESP : OFF")
local teamBtn = btn(frames.COMBAT,0.27,"TEAM CHECK : ON")

--========================================================--
-- RAGE BUTTONS
--========================================================--
local flingBtn = btn(frames.RAGE,0.05,"AUTO FLING : OFF")
local counterBtn = btn(frames.RAGE,0.50,"COUNTER FLING : OFF")
local modeBtn  = btn(frames.RAGE,0.16,"MODE : NORMAL")
local pUp      = btn(frames.RAGE,0.27,"POWER +")
local pDn      = btn(frames.RAGE,0.38,"POWER -")

--========================================================--
-- SYSTEM BUTTONS (EXTENDED)
--========================================================--
local avBtn = btn(frames.SYSTEM,0.05,"ANTI VOID : ON")
local akBtn = btn(frames.SYSTEM,0.16,"ANTI KICK : ON")
local afkBtn = btn(frames.SYSTEM,0.27,"ANTI AFK : ON")
local rjBtn = btn(frames.SYSTEM,0.38,"AUTO REJOIN : ON")

local bringBtn = btn(frames.TROLL,0.05,"BRING NEAREST")
local bringAllBtn = btn(frames.TROLL,0.16,"BRING ALL : OFF")

--========================================================--
-- TARGET SYSTEM (AUTO NEAREST)
--========================================================--
local function getTarget()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end

    local best, dist = nil, math.huge
    local myHRP = lp.Character.HumanoidRootPart

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character
        and p.Character:FindFirstChild("HumanoidRootPart")
        and p.Character:FindFirstChild("Humanoid")
        and p.Character.Humanoid.Health > 0 then

            if State.TeamCheck and p.Team == lp.Team then continue end

            local hrp = p.Character.HumanoidRootPart
            local d = (hrp.Position - myHRP.Position).Magnitude

            if d < dist then
                dist = d
                best = hrp
            end
        end
    end

    return best
end

local function bringTarget(target)
    if not target or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = lp.Character.HumanoidRootPart

    for i = 1,5 do
        target.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
        task.wait(0.05)
    end
end

bringBtn.MouseButton1Click:Connect(function()
    local t = getTarget()
    if t then
        bringTarget(t)
    end
end)

--========================================================--
-- MAIN LOOP (NO FEATURE LOST)
--========================================================--
RunService.Heartbeat:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = State.Speed
        lp.Character.Humanoid.JumpPower = State.Jump
    end

    if State.AutoFling and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
    local hrp = lp.Character.HumanoidRootPart
    local t = getTarget()

    if t then
        if State.FlingMode == "Normal" then
            hrp.CFrame = t.CFrame * CFrame.new(0,0,-2)
            hrp.AssemblyLinearVelocity =
                (t.Position - hrp.Position).Unit * State.Power

        elseif State.FlingMode == "Orbit" then
            hrp.CFrame =
                t.CFrame * CFrame.Angles(0, tick()*4, 0) * CFrame.new(0,0,5)

        elseif State.FlingMode == "Tornado" then
            hrp.AssemblyLinearVelocity = Vector3.new(0, State.Power, 0)
        end
    end
end

    if State.AntiVoid and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        if lp.Character.HumanoidRootPart.Position.Y < -60 then
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(0,60,0)
        end
    end
end)

local lastSafeCFrame

RunService.Heartbeat:Connect(function()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = lp.Character.HumanoidRootPart

    lastSafeCFrame = lastSafeCFrame or hrp.CFrame

    if State.CounterFling then
        if hrp.AssemblyLinearVelocity.Magnitude > 120 then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.CFrame = lastSafeCFrame

            local enemyHRP = getTarget()
            if enemyHRP then
                enemyHRP.AssemblyLinearVelocity =
                    (enemyHRP.Position - hrp.Position).Unit * State.Power
            end
        end
    end

    if hrp.AssemblyLinearVelocity.Magnitude < 60 then
        lastSafeCFrame = hrp.CFrame
    end
end)

--========================================================--
-- BUTTON LOGIC (SAFE)
--========================================================--
aimBtn.MouseButton1Click:Connect(function()
    State.Aim = not State.Aim
    aimBtn.Text = "AIM : "..(State.Aim and "ON" or "OFF")
end)

espBtn.MouseButton1Click:Connect(function()
    State.ESP = not State.ESP
    espBtn.Text = "ESP : "..(State.ESP and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
    State.TeamCheck = not State.TeamCheck
    teamBtn.Text = "TEAM CHECK : "..(State.TeamCheck and "ON" or "OFF")
end)

flingBtn.MouseButton1Click:Connect(function()
    State.AutoFling = not State.AutoFling
    flingBtn.Text = "AUTO FLING : "..(State.AutoFling and "ON" or "OFF")
end)

modeBtn.MouseButton1Click:Connect(function()
    State.FlingMode = State.FlingMode=="Normal" and "Orbit"
        or State.FlingMode=="Orbit" and "Tornado" or "Normal"
    modeBtn.Text = "MODE : "..string.upper(State.FlingMode)
end)

pUp.MouseButton1Click:Connect(function() State.Power = State.Power + 200 end)
pDn.MouseButton1Click:Connect(function() State.Power = math.max(200,State.Power-200) end)

avBtn.MouseButton1Click:Connect(function()
    State.AntiVoid = not State.AntiVoid
    getgenv().AntiVoidHandle = State.AntiVoid
    avBtn.Text = "ANTI VOID : "..(State.AntiVoid and "ON" or "OFF")
end)

akBtn.MouseButton1Click:Connect(function()
    getgenv().ED_AntiKick.Enabled = not getgenv().ED_AntiKick.Enabled
    akBtn.Text = "ANTI KICK : "..(getgenv().ED_AntiKick.Enabled and "ON" or "OFF")
end)

counterBtn.MouseButton1Click:Connect(function()
    State.CounterFling = not State.CounterFling
    counterBtn.Text = "COUNTER FLING : "..(State.CounterFling and "ON" or "OFF")
end)

bringAllBtn.MouseButton1Click:Connect(function()
    State.BringLoop = not State.BringLoop
    bringAllBtn.Text = "BRING ALL : "..(State.BringLoop and "ON" or "OFF")

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

warn("🔥 MOBILE COMBAT HUB v3 RAGE++ FULLY LOADED")