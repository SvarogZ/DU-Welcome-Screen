-- Welcome Screen info
-- Created by SvarogZ
-- 2021
--
--

unit.hide()

-------------------------------
---- BUTTON CLASS -------------
-------------------------------
local ButtonStyleClass = {}

function ButtonStyleClass:new(fontSize,fontColor,borderWidth,borderStyle,borderColor,borderRadius1,borderRadius2,backgroundColor)
	
	local privateObj = {
		fontSize = fontSize or 0, -- in vh, if "0" then adjusted automatically
		fontColor = fontColor or "#F9E79F",
		borderWidth = borderWidth or 0.5, -- in vh
		borderStyle = borderStyle or "solid", -- border-style: none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset|initial|inherit;
		borderColor = borderColor or "#D35400",
		borderRadius1 = borderRadius1 or 0, -- in vh
		borderRadius2 = borderRadius2 or 0, -- in vh
		backgroundColor = backgroundColor or "#2E4053"
	}
	
	local publicObj = {}
	
	publicObj.buttonStyle = [[border-width:]]..privateObj.borderWidth..[[vh ]]..privateObj.borderWidth..[[vw;border-style:]]..privateObj.borderStyle..[[;border-color:]]..privateObj.borderColor..[[;border-radius:]]..privateObj.borderRadius1..[[vh ]]..privateObj.borderRadius2..[[vh;background-color:]]..privateObj.backgroundColor..[[;color:]]..privateObj.fontColor..[[;]]
	
	function publicObj:getStyle(defFontSize)
		local fontSize = defFontSize or 1
		if privateObj.fontSize ~= 0 then
			fontSize = privateObj.fontSize
		end
		
		return publicObj.buttonStyle..[[font-size:]]..fontSize..[[vh;]]
	end

	-- don't delete this
	self.__index = self
	return setmetatable(publicObj, self)
end


local ButtonClass = {}

function ButtonClass:new(screen,x1,y1,x2,y2,functionCall,callBackId,text,buttonNoneActiveStyle,buttonActiveStyle,svgIcon)

	local privateObj = {
		contentId = nil,
		screen = screen or error ("screen must be specified"),
		x1 = x1 or 0,
		y1 = y1 or 0,
		x2 = x2 or 0,
		y2 = y2 or 0,
		text = text or "",
		functionCall = functionCall or error ("function must be specified"),
		callBackId = callBackId,
		buttonNoneActiveStyle = buttonNoneActiveStyle or error ("buttonNoneActiveStyle must be specified"),
		buttonActiveStyle = buttonActiveStyle or error ("buttonActiveStyle must be specified"),
		svgIcon = svgIcon,
		isActive = false
	}

	local function getContent(isPressed)
		local buttonStyle = ""
		if isPressed then
			borderStyle = privateObj.buttonActiveStyle:getStyle((privateObj.y2 - privateObj.y1)/2)
		else
			borderStyle = privateObj.buttonNoneActiveStyle:getStyle((privateObj.y2 - privateObj.y1)/2)
		end

		return [[<div style="width:]]..(privateObj.x2 - privateObj.x1)..[[vw;height:]]..(privateObj.y2 - privateObj.y1)..[[vh;display:flex;justify-content:center;align-items:center;]]..borderStyle..[[">]]..privateObj.text..[[</div>]]		
	end
	
	local function redraw()
		if privateObj.contentId then
			if privateObj.isActive then
				privateObj.screen.resetContent(privateObj.contentId,getContent(true))
			else
				privateObj.screen.resetContent(privateObj.contentId,getContent(false))
			end
		end
	end

	local publicObj = {}

	function publicObj:update(x,y)
		if x > privateObj.x1 and x < privateObj.x2 and y > privateObj.y1 and y < privateObj.y2 then
			if not privateObj.isActive then
				privateObj.isActive = true
				redraw()
			end
			privateObj.functionCall(privateObj.callBackId)
		else
			if privateObj.isActive then
				privateObj.isActive = false
				redraw()
			end
		end
	end

	function publicObj:draw()
		if not privateObj.contentId then
			privateObj.contentId = privateObj.screen.addContent(privateObj.x1,privateObj.y1,getContent(false))
		else
			redraw()
		end
	end

	-- [[ functions below can be deleted if not required
	function publicObj:hide()
		privateObj.screen.showContent(privateObj.contentId, 0)
	end

	function publicObj:show()
		privateObj.screen.showContent(privateObj.contentId, 1)
	end

	function publicObj:isActive()
		return privateObj.isActive
	end

	function publicObj:press()
		privateObj.isActive = true
		redraw()
	end

	function publicObj:release()
		privateObj.isActive = false
		redraw()
	end

	function publicObj:toggle()
		privateObj.isActive = not privateObj.isActive
		redraw()
	end

	function publicObj:changeColors(borderColor,backgroundColor)
		if borderColor then privateObj.borderColor = borderColor end
		if backgroundColor then privateObj.backgroundColor = backgroundColor end
		redraw()
	end

	function publicObj:getContentId()
		return privateObj.contentId
	end

	function publicObj:getCallBackId()
		return privateObj.callBackId
	end

	function publicObj:setCallBackId(callBackId)
		privateObj.callBackId = callBackId
	end

	function publicObj:setText(text)
		privateObj.text = text
	end

	function publicObj:getArea()
		return privateObj.x1,privateObj.y1,privateObj.x2,privateObj.y2
	end

	function publicObj:moveTo(x,y)
		privateObj.screen.moveContent(privateObj.contentId,x,y)
	end

	function publicObj:setSize(x,y)
		privateObj.x2 = privateObj.x1 + x
		privateObj.y2 = privateObj.y1 + y
		redraw()
	end

	function publicObj:assignFunction(newFunction)
		privateObj.functionCall = newFunction
	end

	function publicObj:moveToScreen(newScreen)
		if type(newScreen) == "table" and type(newScreen.getElementClass) == "function" then -- TODO add check for screen - newScreen.getElementClass() == "ScreenUnit?"
			privateObj.screen.deleteContent(privateObj.contentId)
			privateObj.contentId = nil
			privateObj.screen = newScreen
			self:draw()
		end
	end
	-- functions above can be deleted if not required ]]

	-- don't delete this
	self.__index = self
	return setmetatable(publicObj, self)
