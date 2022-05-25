local databank1 = Slot1
local databank2 = Slot2

local keyListString = databank1.getKeys()
local keyList = {}
if keyListString and keyListString ~= "" then
	keyList = json.decode(keyListString)
end

for _, id in ipairs(keyList) do
	local userObjectString = databankSlot.getStringValue(id)
	if userObjectString and userObjectString ~= "" then
		local userObject = json.decode(userObjectString)
		local newObject = {}
		newObject[1] = id
		newObject[2] = userObject.name or "Unknown"
		newObject[3] = math.floor(userObject.time) or 0
		newObject[4] = math.floor(userObject.lastTime) or newObject[3]
		newObject[5] = userObject.counter or 0
		local srtingToRecord = table.concat(newObject,","))
		databank2.setStringValue(id,srtingToRecord)
	end
end
