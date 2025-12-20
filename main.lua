local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

--================================================--
-- SERVICES
--================================================--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

--================================================--
-- KEY CHECK
--================================================--
local function checkKey(input)
    local raw = game:HttpGet(KEY_URL)
    local myId = tostring(lp.UserId)

    for line in raw:gmatch("[^\r\n]+") do
        local uid,key,exp = line:match("(%d+)|(.+)|(.+)")
        if uid == myId then
            if input ~= key then return false,"WRONG KEY" end

            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            local expire = os.time({year=y,month=m,day=d,hour=23,min=59,sec=59})
            if os.time() > expire then return false,"KEY EXPIRED" end

            return true,"SUCCESS",expire
        end
    end
    return false,"NO KEY FOR THIS USER"
end

--================================================--
-- GUI
--================================================--
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "KeyVerifyGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0,0)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(22,22,22)
frame.ClipsDescendants = true
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,18)

-- popup animation
TweenService:Create(frame,TweenInfo.new(0.35,Enum.EasingStyle.Back),{
    Size = UDim2.fromScale(0.45,0.36)
}):Play()

-- title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.2)
title.Text = "KEY VERIFICATION"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- textbox
local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.85,0.18)
box.Position = UDim2.fromScale(0.075,0.3)
box.PlaceholderText = "ENTER YOUR KEY"
box.Font = Enum.Font.Gotham
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",box).CornerRadius = UDim.new(0,12)

-- status
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.fromScale(1,0.12)
status.Position = UDim2.fromScale(0,0.52)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,80,80)

-- countdown
local countdown = Instance.new("TextLabel", frame)
countdown.Size = UDim2.fromScale(1,0.1)
countdown.Position = UDim2.fromScale(0,0.62)
countdown.Text = ""
countdown.Font = Enum.Font.Gotham
countdown.TextScaled = true
countdown.BackgroundTransparency = 1
countdown.TextColor3 = Color3.fromRGB(200,200,200)

-- button
local verify = Instance.new("TextButton", frame)
verify.Size = UDim2.fromScale(0.85,0.18)
verify.Position = UDim2.fromScale(0.075,0.75)
verify.Text = "VERIFY"
verify.Font = Enum.Font.GothamBold
verify.TextScaled = true
verify.BackgroundColor3 = Color3.fromRGB(200,0,0)
verify.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",verify).CornerRadius = UDim.new(0,14)

-- loading bar
local bar = Instance.new("Frame", frame)
bar.Size = UDim2.fromScale(0,0.04)
bar.Position = UDim2.fromScale(0.075,0.7)
bar.BackgroundColor3 = Color3.fromRGB(0,255,120)
Instance.new("UICorner",bar).CornerRadius = UDim.new(0,10)

-- success icon
local check = Instance.new("TextLabel", frame)
check.Size = UDim2.fromScale(0.3,0.3)
check.Position = UDim2.fromScale(0.35,0.3)
check.Text = "✔"
check.Font = Enum.Font.GothamBold
check.TextScaled = true
check.TextColor3 = Color3.fromRGB(0,255,120)
check.BackgroundTransparency = 1
check.Visible = false

--================================================--
-- LOGIC
--================================================--
verify.MouseButton1Click:Connect(function()
    status.TextColor3 = Color3.fromRGB(255,255,0)
    status.Text = "CHECKING..."
    bar.Size = UDim2.fromScale(0,0.04)

    TweenService:Create(bar,TweenInfo.new(0.5),{
        Size = UDim2.fromScale(0.85,0.04)
    }):Play()

    task.wait(0.5)
    local ok,msg,expire = checkKey(box.Text)

    if ok then
        status.TextColor3 = Color3.fromRGB(0,255,120)
        status.Text = "KEY VALID"
        check.Visible = true

        TweenService:Create(check,TweenInfo.new(0.3),{
            TextTransparency = 0
        }):Play()

        -- countdown
        task.spawn(function()
            while os.time() < expire do
                local s = expire - os.time()
                countdown.Text = ("EXPIRES IN %02d:%02d:%02d"):format(
                    s/3600%24, s/60%60, s%60
                )
                task.wait(1)
            end
        end)

        task.wait(1.2)
        TweenService:Create(frame,TweenInfo.new(0.4),{
            Size = UDim2.fromScale(0,0)
        }):Play()

        task.wait(0.4)
        gui:Destroy()
        loadstring(game:HttpGet(MAIN_URL))()
    else
        status.TextColor3 = Color3.fromRGB(255,80,80)
        status.Text = msg
        countdown.Text = ""
    end
end)

StarterGui:SetCore("SendNotification",{
    Title="Key System",
    Text="Enter your personal key",
    Duration=3
})