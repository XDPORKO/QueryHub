--// QueryHub Premium Key System (Rayfield Edition)
--// Mobile + PC | Secure Client-Side

-- ================== CONFIG ==================
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

-- ================== UI LIB ==================
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

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
        h = (h * 31 + string.byte(str, i)) % 2^31
    end
    return tostring(h)
end

-- ================== KEY CHECK ==================
local function checkKey(input)
    local raw = safeHttp(KEY_URL)
    if not raw then
        return false, "NETWORK ERROR"
    end

    local inputHash = hash(input)

    for line in raw:gmatch("[^\r\n]+") do
        local key, exp = line:match("(.+)|(.+)")
        if key and exp then
            if hash(key) == inputHash then
                local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
                local expire = os.time({
                    year=y, month=m, day=d,
                    hour=23, min=59, sec=59
                })
                if os.time() > expire then
                    return false, "KEY EXPIRED"
                end
                return true, expire
            end
        end
    end

    return false, "INVALID KEY"
end

-- ================== UI ==================
local Window = Rayfield:CreateWindow({
    Name = "QueryHub Premium",
    LoadingTitle = "QueryHub",
    LoadingSubtitle = "Secure Key System",
    ConfigurationSaving = false,
    KeySystem = false
})

local Tab = Window:CreateTab("🔐 Key", 4483362458)

local statusLabel = Tab:CreateParagraph({
    Title = "Status",
    Content = "Please enter your key"
})

local countdownLabel = Tab:CreateParagraph({
    Title = "Expiry",
    Content = "-"
})

local keyInput
keyInput = Tab:CreateInput({
    Name = "Key",
    PlaceholderText = "ENTER YOUR KEY",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

Tab:CreateButton({
    Name = "VERIFY KEY",
    Callback = function()
        if os.clock() - getgenv().__QUERYHUB_SESSION.lastTry < 2 then
            Rayfield:Notify({
                Title = "Wait",
                Content = "Please slow down",
                Duration = 2
            })
            return
        end
        getgenv().__QUERYHUB_SESSION.lastTry = os.clock()

        statusLabel:Set({
            Title = "Status",
            Content = "Checking key..."
        })

        local ok, expireOrMsg = checkKey(keyInput.CurrentValue)

        if ok then
            getgenv().__QUERYHUB_SESSION.verified = true

            Rayfield:Notify({
                Title = "Success",
                Content = "Key verified",
                Duration = 3
            })

            task.spawn(function()
                while os.time() < expireOrMsg do
                    local s = expireOrMsg - os.time()
                    countdownLabel:Set({
                        Title = "Expiry",
                        Content = string.format(
                            "%02d:%02d:%02d",
                            s/3600%24,
                            s/60%60,
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
                Title = "Error",
                Content = expireOrMsg,
                Duration = 3
            })

            statusLabel:Set({
                Title = "Status",
                Content = expireOrMsg
            })
        end
    end
})