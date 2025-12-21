--====================================================--
-- QueryHub Gateway | Secure Loader (STABLE EDITION)
-- NO CALLBACK KICK | UI SAFE | MODERN
--====================================================--

--================== SERVICES ==================--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

--================== HARD KICK (FATAL ONLY) ==================--
local function HardKick(reason)
	task.spawn(function()
		pcall(function()
			lp:Kick("[ QUERYHUB SECURITY ] "..tostring(reason))
		end)
		while true do task.wait() end
	end)
end

--================== EXECUTOR CHECK (FATAL) ==================--
local function getExecutor()
	if identifyexecutor then
		return tostring(identifyexecutor())
	end
	return "Unknown"
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
		if exec:find(v,1,true) then ok = true break end
	end
	if not ok then
		HardKick("Executor not supported : "..exec)
		return
	end
end

--================== ANTI DOUBLE LOAD (FATAL) ==================--
if getgenv().__QUERYHUB_LOADED then
	HardKick("Double execution detected")
	return
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
getgenv().__QUERYHUB_SESSION = {
	verified = false,
	lastTry = 0,
	fail = 0
}

--================== UTILS ==================--
local function safeHttp(url)
	local ok,res = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(res) ~= "string" then
		return nil
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
local function checkKey(input)
	if type(input) ~= "string" or #input < 5 then
		return false, "INVALID FORMAT"
	end

	local raw = safeHttp(KEY_URL)
	if not raw then
		return false, "NETWORK ERROR"
	end

	local inputHash = hash(input)
	for line in raw:gmatch("[^\r\n]+") do
		local key, typeKey = line:match("(.+)|(.+)|")
		if key and hash(key) == inputHash then
			return true, typeKey
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

local INPUT_KEY = ""
local verifyRequest = false

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
		verifyRequest = true
		status:Set({
			Title = "Status",
			Content = "Verifying..."
		})
	end
})

--================== WORKER THREAD (NO CALLBACK LOGIC) ==================--
task.spawn(function()
	while task.wait() do
		if verifyRequest then
			verifyRequest = false
			local S = getgenv().__QUERYHUB_SESSION

			if os.clock() - S.lastTry < 2 then
				status:Set({
					Title = "Status",
					Content = "Please wait..."
				})
				return
			end
			S.lastTry = os.clock()

			local ok, result = checkKey(INPUT_KEY)
			if not ok then
				S.fail += 1
				status:Set({
					Title = "Status",
					Content = result
				})

				Rayfield:Notify({
					Title = "Error",
					Content = result,
					Duration = 2,
					Image = ICON_ERROR
				})

				return
			end

			-- SUCCESS
			getgenv().__QUERYHUB_SESSION.verified = true

			status:Set({
				Title = "Status",
				Content = "ACCESS GRANTED"
			})

			Rayfield:Notify({
				Title = "Access Granted",
				Content = "Key Type : "..result,
				Duration = 3,
				Image = ICON_SUCCESS
			})

			task.delay(0.4, function()
				Rayfield:Destroy()
				loadstring(game:HttpGet(MAIN_URL))()
			end)

			return
		end
	end
end)