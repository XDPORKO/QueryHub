-- JOINER ULTIMATE V4 (MODERN UI & FULL FEATURES)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK Logic
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JoinerUltimateV4"
ScreenGui.Parent = CoreGui

-- Notification System
local function ModernNotify(title, text)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 60)
    NotifFrame.Position = UDim2.new(1, 10, 0.85, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Accent = Instance.new("Frame", NotifFrame)
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Instance.new("UICorner", Accent)

    local TLabel = Instance.new("TextLabel", NotifFrame)
    TLabel.Position = UDim2.new(0, 15, 0, 5)
    TLabel.Size = UDim2.new(1, -20, 0, 25)
    TLabel.Text = title
    TLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    TLabel.Font = Enum.Font.GothamBold
    TLabel.TextSize = 14
    TLabel.BackgroundTransparency = 1
    TLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MLabel = Instance.new("TextLabel", NotifFrame)
    MLabel.Position = UDim2.new(0, 15, 0, 25)
    MLabel.Size = UDim2.new(1, -20, 0, 25)
    MLabel.Text = text
    MLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MLabel.Font = Enum.Font.Gotham
    MLabel.TextSize = 12
    MLabel.BackgroundTransparency = 1
    MLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Animation
    NotifFrame:TweenPosition(UDim2.new(1, -260, 0.85, 0), "Out", "Back", 0.5)
    task.delay(4, function()
        NotifFrame:TweenPosition(UDim2.new(1, 10, 0.85, 0), "In", "Sine", 0.5)
        task.wait(0.5)
        NotifFrame:Destroy()
    end)
end

-- Main Window
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 280)
Main.Position = UDim2.new(0.5, -175, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 15)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Text = "JOINER ULTIMATE V4"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.BackgroundTransparency = 1

local StatusIndicator = Instance.new("Frame", Main)
StatusIndicator.Size = UDim2.new(0, 12, 0, 12)
StatusIndicator.Position = UDim2.new(0, 20, 0, 65)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel", Main)
StatusText.Position = UDim2.new(0, 40, 0, 60)
StatusText.Size = UDim2.new(0, 200, 0, 20)
StatusText.Text = "WAITING FOR USERNAME..."
StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12
StatusText.BackgroundTransparency = 1
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- Input Field
local Input = Instance.new("TextBox", Main)
Input.Size = UDim2.new(0, 310, 0, 45)
Input.Position = UDim2.new(0, 20, 0, 95)
Input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Input.PlaceholderText = "Type Username Here..."
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.Font = Enum.Font.Gotham
Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 10)

-- Join Button
local JoinBtn = Instance.new("TextButton", Main)
JoinBtn.Size = UDim2.new(0, 310, 0, 45)
JoinBtn.Position = UDim2.new(0, 20, 0, 155)
JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
JoinBtn.Text = "INSTANT JOIN"
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.TextSize = 14
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 10)

-- Auto Join Button
local AutoBtn = Instance.new("TextButton", Main)
AutoBtn.Size = UDim2.new(0, 310, 0, 45)
AutoBtn.Position = UDim2.new(0, 20, 0, 210)
AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
AutoBtn.Text = "AUTO-JOIN: DISABLED"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.TextSize = 14
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 10)

-- LOGIC CORE
local autoEnabled = false
local currentTargetId = nil

local function GetTargetStatus()
    local name = Input.Text
    if name == "" then return end
    
    local success, id = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
    if not success then return end
    currentTargetId = id
    
    local locSuccess, errorMsg, placeId, instanceId = pcall(function() 
        return TeleportService:GetPlayerPlaceInstanceAsync(id) 
    end)
    
    if locSuccess then
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        StatusText.Text = "TARGET ONLINE - READY TO JOIN"
        StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
        return true, placeId, instanceId
    else
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        StatusText.Text = "TARGET OFFLINE / PRIVACY OFF"
        StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        return false
    end
end

-- Refresh Status Loop
task.spawn(function()
    while true do
        if Input.Text ~= "" then GetTargetStatus() end
        task.wait(5)
    end
end)

JoinBtn.MouseButton1Click:Connect(function()
    local online, pId, iId = GetTargetStatus()
    if online then
        ModernNotify("Success", "Teleporting to target...")
        TeleportService:TeleportToPlaceInstance(pId, iId, Players.LocalPlayer)
    else
        ModernNotify("Failed", "Target is not joinable.")
    end
end)

AutoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        AutoBtn.Text = "AUTO-JOIN: ACTIVE"
        ModernNotify("Auto-Join", "Monitoring target...")
        task.spawn(function()
            while autoEnabled do
                local online, pId, iId = GetTargetStatus()
                if online then
                    ModernNotify("Found!", "Joining target now...")
                    TeleportService:TeleportToPlaceInstance(pId, iId, Players.LocalPlayer)
                    break
                end
                task.wait(10)
            end
        end)
    else
        AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        AutoBtn.Text = "AUTO-JOIN: DISABLED"
        ModernNotify("Auto-Join", "Monitoring disabled.")
    end
end)

ModernNotify("Joiner Pro V4", "Script Loaded Successfully!")
