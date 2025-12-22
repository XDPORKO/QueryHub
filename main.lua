--====================================================--
-- QueryHub Gateway | CLEAN & UPGRADED
-- STABLE • SAFE • MODERN
--====================================================--

------------------------
-- SERVICES
------------------------
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

------------------------
-- SECURITY
------------------------
local function HardKick(reason)
    task.spawn(function()
        pcall(function()
            lp:Kick("[ QUERYHUB SECURITY ] "..tostring(reason))
        end)
        while true do task.wait() end
    end)
end

------------------------
-- EXECUTOR CHECK
------------------------
local function getExecutor()
    return identifyexecutor and tostring(identifyexecutor()) or "Unknown"
end

local ALLOWED_EXECUTORS = {
    "synapse","fluxus","arceus","arceus x",
    "hydrogen","delta","codex","trigon",
    "wave","electron"
}

do
    local exec = getExecutor():lower()
    local allowed = false
    for _,v in ipairs(ALLOWED_EXECUTORS) do
        if exec:find(v,1,true) then
            allowed = true
            break
        end
    end
    if not allowed then
        HardKick("Executor not supported : "..exec)
        return
    end
end

------------------------
-- ANTI DOUBLE LOAD
------------------------
if getgenv().__QUERYHUB_LOADED then
    HardKick("Double execution detected")
    return
end
getgenv().__QUERYHUB_LOADED = true

------------------------
-- CONFIG
------------------------
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/xpdvsp1.lua"
local ICON_ID  = 124796029670238

------------------------
-- UI LIB
------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

------------------------
-- SESSION (MAIN SCRIPT SAFE)
------------------------
local Session = {
    verified = false,
    userid   = nil,
    executor = getExecutor(),
    time     = 0,
    lastTry  = 0,
    fail     = 0
}

getgenv().__QUERYHUB_SESSION = Session
getgenv().__QUERYHUB_LOCK = false

------------------------
-- UTILS
------------------------
local function safeHttp(url)
    local ok,res = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and res or nil
end

local function hash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 33 + str:byte(i)) % 2147483647
    end
    return tostring(h)
end

------------------------
-- KEY CHECK
------------------------
local function verifyKey(input)
    if type(input) ~= "string" or #input < 5 then
        return false, "INVALID FORMAT"
    end

    local raw = safeHttp(KEY_URL)
    if not raw then
        return false, "NETWORK ERROR"
    end

    local ih = hash(input)
    for line in raw:gmatch("[^\r\n]+") do
        local k,t = line:match("(.+)|(.+)|")
        if k and hash(k) == ih then
            return true, t
        end
    end

    return false, "INVALID KEY"
end

------------------------
-- UI SETUP
------------------------
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Gateway",
    LoadingTitle = "QueryHub",
    LoadingSubtitle = "Secure Verification",
    Icon = ICON_ID,
    ConfigurationSaving = false
})

local TabKey  = Window:CreateTab("Key System", ICON_ID)
local TabInfo = Window:CreateTab("Info", ICON_ID)

local Status = TabKey:CreateParagraph({
    Title = "Status",
    Content = "Waiting for key..."
})

local Progress = TabKey:CreateSlider({
    Name = "Verification",
    Range = {0,100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 0,
    Flag = "VERIFY_PROGRESS",
    Callback = function() end
})

local INPUT_KEY = ""
local verifying = false

TabKey:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        INPUT_KEY = tostring(text)
    end
})

TabKey:CreateButton({
    Name = "VERIFY",
    Callback = function()
        if verifying then return end
        verifying = true
        Status:Set({Title="Status",Content="Verifying..."})
    end
})

TabInfo:CreateParagraph({
    Title = "Executor",
    Content = Session.executor
})

TabInfo:CreateParagraph({
    Title = "UserId",
    Content = tostring(lp.UserId)
})

------------------------
-- WORKER
------------------------
task.spawn(function()
    while task.wait() do
        if verifying then
            verifying = false

            if os.clock() - Session.lastTry < 2 then
                Status:Set({Title="Cooldown",Content="Please wait..."})
                continue
            end
            Session.lastTry = os.clock()

            for i = 0, 100, 25 do
                Progress:Set(i)
                task.wait(0.05)
            end

            local ok, result = verifyKey(INPUT_KEY)
            if not ok then
                Session.fail += 1
                Progress:Set(0)
                Status:Set({Title="Error",Content=result})
                Rayfield:Notify({
                    Title = "Verification Failed",
                    Content = result,
                    Duration = 2,
                    Image = ICON_ID
                })
                continue
            end

            -- SUCCESS
            Session.verified = true
            Session.userid   = lp.UserId
            Session.time     = os.time()
            getgenv().__QUERYHUB_LOCK = true

            Status:Set({
                Title = "ACCESS GRANTED ✔",
                Content = "Key Type : "..result
            })

            Rayfield:Notify({
                Title = "Welcome",
                Content = "QueryHub Loaded",
                Duration = 3,
                Image = ICON_ID
            })

            task.delay(2, function()
                Rayfield:Destroy()
                loadstring(game:HttpGet(MAIN_URL))()
            end)
        end
    end
end)