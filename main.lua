--====================================================--
-- QueryHub Gateway | ULTRA MODERN UI + BADGE KEY
-- PREMIUM • SMOOTH • SAFE
--====================================================--

------------------------
-- SERVICES
------------------------
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

------------------------
-- HARD SECURITY
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
    local ok = false
    for _,v in ipairs(ALLOWED_EXECUTORS) do
        if exec:find(v,1,true) then
            ok = true
            break
        end
    end
    if not ok then
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
-- SESSION
------------------------
local Session = {
    verified = false,
    userid   = nil,
    executor = getExecutor(),
    time     = 0,
    lastTry  = 0,
    fail     = 0,
    badge    = "UNVERIFIED"
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

-- FIXED HASH (Luau compatible)
local function hash(str)
    local h = 5381
    for i = 1, #str do
        h = bit32.bxor(h * 33, str:byte(i))
        h = h % 2147483647
    end
    return tostring(h)
end

------------------------
-- KEY VERIFY
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
        -- support: key|type  OR  key|type|
        local k,t = line:match("^([^|]+)|([^|]+)")
        if k and hash(k) == ih then
            return true, t
        end
    end

    return false, "INVALID KEY"
end

------------------------
-- BADGE STYLE
------------------------
local BADGE_STYLE = {
    FREE      = "🟦 FREE ACCESS",
    VIP       = "🟨 VIP MEMBER",
    LIFETIME  = "🟪 LIFETIME ACCESS",
    ADMIN     = "🟥 ADMIN ACCESS"
}

------------------------
-- WINDOW
------------------------
local Window = Rayfield:CreateWindow({
    Name = "QueryHub",
    LoadingTitle = "QueryHub Gateway",
    LoadingSubtitle = "Encrypted Access Layer",
    Icon = ICON_ID,
    DisableRayfieldPrompts = true,
    ConfigurationSaving = false
})

------------------------
-- TABS
------------------------
local TabAccess = Window:CreateTab("Access", ICON_ID)
local TabStatus = Window:CreateTab("Session", ICON_ID)

------------------------
-- ACCESS UI
------------------------
TabAccess:CreateSection("🔐 Secure Verification")

local Status = TabAccess:CreateParagraph({
    Title = "STATUS",
    Content = "Idle • Awaiting key"
})

local Progress = TabAccess:CreateSlider({
    Name = "Access Progress",
    Range = {0,100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 0,
    Callback = function() end
})

local INPUT_KEY = ""
local verifying = false

TabAccess:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "XXXX-XXXX-XXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        INPUT_KEY = tostring(text)
    end
})

TabAccess:CreateButton({
    Name = "Authenticate",
    Callback = function()
        if verifying then return end
        verifying = true
        Status:Set({
            Title = "STATUS",
            Content = "Authenticating..."
        })
    end
})

------------------------
-- SESSION TAB
------------------------
TabStatus:CreateSection("📡 Environment")

TabStatus:CreateParagraph({
    Title = "Executor",
    Content = Session.executor
})

TabStatus:CreateParagraph({
    Title = "User ID",
    Content = tostring(lp.UserId)
})

TabStatus:CreateSection("🏷️ Key Badge")

local Badge = TabStatus:CreateParagraph({
    Title = "KEY STATUS",
    Content = "Not Verified"
})

------------------------
-- WORKER
------------------------
task.spawn(function()
    while task.wait() do
        if not verifying then
            continue
        end
        verifying = false

        if os.clock() - Session.lastTry < 2 then
            Status:Set({
                Title = "COOLDOWN",
                Content = "Please wait..."
            })
            continue
        end
        Session.lastTry = os.clock()

        for i = 0, 100, math.random(8,12) do
            Progress:Set(math.clamp(i,0,100))
            task.wait(0.035)
        end

        local ok, result = verifyKey(INPUT_KEY)
        if not ok then
            Session.fail += 1
            Progress:Set(0)
            Status:Set({
                Title = "DENIED",
                Content = result
            })
            Badge:Set({
                Title = "KEY STATUS",
                Content = "❌ INVALID"
            })
            Rayfield:Notify({
                Title = "Access Denied",
                Content = result,
                Duration = 2.5,
                Image = ICON_ID
            })
            continue
        end

        -- SUCCESS
        Session.verified = true
        Session.userid   = lp.UserId
        Session.time     = os.time()
        getgenv().__QUERYHUB_LOCK = true

        local tier = string.upper(result)
        Session.badge = tier

        Status:Set({
            Title = "ACCESS GRANTED ✔",
            Content = "Key Type : "..tier
        })

        Badge:Set({
            Title = "KEY BADGE",
            Content = BADGE_STYLE[tier] or ("🟩 PREMIUM • "..tier)
        })

        Rayfield:Notify({
            Title = "Welcome",
            Content = "QueryHub Unlocked",
            Duration = 3,
            Image = ICON_ID
        })

        task.delay(2, function()
            Rayfield:Destroy()
            loadstring(game:HttpGet(MAIN_URL))()
        end)
    end
end)