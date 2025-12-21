--================== SERVICES ==================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

--================== HARD KICK ==================--
local function HardKick(reason)
    pcall(function()
        lp:Kick("[ QUERYHUB SECURITY ] "..tostring(reason))
    end)
    task.wait()
    error(reason, 0)
    while true do end
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
    local exec = getExecutor()
    for _,v in ipairs(ALLOWED_EXECUTORS) do
        if exec:lower():find(v:lower()) then
            return true, exec
        end
    end
    return false, exec
end

local okExec, execName = isExecutorAllowed()
if not okExec then
    HardKick("Executor not supported : "..execName)
end

--================== ANTI DOUBLE LOAD ==================--
if getgenv().__QUERYHUB_LOADED then
    HardKick("Double execution detected")
end
getgenv().__QUERYHUB_LOADED = true

--================== CONFIG ==================--
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

--================== ICONS ==================--
local ICON_APP     = 6031071053
local ICON_KEY     = 6031075924
local ICON_SUCCESS = 6031094678
local ICON_ERROR   = 6031075925

--================== UI LIB ==================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--================== SESSION ==================--
getgenv().__QUERYHUB_SESSION = getgenv().__QUERYHUB_SESSION or {
    verified = false,
    lastTry = 0,
    fail = 0
}

--================== UTILS ==================--
local function safeHttp(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(res) ~= "string" then
        HardKick("Network manipulation detected")
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
        year = tonumber(y),
        month = tonumber(m),
        day = tonumber(d),
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
        return false, "INVALID FORMAT"
    end

    local raw = safeHttp(KEY_URL)
    local inputHash = hash(input)

    for line in raw:gmatch("[^\r\n]+") do
        local key, typeKey, exp = line:match("(.+)|(.+)|(.+)")
        if key and hash(key) == inputHash then
            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            if not y then
                HardKick("Corrupted key data")
            end
            local expire = getExpire(typeKey, y,m,d)
            if os.time() > expire then
                HardKick("Expired key usage")
            end
            return true, expire, typeKey
        end
    end

    return false, "INVALID KEY"
end

--================== UI ==================--
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Gateway",
    LoadingTitle = "QueryHub",
    LoadingSubtitle = "Secure Verification",
    Icon = ICON_APP,
    ConfigurationSaving = false
})

local Tab = Window:CreateTab("Key System", ICON_KEY)

local status = Tab:CreateParagraph({
    Title = "Status",
    Content = "Waiting for key"
})

-- 🔑 INPUT FIX (ANTI CALLBACK ERROR)
local INPUT_KEY = ""

Tab:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        INPUT_KEY = tostring(text)
    end
})

Tab:CreateButton({
    Name = "VERIFY KEY",
    Callback = function()
        local S = getgenv().__QUERYHUB_SESSION

        if os.clock() - S.lastTry < 2 then
            HardKick("Spam verification detected")
        end
        S.lastTry = os.clock()

        if INPUT_KEY == "" then
            status:Set({
                Title = "Status",
                Content = "PLEASE INPUT KEY"
            })
            return
        end

        local ok, expire, typeKey = checkKey(INPUT_KEY)

        if not ok then
            S.fail += 1
            status:Set({
                Title = "Status",
                Content = "INVALID KEY"
            })
            if S.fail >= 2 then
                HardKick("Multiple invalid key attempts")
            end
            return
        end

        -- 🔒 SESSION LOCK
        getgenv().__QUERYHUB_SESSION = {
            verified = true,
            userid = lp.UserId,
            executor = execName,
            token = HttpService:GenerateGUID(false),
            issued = os.time()
        }
        getgenv().__QUERYHUB_LOCK = true

        Rayfield:Notify({
            Title = "Access Granted",
            Content = "Key Type : "..typeKey,
            Duration = 3,
            Image = ICON_SUCCESS
        })

        Rayfield:Destroy()

        -- SAFE LOAD MAIN
        local okLoad, err = pcall(function()
            loadstring(game:HttpGet(MAIN_URL))()
        end)

        if not okLoad then
            HardKick("Main loader tampered")
        end
    end
})