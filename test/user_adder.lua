local add = 1
local databank1 = slot1

local keyListString = databank1.getKeys()
system.print(keyListString)
local keyList = {}
if keyListString and keyListString ~= "" then
	keyList = json.decode(keyListString)
end

table.sort(keyList, function(a,b) return a > b end)
local maxKey = keyList[1]
if maxKey < 100000 then maxKey = 100000 end

for i=1, add do
	local nextKey = maxKey + i
	local newObject = {}
	newObject[1] = nextKey
	newObject[2] = "U"..nextKey
	newObject[3] = 0
	newObject[4] = 0
	newObject[5] = 0
	local srtingToRecord = table.concat(newObject,",")
	databank1.setStringValue(nextKey,srtingToRecord)
end
