local databank1 = slot1
local databank2 = slot2

local keyListString = databank1.getKeys()
local keyList = {}
if keyListString and keyListString ~= "" then
	local i = 1
	for c in keyListString:gmatch('%d+') do
		keyList[i] = tonumber(c)
		i = i + 1
	end
end

local i = 1
for _, id in ipairs(keyList) do
	if tonumber(id) then
		local userObjectString = databank1.getStringValue(id)
		if userObjectString and userObjectString ~= "" then
			local userObject = json.decode(userObjectString)
			local newObject = {}
			newObject[1] = userObject.name or "Unknown"
			newObject[2] = userObject.counter or 0
			newObject[3] = userObject.time and math.floor(userObject.time) or 0
			newObject[4] = userObject.lastTime and math.floor(userObject.lastTime) or newObject[3]
			local srtingToRecord = table.concat(newObject,",")
			databank2.setStringValue(id,srtingToRecord)
		end
	end
	i = i+1
end
