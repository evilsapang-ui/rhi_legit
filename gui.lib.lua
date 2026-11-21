local Gui = {}
Gui.__index = Gui
local Container = {}
Container.__index = Container
local TabBar = {}
TabBar.__index = TabBar

local WINDOW_WIDTH = 500
local WINDOW_PADDING = 8
local FRAME_HEIGHT = 19
local ITEM_SPACING = 4
local SLIDER_RATIO = 0.6
local GRAB_WIDTH = 10
local FONT = Enum.Font.Code
local FONT_SIZE = 14

local userInputService = game:GetService("UserInputService")
local coreGuiService = game:GetService("CoreGui")

local function buildTheme(accent, titleAccent, windowBg, text, border, overrides)
	local black = Color3.new(0, 0, 0)

	local theme = {
		text = text,
		textDisabled = windowBg:Lerp(text, 0.5),
		windowBg = windowBg,
		border = windowBg:Lerp(border, 0.5),
		frameBg = windowBg:Lerp(titleAccent, 0.54),
		frameBgHovered = windowBg:Lerp(accent, 0.4),
		frameBgActive = windowBg:Lerp(accent, 0.67),
		titleBgActive = titleAccent,
		menuBarBg = windowBg:Lerp(text, 0.1),
		checkMark = accent,
		sliderGrab = accent:Lerp(black, 0.1),
		sliderGrabActive = accent,
		button = windowBg:Lerp(accent, 0.4),
		buttonHovered = accent,
		buttonActive = accent:Lerp(black, 0.15),
		header = windowBg:Lerp(accent, 0.31),
		headerHovered = windowBg:Lerp(accent, 0.8),
		headerActive = accent,
		tab = windowBg:Lerp(titleAccent, 0.8),
		tabHovered = windowBg:Lerp(accent, 0.8),
		tabActive = titleAccent:Lerp(accent, 0.5),
	}

	theme.separator = theme.border

	for key, value in pairs(overrides or {}) do
		theme[key] = value
	end

	return theme
end

local THEMES = {
	Dark = buildTheme(
		Color3.fromRGB(66, 150, 250),
		Color3.fromRGB(41, 74, 122),
		Color3.fromRGB(15, 15, 15),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(110, 110, 128)
	),
	Light = buildTheme(
		Color3.fromRGB(66, 150, 250),
		Color3.fromRGB(209, 209, 209),
		Color3.fromRGB(240, 240, 240),
		Color3.fromRGB(0, 0, 0),
		Color3.fromRGB(120, 120, 120),
		{
			frameBg = Color3.fromRGB(255, 255, 255),
			tab = Color3.fromRGB(194, 204, 214),
			tabActive = Color3.fromRGB(153, 189, 235),
		}
	),
	Cherry = buildTheme(
		Color3.fromRGB(226, 70, 95),
		Color3.fromRGB(122, 38, 58),
		Color3.fromRGB(20, 14, 16),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(128, 100, 106)
	),
	Forest = buildTheme(
		Color3.fromRGB(70, 200, 120),
		Color3.fromRGB(36, 96, 62),
		Color3.fromRGB(13, 17, 14),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(100, 125, 108)
	),
	Purple = buildTheme(
		Color3.fromRGB(158, 110, 245),
		Color3.fromRGB(78, 52, 128),
		Color3.fromRGB(17, 14, 22),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(112, 100, 130)
	),
}

Gui.themeOrder = { "Dark", "Light", "Cherry", "Forest", "Purple" }

local function make(className, properties, parent)
	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
	end

	if instance:IsA("GuiButton") then
		instance.AutoButtonColor = false
	end

	if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
		instance.Font = FONT
		instance.TextSize = FONT_SIZE
	end

	for key, value in pairs(properties) do
		instance[key] = value
	end

	instance.Parent = parent
	return instance
end

