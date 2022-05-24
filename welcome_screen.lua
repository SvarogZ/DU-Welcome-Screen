local json = require "dkjson"
local stringForm = getInput()
local data = json.decode(stringForm)

local stringToShow = "Welcome"
if data[1] then
	stringToShow = stringToShow .. ", " .. data[1] .. "!"
end

if data[2] then
	local function dateFormat(t)
		local t = type(t)=='number' and t>0 and t or 0
		local text = ""
		
		local day = math.floor(t/86400)
		t = t%(24*3600)
		local hour = math.floor(t/3600)
		t = t%3600
		local minute = math.floor(t/60)
		t = t%60
		local second = math.floor(t)

		if day > 0 then text = day.."d:" end
		if day > 0 or hour > 0 then text = text..hour.."h:" end

		return text..minute.."m"
	end

	stringToShow = stringToShow .. "\n\n You visited us\n" .. dateFormat(data[2]) .. " ago."
else
	stringToShow = stringToShow .. "\n\n This is your first visit."
end



local rslib = require('rslib')
local config = { fontSize = 80 }
rslib.drawQuickText(stringToShow, config)
