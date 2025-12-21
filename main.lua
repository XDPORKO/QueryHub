local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local lp = Players.LocalPlayer

-- SESSION TABLE
if not _G.VerifiedPlayers then _G.VerifiedPlayers = {} end
if _G.VerifiedPlayers[lp.UserId] then
    loadstring(game:HttpGet(MAIN_URL))()
    return
end

-- KEY CHECK
local function checkKey(input)
    local raw = game:HttpGet(KEY_URL)
    for line in raw:gmatch("[^\r\n]+") do
        local key,exp = line:match("(.+)|(.+)")
        if input == key then
            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            local expire = os.time({year=y, month=m, day=d, hour=23, min=59, sec=59})
            if os.time() > expire then return false,"KEY EXPIRED" end
            return true,"SUCCESS",expire
        end
    end
    return false,"WRONG KEY"
end

-- SOUNDS
local clickSound = Instance.new("Sound", lp.PlayerGui)
clickSound.SoundId = "rbxassetid://9118821771"
clickSound.Volume = 0.6

local successSound = Instance.new("Sound", lp.PlayerGui)
successSound.SoundId = "rbxassetid://9118821842"
successSound.Volume = 0.7

local errorSound = Instance.new("Sound", lp.PlayerGui)
errorSound.SoundId = "rbxassetid://9118821911"
errorSound.Volume = 0.7

-- GUI MAIN
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "UltraPremiumGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0,0)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.ClipsDescendants = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,28)

-- Shadow + Gradient
local shadow = Instance.new("Frame", frame)
shadow.Size = UDim2.fromScale(1,1)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.75
shadow.ZIndex = 0
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0,28)

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,180))
}
grad.Rotation = 45

-- POPUP ANIMATION
TweenService:Create(frame,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Size = UDim2.fromScale(0.55,0.45)
}):Play()

-- ICON SCRIPT
local icon = Instance.new("ImageLabel", frame)
icon.Size = UDim2.fromScale(0.15,0.15)
icon.Position = UDim2.fromScale(0.05,0.02)
icon.Image = "rbxassetid://INSERT_ICON_ASSETID_HERE"
icon.BackgroundTransparency = 1
icon.ScaleType = Enum.ScaleType.Fit

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(0.8,0.15)
title.Position = UDim2.fromScale(0.2,0.02)
title.Text = "PREMIUM KEY SYSTEM"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1

-- MAIN TAB
local mainTab = Instance.new("Frame", frame)
mainTab.Size = UDim2.fromScale(1,0.8)
mainTab.Position = UDim2.fromScale(0,0.18)
mainTab.BackgroundTransparency = 1

local box = Instance.new("TextBox", mainTab)
box.Size = UDim2.fromScale(0.85,0.18)
box.Position = UDim2.fromScale(0.075,0.05)
box.PlaceholderText = "ENTER YOUR KEY"
box.Font = Enum.Font.Gotham
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", box).CornerRadius = UDim.new(0,20)

local status = Instance.new("TextLabel", mainTab)
status.Size = UDim2.fromScale(1,0.12)
status.Position = UDim2.fromScale(0,0.28)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,80,80)

local countdown = Instance.new("TextLabel", mainTab)
countdown.Size = UDim2.fromScale(1,0.1)
countdown.Position = UDim2.fromScale(0,0.4)
countdown.Text = ""
countdown.Font = Enum.Font.Gotham
countdown.TextScaled = true
countdown.BackgroundTransparency = 1
countdown.TextColor3 = Color3.fromRGB(200,200,200)

local verify = Instance.new("TextButton", mainTab)
verify.Size = UDim2.fromScale(0.85,0.18)
verify.Position = UDim2.fromScale(0.075,0.55)
verify.Text = "VERIFY"
verify.Font = Enum.Font.GothamBold
verify.TextScaled = true
verify.BackgroundColor3 = Color3.fromRGB(255,0,180)
verify.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", verify).CornerRadius = UDim.new(0,22)