local function cornerIfHVH(window, instance, radius)
	if window.style == "HVH" then
		make("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, instance)
	end
end

local function isInside(object, point)
	local position, size = object.AbsolutePosition, object.AbsoluteSize

	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y
end

local MOUSE_NAMES = {
	[Enum.UserInputType.MouseButton1] = "M1",
	[Enum.UserInputType.MouseButton2] = "M2",
	[Enum.UserInputType.MouseButton3] = "M3",
}

local function toBind(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
		return { kind = "KeyCode", code = input.KeyCode }
	end

	if MOUSE_NAMES[input.UserInputType] then
		return { kind = "UserInputType", code = input.UserInputType }
	end

	return nil
end

local function bindName(bind)
	if not bind then
		return "None"
	end

	if bind.kind == "UserInputType" then
		return MOUSE_NAMES[bind.code]
	end

	return bind.code.Name
end

local function matchesBind(bind, input)
	if not bind then
		return false
	end

	if bind.kind == "KeyCode" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.code
	end

	return input.UserInputType == bind.code
end

function Gui.new(title, style)
	local self = setmetatable({}, Gui)
	self.connections = {}
	self.bound = {}
	self.restylers = {}
	self.popup = nil
	self.popupOwner = nil
	self.activeDrag = nil
	self.capture = nil
	self.lastCaptureAt = 0
	self.themeName = "Dark"
	self.theme = THEMES.Dark
	self.style = style or "ImGui"

	local hvh = self.style == "HVH"
	local parent = gethui and gethui() or coreGuiService

	self.screenGui = make("ScreenGui", {
		Name = "TriggerBotGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, parent)

	self.frame = make("Frame", {
		Position = UDim2.fromOffset(40, 120),
		Size = UDim2.fromOffset(WINDOW_WIDTH, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, self.screenGui)
	self:bind(self.frame, "BackgroundColor3", "windowBg")
	cornerIfHVH(self, self.frame, 10)

	local stroke = make("UIStroke", { Thickness = hvh and 2 or 1 }, self.frame)
	self:bind(stroke, "Color", hvh and "checkMark" or "border")

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, self.frame)

	self.titleBar = make("Frame", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		LayoutOrder = 1,
	}, self.frame)
	self:bind(self.titleBar, "BackgroundColor3", hvh and "checkMark" or "titleBgActive")

	local arrow = make("TextButton", {
		Size = UDim2.fromOffset(FRAME_HEIGHT, FRAME_HEIGHT),
		BackgroundTransparency = 1,
		Text = "▼",
		TextSize = 10,
	}, self.titleBar)

	local titleLabel = make("TextLabel", {
		Position = UDim2.fromOffset(FRAME_HEIGHT, 0),
		Size = UDim2.new(1, -FRAME_HEIGHT, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, self.titleBar)

	if hvh then
		arrow.TextColor3 = Color3.new(1, 1, 1)
		titleLabel.TextColor3 = Color3.new(1, 1, 1)
	else
		self:bind(arrow, "TextColor3", "text")
		self:bind(titleLabel, "TextColor3", "text")
	end

	self.menuBar = make("Frame", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		LayoutOrder = 2,
	}, self.frame)
	self:bind(self.menuBar, "BackgroundColor3", "menuBarBg")

	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, self.menuBar)

	make("UIPadding", { PaddingLeft = UDim.new(0, 4) }, self.menuBar)

	local bodyFrame = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	}, self.frame)

	make("UIPadding", {
		PaddingTop = UDim.new(0, WINDOW_PADDING),
		PaddingBottom = UDim.new(0, WINDOW_PADDING),
		PaddingLeft = UDim.new(0, WINDOW_PADDING),
		PaddingRight = UDim.new(0, WINDOW_PADDING),
	}, bodyFrame)

	self.body = Container.new(self, bodyFrame)

	local collapsed = false

	arrow.MouseButton1Click:Connect(function()
		collapsed = not collapsed
		arrow.Text = collapsed and "▶" or "▼"
		self.menuBar.Visible = not collapsed
		bodyFrame.Visible = not collapsed
		self:closePopup()
	end)

	self:bindInput()
	self:applyTheme()

	self.titleBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local offset = Vector2.new(self.frame.AbsolutePosition.X, self.frame.AbsolutePosition.Y)
			- userInputService:GetMouseLocation()

		self:beginDrag(function(mouse)
			local target = mouse + offset
			self.frame.Position = UDim2.fromOffset(target.X, target.Y)
		end)
	end)

	return self
end

function Gui:bind(instance, property, key)
	table.insert(self.bound, { instance = instance, property = property, key = key })
	instance[property] = self.theme[key]
end

function Gui:applyTheme()
	for _, entry in ipairs(self.bound) do
		entry.instance[entry.property] = self.theme[entry.key]
	end

	for _, restyle in ipairs(self.restylers) do
		restyle()
	end
end

function Gui:setTheme(name)
	if not THEMES[name] then
		return
	end

	self.themeName = name
	self.theme = THEMES[name]
	self:applyTheme()
end

function Gui:beginDrag(update, finish)
	self.activeDrag = { update = update, finish = finish }
end

function Gui:bindInput()
	table.insert(self.connections, userInputService.InputChanged:Connect(function(input)
		if self.activeDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
			self.activeDrag.update(userInputService:GetMouseLocation())
		end
	end))

	table.insert(self.connections, userInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self.activeDrag then
			return
		end

		local finish = self.activeDrag.finish
		self.activeDrag = nil

		if finish then
			finish()
		end
	end))

	table.insert(self.connections, userInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self.popup then
			return
		end

		local mouse = userInputService:GetMouseLocation()

		if not isInside(self.popup, mouse) and not isInside(self.menuBar, mouse) then
			self:closePopup()
		end
	end))
