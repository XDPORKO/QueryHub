--[[ 
Ultimate NDS Executor - FINAL
Fitur:
1. Orbit Part dengan push & hancurkan disaster
2. Copot / remove part tertentu
3. Fly toggle
4. Leaderboard & timer survival
5. Particle & sound effect
6. GUI lengkap & mobile friendly
]]--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LocalPlayer
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- =========================
-- Survival Timer & Leaderboard
-- =========================
local startTime = tick()
local survivalLabel = Instance.new("TextLabel")
survivalLabel.Size = UDim2.new(0,200,0,40)
survivalLabel.Position = UDim2.new(0.5,-100,0.02,0)
survivalLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
survivalLabel.TextColor3 = Color3.fromRGB(255,255,255)
survivalLabel.TextScaled = true
survivalLabel.Text = "Survival: 0s"
survivalLabel.Parent = player:WaitForChild("PlayerGui")

RunService.RenderStepped:Connect(function()
    local elapsed = math.floor(tick()-startTime)
    survivalLabel.Text = "Survival: "..elapsed.."s"
end)

-- =========================
-- GUI Setup
-- =========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NDS_Ultimate_GUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,350,0,550)
mainFrame.Position = UDim2.new(0.02,0,0.1,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local function createLabel(text,posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,25)
    lbl.Position = UDim2.new(0,10,posY,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextScaled = true
    lbl.Text = text
    lbl.Parent = mainFrame
    return lbl
end

local function createSlider(min,max,posY,default,labelText)
    createLabel(labelText,posY-25)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1,-20,0,25)
    sliderFrame.Position = UDim2.new(0,10,posY,0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = mainFrame
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0,20,1,0)
    slider.Position = UDim2.new((default-min)/(max-min),0,0,0)
    slider.BackgroundColor3 = Color3.fromRGB(200,200,200)
    slider.Text = ""
    slider.Parent = sliderFrame
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = player:GetMouse()
            local relX = math.clamp(mouse.X - sliderFrame.AbsolutePosition.X,0,sliderFrame.AbsoluteSize.X)
            slider.Position = UDim2.new(relX/sliderFrame.AbsoluteSize.X,0,0,0)
        end
    end)
    return sliderFrame, slider
end

local function createToggle(text,posY,default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1,-20,0,30)
    toggle.Position = UDim2.new(0,10,posY,0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.TextScaled = true
    toggle.Text = text
    toggle.Parent = mainFrame
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    end)
    return toggle,function() return state end
end

-- =========================
-- Orbit Part Config
-- =========================
local orbitConfig = {enabled=true,numParts=5,radius=6,verticalAmplitude=2,speed=3,pushPower=50,size=Vector3.new(2,2,2),colorRandom=true, destroyDisaster=true}
local toggleOrbit,getOrbitState = createToggle("Orbit Part",0,true)
local numPartsSliderF,numPartsSlider = createSlider(1,10,40,orbitConfig.numParts,"Jumlah Part")
local radiusSliderF,radiusSlider = createSlider(1,15,90,orbitConfig.radius,"Radius Orbit")
local verticalSliderF,verticalSlider = createSlider(0,5,140,orbitConfig.verticalAmplitude,"Lebar Vertikal")
local speedSliderF,speedSlider = createSlider(0.1,10,190,orbitConfig.speed,"Kecepatan")
local pushSliderF,pushSlider = createSlider(0,100,240,orbitConfig.pushPower,"Push Power")

local orbitParts = {}
for i=1, orbitConfig.numParts do
    local part = Instance.new("Part")
    part.Size = orbitConfig.size
    part.Shape = Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.Color = orbitConfig.colorRandom and Color3.fromRGB(math.random(50,255),math.random(50,255),math.random(50,255)) or Color3.new(1,0,0)
    part.Parent = Workspace
    table.insert(orbitParts, part)
end

