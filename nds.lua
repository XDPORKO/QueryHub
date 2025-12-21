--[[ 
Ultimate NDS Executor - Full Modern GUI + Tabs
Fitur:
1. Orbit Part + hasil bangunan dihancurkan jadi orbit
2. Copot / remove part tertentu
3. Fly toggle
4. Survival timer
5. GUI modern, mobile-friendly dengan tab system
]]--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- LocalPlayer
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- =========================
-- Survival Timer
-- =========================
local startTime = tick()
local playerGui = player:WaitForChild("PlayerGui")
local survivalLabel = Instance.new("TextLabel")
survivalLabel.Size = UDim2.new(0,220,0,40)
survivalLabel.Position = UDim2.new(0.5,-110,0.02,0)
survivalLabel.BackgroundColor3 = Color3.fromRGB(25,25,25)
survivalLabel.BorderSizePixel = 0
survivalLabel.TextColor3 = Color3.fromRGB(255,255,255)
survivalLabel.TextScaled = true
survivalLabel.Font = Enum.Font.GothamBold
survivalLabel.Text = "Survival: 0s"
survivalLabel.Parent = playerGui

RunService.RenderStepped:Connect(function()
    survivalLabel.Text = "Survival: "..math.floor(tick()-startTime).."s"
end)

-- =========================
-- GUI Modern + Tabs
-- =========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NDS_Ultimate_GUI"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,380,0,580)
mainFrame.Position = UDim2.new(0.02,0,0.1,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0,15)
uiCorner.Parent = mainFrame

-- Tab Buttons Container
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,0)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabPages = {} -- table untuk menyimpan page frame

-- Helper function buat tab
local function createTab(name,posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,1,0)
    btn.Position = UDim2.new(0,posX,0,0)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = tabBar
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0,10)
    uiCorner.Parent = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1,0,1,-40)
    page.Position = UDim2.new(0,0,0,40)
    page.BackgroundTransparency = 0
    page.BackgroundColor3 = Color3.fromRGB(30,30,30)
    page.Visible = false
    page.Parent = mainFrame

    tabPages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(tabPages) do
            p.Visible = false
        end
        page.Visible = true
    end)

    return page
end

-- =========================
-- Orbit Part Tab
-- =========================
local orbitTab = createTab("Orbit",0)

local function createSlider(parent,min,max,posY,default,labelText)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,25)
    lbl.Position = UDim2.new(0,10,posY-25,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = labelText
    lbl.Parent = parent

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1,-20,0,25)
    sliderFrame.Position = UDim2.new(0,10,posY,0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = parent
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0,10)
    uiCorner.Parent = sliderFrame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0,20,1,0)
    slider.Position = UDim2.new((default-min)/(max-min),0,0,0)
    slider.BackgroundColor3 = Color3.fromRGB(200,200,200)
    slider.Text = ""
    slider.AutoButtonColor = false
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
    return slider
end

local function createToggle(parent,text,posY,default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1,-20,0,30)
    toggle.Position = UDim2.new(0,10,posY,0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.TextScaled = true
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = text
    toggle.Parent = parent
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0,10)
    uiCorner.Parent = toggle
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)
    end)
    return toggle,function() return state end
end

-- Orbit Config
local orbitConfig = {enabled=true,numParts=5,radius=6,verticalAmplitude=2,speed=3,pushPower=50,size=Vector3.new(2,2,2),colorRandom=true,destroyDisaster=true}
local toggleOrbit,getOrbitState = createToggle(orbitTab,"Orbit Enabled",20,true)
local numPartsSlider = createSlider(orbitTab,1,10,70,orbitConfig.numParts,"Jumlah Part")
local radiusSlider = createSlider(orbitTab,1,20,120,orbitConfig.radius,"Radius Orbit")
local verticalSlider = createSlider(orbitTab,0,5,170,orbitConfig.verticalAmplitude,"Lebar Vertikal")
local speedSlider = createSlider(orbitTab,0.1,10,220,orbitConfig.speed,"Kecepatan")
local pushSlider = createSlider(orbitTab,0,100,270,orbitConfig.pushPower,"Push Power")

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