end

function Gui:closePopup()
	if self.popup then
		self.popup:Destroy()
		self.popup = nil
	end

	if self.popupOwner then
		self.popupOwner.BackgroundTransparency = 1
		self.popupOwner = nil
	end
end

function Gui:handleCapture(input)
	if not self.capture then
		return false
	end

	local bind = toBind(input)
	if not bind then
		return false
	end

	local capture = self.capture
	self.capture = nil
	self.lastCaptureAt = os.clock()

	capture(bind)
	return true
end

function Gui:openPopup(owner, items)
	self:closePopup()

	self.popupOwner = owner
	owner.BackgroundTransparency = 0

	local popup = make("Frame", {
		Position = UDim2.fromOffset(owner.AbsolutePosition.X, owner.AbsolutePosition.Y + owner.AbsoluteSize.Y),
		Size = UDim2.fromOffset(150, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
	}, self.screenGui)
	self:bind(popup, "BackgroundColor3", "windowBg")
	cornerIfHVH(self, popup, 6)

	local stroke = make("UIStroke", { Thickness = 1 }, popup)
	self:bind(stroke, "Color", "border")

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, popup)

	for index, item in ipairs(items) do
		local entry = make("TextButton", {
			Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
			BackgroundTransparency = 1,
			Text = (item.checked and "• " or "  ") .. item.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = index,
		}, popup)
		self:bind(entry, "BackgroundColor3", "headerHovered")
		self:bind(entry, "TextColor3", "text")

		make("UIPadding", { PaddingLeft = UDim.new(0, 6) }, entry)

		entry.MouseEnter:Connect(function()
			entry.BackgroundTransparency = 0
		end)

		entry.MouseLeave:Connect(function()
			entry.BackgroundTransparency = 1
		end)

		entry.MouseButton1Click:Connect(function()
			self:closePopup()
			item.callback()
		end)
	end

	self.popup = popup
end

function Gui:menu(name, getItems)
	local button = make("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = name,
		LayoutOrder = #self.menuBar:GetChildren(),
	}, self.menuBar)
	self:bind(button, "BackgroundColor3", "headerHovered")
	self:bind(button, "TextColor3", "text")

	make("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, button)

	button.MouseButton1Click:Connect(function()
		if self.popupOwner == button then
			self:closePopup()
			return
		end

		self:openPopup(button, getItems())
	end)

	button.MouseEnter:Connect(function()
		if self.popup and self.popupOwner ~= button then
			self:openPopup(button, getItems())
		end
	end)
end

function Gui:isMouseOver()
	if not self.screenGui.Enabled then
		return false
	end

	local mouse = userInputService:GetMouseLocation()
	return isInside(self.frame, mouse) or (self.popup ~= nil and isInside(self.popup, mouse))
end

function Gui:toggle()
	self:closePopup()
	self.screenGui.Enabled = not self.screenGui.Enabled
end

function Gui:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	table.clear(self.connections)
	self.screenGui:Destroy()
end

function Container.new(owner, frame)
	local self = setmetatable({}, Container)
	self.window = owner
	self.frame = frame
	self.counter = 0

	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, ITEM_SPACING),
	}, frame)

	return self
end

function Container:place(instance)
	self.counter += 1
	instance.LayoutOrder = self.counter
	instance.Parent = self.frame
	return instance
end

function Container:row(height)
	return self:place(make("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
	}))