end

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

local welcomeScreenSlot = screens[1]
welcomeScreenSlot.clear()

local statisticScreenSlot = screens[2]
if not statisticScreenSlot then
	system.print("Statistic screen (second) is not connected")
else
	statisticScreenSlot.clear()
end

local databankSlot = databanks[1]
--databankSlot.clear()

-------------------------------
---- WELCOME SCREEN -----------
-------------------------------
local masterPlayerId = unit.getMasterPlayerId()
local masterPlayerName = system.getPlayerName(masterPlayerId)
local visitTime = system.getTime()

local usersString = databankSlot.getStringValue("users") or error ("key 'users' is not found in the databank")
local users = json.decode(usersString) or {}

local user = {}
local userKey = 0

for key, playerObject in ipairs(users) do
	if playerObject.id == masterPlayerId then
		user = playerObject
		userKey = key	
		break
	end
end

if not user.id then
	user.id = masterPlayerId
	user.name = masterPlayerName
	user.counter = 1
	table.insert(users,user)
	userKey = #users
end

local timeout = 3600 --export: timeout for the counter in seconds

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

users[userKey] = user
-- record to the databank
databankSlot.setStringValue("users",json.encode(users))

local durationString = "This is your first visit"

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

if previousVisit then
	durationString = "You visited us "..dateFormat(visitTime - previousVisit).." ago"
end

local welcomeColor = "#ffffff" --export: Welcome screen: "Welcome" color
local nameColor = "#ffffff" --export: Welcome screen: masterPlayerName color
local infoColor = "#ffffff" --export: Welcome screen: Info text color

local htmlWelcomScreen = [[<table style="height: 100%;width: 100%;text-align: center;">
	<tr><td style="color: ]]..welcomeColor..[[;font-size: 20vh;">Welcome</td></tr>
	<tr><td style="color: ]]..nameColor..[[;font-size: 30vh;">]]..masterPlayerName..[[</td></tr>
	<tr><td style="color: ]]..infoColor..[[;font-size: 10vh;">]]..durationString..[[</td></tr>
</table>]]

welcomeScreenSlot.setHTML(htmlWelcomScreen)

-------------------------------
---- STATISTIC SCREEN ---------
-------------------------------
buttonPanel = {} -- forward declaration