-- Ripple effect
local function rippleEffect(btn)
    local ripple = Instance.new("Frame", btn)
    ripple.Size = UDim2.fromScale(0,0)
    ripple.Position = UDim2.fromScale(0.5,0.5)
    ripple.AnchorPoint = Vector2.new(0.5,0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ripple.BackgroundTransparency = 0.5
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
    TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size=UDim2.fromScale(2,2), BackgroundTransparency=1}):Play()
    game.Debris:AddItem(ripple,0.5)
end

-- POPUP FUNCTION (pojok kanan bawah)
local function createPopup(msg,color)
    local pop = Instance.new("Frame", gui)
    pop.Size = UDim2.fromScale(0,0.08)
    pop.Position = UDim2.fromScale(0.7,0.9)
    pop.AnchorPoint = Vector2.new(0.5,0.5)
    pop.BackgroundColor3 = color
    Instance.new("UICorner", pop).CornerRadius = UDim.new(0,16)
    
    local txt = Instance.new("TextLabel", pop)
    txt.Size = UDim2.fromScale(1,1)
    txt.Position = UDim2.fromScale(0,0)
    txt.Text = msg
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.BackgroundTransparency = 1

    TweenService:Create(pop,TweenInfo.new(0.5,Enum.EasingStyle.Back),{Size=UDim2.fromScale(0.25,0.08)}):Play()
    task.delay(2, function()
        TweenService:Create(pop,TweenInfo.new(0.5,Enum.EasingStyle.Back),{Size=UDim2.fromScale(0,0)}):Play()
        task.wait(0.5)
        pop:Destroy()
    end)
end

-- VERIFY LOGIC
verify.MouseButton1Click:Connect(function()
    rippleEffect(verify)
    clickSound:Play()
    status.TextColor3 = Color3.fromRGB(255,255,0)
    status.Text = "CHECKING..."

    local bar = Instance.new("Frame", mainTab)
    bar.Size = UDim2.fromScale(0,0.04)
    bar.Position = UDim2.fromScale(0.075,0.48)
    bar.BackgroundColor3 = Color3.fromRGB(0,255,200)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,12)
    TweenService:Create(bar, TweenInfo.new(0.5), {Size=UDim2.fromScale(0.85,0.04)}):Play()
    task.wait(0.5)

    local ok,msg,expire = checkKey(box.Text)
    if ok then
        _G.VerifiedPlayers[lp.UserId] = true
        status.TextColor3 = Color3.fromRGB(0,255,120)
        status.Text = "KEY VALID"
        successSound:Play()
        createPopup("KEY VERIFIED!",Color3.fromRGB(0,200,120))

        local check = Instance.new("TextLabel", mainTab)
        check.Size = UDim2.fromScale(0.3,0.3)
        check.Position = UDim2.fromScale(0.35,0.15)
        check.Text = "✔"
        check.Font = Enum.Font.GothamBold
        check.TextScaled = true
        check.TextColor3 = Color3.fromRGB(0,255,120)
        check.BackgroundTransparency = 1
        check.Visible = true
        check.TextTransparency = 1
        TweenService:Create(check, TweenInfo.new(0.4), {TextTransparency=0}):Play()

        task.spawn(function()
            while os.time() < expire do
                local s = expire - os.time()
                countdown.Text = ("EXPIRES IN %02d:%02d:%02d"):format(s/3600%24, s/60%60, s%60)
                task.wait(1)
            end
        end)

        task.wait(1)
        TweenService:Create(frame, TweenInfo.new(0.4),{Size=UDim2.fromScale(0,0)}):Play()
        task.wait(0.4)
        gui:Destroy()
        loadstring(game:HttpGet(MAIN_URL))()
    else
        status.TextColor3 = Color3.fromRGB(255,80,80)
        status.Text = msg
        countdown.Text = ""
        errorSound:Play()
        createPopup(msg,Color3.fromRGB(200,50,50))
    end
end)

StarterGui:SetCore("SendNotification",{
    Title="Premium Key System",
    Text="Enter your key",
    Duration=3
})