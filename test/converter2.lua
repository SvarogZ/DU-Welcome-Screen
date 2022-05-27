local databank1 = slot1
local databank2 = slot2

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

local keyListString = databank1.getKeys()
local keyList = {}
if keyListString and keyListString ~= "" then
	keyList = keyListString:gsub([[([%[%]"])]],""):split(",")
end

local i = 1
for _, id in ipairs(keyList) do
	if tonumber(id) then
		local userObjectString = databank1.getStringValue(id)
		if userObjectString and userObjectString ~= "" then
			local userObject = userObjectString:split(",")
			local newObject = {}
			newObject[1] = userObject[5]
			newObject[2] = userObject[3]
			newObject[3] = userObject[4]
			local srtingToRecord = table.concat(newObject,",")
			databank2.setStringValue(id,srtingToRecord)
		end
	end
	i = i+1
end