end

function Container:label(text, disabled)
	local label = self:place(make("TextLabel", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}))

	self.window:bind(label, "TextColor3", disabled and "textDisabled" or "text")
	return label
end

function Container:separator()
	local line = self:place(make("Frame", { Size = UDim2.new(1, 0, 0, 1) }))
	self.window:bind(line, "BackgroundColor3", "separator")
end

function Container:button(text, callback)
	local window = self.window

	local button = self:place(make("TextButton", {
		Size = UDim2.fromOffset(0, FRAME_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
	}))
	window:bind(button, "BackgroundColor3", "button")
	window:bind(button, "TextColor3", "text")
	cornerIfHVH(window, button, 6)

	make("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, button)

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = window.theme.buttonHovered
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = window.theme.button
	end)

	button.MouseButton1Down:Connect(function()
		button.BackgroundColor3 = window.theme.buttonActive
	end)

	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = window.theme.buttonHovered
		callback()
	end)

	return button
end

function Container:checkbox(text, default, callback)
	local window = self.window
	local value = default
	local hvh = window.style == "HVH"

	local row = self:place(make("TextButton", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		BackgroundTransparency = 1,
		Text = "",
	}))

	local control = {}
	local render

	if hvh then
		local pillWidth, pillHeight, knobSize, knobInset = 32, 16, 12, 2

		local pill = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(pillWidth, pillHeight),
		}, row)
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)

		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(knobInset, pillHeight / 2),
			Size = UDim2.fromOffset(knobSize, knobSize),
		}, pill)
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

		local label = make("TextLabel", {
			Position = UDim2.fromOffset(pillWidth + ITEM_SPACING + 2, 0),
			Size = UDim2.new(1, -(pillWidth + ITEM_SPACING + 2), 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row)
		window:bind(label, "TextColor3", "text")

		function render()
			local onX = pillWidth - knobSize - knobInset

			knob.Position = UDim2.fromOffset(value and onX or knobInset, pillHeight / 2)
			pill.BackgroundColor3 = value and window.theme.checkMark or window.theme.frameBg
			knob.BackgroundColor3 = value and Color3.new(1, 1, 1) or window.theme.textDisabled
		end

		table.insert(window.restylers, render)
	else
		local box = make("Frame", { Size = UDim2.fromOffset(FRAME_HEIGHT, FRAME_HEIGHT) }, row)
		window:bind(box, "BackgroundColor3", "frameBg")

		local shortStroke = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(6, 11),
			Size = UDim2.fromOffset(2, 5),
			Rotation = -45,
			Visible = value,
		}, box)
		window:bind(shortStroke, "BackgroundColor3", "checkMark")

		local longStroke = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(11, 9),
			Size = UDim2.fromOffset(2, 10),
			Rotation = 45,
			Visible = value,
		}, box)
		window:bind(longStroke, "BackgroundColor3", "checkMark")

		local label = make("TextLabel", {
			Position = UDim2.fromOffset(FRAME_HEIGHT + ITEM_SPACING, 0),
			Size = UDim2.new(1, -(FRAME_HEIGHT + ITEM_SPACING), 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, row)
		window:bind(label, "TextColor3", "text")

		function render()
			shortStroke.Visible = value
			longStroke.Visible = value
		end

		row.MouseEnter:Connect(function()
			box.BackgroundColor3 = window.theme.frameBgHovered
		end)

		row.MouseLeave:Connect(function()
			box.BackgroundColor3 = window.theme.frameBg
		end)

		row.MouseButton1Down:Connect(function()
			box.BackgroundColor3 = window.theme.frameBgActive
		end)

		row.MouseButton1Click:Connect(function()
			box.BackgroundColor3 = window.theme.frameBgHovered
		end)
	end

	function control.set(newValue)
		value = newValue
		render()
		callback(value)
	end

	function control.get()
		return value
	end

	row.MouseButton1Click:Connect(function()
		control.set(not value)
	end)

	render()
	callback(value)
	return control
end

function Container:slider(text, minimum, maximum, default, step, callback, format)
	local window = self.window
	local value = default
	local hovered = false
	local dragging = false

	format = format or (step % 1 == 0 and "%d" or "%.2f")

	local row = self:row(FRAME_HEIGHT)

	local track = make("TextButton", {
		Size = UDim2.new(SLIDER_RATIO, 0, 1, 0),
		Text = "",
	}, row)
	window:bind(track, "BackgroundColor3", "frameBg")
	cornerIfHVH(window, track, 6)

	local grab = make("Frame", { Size = UDim2.fromOffset(GRAB_WIDTH, FRAME_HEIGHT - 4) }, track)
	window:bind(grab, "BackgroundColor3", "sliderGrab")
	cornerIfHVH(window, grab, 4)

	local caption = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, track)
	window:bind(caption, "TextColor3", "text")

	local label = make("TextLabel", {
		Position = UDim2.new(SLIDER_RATIO, 6, 0, 0),
		Size = UDim2.new(1 - SLIDER_RATIO, -6, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	window:bind(label, "TextColor3", "text")

	local function render()
		local ratio = (value - minimum) / (maximum - minimum)
		caption.Text = string.format(format, value)
		grab.Position = UDim2.new(ratio, -ratio * GRAB_WIDTH, 0, 2)
	end

	local function recolor()
		if dragging then
			track.BackgroundColor3 = window.theme.frameBgActive
			grab.BackgroundColor3 = window.theme.sliderGrabActive
		else
			track.BackgroundColor3 = hovered and window.theme.frameBgHovered or window.theme.frameBg
			grab.BackgroundColor3 = window.theme.sliderGrab
		end
	end

	local function updateFromMouse(mouse)
		local usable = track.AbsoluteSize.X - GRAB_WIDTH
		local relative = math.clamp((mouse.X - track.AbsolutePosition.X - GRAB_WIDTH / 2) / usable, 0, 1)
		local raw = minimum + relative * (maximum - minimum)

		value = math.clamp(math.round(raw / step) * step, minimum, maximum)
		render()
		callback(value)
	end

	track.MouseEnter:Connect(function()
		hovered = true
		recolor()
	end)

	track.MouseLeave:Connect(function()
		hovered = false
		recolor()
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		dragging = true
		recolor()
		updateFromMouse(userInputService:GetMouseLocation())

		window:beginDrag(updateFromMouse, function()
			dragging = false
			recolor()
		end)
	end)

	render()
	callback(value)
	return {}
end

function Container:keybind(text, default, callback)
	local window = self.window
	local bind = default
	local listening = false
	local hovered = false
	local control = {}

	local row = self:row(FRAME_HEIGHT)

	local button = make("TextButton", {
		Size = UDim2.new(SLIDER_RATIO, 0, 1, 0),
		Text = "",
	}, row)
	window:bind(button, "TextColor3", "text")
	cornerIfHVH(window, button, 6)

	local label = make("TextLabel", {
		Position = UDim2.new(SLIDER_RATIO, 6, 0, 0),
		Size = UDim2.new(1 - SLIDER_RATIO, -6, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	window:bind(label, "TextColor3", "text")

	local function render()
		button.Text = listening and "press a key..." or string.format("[ %s ]", bindName(bind))

		if listening then
			button.BackgroundColor3 = window.theme.frameBgActive
		else
			button.BackgroundColor3 = hovered and window.theme.frameBgHovered or window.theme.frameBg
		end
	end

	table.insert(window.restylers, render)

	function control.set(newBind)
		bind = newBind
		render()
		callback(bind)
	end

	function control.get()
		return bind
	end

	button.MouseEnter:Connect(function()
		hovered = true
		render()
	end)

	button.MouseLeave:Connect(function()
		hovered = false
		render()
	end)

	button.MouseButton1Click:Connect(function()
		if listening or os.clock() - window.lastCaptureAt < 0.4 then
			return
		end

		listening = true
		render()

		window.capture = function(newBind)
			listening = false

			if newBind.kind == "KeyCode" and newBind.code == Enum.KeyCode.Escape then
				render()
			elseif newBind.kind == "KeyCode" and newBind.code == Enum.KeyCode.Backspace then
				control.set(nil)
			else
				control.set(newBind)
			end
		end
	end)

	render()
	callback(bind)
	return control
end

function Container:textbox(text, default, callback)
	local window = self.window
	local hovered = false
	local focused = false
	local control = {}

	local row = self:row(FRAME_HEIGHT)

	local box = make("TextBox", {
		Size = UDim2.new(SLIDER_RATIO, 0, 1, 0),
		Text = default,
		PlaceholderText = "type here",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	window:bind(box, "TextColor3", "text")
	window:bind(box, "PlaceholderColor3", "textDisabled")
	cornerIfHVH(window, box, 6)

	make("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)

	local label = make("TextLabel", {
		Position = UDim2.new(SLIDER_RATIO, 6, 0, 0),
		Size = UDim2.new(1 - SLIDER_RATIO, -6, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	window:bind(label, "TextColor3", "text")

	local function render()
		if focused then
			box.BackgroundColor3 = window.theme.frameBgActive
		elseif hovered then
			box.BackgroundColor3 = window.theme.frameBgHovered
		else
			box.BackgroundColor3 = window.theme.frameBg
		end
	end

	table.insert(window.restylers, render)

	function control.set(newText)
		box.Text = newText
		callback(newText)
	end

	function control.get()
		return box.Text
	end

	box.MouseEnter:Connect(function()
		hovered = true
		render()
	end)

	box.MouseLeave:Connect(function()
		hovered = false
		render()
	end)

	box.Focused:Connect(function()
		focused = true
		render()
	end)

	box.FocusLost:Connect(function()
		focused = false
		render()
		callback(box.Text)
	end)

	render()
	return control
end

function Container:codeBox(default, height)
	local window = self.window
	local control = {}
	local hovered = false
	local focused = false

	local row = self:row(height)

	local box = make("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		Text = default,
		PlaceholderText = "-- paste or write your lua here",
		ClearTextOnFocus = false,
		MultiLine = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, row)
	window:bind(box, "TextColor3", "text")
	window:bind(box, "PlaceholderColor3", "textDisabled")
	cornerIfHVH(window, box, 6)

	make("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
	}, box)

	local function render()
		if focused then
			box.BackgroundColor3 = window.theme.frameBgActive
		elseif hovered then
			box.BackgroundColor3 = window.theme.frameBgHovered
		else
			box.BackgroundColor3 = window.theme.frameBg
		end
	end

	table.insert(window.restylers, render)

	function control.get()
		return box.Text
	end

	function control.set(text)
		box.Text = text
	end

	box.MouseEnter:Connect(function()
		hovered = true
		render()
	end)

	box.MouseLeave:Connect(function()
		hovered = false
		render()
	end)

	box.Focused:Connect(function()
		focused = true
		render()
	end)

	box.FocusLost:Connect(function()
		focused = false
		render()
	end)

	render()
	return control
end

function Container:collapsingHeader(text, open)
	local window = self.window

	local wrapper = self:place(make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}))

	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, ITEM_SPACING),
	}, wrapper)

	local header = make("TextButton", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		Text = "",
		LayoutOrder = 1,
	}, wrapper)
	window:bind(header, "BackgroundColor3", "header")

	local title = make("TextLabel", {
		Position = UDim2.fromOffset(6, 0),
		Size = UDim2.new(1, -6, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)
	window:bind(title, "TextColor3", "text")

	local content = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = open,
		LayoutOrder = 2,
	}, wrapper)

	local function render()
		title.Text = (open and "▼ " or "▶ ") .. text
		content.Visible = open
	end

	header.MouseEnter:Connect(function()
		header.BackgroundColor3 = window.theme.headerHovered
	end)

	header.MouseLeave:Connect(function()
		header.BackgroundColor3 = window.theme.header
	end)

	header.MouseButton1Down:Connect(function()
		header.BackgroundColor3 = window.theme.headerActive
	end)

	header.MouseButton1Click:Connect(function()
		header.BackgroundColor3 = window.theme.headerHovered
		open = not open
		render()
	end)

	render()
	return Container.new(window, content)
end

function Container:tabBar()
	local window = self.window
	local hvh = window.style == "HVH"
	local sidebarWidth = 120

	local wrapper = self:place(make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}))

	make("UIListLayout", {
		FillDirection = hvh and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = hvh and UDim.new(0, ITEM_SPACING) or UDim.new(0, 0),
	}, wrapper)

	local barFrame

	if hvh then
		barFrame = make("Frame", {
			Size = UDim2.fromOffset(sidebarWidth, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
		}, wrapper)
		window:bind(barFrame, "BackgroundColor3", "menuBarBg")
		cornerIfHVH(window, barFrame, 8)

		make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, barFrame)
		make("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}, barFrame)
	else
		barFrame = make("Frame", {
			Size = UDim2.new(1, 0, 0, FRAME_HEIGHT + 2),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, wrapper)

		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 2),
		}, barFrame)

		local line = make("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			LayoutOrder = 2,
		}, wrapper)
		window:bind(line, "BackgroundColor3", "tabActive")
	end

	local pages = make("Frame", {
		Size = hvh and UDim2.new(1, -(sidebarWidth + ITEM_SPACING), 0, 0) or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = hvh and 2 or 3,
	}, wrapper)

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, pages)

	local bar = setmetatable({
		window = window,
		style = window.style,
		barFrame = barFrame,
		pages = pages,
		tabs = {},
		active = nil,
	}, TabBar)

	table.insert(window.restylers, function()
		bar:restyle()
	end)

	return bar
end

function TabBar:tab(name)
	local window = self.window
	local hvh = self.style == "HVH"
	local button
	local accentBar = nil

	if hvh then
		button = make("TextButton", {
			Size = UDim2.new(1, 0, 0, FRAME_HEIGHT + 6),
			Text = "  " .. name,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = #self.tabs + 1,
		}, self.barFrame)
		cornerIfHVH(window, button, 6)

		accentBar = make("Frame", {
			Size = UDim2.fromOffset(3, FRAME_HEIGHT + 6),
			ZIndex = 2,
			Visible = false,
		}, button)
		window:bind(accentBar, "BackgroundColor3", "checkMark")
	else
		button = make("TextButton", {
			Size = UDim2.fromOffset(0, FRAME_HEIGHT),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = name,
			LayoutOrder = #self.tabs + 1,
		}, self.barFrame)

		make("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}, button)
	end

	if not hvh then
		window:bind(button, "TextColor3", "text")
	end

	local page = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
	}, self.pages)

	make("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingLeft = hvh and UDim.new(0, 4) or UDim.new(0, 0),
	}, page)

	local entry = { button = button, page = page, hovered = false, accentBar = accentBar }
	table.insert(self.tabs, entry)

	button.MouseEnter:Connect(function()
		entry.hovered = true
		self:restyle()
	end)

	button.MouseLeave:Connect(function()
		entry.hovered = false
		self:restyle()
	end)

	button.MouseButton1Click:Connect(function()
		self:select(entry)
	end)

	if not self.active then
		self:select(entry)
	else
		self:restyle()
	end

	return Container.new(window, page)