if statisticScreenSlot then

	local numberRecords = #users

	table.sort(users, function(a, b) return a.time > b.time end)

	local tableColor = "#000000" --export: Statistic screen: table background color
	local textColor = "#FCFFA6" --export: Statistic screen: table text color
	local headColor = "#000000"  --export: Statistic screen: head background color
	local numLinesToShow = 10

	currentList = 1 -- global

	local function showStaticticTable()
		
		local tableHeight = 90
		local recordsLeft = numberRecords - (currentList-1)*numLinesToShow
		if recordsLeft < numLinesToShow then tableHeight = tableHeight/numLinesToShow*recordsLeft end
		
		local htmlStaticticTable = {}
		table.insert(htmlStaticticTable,[[<table style="width:100vw;height:]]..tableHeight..[[vh;text-align:center;font-size: 5vh;background-color: ]]..tableColor..[[;color: ]]..textColor..[[;">
	<tr style="background-color: ]]..headColor..[[;">
	<th>#</th>
	<th>ID</th>
	<th>Name</th>
	<th>Visit</th>
	<th>Pre. visit</th>
	<th>Visits</th>
	</tr>]])
		
		local firstLine = (currentList - 1) * 10 + 1
		local lastLine = firstLine + numLinesToShow - 1
		if lastLine > numberRecords then lastLine = numberRecords end

		for i=firstLine,lastLine do
			local playerObject = users[i]	
			local lastVisit = ""
			if playerObject.lastTime then
				lastVisit = dateFormat(visitTime - playerObject.lastTime)
			end
			local lineColor1 = "#525252" --export: Statistic screen: odd line color #839192
			local lineColor2 = "#3B3B3B" --export: Statistic screen: even line color #717D7E
			local backgroundColor = lineColor1
			if i%2 < 0.1 then
				backgroundColor = lineColor2
			end
			
			table.insert(htmlStaticticTable,[[
	<tr style="background-color:]]..backgroundColor..[[;">
		<td>]]..i..[[</td>
		<td>]]..playerObject.id..[[</td>
		<td>]]..playerObject.name..[[</td>
		<td>]]..dateFormat(visitTime - playerObject.time)..[[</td>
		<td>]]..lastVisit..[[</td>
		<td>]]..playerObject.counter..[[</td>
	</tr>
]])
		end
		
		if not statisticTableId then
			statisticTableId = statisticScreenSlot.addContent(0,0,table.concat(htmlStaticticTable) .. [[</table>]])
		else
			statisticScreenSlot.resetContent(statisticTableId,table.concat(htmlStaticticTable) .. [[</table>]])
		end	
	end

	showStaticticTable()

	--ButtonStyleClass:new(fontSize,fontColor,borderWidth,borderStyle,borderColor,borderRadius1,borderRadius2,backgroundColor)
	local buttonStyleOutset = ButtonStyleClass:new(0,nil,nil,nil,nil,2,2,nil)
	local buttonStyleInset = ButtonStyleClass:new(0,nil,1,nil,"#A93226",2,2,"#07006C")

	local function updateButtonPanel()
		local numberOfButtons = (numberRecords -1)//numLinesToShow + 1
		if numberOfButtons < 7 then return end

		local buttonShift = 0
		if currentList > 4 then
			if currentList < numberOfButtons - 3 then
				buttonShift = currentList - 4
			else
				buttonShift = numberOfButtons - 7
			end
		end

		for _,button in pairs(buttonPanel) do
			local contentId = button:getCallBackId()
			if contentId ~= "prev." and contentId ~= "next" then
				buttonShift = buttonShift + 1
				button:setCallBackId(buttonShift)
				button:setText(buttonShift)
			end
		end
	end

	local function callButton(callBackId)

		if callBackId == "prev." then
			if currentList > 1 then currentList = currentList - 1 end
		elseif callBackId == "next" then
			if numberRecords - currentList * numLinesToShow > 0 then
				currentList = currentList + 1
			end
		elseif type(callBackId) == 'number' then
			currentList = callBackId
		end
		
		showStaticticTable()
		updateButtonPanel()
	end

	--ButtonClass:new(screen,x1,y1,x2,y2,functionCall,text,buttonNoneActiveStyle,buttonActiveStyle,svgIcon)
	buttonPanel["prev."] = ButtonClass:new(statisticScreenSlot,5,90,15,100,callButton,"prev.","prev.",buttonStyleOutset,buttonStyleOutset)
	buttonPanel["prev."]:draw()

	local numberOfButtons = numberRecords//numLinesToShow + 1
	if numberOfButtons > 7 then numberOfButtons = 7 end
	local buttonwidth = 70 / 7

	for n = 1,numberOfButtons,1 do
		buttonPanel[n] = ButtonClass:new(statisticScreenSlot,5+n*buttonwidth,90,15+n*buttonwidth,100,callButton,n,n,buttonStyleOutset,buttonStyleInset)
		buttonPanel[n]:draw()
	end

	buttonPanel["next"] = ButtonClass:new(statisticScreenSlot,85,90,95,100,callButton,"next","next",buttonStyleOutset,buttonStyleOutset)
	buttonPanel["next"]:draw()

	buttonPanel[1]:press()
end


-------------------------------
---- SCREEN EVENT -------------
-------------------------------
--mouseDown(*,*) event --------
-------------------------------
local xs = x*100
local ys = y*100

--check clickable zone
if xs > 5 and ys > 90 and xs < 95 then
	-- perform button command
	for _,button in pairs(buttonPanel) do
		button:update(xs,ys)
	end
	
	-- update visual status for all buttons
	for _,button in pairs(buttonPanel) do
		local callBackId = button:getCallBackId()
		if type(callBackId) == 'number' and callBackId == currentList then
			button:press()
		else
			button:release()
		end
	end
end
