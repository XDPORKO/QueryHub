--====================================================--
-- QueryHub Gateway | STABLE EDITION (NO ERROR)
--====================================================--

--================== GLOBAL DEAD GATE ==================--
if getgenv().__QUERYHUB_DEAD then
    return
end

--================== SERVICES ==================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

--================== ICONS ==================--
local ICON_APP     = 6031071053
local ICON_KEY     = 6031075924
local ICON_SUCCESS = 6031094678
local ICON_ERROR   = 6031075925
local ICON_INFO    = 6031071054

--================== HARD KICK ==================--
local function HardKick(reason)
    reason = tostring(reason)
    getgenv().__QUERYHUB_DEAD = true

    pcall(function()
        lp:Kick("[ QUERYHUB SECURITY ] "..reason)
    end)

    task.delay(0, function()
        while true do task.wait() end
    end)

    error(reason, 0)
end

--================== EXECUTOR CHECK ==================--
local function getExecutor()
    if identifyexecutor then
        return tostring(identifyexecutor())
    end
    return "Unknown"
end

local ALLOWED_EXECUTORS = {
    "Synapse","Fluxus","Arceus","Arceus X",
    "Hydrogen","Delta","Codex","Trigon",
    "Wave","Electron"
}

local function isExecutorAllowed()
    local exec = getExecutor():lower()
    for _, v in ipairs(ALLOWED_EXECUTORS) do
        if exec:find(v:lower(), 1, true) then
            return true, v
        end
    end
    return false, exec
end

local okExec, execName = isExecutorAllowed()
if not okExec then
    HardKick("Executor not supported")
end

--================== ANTI DOUBLE EXEC ==================--
if getgenv().__QUERYHUB_LOCK or getgenv().__QUERYHUB_LOADED then
    HardKick("Double execution detected")
end
getgenv().__QUERYHUB_LOADED = true

--================== CONFIG ==================--
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

--================== UI LIB ==================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--================== SAFE NOTIFY ==================--
local function Notify(title, content, icon)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 3,
            Image = icon
        })
    end)
end

--================== SESSION ==================--
local SESSION = {
    verified = false,
    lastTry = 0,
    fail = 0
}
getgenv().__QUERYHUB_SESSION = SESSION

--================== UTILS ==================--
local function safeHttp(url)
    local ok, res = pcall(game.HttpGet, game, url)
    if not ok or type(res) ~= "string" then
        HardKick("Network blocked")
    end
    return res
end

local function hash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 33 + string.byte(str, i)) % 2147483647
    end
    return tostring(h)
end

--================== KEY SYSTEM ==================--
local function getExpire(typeKey, y, m, d)
    local base = os.time({
        year = y, month = m, day = d,
        hour = 23, min = 59, sec = 59
    })
    if typeKey == "DAILY" then
        return base + 86400
    elseif typeKey == "WEEKLY" then
        return base + 604800
    elseif typeKey == "LIFETIME" then
        return math.huge
    end
end

local function checkKey(input)
    if type(input) ~= "string" or #input < 5 then
        return false
    end

    local raw = safeHttp(KEY_URL)
    local inputHash = hash(input)

    for line in raw:gmatch("[^\r\n]+") do
        local key, typeKey, exp = line:match("(.+)|(.+)|(.+)")
        if key and hash(key) == inputHash then
            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            if not y then return false end
            if os.time() > getExpire(typeKey, tonumber(y), tonumber(m), tonumber(d)) then
                HardKick("Expired key")
            end
            return true, typeKey
        end
    end

    return false
end

--================== UI ==================--
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Gateway",
    LoadingTitle = "QueryHub",
    LoadingSubtitle = "Verification",
    Icon = ICON_APP,
    ConfigurationSaving = false
})

local Tab = Window:CreateTab("Key System", ICON_KEY)

local Status = Tab:CreateParagraph({
    Title = "Status",
    Content = "Waiting for key..."
})

Notify("QueryHub", "Executor : "..execName, ICON_INFO)

--================== INPUT ==================--
local INPUT_KEY = ""

Tab:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        INPUT_KEY = tostring(text or "")
        Status:Set("Key ready")
    end
})

--================== VERIFY ==================--
Tab:CreateButton({
    Name = "VERIFY",
    Callback = function()
        if os.clock() - SESSION.lastTry < 2 then
            HardKick("Spam detected")
        end
        SESSION.lastTry = os.clock()

        if INPUT_KEY == "" then
            Status:Set("Key empty")
            Notify("Error", "Please input key", ICON_ERROR)
            return
        end

        Status:Set("Verifying...")
        local ok, keyType = checkKey(INPUT_KEY)
        if not ok then
            SESSION.fail += 1
            Status:Set("Invalid key")
            Notify("Denied", "Invalid key", ICON_ERROR)
            if SESSION.fail >= 2 then
                HardKick("Too many failures")
            end
            return
        end

        -- SUCCESS
        getgenv().__QUERYHUB_LOCK = true
        SESSION.verified = true

        Status:Set("Access granted")
        Notify("Success", "Key type : "..keyType, ICON_SUCCESS)

        task.wait(0.5)
        Rayfield:Destroy()

        if not SESSION.verified then
            HardKick("Session error")
        end

        loadstring(game:HttpGet(MAIN_URL))()
    end
})