end

function TabBar:select(entry)
	self.active = entry

	for _, other in ipairs(self.tabs) do
		other.page.Visible = other == entry
	end

	self:restyle()
end

function TabBar:restyle()
	local theme = self.window.theme
	local hvh = self.style == "HVH"

	for _, entry in ipairs(self.tabs) do
		local active = entry == self.active

		if hvh then
			entry.button.BackgroundTransparency = (active or entry.hovered) and 0 or 1
			entry.button.BackgroundColor3 = active and theme.checkMark or theme.headerHovered
			entry.button.TextColor3 = active and Color3.new(1, 1, 1) or theme.text

			if entry.accentBar then
				entry.accentBar.Visible = active
			end
		else
			if active then
				entry.button.BackgroundColor3 = theme.tabActive
			elseif entry.hovered then
				entry.button.BackgroundColor3 = theme.tabHovered
			else
				entry.button.BackgroundColor3 = theme.tab
			end
		end
	end
end

for _, name in ipairs({ "label", "separator", "button", "checkbox", "slider", "keybind", "textbox", "codeBox", "collapsingHeader", "tabBar" }) do
	Gui[name] = function(self, ...)
		return self.body[name](self.body, ...)
	end
end

return {
	Gui = Gui,
	Container = Container,
	TabBar = TabBar,
	THEMES = THEMES,
	FRAME_HEIGHT = FRAME_HEIGHT,
	ITEM_SPACING = ITEM_SPACING,
	SLIDER_RATIO = SLIDER_RATIO,
	GRAB_WIDTH = GRAB_WIDTH,
	FONT = FONT,
	FONT_SIZE = FONT_SIZE,
	WINDOW_WIDTH = WINDOW_WIDTH,
	WINDOW_PADDING = WINDOW_PADDING,
	make = make,
	isInside = isInside,
	toBind = toBind,
	bindName = bindName,
	matchesBind = matchesBind,
}
