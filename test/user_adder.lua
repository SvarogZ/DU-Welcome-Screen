local add = 100
local databank1 = slot1
--databank1.clear()


local keyListString = databank1.getKeys()
--system.print(keyListString)
local keyList = {}
if keyListString and keyListString ~= "" then
	--keyList = json.decode(keyListString)
    local replaced = keyListString:gsub('[[]', '{'):gsub('[]]', '}'):gsub('"(%w+)":', '["%1"]=')
    keyList = load('return ' .. replaced)()
end
system.print(#keyList)
table.sort(keyList, function(a,b) return tonumber(a) > tonumber(b) end)
local maxKey = tonumber(keyList[1])
--system.print("maxKey1="..maxKey)
if not maxKey then maxKey = 1 end
--system.print("maxKey2="..maxKey)

for i=1, add do
	local nextKey = maxKey + i
	local newObject = {}
	newObject[1] = nextKey
	newObject[2] = "U"..nextKey
	newObject[3] = 12345678999
	newObject[4] = 12345678999
	newObject[5] = 12345678999
	local srtingToRecord = table.concat(newObject,",")
	databank1.setStringValue(nextKey,srtingToRecord)
	--system.print("nextKey="..nextKey.." recorded")
end
