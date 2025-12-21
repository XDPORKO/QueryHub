--// QueryHub Premium Key System
--// Key Type + Anti Tamper (Rayfield)

-- ================== CONFIG ==================
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ================== ICONS ==================
local ICON_APP     = 6031071053
local ICON_KEY     = 6031075924
local ICON_SUCCESS = 6031094678
local ICON_ERROR   = 6031075925
local ICON_TIME    = 6031075936

-- ================== UI ==================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ================== ANTI TAMPER ==================
local __SIGNATURE = "QH_SIG_V1"
local __CHECKSUM = tostring(#KEY_URL + #MAIN_URL)

local function tamperDetected()
    pcall(function()
        lp:Kick("QueryHub | Script modified or corrupted")
    end)
    while true do end
end

if _G.__QH_LOADED or __SIGNATURE ~= "QH_SIG_V1" then
    tamperDetected()
end
_G.__QH_LOADED = true

if tostring(#KEY_URL + #MAIN_URL) ~= __CHECKSUM then
    tamperDetected()
end

-- ================== SESSION ==================
getgenv().__QUERYHUB_SESSION = getgenv().__QUERYHUB_SESSION or {
    verified = false,
    lastTry = 0
}

if getgenv().__QUERYHUB_SESSION.verified then
    loadstring(game:HttpGet(MAIN_URL))()
    return
end

-- ================== UTILS ==================
local function safeHttp(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    return ok and res or nil
end

local function hash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 33 + string.byte(str, i)) % 2^31
    end
    return tostring(h)
end

-- ================== KEY CHECK ==================
local function getExpire(typeKey, y,m,d)
    local base = os.time({year=y, month=m, day=d, hour=23, min=59, sec=59})
    if typeKey == "DAILY" then
        return base + 86400
    elseif typeKey == "WEEKLY" then
        return base + (86400 * 7)
    elseif typeKey == "LIFETIME" then
        return base
    end
end

local function checkKey(input)
    local raw = safeHttp(KEY_URL)
    if not raw then
        return false, "NETWORK ERROR"
    end

    local inputHash = hash(input)

    for line in raw:gmatch("[^\r\n]+") do
        local key, typeKey, exp = line:match("(.+)|(.+)|(.+)")
        if key and typeKey and exp and hash(key) == inputHash then
            local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
            local expire = getExpire(typeKey, y,m,d)
            if os.time() > expire then
                return false, "KEY EXPIRED"
            end
            return true, expire, typeKey
        end
    end

    return false, "INVALID KEY"
end

-- ================== UI ==================
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Premium",
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

local expiry = Tab:CreateParagraph({
    Title = "Expiry",
    Content = "-"
})

local keyBox = Tab:CreateInput({
    Name = "Premium Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false
})

Tab:CreateButton({
    Name = "VERIFY KEY",
    Callback = function()
        if os.clock() - getgenv().__QUERYHUB_SESSION.lastTry < 2 then
            Rayfield:Notify({
                Title = "Wait",
                Content = "Slow down",
                Duration = 2,
                Image = ICON_TIME
            })
            return
        end
        getgenv().__QUERYHUB_SESSION.lastTry = os.clock()

        status:Set({Title="Status",Content="Checking key..."})

        local ok, expire, typeKey = checkKey(keyBox.CurrentValue)

        if ok then
            getgenv().__QUERYHUB_SESSION.verified = true

            Rayfield:Notify({
                Title = "Access Granted",
                Content = "Key Type : "..typeKey,
                Duration = 3,
                Image = ICON_SUCCESS
            })

            task.spawn(function()
                while os.time() < expire do
                    local s = expire - os.time()
                    expiry:Set({
                        Title = "Expiry",
                        Content = string.format("%02d:%02d:%02d",
                            math.floor(s/3600),
                            math.floor(s/60)%60,
                            s%60
                        )
                    })
                    task.wait(1)
                end
            end)

            task.wait(1)
            Rayfield:Destroy()
            loadstring(game:HttpGet(MAIN_URL))()
        else
            Rayfield:Notify({
                Title = "Denied",
                Content = expire,
                Duration = 3,
                Image = ICON_ERROR
            })
            status:Set({Title="Status",Content=expire})
        end
    end
})