local buildingOrbitParts = {}
local function addPartToOrbit(part)
    local newPart = part:Clone()
    newPart.Anchored = true
    newPart.CanCollide = false
    newPart.Parent = Workspace
    table.insert(buildingOrbitParts, newPart)
end

-- =========================
-- Copot Tab
-- =========================
local removeTab = createTab("Copot",120)
local removeConfig = {enabled=true,radius=10,targetClass="BasePart"}
local toggleRemove,getRemoveState = createToggle(removeTab,"Copot Enabled",20,true)
local removeRadiusSlider = createSlider(removeTab,1,30,70,removeConfig.radius,"Radius Copot")
local removeBtn = Instance.new("TextButton")
removeBtn.Size = UDim2.new(1,-20,0,30)
removeBtn.Position = UDim2.new(0,10,0,120)
removeBtn.BackgroundColor3 = Color3.fromRGB(0,0,180)
removeBtn.TextColor3 = Color3.fromRGB(255,255,255)
removeBtn.TextScaled = true
removeBtn.Text = "Copot Part!"
removeBtn.Parent = removeTab
local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(0,10)
uiCornerBtn.Parent = removeBtn

removeBtn.MouseButton1Click:Connect(function()
    removeConfig.enabled = getRemoveState()
    removeConfig.radius = 1 + removeRadiusSlider.Position.X.Scale*(30-1)
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA(removeConfig.targetClass) and (part.Position - hrp.Position).Magnitude <= removeConfig.radius then
            if part ~= hrp and part.Parent ~= character then
                addPartToOrbit(part)
                part:Destroy()
            end
        end
    end
end)

-- =========================
-- Fly Tab
-- =========================
local flyTab = createTab("Fly",240)
local flyConfig = {enabled=false,speed=50}
local toggleFly,getFlyState = createToggle(flyTab,"Fly Enabled",20,false)
local flySpeedSlider = createSlider(flyTab,10,200,70,flyConfig.speed,"Fly Speed")
local flyVelocity = Instance.new("BodyVelocity")
flyVelocity.MaxForce = Vector3.new(400000,400000,400000)
flyVelocity.Velocity = Vector3.new(0,0,0)
flyVelocity.Parent = hrp

-- =========================
-- Main RenderStepped Loop
-- =========================
RunService.RenderStepped:Connect(function(delta)
    -- Orbit update
    orbitConfig.enabled = getOrbitState()
    orbitConfig.numParts = math.floor(1 + (numPartsSlider.Position.X.Scale)*(10-1))
    orbitConfig.radius = 1 + radiusSlider.Position.X.Scale*(20-1)
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
        local totalOrbitParts = {}
        for _, p in pairs(orbitParts) do table.insert(totalOrbitParts,p) end
        for _, p in pairs(buildingOrbitParts) do table.insert(totalOrbitParts,p) end

        for i, part in pairs(totalOrbitParts) do
            local offset = angle + (i*(2*math.pi/#totalOrbitParts))
            part.Position = hrp.Position + Vector3.new(
                math.cos(offset)*orbitConfig.radius,
                math.sin(offset)*orbitConfig.verticalAmplitude,
                math.sin(offset)*orbitConfig.radius
            )
            -- Push players
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local oh = other.Character.HumanoidRootPart
                    local dist = (oh.Position - part.Position).Magnitude
                    if dist < 3 then
                        oh.Velocity = (oh.Position - hrp.Position).Unit * orbitConfig.pushPower
                    end
                end
            end
            -- Destroy disaster
            if orbitConfig.destroyDisaster then
                for _, p in pairs(Workspace:GetChildren()) do
                    if p:IsA("BasePart") and p.Name:match("Disaster") then
                        if (p.Position - part.Position).Magnitude <= 3 then
                            addPartToOrbit(p)
                            p:Destroy()
                        end
                    end
                end
            end
        end
    end

    -- Fly toggle
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