------------------------------
---- CUSTOM VARIABLES ---------
-------------------------------
local timeout = 3600 --export: timeout for the counter in seconds
local update_time = 0.05 --export: cycle for the package of data
local startPattern = "[s]" --export: pattern to indicate the start of the package
local stopPattern = "[e]" --export: pattern to indicate the end of the package
local clearDatabank = false --export: select to clear the databank when programming board started
local stringMax = 1024 --export: max string lengh to transmite in one cycle
local maxUsersForDatabank = 600
local maxRecords = 2000

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

--local databankSlot = databanks[1]
if clearDatabank then
	for _, databank in ipairs(databanks) do
		databank.clear()
	end
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
---- FUNCTIONS ----------------
-------------------------------
function string:split(sep)
    local sep = sep or ","
    local result = {}
    local i = 1
    for c in self:gmatch(string.format("([^%s]+)", sep)) do
        local n = tonumber(c)
        if n then
            result[i] = n
        else
            result[i] = c
        end
        i = i + 1
    end
    return result
end

-------------------------------
---- IDENTIFY AND COUNT USER --
-------------------------------
local masterPlayerId = unit.getMasterPlayerId()
local masterPlayerName = system.getPlayerName(masterPlayerId)
local visitTime = math.floor(system.getArkTime())

local function signInUser(id)
	for _, databank in ipairs(databanks) do
		local userString = databank.getStringValue(id)
		if userString and userString ~= "" then
			local user = userString:split(",")
			return user, databank
		end
	end
	local totalRecords = 0
	for _, databank in ipairs(databanks) do
		local recordsInDatabank = databank.getNbKeys()
		totalRecords = totalRecords + recordsInDatabank
		if recordsInDatabank < maxUsersForDatabank and totalRecords < maxRecords then
			return {masterPlayerName,1,visitTime,visitTime}, databank
		end
	end
	system.print("No space in databanks!")
	return {masterPlayerName,1,visitTime,visitTime}, nil
end


local user, userDatabank = signInUser(masterPlayerId)

if visitTime - user[3] > timeout then
	user[4] = user[3]
	user[2] = user[2] + 1
end

user[3] = visitTime

-- record to the databank
if userDatabank then
	userDatabank.setStringValue(masterPlayerId,table.concat(user,","))
end
-------------------------------
---- SHOW ON SCREEN -----------
-------------------------------
if #welcomeScreen > 0 then
	local data = {}
	data[1] = masterPlayerName

	if user[2] > 1 then
		data[2] = visitTime - user[4]
	end

	local dataString = table.concat(data,",")
	
	for _, screen in ipairs(welcomeScreen) do
		screen.setScriptInput(dataString)
	end
end

local dataString = ""

if #statisticScreen > 0 then
	local users = {}

	for i, databank in ipairs(databanks) do
		local keyList = {}
		local keyListString = databank.getKeys()
		if keyListString and keyListString ~= "" then
			local i = 1
			for c in keyListString:gmatch('%d+') do
				keyList[i] = tonumber(c)
				i = i + 1
			end
		end

		for _, id in ipairs(keyList) do
			local userObjectString = databank.getStringValue(id)
			if userObjectString and userObjectString ~= "" then
				local userObject = userObjectString:split(",")
				local objectToRecord = {}
				objectToRecord[1] = id
				objectToRecord[2] = userObject[1]
				objectToRecord[3] = visitTime - userObject[3]
				objectToRecord[4] = visitTime - userObject[4]
				objectToRecord[5] = userObject[2]
				table.insert(users,table.concat(objectToRecord,","))
			end
		end
	end
	
	dataString = table.concat(users,";")
	
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
	
	local function sendToScreen(stringData)
		for _, screen in ipairs(statisticScreen) do
			screen.setScriptInput(stringData)
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
end

