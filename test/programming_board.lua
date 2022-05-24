-------------------------------
---- CUSTOM VARIABLES ---------
-------------------------------
local timeout = 3600 --export: timeout for the counter in seconds
local update_time = 0.1 --export: cycle for the package of data
local startPattern = "[s]" --export: pattern to indicate the start of the package
local stopPattern = "[e]" --export: pattern to indicate the end of the package
local clearDatabank = false --export: select to clear the databank when programming board started
local stringMax = 1024 --export: max string lengh to transmite in one cycle

unit.hide()
-------------------------------
---- SLOTS DETECTION ----------
-------------------------------
local screens = {}
local databanks = {}

local function initiateSlots()
	for _, slot in pairs(unit) do
		if type(slot) == "table" and type(slot.export) == "table" and slot.getElementClass then
			local elementClass = slot.getElementClass():lower()
			if elementClass == "databankunit" then
				table.insert(databanks,slot)
			elseif elementClass == "screenunit" then
				table.insert(screens,slot)
			end
		end
	end
	
	if #databanks < 1 then
		error("No databank connected!")
	end

	if #screens < 1 then
		system.print("No screen connected!")
		--error("No screen connected!")
	end
	
	table.sort(screens, function (a, b) return (a.getId() < b.getId()) end)
	table.sort(databanks, function (a, b) return (a.getId() < b.getId()) end)
end

initiateSlots()

local databankSlot = databanks[1]
if clearDatabank then
	databankSlot.clear()
end

local welcomeScreen = {}
local statisticScreen = {}
for _, screen in ipairs(screens) do
	if screen.getScriptOutput() == "welcome" then
		table.insert(welcomeScreen,screen)
	elseif screen.getScriptOutput() == "statistic" then
		table.insert(statisticScreen,screen)
	end
end

-------------------------------
---- IDENTIFY AND COUNT USER --
-------------------------------
local masterPlayerId = unit.getMasterPlayerId()
local masterPlayerName = system.getPlayerName(masterPlayerId)
local visitTime = system.getArkTime()

local user = {}

local userString = databankSlot.getStringValue(masterPlayerId)
if userString and userString ~= "" then
	user = json.decode(userString)
else
	user.name = masterPlayerName
	user.counter = 1
end

if user.time and visitTime - user.time > timeout then
	user.lastTime = user.time
	user.counter = user.counter + 1
end

user.time = visitTime
local previousVisit = user.lastTime

if user.name ~= masterPlayerName then
	--name is changed since last visit
	user.previousName = user.name
	user.name = masterPlayerName
end

-- record to the databank
databankSlot.setStringValue(masterPlayerId,json.encode(user))

-------------------------------
---- SHOW ON SCREEN -----------
-------------------------------
if #welcomeScreen > 0 do
	local data = {}
	data[1] = masterPlayerName

	if previousVisit then
		data[2] = visitTime - previousVisit
	end

	local dataString = json.encode(data)
	
	for _, screen in ipairs(welcomeScreen) do
		screen.setScriptInput(dataString)
	end
end

local dataString = ""

if #statisticScreen > 0 then
	local keyListString = databankSlot.getKeys()
	local keyList = {}
	if keyListString and keyListString ~= "" then
		keyList = json.decode(keyListString)
	end

	local users = {}

	for _, id in ipairs(keyList) do
		local userObjectString = databankSlot.getStringValue(id)
		if userObjectString and userObjectString ~= "" then
			local userObject = json.decode(userObjectString)
			local name = userObject.name or "Unknown"
			local time = userObject.time or 0
			local lastTime = userObject.lastTime or time
			local counter = userObject.counter or 0
			local objectToRecord = {id, name, visitTime - time, visitTime - lastTime, counter}
			table.insert(users,objectToRecord)
		end
	end

	dataString = json.encode(users)
	
	unit.setTimer("transmission", update_time)
end

--system.print("string = "..dataString)

function transmission()
	if not isTransmissionInProgress then
		if dataString ~= "" then
			stringToTransmit = startPattern .. dataString .. stopPattern
			--system.print("stringToTransmit = "..stringToTransmit)
			isTransmissionInProgress = true
		else
			unit.stopTimer("transmission")
		end
	end
	
	if #stringToTransmit > stringMax then
		local stringPart = string.sub(stringToTransmit,1,stringMax)
		sendToScreen(stringPart)
		stringToTransmit = string.sub(stringToTransmit,stringMax+1)
	else
		sendToScreen(stringToTransmit)
		isTransmissionInProgress = false
		unit.stopTimer("transmission")
		system.print("transmission complete")
	end
		
	local function sendToScreen(stringData)
		for _, screen in ipairs(statisticScreen) do
			screen.setScriptInput(stringData)
		end
	end
end
