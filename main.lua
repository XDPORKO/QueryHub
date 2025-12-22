
----------------------------------------------------------------
-- [ QUERYHUB GATEWAY MODERN v2.0 ]
-- Author: XDPORKO
----------------------------------------------------------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

------------------------
-- CONFIGURATION
------------------------
local CONFIG = {
    Name = "QueryHub Gateway • Premium",
    KeyURL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt",
    MainURL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/xpdvsp1.lua",
    Discord = "https://discord.gg/queryhub", -- Ganti link discordmu
    Icon = 124796029670238,
    Theme = "Amethyst" -- "Default", "Amber", "Amethyst", "Bloom", "DarkBlue", "Green", "Ocean", "Serenity"
}

------------------------
-- UTILITIES
------------------------
local function safeHttp(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and res or nil
end

local function copyDiscord()
    if setclipboard then
        setclipboard(CONFIG.Discord)
        return true
    end
    return false
end

local function checkExpiry(dateStr)
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    if not y then return true end
    local expireTime = os.time({year = y, month = m, day = d, hour = 23, min = 59})
    return os.time() > expireTime
end

------------------------
-- CORE AUTH ENGINE
------------------------
local function validate(input)
    if not input or #input < 3 then return false, "Key too short!" end
    
    local raw = safeHttp(CONFIG.KeyURL)
    if not raw then return false, "Server connection failed!" end

    local userKey = input:gsub("%s+", "")
    
    for line in raw:gmatch("[^\r\n]+") do
        local k, tier, exp = line:match("^([^|]+)|([^|]+)|([^|]+)")
        if k and k == userKey then
            if checkExpiry(exp) then return false, "Key Expired: " .. exp end
            return true, {tier = tier, exp = exp}
        end
    end
    return false, "Invalid License Key!"
end

------------------------
-- UI INITIALIZATION
------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = CONFIG.Name,
    LoadingTitle = "QUERYHUB ECOSYSTEM",
    LoadingSubtitle = "by XDPORKO",
    ConfigurationSaving = { Enabled = false },
    Theme = CONFIG.Theme,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,
})

-- Tabs
local TabAuth = Window:CreateTab("Verification", "fingerprint")
local TabExtra = Window:CreateTab("Community", "users")
local TabSystem = Window:CreateTab("Debug", "terminal")

------------------------
-- VERIFICATION TAB
------------------------
TabAuth:CreateSection("🛡️ Secure Authentication")

local StatusLabel = TabAuth:CreateParagraph({
    Title = "Ready to Verify",
    Content = "Please enter your license key to access the main script."
})

local InputKey = ""
local Loading = false

TabAuth:CreateInput({
    Name = "License Key",
    PlaceholderText = "QH-XXXX-XXXX-XXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) InputKey = text end
})

TabAuth:CreateButton({
    Name = "Unlock QueryHub",
    Callback = function()
        if Loading then return end
        Loading = true
        
        StatusLabel:Set({Title = "⏳ Verifying...", Content = "Communicating with GitHub database..."})

        local success, data = validate(InputKey)

        task.wait(1) -- Biar ada efek loading sedikit (keren)

        if success then
            StatusLabel:Set({Title = "✅ Access Granted!", Content = "Welcome back! Loading environment..."})
            
            -- Setup Session
            getgenv().__QUERYHUB_SESSION = {
                verified = true,
                userid = lp.UserId,
                tier = data.tier,
                expiry = data.exp
            }

            Rayfield:Notify({
                Title = "Success!",
                Content = "Tier: " .. data.tier .. " | Expires: " .. data.exp,
                Duration = 4,
                Image = 4483345998,
            })

            local main = safeHttp(CONFIG.MainURL)
            if main then
                task.wait(1)
                Rayfield:Destroy()
                loadstring(main)()
            else
                Loading = false
                StatusLabel:Set({Title = "❌ Error", Content = "Failed to fetch Main Script."})
            end
        else
            Loading = false
            StatusLabel:Set({Title = "❌ Rejected", Content = data})
            Rayfield:Notify({Title = "Authentication Failed", Content = data, Duration = 5})
        end
    end
})

------------------------
-- COMMUNITY TAB
------------------------
TabExtra:CreateSection("Links")

TabExtra:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if copyDiscord() then
            Rayfield:Notify({Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3})
        else
            StatusLabel:Set({Title = "Discord Link", Content = CONFIG.Discord})
        end
    end
})

TabExtra:CreateParagraph({
    Title = "Need a Key?",
    Content = "Visit our Discord to get a free weekly key or purchase a Lifetime license."
})

------------------------
-- SYSTEM TAB
------------------------
TabSystem:CreateSection("Machine Info")
TabSystem:CreateParagraph({Title = "Account", Content = "User: " .. lp.Name .. "\nID: " .. lp.UserId})
TabSystem:CreateParagraph({Title = "Hardware", Content = "Executor: " .. (identifyexecutor and identifyexecutor() or "Generic")})

Rayfield:Notify({
    Title = "System Loaded",
    Content = "Welcome, " .. lp.DisplayName,
    Duration = 3
})
