setOutput("statistic")

local col_number = 6
local row_number = 11
local header = {"#","Id","Name","Visit","Prev. Visit","Visits"}


local screenWidth, screenHeight = getResolution()

local tableLayer = createLayer()
local controlLayer = createLayer()


local navigationButtonFontName = "FiraMono"
local navigationButtonFontSize = screenHeight / 30
local navigationButtonFont = loadFont (navigationButtonFontName, navigationButtonFontSize)

if not control then		
	local ButtonClass = {}
	function ButtonClass:new(layer,locationX,locationY,switchMode,checkArea,drawPressedButton,drawReleasedButton)
		
		local privateObj = {
			layer = layer,
			locationX = locationX or 0,
			locationY = locationY or 0,
			switchMode = switchMode or false,
			checkArea = checkArea,
			drawPressedButton = drawPressedButton,
			drawReleasedButton = drawReleasedButton or drawPressedButton,
			--down = false,
			pressed = false
		}
		
		function privateObj.setStatus()
			if getCursorDown() then
				local cursorX, cursorY = getCursor()
				if privateObj.checkArea(privateObj.locationX,privateObj.locationY,cursorX,cursorY) then
					if privateObj.switchMode then
						if privateObj.pressed then
							privateObj.pressed = false
						else
							privateObj.pressed = true
						end
					else
						privateObj.pressed = true
					end
				end
			end

			if getCursorReleased() then
				if not privateObj.switchMode then
					privateObj.pressed = false
				end
			end
		end
		
		local publicObj = {}
		
		function publicObj:update()
			privateObj.setStatus()
			if privateObj.pressed then
				privateObj.drawPressedButton(privateObj.layer,privateObj.locationX,privateObj.locationY)
			else
				privateObj.drawReleasedButton(privateObj.layer,privateObj.locationX,privateObj.locationY)
			end
		end
		
		function publicObj:getStatus()
			return privateObj.pressed
		end
		
		function publicObj:setStatus(status)
			privateObj.pressed = status
		end

		-- don't delete this
		self.__index = self
		return setmetatable(publicObj, self)
	end
	
	local SelectorClass = {}
	function SelectorClass:new(layer,locations,checkArea,drawEnabledSelector,drawDisabledSelector)
		
		local privateObj = {
			layer = layer,
			locations = locations or {},
			checkArea = checkArea,
			drawEnabledSelector = drawEnabledSelector,
			drawDisabledSelector = drawDisabledSelector or drawEnabledSelector
		}
		
		privateObj.status = {}
		for i = 1,#privateObj.locations do
			table.insert(privateObj.status,false)
		end
		
		function privateObj.setSelector(n)
			for i = 1,#privateObj.status do
				if i == n then
					privateObj.status[i] = true
				else
					privateObj.status[i] = false
				end
			end
		end
		
		function privateObj.setStatus()
			if not getCursorDown() then return end
			
			local cursorX, cursorY = getCursor()
			
			local activatedSelectorNumber
			for i,location in ipairs(privateObj.locations) do
				if privateObj.checkArea(location[1],location[2],cursorX,cursorY) then
					activatedSelectorNumber = i
					break
				end
			end
			
			if activatedSelectorNumber then
				privateObj.setSelector(activatedSelectorNumber)
			end
		end
			
		local publicObj = {}
		
		function publicObj:update()
			privateObj.setStatus()
			for i,location in ipairs(privateObj.locations) do
				if privateObj.status[i] then
					privateObj.drawEnabledSelector(privateObj.layer,location[1],location[2])
				else
					privateObj.drawDisabledSelector(privateObj.layer,location[1],location[2])
				end
			end
		end
		
		function publicObj:getSelector()
			for i,status in ipairs(privateObj.status) do
				if status then
					return i
				end
			end
			return 0
		end
		
		function publicObj:setSelector(n)
			privateObj.setSelector(n)
		end

		-- don't delete this
		self.__index = self
		return setmetatable(publicObj, self)
	end
	
	local navigationButtonWidth = screenWidth / 2.2
	local navigationButtonHeight = screenHeight / 25
	local navigationBorderRadius = screenHeight / 50
	
	local function drawNextNavigationButtonPressed(layer,x,y)
		setNextFillColor(layer, 0.2, 0.2, 0.2, 1)
		addBoxRounded(layer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(layer, 1, 1, 1, 1)
		setNextTextAlign(layer, 1, 2)
		addText(layer, navigationButtonFont, "Next", x, y)
	end
	
	local function drawNextNavigationButtonReliased(layer,x,y)
		setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
		addBoxRounded(layer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(layer, 1, 1, 1, 1)
		setNextTextAlign(layer, 1, 2)
		addText(layer, navigationButtonFont, "Next", x, y)
	end
	
	local function drawPreviousNavigationButtonPressed(layer,x,y)
		setNextFillColor(layer, 0.2, 0.2, 0.2, 1)
		addBoxRounded(layer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(layer, 1, 1, 1, 1)
		setNextTextAlign(layer, 1, 2)
		addText(layer, navigationButtonFont, "Previous", x, y)
	end
	
	local function drawPreviousNavigationButtonReliased(layer,x,y)
		setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
		addBoxRounded(layer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(layer, 1, 1, 1, 1)
		setNextTextAlign(layer, 1, 2)
		addText(layer, navigationButtonFont, "Previous", x, y)
	end
	
	local function checkAreaNavigationButton(x,y,xc,yc)
		local deviationX = math.abs(xc - x) - navigationButtonWidth/2
		local deviationY = math.abs(yc - y) - navigationButtonHeight/2
		
		if deviationX > 0 or deviationY > 0 then
			return false
		else
			return true
		end
	end
	
	control = {}
	control.buttonNext = ButtonClass:new(controlLayer,screenWidth*0.75, screenHeight*0.975,false,checkAreaNavigationButton,drawNextNavigationButtonPressed,drawNextNavigationButtonReliased)
	control.buttonPrevious = ButtonClass:new(controlLayer,screenWidth*0.25, screenHeight*0.975,false,checkAreaNavigationButton,drawPreviousNavigationButtonPressed,drawPreviousNavigationButtonReliased)
	
	local sortMarkSize = screenHeight/100
	
	local function drawSortOn(layer,x,y)
		setNextFillColor(layer, 1, 1, 1, 1)
		addTriangle (layer, x-sortMarkSize, y-sortMarkSize, x+sortMarkSize, y-sortMarkSize, x, y+sortMarkSize)
	end
	
	local function drawSortOff(layer,x,y)
		setNextFillColor(layer, 0.4, 0.4, 0.4, 1)
		addTriangle (layer, x-sortMarkSize, y-sortMarkSize, x+sortMarkSize, y-sortMarkSize, x, y+sortMarkSize)
	end
	
	local function checkAreaSortSelector(x,y,xc,yc)
		local deviationX = math.abs(xc - x) - sortMarkSize * 2
		local deviationY = math.abs(yc - y) - sortMarkSize * 2
		
		if deviationX > 0 or deviationY > 0 then
			return false
		else
			return true
		end
	end
	
	local locations = {
		{screenWidth*0.16, screenHeight*0.07},
		{screenWidth*0.45, screenHeight*0.07},
		{screenWidth*0.65, screenHeight*0.07},
		{screenWidth*0.85, screenHeight*0.07},
		{screenWidth*0.975, screenHeight*0.07}
	}
	control.selectorSort = SelectorClass:new(controlLayer,locations,checkAreaSortSelector,drawSortOn,drawSortOff)
	selector = 3
	dataSorted = false
	control.selectorSort:setSelector(selector)
	page = 1
	pageLimit = 1
	dataVersion = 0
end

for _,item in pairs(control) do
	item.update()
end

if control.buttonNext.getStatus() then
	page = page + 1
	if page > pageLimit then page = 1 end
	--logMessage("buttonNext pressed")
end

if control.buttonPrevious.getStatus() then
	page = page - 1
	if page < 1 then page = pageLimit end
	--logMessage("buttonPrevious pressed")
end

if control.selectorSort.getSelector() ~= selector then
	selector = control.selectorSort.getSelector()
	dataSorted = false
	--logMessage("sort "..control.selectorSort.getSelector().." selected")
end

local DataClass = {}
function DataClass:new(startPattern,stopPattern)
	
	local privateObj = {
		startPattern = startPattern or "[s]",
		stopPattern = stopPattern or "[e]",
		data = {},
		finalString = "",
		isRecordingInProcess = false,
		isDataUpdated = true,
		sortColumn = 1,
		dataVersion = 0
	}
	
	function privateObj:sort()
		table.sort(privateObj.data, function (a, b) return (a[privateObj.sortColumn] < b[privateObj.sortColumn]) end)
	end
	
	local publicObj = {}
	
	function publicObj:update(newString)
		if not newString then return end
	
		if string.sub(newString,1,#privateObj.startPattern) == privateObj.startPattern then
			privateObj.finalString = string.sub(newString,#privateObj.startPattern+1)
			privateObj.isRecordingInProcess = true
			--logMessage("start record")
			--logMessage(privateObj.finalString)
		elseif privateObj.isRecordingInProcess then
			privateObj.finalString = privateObj.finalString .. newString
			--logMessage("add record")
			--logMessage(privateObj.finalString)
		end
		
		if privateObj.isRecordingInProcess and string.sub(newString, -#privateObj.stopPattern) == privateObj.stopPattern then
			privateObj.finalString = string.sub(privateObj.finalString,1,-#privateObj.stopPattern-1)
			privateObj.isRecordingInProcess = false
			privateObj.isDataUpdated = false
			--logMessage("cut end")
		end
		
		if not privateObj.isDataUpdated then
			--logMessage(privateObj.finalString)
			local json = require "dkjson"
			privateObj.data = json.decode(privateObj.finalString)
			privateObj:sort()
			privateObj.isDataUpdated = true
			privateObj.dataVersion = privateObj.dataVersion + 1
		end
	end
	
	function publicObj:sort(column)
		if column then
			privateObj.sortColumn = column
			privateObj:sort()
		end
	end
	
	function publicObj:getData()
		return privateObj.data
	end
	
	function publicObj:getStatus()
		return not privateObj.isRecordingInProcess
	end
	
	function publicObj:getVersion()
		return not privateObj.dataVersion
	end
	
	-- don't delete this
	self.__index = self
	return setmetatable(publicObj, self)
end

if not dataFromPB then
	dataFromPB = DataClass:new("[s]","[e]")
end

local stringForm = getInput()
dataFromPB:update(stringForm)
local data = dataFromPB:getData()
pageLimit = math.floor(#data / row_number) + 1
if not dataSorted then
	dataFromPB:sort(selector)
	dataSorted = true
end

local function getProcessedData(data,rowsToShow,page,header)
	local dataSize = #data
	local firstRow = (page -1) * rowsToShow + 1
	if firstRow > dataSize then
		page = page - 1
		if page < 1 then page = 1 end
		firstRow = (page -1) * rowsToShow + 1
	end
	local lastRow = page * rowsToShow
	if lastRow > dataSize then lastRow = dataSize end
	
	--logMessage("rowsToShow="..rowsToShow)
	--logMessage("page="..page)
	--logMessage("firstRow="..firstRow)
	--logMessage("lastRow="..lastRow)
	
	local processedData = {}
	
	if header and type(header) == "table" then
		table.insert(processedData,header)
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
	
	local k = firstRow
	for i = firstRow, lastRow do
		local row = {k}
		local dataRow = data[i] or {}
		for n,item in ipairs(dataRow) do
			if n == 3 or n == 4 then
				item = dateFormat(item)
			end
			table.insert(row,item)
		end
		table.insert(processedData,row)
		k = k + 1
	end
	
	return processedData
end


local dataPage = getProcessedData(data,row_number-1,page,header)


local TableClass = {}
function TableClass:new(backgroundColor,borderWidth,borderColor,borderSpacing,borderPadding,borderRadius)
	
	local privateObj = {
		backgroundColor = backgroundColor or {0,0,0,1},
		borderWidth = borderWidth or 1,
		borderColor = borderColor or {1,1,1,1},
		borderSpacing = borderSpacing or 5,
		borderPadding = borderPadding or 5,
		borderRadius = borderRadius or 0
	}
	
	function privateObj.getFormPattern(pattern,i)
		if pattern and #pattern > 0 and i and i > 0 then
			return pattern[(i-1) % #pattern + 1]
		end
		
		return nil
	end
	
	local publicObj = {}
	
	function publicObj:draw(layer, x, y, width, height, column, row, cellHeader, cellOddRow, cellEvenRow, data, columnPattern, textAlignPattern, rowPattern)
		local x = x + privateObj.borderSpacing
		local y = y + privateObj.borderSpacing
		local width = width - 2 * privateObj.borderSpacing
		local height = height - 2 * privateObj.borderSpacing
		
		setNextFillColor(layer, privateObj.backgroundColor[1], privateObj.backgroundColor[2], privateObj.backgroundColor[3], privateObj.backgroundColor[4])
		setNextStrokeColor(layer, privateObj.borderColor[1], privateObj.borderColor[2], privateObj.borderColor[3], privateObj.borderColor[4])
		setNextStrokeWidth(layer, privateObj.borderWidth)
				
		addBoxRounded(layer, x, y, width, height, privateObj.borderRadius)
		
		x = x + privateObj.borderPadding
		y = y + privateObj.borderPadding
		width = width - 2 * privateObj.borderPadding
		height = height - 2 * privateObj.borderPadding
		
		local cellWidth = width / column
		local cellHeight = height / row
		
		local heightUsed = 0
		for i = 0,row - 1 do
			local cellHeightPercent = privateObj.getFormPattern(rowPattern,i+1)
			local cellHeight = cellHeightPercent and height * cellHeightPercent / 100 or cellHeight
			
			local cell = cellOddRow
			if i == 0 then
				cell = cellHeader
			elseif (i+1) % 2 == 0 then
				cell = cellEvenRow
			end			
			
			local widthUsed = 0
			for j = 0, column - 1 do
				local cellWidthPercent = privateObj.getFormPattern(columnPattern,j+1) 
				local cellWidth = cellWidthPercent and width * cellWidthPercent / 100 or cellWidth
				local textAlign = privateObj.getFormPattern(textAlignPattern,j+1) or 0
				
				local text = data and data[i+1] and data[i+1][j+1] or ""
				cell:draw(layer, x+widthUsed, y+heightUsed, cellWidth, cellHeight, text, textAlign)
				widthUsed = widthUsed + cellWidth
			end
			heightUsed = heightUsed + cellHeight
		end
	end

	-- don't delete this
	self.__index = self
	return setmetatable(publicObj, self)
end

local CellClass = {}
function CellClass:new(font,fontColor,backgroundColor,borderWidth,borderColor,borderSpacing,borderPadding,borderRadius)
	
	local privateObj = {
		font = font,
		fontColor = fontColor or {1,1,1,1},
		backgroundColor = backgroundColor or {0,0,0,1},
		borderWidth = borderWidth or 1,
		borderColor = borderColor or {1,1,1,1},
		borderSpacing = borderSpacing or 5,
		borderPadding = borderPadding or 5,
		borderRadius = borderRadius or 0
	}
	
	function privateObj.getTextWrapped(font, text, maxWidth)
		local out, line, lineW = {}, {}, 0
		for p in text:gmatch("([^\n]*)\n?") do
			out[#out+1] = {}
			for w in p:gmatch("%S+") do
				line = out[#out]
				local word = #line==0 and w or ' '..w
				local wordW, wordH = getTextBounds(font, word)
				if lineW + wordW < maxWidth then
					line[#line+1] = word
					lineW = lineW + wordW
				else
					out[#out] = table.concat(line)
					out[#out+1] = {w}
					lineW = getTextBounds(font, w)
					line = nil
				end
			end
			out[#out] = table.concat(out[#out])
			lineW = 0
		end
		return out
	end
	
	local publicObj = {}
	
	function publicObj:draw(layer, x, y, width, height, text, textAlign)
		local x = x + privateObj.borderSpacing
		local y = y + privateObj.borderSpacing
		local width = width - 2 * privateObj.borderSpacing
		local height = height - 2 * privateObj.borderSpacing
		
		setNextFillColor(layer, privateObj.backgroundColor[1], privateObj.backgroundColor[2], privateObj.backgroundColor[3], privateObj.backgroundColor[4])
		setNextStrokeColor(layer, privateObj.borderColor[1], privateObj.borderColor[2], privateObj.borderColor[3], privateObj.borderColor[4])
		setNextStrokeWidth(layer, privateObj.borderWidth)
				
		addBoxRounded(layer, x, y, width, height, privateObj.borderRadius)
		
		local textLines = privateObj.getTextWrapped(privateObj.font, tostring(text), width-privateObj.borderPadding*2)
		local lineVerticalShift = (height)/(1+#textLines)
		
		local textX = x + privateObj.borderPadding + textAlign * (width - privateObj.borderPadding) / 2
		
		for i,textLine in ipairs(textLines) do
			setNextFillColor(layer, privateObj.fontColor[1], privateObj.fontColor[2], privateObj.fontColor[3], privateObj.fontColor[4])
			setNextTextAlign(layer, textAlign, 2)
			addText(layer, privateObj.font, textLine, textX, y+i*lineVerticalShift)
		end
	end

	-- don't delete this
	self.__index = self
	return setmetatable(publicObj, self)
end

local tableColumnWidthPattern = {5,12,30,20,20,13}
local tableRowHeightPattern = {}
local textAlignColumnPattern = {1}

local font_name = "FiraMono"
local font_size = screenHeight / 30
local font_color = {1,1,1,1}
local table_color = {0,0,0,1}
local table_border_width = screenHeight / 50
local table_border_color = {0.5,0.5,0.5,1}
local table_border_spacing = screenHeight / 50
local table_border_padding = 0
local table_border_radius = 0
local cell_color_odd_row = {0.2,0.2,0.2,1}
local cell_color_even_row = {0.25,0.25,0.25,1}
local cell_color_header = {0.1,0.1,0.1,1}
local cell_border_width = screenHeight / 400
local cell_border_color = {0,0,0,1}
local cell_border_spacing = 0
local cell_border_padding = screenHeight / 100
local cell_border_radius = 0

local font = loadFont (font_name, font_size)

local tableT = TableClass:new(table_color,table_border_width,table_border_color,table_border_spacing,table_border_padding,table_border_radius)
local cellOddRow = CellClass:new(font,font_color,cell_color_odd_row,cell_border_width,cell_border_color,cell_border_spacing,cell_border_padding,cell_border_radius)
local cellEvenRow = CellClass:new(font,font_color,cell_color_even_row,cell_border_width,cell_border_color,cell_border_spacing,cell_border_padding,cell_border_radius)
local cellHeader = CellClass:new(font,font_color,cell_color_header,cell_border_width,cell_border_color,cell_border_spacing,cell_border_padding,cell_border_radius)

tableT:draw(tableLayer, 0, 0, screenWidth, screenHeight*0.95, col_number, row_number, cellHeader, cellOddRow, cellEvenRow, dataPage, tableColumnWidthPattern, textAlignColumnPattern, tableRowHeightPattern)

