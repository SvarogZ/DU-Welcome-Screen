-------------------------------
---- CUSTOM VARIABLES ---------
-------------------------------
local stringMax = 1024 --export: max string lengh to transmite in one cycle
local startPattern = "[s]" --export: pattern to indicate the start of the package
local stopPattern = "[e]" --export: pattern to indicate the end of the package
local update_time = 0.1 --export: cycle for the package of data
local timeout = 3600 --export: timeout for the counter in seconds
local clearDatabank = false --export: select to clear the databank when programming board started

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
		error("No screen connected!")
	end
	
	table.sort(screens, function (a, b) return (a.getId() < b.getId()) end)
	table.sort(databanks, function (a, b) return (a.getId() < b.getId()) end)
end

initiateSlots()


local databankSlot = databanks[1]
if clearDatabank then
	databankSlot.clear()
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
if screens[1] then
	local data = {}
	data[1] = masterPlayerName

	if previousVisit then
		data[2] = visitTime - previousVisit
	end

	local dataString = json.encode(data)
	screens[1].setScriptInput(dataString)
end

local dataString = ""

if screens[2] then
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
		stringToTransmit = startPattern .. dataString .. stopPattern
		--system.print("stringToTransmit = "..stringToTransmit)
		isTransmissionInProgress = true
	end
	
	if #stringToTransmit > stringMax then
		screens[2].setScriptInput(string.sub(stringToTransmit,1,stringMax))
		stringToTransmit = string.sub(stringToTransmit,stringMax+1)
	else
		screens[2].setScriptInput(stringToTransmit)
		isTransmissionInProgress = false
		unit.stopTimer("transmission")
		system.print("transmission complete")
	end

end
