local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
if not LP then return end

if getgenv().HELL_PRANK then return end
getgenv().HELL_PRANK = true

--================ CLEAN =================
for _,v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "HellPanic" then v:Destroy() end
end

--================ GUI =================
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "HellPanic"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false

--================ SOUND JUMPSCARE =================
local scream = Instance.new("Sound", SoundService)
scream.SoundId = "rbxassetid://9125713501"
scream.Volume = 10

--================ GLITCH EFFECT =================
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local function Glitch()
    for i=1,15 do
        blur.Size = math.random(10,40)
        task.wait(0.05)
    end
end

--================ EXPLOSION EFFECT =================
local function FakeExplosion()
    local part = Instance.new("Part", workspace)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Position = workspace.CurrentCamera.CFrame.Position + Vector3.new(0,0,-10)

    local exp = Instance.new("Explosion", workspace)
    exp.Position = part.Position
    exp.BlastRadius = 0
    exp.BlastPressure = 0

    task.delay(1,function()
        part:Destroy()
    end)
end

--================ FULLSCREEN MESSAGE =================
local function FullMsg(text,color)
    local t = Instance.new("TextLabel",Gui)
    t.Size = UDim2.fromScale(1,1)
    t.BackgroundColor3 = Color3.new(0,0,0)
    t.TextColor3 = color or Color3.fromRGB(255,0,0)
    t.Font = Enum.Font.GothamBlack
    t.TextSize = 36
    t.TextWrapped = true
    t.Text = text
    return t
end

--================ EXECUTION =================
task.wait(2)

local warn1 = FullMsg(
[[ROBLOX SECURITY ALERT

Suspicious activity detected
Unauthorized scripts found]], Color3.fromRGB(255,80,80))

task.wait(2)
warn1.Text = "Logging IP Address...\nCollecting Hardware ID..."
task.wait(1)

Glitch()
scream:Play()

task.wait(0.5)
warn1.Text = "IP: 192.168."..math.random(1,255).."."..math.random(1,255).."\nHWID: VERIFIED"

task.wait(1)

warn1.Text = "LIVE CAMERA RECORDING STARTED"
task.wait(1)

FakeExplosion()

task.wait(0.5)
warn1.Text = "ACCOUNT TERMINATION IN PROGRESS"

task.wait(2)
warn1:Destroy()

--================ TERMINATION SCREEN =================
local ban = FullMsg(
[[ACCOUNT TERMINATED

Reason:
Exploiting / Third-Party Software

This decision is final.
Error Code: 267]], Color3.fromRGB(255,0,0))

task.wait(3)

--================ FORCE FREEZE =================
RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.CFrame *= CFrame.Angles(
        math.rad(math.random(-1,1)),
        math.rad(math.random(-1,1)),
        0
    )
end)

task.wait(2)
Gui:Destroy()
blur:Destroy()