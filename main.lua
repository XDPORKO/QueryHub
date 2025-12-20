local KEY_URL    = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL   = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

--================================================--
-- SERVICES
--================================================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
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
            if input ~= key then
                return false,"WRONG KEY"
            end

            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            local expire = os.time({
                year=y, month=m, day=d,
                hour=23, min=59, sec=59
            })

            if os.time() > expire then
                return false,"KEY EXPIRED"
            end

            return true,"SUCCESS"
        end
    end

    return false,"NO KEY FOR THIS USER"
end

--================================================--
-- GUI
--================================================--
local gui = Instance.new("ScreenGui")
gui.Name = "KeyVerifyGUI"
gui.ResetOnSpawn = false
gui.Parent = lp.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.7,0.35)
frame.Position = UDim2.fromScale(0.15,0.33)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.25)
title.Text = "KEY SYSTEM"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.9,0.22)
box.Position = UDim2.fromScale(0.05,0.3)
box.PlaceholderText = "ENTER YOUR KEY"
box.Text = ""
box.TextScaled = true
box.Font = Enum.Font.Gotham
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",box).CornerRadius = UDim.new(0,12)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.fromScale(1,0.15)
status.Position = UDim2.fromScale(0,0.55)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,80,80)

local verify = Instance.new("TextButton", frame)
verify.Size = UDim2.fromScale(0.9,0.22)
verify.Position = UDim2.fromScale(0.05,0.72)
verify.Text = "VERIFY"
verify.TextScaled = true
verify.Font = Enum.Font.GothamBold
verify.BackgroundColor3 = Color3.fromRGB(60,0,0)
verify.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",verify).CornerRadius = UDim.new(0,14)

--================================================--
-- LOGIC
--================================================--
verify.MouseButton1Click:Connect(function()
    local ok,msg = checkKey(box.Text)

    if ok then
        status.TextColor3 = Color3.fromRGB(0,255,120)
        status.Text = "KEY VALID"

        task.wait(0.6)
        gui:Destroy()

        loadstring(game:HttpGet(MAIN_URL))()
    else
        status.TextColor3 = Color3.fromRGB(255,80,80)
        status.Text = msg
    end
end)

StarterGui:SetCore("SendNotification",{
    Title = "Key System",
    Text = "Enter your personal key",
    Duration = 3
})