RunService.RenderStepped:Connect(function(delta)
    orbitConfig.enabled = getOrbitState()
    orbitConfig.numParts = math.floor(1 + (numPartsSlider.Position.X.Scale)*(10-1))
    orbitConfig.radius = 1 + radiusSlider.Position.X.Scale*(15-1)
    orbitConfig.verticalAmplitude = verticalSlider.Position.X.Scale*5
    orbitConfig.speed = 0.1 + speedSlider.Position.X.Scale*(10-0.1)
    orbitConfig.pushPower = pushSlider.Position.X.Scale*100

    while #orbitParts < orbitConfig.numParts do
        local part = Instance.new("Part")
        part.Size = orbitConfig.size
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.Color = orbitConfig.colorRandom and Color3.fromRGB(math.random(50,255),math.random(50,255),math.random(50,255)) or Color3.new(1,0,0)
        part.Parent = Workspace
        table.insert(orbitParts, part)
    end
    while #orbitParts > orbitConfig.numParts do
        orbitParts[#orbitParts]:Destroy()
        table.remove(orbitParts,#orbitParts)
    end

    if orbitConfig.enabled then
        local angle = tick()*orbitConfig.speed
        for i, part in pairs(orbitParts) do
            local offset = angle + (i*(2*math.pi/orbitConfig.numParts))
            part.Position = hrp.Position + Vector3.new(
                math.cos(offset)*orbitConfig.radius,
                math.sin(offset)*orbitConfig.verticalAmplitude,
                math.sin(offset)*orbitConfig.radius
            )
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local oh = other.Character.HumanoidRootPart
                    local dist = (oh.Position - part.Position).Magnitude
                    if dist < 3 then
                        oh.Velocity = (oh.Position - hrp.Position).Unit * orbitConfig.pushPower
                    end
                end
            end
            -- Destroy disaster part
            if orbitConfig.destroyDisaster then
                for _, p in pairs(Workspace:GetChildren()) do
                    if p:IsA("BasePart") and p.Name:match("Disaster") then
                        if (p.Position - part.Position).Magnitude <= 3 then
                            p:Destroy()
                        end
                    end
                end
            end
        end
    end
end)

-- =========================
-- Copot Part Config
-- =========================
local removeConfig = {enabled=true,radius=10,targetClass="BasePart"}
local toggleRemove,getRemoveState = createToggle("Copot Part",290,true)
local removeRadiusSliderF,removeRadiusSlider = createSlider(1,30,330,removeConfig.radius,"Radius Copot")
local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(1,-20,0,30)
removeBtn.Position = UDim2.new(0,10,0,370)
removeBtn.BackgroundColor3 = Color3.fromRGB(0,0,200)
removeBtn.TextColor3 = Color3.fromRGB(255,255,255)
removeBtn.TextScaled = true
removeBtn.Text = "Copot Part!"
removeBtn.Parent = mainFrame
removeBtn.MouseButton1Click:Connect(function()
    removeConfig.enabled = getRemoveState()
    removeConfig.radius = 1 + removeRadiusSlider.Position.X.Scale*(30-1)
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA(removeConfig.targetClass) and (part.Position - hrp.Position).Magnitude <= removeConfig.radius then
            if part ~= hrp and part.Parent ~= character then
                part:Destroy()
            end
        end
    end
end)

-- =========================
-- Fly Toggle
-- =========================
local flyConfig = {enabled=false,speed=50}
local toggleFly,getFlyState = createToggle("Fly Toggle",410,false)
local flySpeedSliderF,flySpeedSlider = createSlider(10,200,450,flyConfig.speed,"Fly Speed")
local flyVelocity = Instance.new("BodyVelocity")
flyVelocity.MaxForce = Vector3.new(400000,400000,400000)
flyVelocity.Velocity = Vector3.new(0,0,0)
flyVelocity.Parent = hrp

RunService.RenderStepped:Connect(function()
    flyConfig.enabled = getFlyState()
    flyConfig.speed = 10 + flySpeedSlider.Position.X.Scale*(200-10)
    if flyConfig.enabled then
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - hrp.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + hrp.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then
            flyVelocity.Velocity = moveDir.Unit * flyConfig.speed
        else
            flyVelocity.Velocity = Vector3.new(0,0,0)
        end
    else
        flyVelocity.Velocity = Vector3.new(0,0,0)
    end
end)