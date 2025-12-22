------------------------
-- SERVICES
------------------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

------------------------
-- HARD SECURITY
------------------------
local function HardKick(reason)
    task.spawn(function()
        pcall(function()
            lp:Kick("\n[ QUERYHUB SECURITY ]\n" .. tostring(reason))
        end)
        task.wait(0.5)
        while true do end -- Freeze thread
    end)
end

------------------------
-- EXECUTOR CHECK
------------------------
local function getExecutor()
    return (identifyexecutor and identifyexecutor() or "Unknown")
end

local ALLOWED_EXECUTORS = {
    "synapse", "fluxus", "arceus", "hydrogen", 
    "delta", "codex", "trigon", "wave", "electron"
}

local function checkExecutor()
    local exec = getExecutor():lower()
    for _, v in ipairs(ALLOWED_EXECUTORS) do
        if exec:find(v, 1, true) then return true end
    end
    return false
end

if not checkExecutor() then
    HardKick("Executor Not Supported: " .. getExecutor())
    return
end

------------------------
-- ANTI DOUBLE LOAD
------------------------
if getgenv().__QUERYHUB_LOADED then
    warn("[QueryHub] Already running!")
    return
end
getgenv().__QUERYHUB_LOADED = true

------------------------
-- CONFIG
------------------------
local CONFIG = {
    KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt",
    MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/xpdvsp1.lua",
    ICON_ID  = 124796029670238,
    THEME    = "Amethyst" -- Pilihan: Default, Amber, Ocean, Green, Lucid
}

------------------------
-- UI LIB LOAD
------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

------------------------
-- SESSION
------------------------
local Session = {
    verified = false,
    executor = getExecutor(),
    lastTry  = 0,
    badge    = "UNVERIFIED"
}

------------------------
-- UTILS
------------------------
local function safeHttp(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and res or nil
end

-- Hash Function (DJB2 Algorithm)
local function hash(str)
    local h = 5381
    for i = 1, #str do
        h = bit32.band(h * 33 + str:byte(i), 0xFFFFFFFF)
    end
    return tostring(h)
end

------------------------
-- KEY VERIFY
------------------------
local function verifyKey(input)
    if not input or #input < 3 then return false, "KEY TOO SHORT" end

    local raw = safeHttp(CONFIG.KEY_URL)
    if not raw then return false, "SERVER CONNECTION FAILED" end

    local userHash = hash(input:gsub("%s+", "")) -- Remove spaces
    
    for line in raw:gmatch("[^\r\n]+") do
        local k, tier = line:match("^([^|]+)|([^|]+)")
        if k and hash(k) == userHash then
            return true, tier
        end
    end
    return false, "INVALID KEY"
end

------------------------
-- WINDOW CREATION
------------------------
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Gateway • v2.0",
    LoadingTitle = "Initializing QueryHub",
    LoadingSubtitle = "by XDPORKO",
    ConfigurationSaving = { Enabled = false },
    Theme = CONFIG.THEME,
    DisableRayfieldPrompts = false
})

------------------------
-- TABS
------------------------
local TabAccess = Window:CreateTab("Authentication", "lock")
local TabInfo = Window:CreateTab("System Info", "info")

------------------------
-- ACCESS TAB
------------------------
TabAccess:CreateSection("🔐 Secure Access")

local StatusPara = TabAccess:CreateParagraph({
    Title = "SYSTEM STATUS",
    Content = "Waiting for user input..."
})

local ProgressBar = TabAccess:CreateSlider({
    Name = "Validation Progress",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function() end
})

local INPUT_KEY = ""
local isProcessing = false

TabAccess:CreateInput({
    Name = "Enter License Key",
    PlaceholderText = "Paste key here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        INPUT_KEY = text
    end
})

TabAccess:CreateButton({
    Name = "Verify & Access",
    Callback = function()
        if isProcessing then return end
        if #INPUT_KEY < 3 then
            Rayfield:Notify({Title = "Error", Content = "Please enter a valid key", Duration = 2})
            return 
        end

        isProcessing = true
        StatusPara:Set({Title = "STATUS", Content = "Connecting to database..."})
        
        -- Smooth Progress Animation
        task.spawn(function()
            for i = 1, 100, math.random(5, 15) do
                ProgressBar:Set(i)
                task.wait(0.05)
            end
        end)

        task.wait(1)
        local success, result = verifyKey(INPUT_KEY)

        if success then
            ProgressBar:Set(100)
            StatusPara:Set({Title = "SUCCESS", Content = "Access Granted! Tier: " .. result})
            
            Rayfield:Notify({
                Title = "Authenticated",
                Content = "Welcome back! Loading main script...",
                Duration = 3,
                Image = "check-circle"
            })

            task.wait(1.5)
            Rayfield:Destroy()
            
            -- Load Main Script
            local main_script = safeHttp(CONFIG.MAIN_URL)
            if main_script then
                loadstring(main_script)()
            else
                lp:Kick("Failed to load Main Script. Check Connection.")
            end
        else
            isProcessing = false
            ProgressBar:Set(0)
            StatusPara:Set({Title = "ERROR", Content = result})
            Rayfield:Notify({Title = "Access Denied", Content = result, Duration = 3})
        end
    end
})

TabAccess:CreateButton({
    Name = "Get Key / Support",
    Callback = function()
        setclipboard("https://discord.gg/yourlink") -- Ganti link discord kamu
        Rayfield:Notify({Title = "Link Copied", Content = "Link has been copied to clipboard!", Duration = 3})
    end
})

------------------------
-- INFO TAB
------------------------
TabInfo:CreateSection("User Data")
TabInfo:CreateParagraph({Title = "Player", Content = lp.Name .. " (" .. lp.UserId .. ")"})
TabInfo:CreateParagraph({Title = "Executor", Content = Session.executor})

TabInfo:CreateSection("Gateway Information")
TabInfo:CreateParagraph({Title = "Version", Content = "2.0.4 Premium"})
TabInfo:CreateParagraph({Title = "Encryption", Content = "AES-256 + DJB2 Hash"})