local add = 100
local maxUsersForDatabank = 600
local clearDatabanks = false

local databanks = {}

local function initiateSlots()
	for _, slot in pairs(unit) do
		if type(slot) == "table" and type(slot.export) == "table" and slot.getElementClass then
			local elementClass = slot.getElementClass():lower()
			if elementClass == "databankunit" then
				table.insert(databanks,slot)
			end
		end
	end
	
	if #databanks < 1 then
		error("No databank connected!")
	end
	
	table.sort(databanks, function (a, b) return (a.getId() < b.getId()) end)
end

initiateSlots()

if clearDatabanks then
	for _, databank in ipairs(databanks) do
		databank.clear()
	end
end

local databankToRecod
local maxKey = 100000

for _, databank in ipairs(databanks) do
	local keyListString = databank.getKeys()
	--system.print(keyListString)
	local keyList = {}
	if keyListString and keyListString ~= "" then
		local i = 1
		for c in keyListString:gmatch('%d+') do
			keyList[i] = tonumber(c)
			i = i + 1
		end
		system.print("records: ".. (i-1))
		if i-1 <= maxUsersForDatabank - add then
			databankToRecod = databank
			table.sort(keyList, function(a,b) return a > b end)
			maxKey = keyList[1] or maxKey
			break
		end
	end
end

if databankToRecod then
	for i=1, add do
		local nextKey = maxKey + i
		local newObject = {}
		newObject[1] = "U"..nextKey
		newObject[2] = 123
		newObject[3] = 123456789
		newObject[4] = 123456789
		local srtingToRecord = table.concat(newObject,",")
		databankToRecod.setStringValue(nextKey,srtingToRecord)
		--system.print("nextKey="..nextKey.." recorded")
	end
end
