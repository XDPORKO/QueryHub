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
    -- Jika di PC pakai Studio atau executor lain yang tak terdaftar, tetap izinkan untuk dev? 
    -- Jika ingin ketat, biarkan return false.
    return true 
end

------------------------
-- ANTI DOUBLE LOAD
------------------------
if getgenv().__QUERYHUB_LOADED then
    warn("[QueryHub] Already running!")
    return
end
-- Jangan set LOADED di sini jika ini hanya gateway, set di main script saja.
-- getgenv().__QUERYHUB_LOADED = true 

------------------------
-- CONFIG
------------------------
local CONFIG = {
    KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt",
    MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/xpdvsp1.lua",
    ICON_ID  = 4483345998,
    THEME    = "Amethyst"
}

------------------------
-- UI LIB LOAD
------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

------------------------
-- UTILS
------------------------
local function safeHttp(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and res or nil
end

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

    local userHash = hash(input:gsub("%s+", ""))
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
})

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
        isProcessing = true
        
        StatusPara:Set({Title = "STATUS", Content = "Verifying..."})

        task.spawn(function()
            for i = 1, 100, 10 do
                ProgressBar:Set(i)
                task.wait(0.05)
            end
        end)

        local success, result = verifyKey(INPUT_KEY)

        if success then
            --========================================================--
            -- INI BAGIAN PENTING UNTUK SYNC DENGAN MAIN SCRIPT
            --========================================================--
            getgenv().__QUERYHUB_SESSION = {
                verified = true,
                userid = lp.UserId,
                tier = result,
                executor = getExecutor()
            }
            --========================================================--

            ProgressBar:Set(100)
            StatusPara:Set({Title = "SUCCESS", Content = "Access Granted! Loading..."})
            
            task.wait(1)
            Rayfield:Destroy()

            -- Memuat Script Utama
            local main_script = safeHttp(CONFIG.MAIN_URL)
            if main_script then
                loadstring(main_script)()
            else
                lp:Kick("Critical Error: Main Script unreachable.")
            end
        else
            isProcessing = false
            ProgressBar:Set(0)
            StatusPara:Set({Title = "ERROR", Content = result})
        end
    end
})

------------------------
-- INFO TAB
------------------------
TabInfo:CreateSection("User Data")
TabInfo:CreateParagraph({Title = "Player", Content = lp.Name .. " (" .. lp.UserId .. ")"})
TabInfo:CreateParagraph({Title = "Executor", Content = getExecutor()})
