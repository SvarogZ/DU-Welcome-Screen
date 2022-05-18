local screenWidth, screenHeight = getResolution()

local tableLayer = createLayer()
local buttonLayer = createLayer()


local navigationButtonFontName = "FiraMono"
local navigationButtonFontSize = screenHeight / 30
local navigationButtonFont = loadFont (navigationButtonFontName, navigationButtonFontSize)

if not buttons then		
	local ButtonClass = {}
	function ButtonClass:new(layer,locationX,locationY,switchMode,checkArea,drawPressedButton,drawReleasedButtom)
		
		local privateObj = {
			layer = layer,
			locationX = locationX or 0,
			locationY = locationY or 0,
			switchMode = switchMode or false,
			checkArea = checkArea,
			drawPressedButton = drawPressedButton,
			drawReleasedButtom = drawReleasedButtom or drawPressedButton,
			--down = false,
			pressed = false
		}
		
		function privateObj.setStatus()
			local cursorX, cursorY = getCursor()
			if privateObj.checkArea(privateObj.locationX,privateObj.locationY,cursorX,cursorY) then
				if getCursorDown() then
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
				privateObj.drawReleasedButtom(privateObj.layer,privateObj.locationX,privateObj.locationY)
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
	
	local navigationButtonWidth = screenWidth / 2.1
	local navigationButtonHeight = screenHeight / 25
	local navigationBorderRadius = screenHeight / 50
	
	local function drawNextNavigationButtonPressed(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 0.2, 0.2, 0.2, 1)
		addBoxRounded(buttonLayer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(buttonLayer, 1, 1, 1, 1)
		setNextTextAlign(buttonLayer, 1, 2)
		addText(buttonLayer, navigationButtonFont, "Next", x, y)
	end
	
	local function drawNextNavigationButtonReliased(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 0.1, 0.1, 0.1, 1)
		addBoxRounded(buttonLayer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(buttonLayer, 1, 1, 1, 1)
		setNextTextAlign(buttonLayer, 1, 2)
		addText(buttonLayer, navigationButtonFont, "Next", x, y)
	end
	
	local function drawPreviousNavigationButtonPressed(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 0.2, 0.2, 0.2, 1)
		addBoxRounded(buttonLayer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(buttonLayer, 1, 1, 1, 1)
		setNextTextAlign(buttonLayer, 1, 2)
		addText(buttonLayer, navigationButtonFont, "Previous", x, y)
	end
	
	local function drawPreviousNavigationButtonReliased(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 0.1, 0.1, 0.1, 1)
		addBoxRounded(buttonLayer, x-navigationButtonWidth/2, y-navigationButtonHeight/2, navigationButtonWidth, navigationButtonHeight, navigationBorderRadius)
		setNextFillColor(buttonLayer, 1, 1, 1, 1)
		setNextTextAlign(buttonLayer, 1, 2)
		addText(buttonLayer, navigationButtonFont, "Previous", x, y)
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
	
	local sortSize = screenHeight/100
	
	local function drawSortOn(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 1, 1, 1, 1)
		addTriangle (buttonLayer, x-sortSize, y-sortSize, x+sortSize, y-sortSize, x, y+sortSize)
	end
	
	local function drawSortOff(buttonLayer,x,y)
		setNextFillColor(buttonLayer, 0.4, 0.4, 0.4, 1)
		addTriangle (buttonLayer, x-sortSize, y-sortSize, x+sortSize, y-sortSize, x, y+sortSize)
	end
	
	local function checkAreaSortButton(x,y,xc,yc)
		local deviationX = math.abs(xc - x) - sortSize
		local deviationY = math.abs(yc - y) - sortSize
		
		if deviationX > 0 or deviationY > 0 then
			return false
		else
			return true
		end
	end
	
	buttons = {}
	buttons.next = ButtonClass:new(buttonLayer,screenWidth*0.2, screenHeight*0.975,false,checkAreaNavigationButton,drawNextNavigationButtonPressed,drawNextNavigationButtonReliased)
	buttons.previous = ButtonClass:new(buttonLayer,screenWidth*0.75, screenHeight*0.975,false,checkAreaNavigationButton,drawPreviousNavigationButtonPressed,drawPreviousNavigationButtonReliased)
	buttons.sortId = ButtonClass:new(buttonLayer,screenWidth*0.16, screenHeight*0.07,true,checkAreaSortButton,drawSortOn,drawSortOff)
	buttons.sortName = ButtonClass:new(buttonLayer,screenWidth*0.45, screenHeight*0.07,true,checkAreaSortButton,drawSortOn,drawSortOff)
	buttons.sortLastVisit = ButtonClass:new(buttonLayer,screenWidth*0.65, screenHeight*0.07,true,checkAreaSortButton,drawSortOn,drawSortOff)
	buttons.sortPreviousVisit = ButtonClass:new(buttonLayer,screenWidth*0.85, screenHeight*0.07,true,checkAreaSortButton,drawSortOn,drawSortOff)
	buttons.sortVisits = ButtonClass:new(buttonLayer,screenWidth*0.975, screenHeight*0.07,true,checkAreaSortButton,drawSortOn,drawSortOff)
end

for _,button in pairs(buttons) do
	button:update()
end

if buttons.sortId.getStatus() then
	buttons.sortName.setStatus(false)
	buttons.sortLastVisit.setStatus(false)
	buttons.sortPreviousVisit.setStatus(false)
	buttons.sortVisits.setStatus(false)
	if not counter then counter = 1 else counter = counter + 1 end
	logMessage("sortId pressed "..counter.." times")
end

if buttons.sortName.getStatus() then
	buttons.sortId.setStatus(false)
	buttons.sortLastVisit.setStatus(false)
	buttons.sortPreviousVisit.setStatus(false)
	buttons.sortVisits.setStatus(false)
	if not counter then counter = 1 else counter = counter + 1 end
	logMessage("sortName pressed "..counter.." times")
end

if buttons.sortLastVisit.getStatus() then
	buttons.sortId.setStatus(false)
	buttons.sortName.setStatus(false)
	buttons.sortPreviousVisit.setStatus(false)
	buttons.sortVisits.setStatus(false)
	if not counter then counter = 1 else counter = counter + 1 end
	logMessage("sortLastVisit pressed "..counter.." times")
end

if buttons.sortPreviousVisit.getStatus() then
	buttons.sortId.setStatus(false)
	buttons.sortName.setStatus(false)
	buttons.sortLastVisit.setStatus(false)
	buttons.sortVisits.setStatus(false)
	if not counter then counter = 1 else counter = counter + 1 end
	logMessage("sortPreviousVisit pressed "..counter.." times")
end

if buttons.sortVisits.getStatus() then
	buttons.sortId.setStatus(false)
	buttons.sortName.setStatus(false)
	buttons.sortLastVisit.setStatus(false)
	buttons.sortPreviousVisit.setStatus(false)
	if not counter then counter = 1 else counter = counter + 1 end
	logMessage("sortVisits pressed "..counter.." times")
end



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
		
		local textLines = privateObj.getTextWrapped(privateObj.font, text, width-privateObj.borderPadding*2)
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

local headingData = { {"#","ID","Name","Visit","Pre. visit","Visits"} }
local tableColumnWidthPattern = {5,12,30,20,20,13}
local tableRowHeightPattern = {}
local textAlignColumnPattern = {1}


local col_number = 6
local row_number = 10
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

local data = {	{"#","ID","Name","Last Visit","Prev. Visit","Visits"},
				{"1","123456","New Player 1","3d:03h:16m","10d:03h:16m"},
				{"2","123456","New Player 2","3d:03h:16m","10d:03h:16m"},
				{"3","123456","New Player 2","3d:03h:16m","10d:03h:16m"},
				{"4","123456","New Player 4","3d:03h:16m","10d:03h:16m"}}

tableT:draw(tableLayer, 0, 0, screenWidth, screenHeight*0.95, col_number, row_number, cellHeader, cellOddRow, cellEvenRow, data, tableColumnWidthPattern, textAlignColumnPattern, tableRowHeightPattern)


