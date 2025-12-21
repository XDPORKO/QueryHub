--====================================================--
-- QueryHub Gateway | MODERN UI • CALLBACK SAFE • STABLE
--====================================================--

--================== GLOBAL DEAD ==================--
if getgenv().__QUERYHUB_DEAD then return end

--================== SERVICES ==================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

--================== CONFIG ==================--
local KEY_URL  = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/key.txt"
local MAIN_URL = "https://raw.githubusercontent.com/XDPORKO/QueryHub/main/p1.lua"

--================== ICONS ==================--
local ICON_APP     = 6031071053
local ICON_KEY     = 6031075924
local ICON_SUCCESS = 6031094678
local ICON_ERROR   = 6031075925
local ICON_INFO    = 6031071054
local ICON_WARN    = 6031075926

--================== SAFE KICK (NO CALLBACK ERROR) ==================--
local function SafeKick(reason)
	getgenv().__QUERYHUB_DEAD = true
	task.spawn(function()
		pcall(function()
			lp:Kick("[ QUERYHUB SECURITY ] "..tostring(reason))
		end)
		while true do task.wait() end
	end)
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
	for _,v in ipairs(ALLOWED_EXECUTORS) do
		if exec:find(v:lower(),1,true) then
			return true, v
		end
	end
	return false, exec
end

local okExec, execName = isExecutorAllowed()
if not okExec then SafeKick("Executor not supported") return end

--================== ANTI DOUBLE EXEC ==================--
if getgenv().__QUERYHUB_LOCK or getgenv().__QUERYHUB_LOADED then
	SafeKick("Double execution detected")
	return
end
getgenv().__QUERYHUB_LOADED = true

--================== UI LIB ==================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--================== SAFE NOTIFY ==================--
local function Notify(title, content, icon, dur)
	pcall(function()
		Rayfield:Notify({
			Title = title,
			Content = content,
			Duration = dur or 3,
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
		SafeKick("Network blocked")
		return ""
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
local function getExpire(typeKey,y,m,d)
	local base = os.time({
		year=y, month=m, day=d,
		hour=23, min=59, sec=59
	})
	if typeKey=="DAILY" then
		return base+86400
	elseif typeKey=="WEEKLY" then
		return base+604800
	elseif typeKey=="LIFETIME" then
		return math.huge
	end
end

local function checkKey(input)
	if type(input)~="string" or #input<5 then return false end
	local raw = safeHttp(KEY_URL)
	local ih = hash(input)

	for line in raw:gmatch("[^\r\n]+") do
		local key,typeKey,exp = line:match("(.+)|(.+)|(.+)")
		if key and hash(key)==ih then
			local y,m,d = exp:match("(%d+)%-(%d+)%-(%d+)")
			if not y then return false end
			if os.time() > getExpire(typeKey,tonumber(y),tonumber(m),tonumber(d)) then
				SafeKick("Expired key")
				return false
			end
			return true,typeKey
		end
	end
	return false
end

--================== MODERN UI ==================--
local Window = Rayfield:CreateWindow({
	Name = "QueryHub",
	LoadingTitle = "QueryHub Gateway",
	LoadingSubtitle = "Secure Verification",
	Icon = ICON_APP,
	Theme = "Dark",
	ConfigurationSaving = false
})

local Tab = Window:CreateTab("Verification", ICON_KEY)

local Status = Tab:CreateParagraph({
	Title = "Status",
	Content = "Waiting for key input..."
})

Notify("QueryHub Ready","Executor : "..execName,ICON_INFO,3)

--================== INPUT ==================--
local INPUT_KEY = ""

Tab:CreateInput({
	Name = "Premium Key",
	PlaceholderText = "XXXX-XXXX-XXXX",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		INPUT_KEY = tostring(text or "")
		Status:Set("Key inserted")
	end
})

--================== VERIFY BUTTON (CALLBACK SAFE) ==================--
Tab:CreateButton({
	Name = "Verify & Continue",
	Callback = function()
		if os.clock() - SESSION.lastTry < 2 then
			Status:Set("Please wait...")
			Notify("Slow down","Too fast input",ICON_WARN)
			return
		end
		SESSION.lastTry = os.clock()

		if INPUT_KEY == "" then
			Status:Set("Key required")
			Notify("Error","Key is empty",ICON_ERROR)
			return
		end

		Status:Set("Verifying key...")
		Notify("Checking","Validating key",ICON_INFO)

		local ok, keyType = checkKey(INPUT_KEY)
		if not ok then
			SESSION.fail = SESSION.fail + 1
			Status:Set("Invalid key")
			Notify("Denied","Invalid key",ICON_ERROR)
			if SESSION.fail >= 2 then
				task.spawn(function()
					task.wait(0.15)
					SafeKick("Too many invalid attempts")
				end)
			end
			return
		end

		-- SUCCESS
		SESSION.verified = true
		getgenv().__QUERYHUB_LOCK = true

		Status:Set("Access granted ("..keyType..")")
		Notify("Success","Welcome to QueryHub",ICON_SUCCESS,4)

		task.spawn(function()
			task.wait(0.25)
			pcall(function() Rayfield:Destroy() end)
			if SESSION.verified then
				loadstring(game:HttpGet(MAIN_URL))()
			end
		end)
	end
})