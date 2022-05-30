setOutput("welcome")

local screenWidth, screenHeight = getResolution()

local background_color = {0,0,0,1}
local border_width = screenHeight / 50
local border_color = {0.5,0.5,0.5,1}
local border_spacing = screenHeight / 50
local border_radius = screenHeight / 50
local welcome_text = "Welcome, %s!"
local welcome_font_name = "FiraMono"
local welcome_font_size = screenHeight / 8
local welcome_font_color = {0.9,0.9,1,1}
local first_visit_text = "This is your first visit"
local not_first_visit_ext = "You visited us %s ago"
local time_font_name = "FiraMono"
local time_font_size = screenHeight / 12
local time_font_color = {0.9,1,0.9,1}

local welcomeFont = loadFont(welcome_font_name, welcome_font_size)
local timeFont = loadFont(time_font_name, time_font_size)

local function split(s,sep)
    local sep = sep or ","
    local result = {}
    local i = 1
    for c in s:gmatch(string.format("([^%s]+)", sep)) do
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

local function showWelcome(layer, name)
	if not name then name = "stranger" end
	local text = string.format(welcome_text, name)
	setNextTextAlign(layer, 1, 2)
	setNextFillColor(layer, welcome_font_color[1], welcome_font_color[2], welcome_font_color[3], welcome_font_color[4])
	addText(layer, welcomeFont, text, screenWidth/2, screenHeight/3)
end

local function showTime(layer, time)
	local text
	if time and type(time)=="number" then
		text = string.format(not_first_visit_ext, dateFormat(time))
	else
		text = first_visit_text
	end
	setNextTextAlign(layer, 1, 2)
	setNextFillColor(layer, time_font_color[1], time_font_color[2], time_font_color[3], time_font_color[4])
	addText(layer, timeFont, text, screenWidth/2, screenHeight*2/3)
end

local layer = createLayer()
setNextStrokeColor(layer, border_color[1], border_color[2], border_color[3], border_color[4])
setNextStrokeWidth(layer, border_width)
setNextFillColor(layer, background_color[1], background_color[2], background_color[3], background_color[4])
addBoxRounded(layer, border_spacing, border_spacing, screenWidth-2*border_spacing, screenHeight-2*border_spacing, border_radius)

local stringForm = getInput()
--logMessage("stringForm is "..stringForm)
local data = stringForm ~= "" and split(stringForm,",")

if data then
	showWelcome(layer, data[1])
	showTime(layer, data[2])
else
	showWelcome(layer)
end
