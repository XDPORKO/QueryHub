--====================================================--
-- QueryHub Gateway | Secure Loader (HARD KICK EDITION)
--====================================================--

--================== SERVICES ==================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

local function HardKick(reason)
    pcall(function()
        lp:Kick("[ QUERYHUB SECURITY ] "..reason)
    end)
    task.wait(1)
    while true do end
end

--================== EXECUTOR WHITELIST ==================--
local function getExecutor()
    if identifyexecutor then
        return tostring(identifyexecutor())
    end
    return "Unknown"
end

local ALLOWED_EXECUTORS = {
    "Synapse","Fluxus","Arceus","Arceus X","Hydrogen",
    "Delta","Codex","Trigon","Wave","Electron"
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
local ICON_TIME    = 6031075936

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
    if not ok or not res then
        HardKick("Network manipulation detected")
    end
    return res
end

local function hash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 33 + string.byte(str, i)) % 2^31
    end
    return tostring(h)
end

--================== KEY CHECK ==================--
local function getExpire(typeKey, y,m,d)
    local base = os.time({year=y, month=m, day=d, hour=23, min=59, sec=59})
    if typeKey == "DAILY" then
        return base + 86400
    elseif typeKey == "WEEKLY" then
        return base + 604800
    elseif typeKey == "LIFETIME" then
        return math.huge
    end
end

local function checkKey(input)
    local raw = safeHttp(KEY_URL)
    local inputHash = hash(input)

    for line in raw:gmatch("[^\r\n]+") do
        local key, typeKey, exp = line:match("(.+)|(.+)|(.+)")
        if key and hash(key) == inputHash then
            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
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

local keyBox = Tab:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false
})

Tab:CreateButton({
    Name = "VERIFY KEY",
    Callback = function()
        local S = getgenv().__QUERYHUB_SESSION

        if os.clock() - S.lastTry < 2 then
            HardKick("Spam verification detected")
        end
        S.lastTry = os.clock()

        local ok, expire, typeKey = checkKey(keyBox.CurrentValue)

        if not ok then
            S.fail += 1
            if S.fail >= 2 then
                HardKick("Multiple invalid key attempts")
            end
            status:Set({Title="Status", Content="INVALID KEY"})
            return
        end

        -- 🔒 HARD SESSION LOCK
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
        loadstring(game:HttpGet(MAIN_URL))()
    end
})