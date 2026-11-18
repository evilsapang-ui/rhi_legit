-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- Module tables.
local TriggerBot = {}
local Gui = {}
Gui.__index = Gui
local Container = {}
Container.__index = Container
local TabBar = {}
TabBar.__index = TabBar

-- Constants.
local MENU_KEY = Enum.KeyCode.Insert
local WINDOW_WIDTH = 450
local WINDOW_PADDING = 8
local FRAME_HEIGHT = 19
local ITEM_SPACING = 4
local SLIDER_RATIO = 0.6
local GRAB_WIDTH = 10
local FONT = Enum.Font.Code
local FONT_SIZE = 14
local MAX_WALL_STEPS = 6
local SEE_THROUGH_TRANSPARENCY = 0.9
local KEY_HOLD_TIME = 0.05
local AIM_DEADZONE = 2
local ASSIST_REACQUIRE_DELAY = 0.4
local FULLBRIGHT_AMBIENT = Color3.fromRGB(178, 178, 178)
local FULLBRIGHT_CLOCK_TIME = 14

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local coreGuiService = game:GetService("CoreGui")
local lightingService = game:GetService("Lighting")

-- State.
local localPlayer = playersService.LocalPlayer
local currentCamera = workspace.CurrentCamera
local lastClick = 0
local pending = false
local connections = {}
local window = nil

-- Trigger key state.
local MODES = { "Toggle", "Hold", "Always" }
local FIRE_STYLES = { "Click", "Hold" }
local AIM_MODES = { "Cursor", "Center" }
local AIM_PARTS = { "Head", "Torso" }
local toggled = true
local held = false
local aimHeld = false
local ignoreInputUntil = 0
local statusLabel = nil

-- Hold-fire state.
local holding = false
local holdBind = nil
local lastTargetSeen = 0
local botShotUntil = 0

-- Recoil state.
local recoilStart = nil
local recoilRemainder = Vector2.zero

-- ESP and aim drawing state.
local espObjects = {}
local fovCircle = nil

-- Aim assist state.
local assistTarget = nil
local assistReleasedUntil = 0
local assistRemainder = Vector2.zero
local assistCircle = nil

-- Fullbright state.
local savedLighting = nil
local savedAtmospheres = {}

-- ESP palette.
local ESP_COLORS = {
	Red = Color3.fromRGB(255, 60, 60),
	Green = Color3.fromRGB(70, 230, 110),
	Blue = Color3.fromRGB(80, 150, 255),
	Yellow = Color3.fromRGB(255, 220, 70),
	Purple = Color3.fromRGB(180, 110, 255),
	White = Color3.fromRGB(255, 255, 255),
}
local ESP_COLOR_NAMES = { "Red", "Green", "Blue", "Yellow", "Purple", "White" }
local TEAM_COLOR = Color3.fromRGB(80, 200, 120)

-- Config, edited live by the GUI.
local Config = {
	enabled = true,
	teamCheck = true,
	wallCheck = true,
	mode = "Toggle",
	fireStyle = "Click",
	holdRelease = 80,
	aimAt = "Cursor",
	bind = { kind = "KeyCode", code = Enum.KeyCode.RightAlt },
	fireBind = { kind = "UserInputType", code = Enum.UserInputType.MouseButton1 },
	maxDistance = 500,
	reactionDelay = 50,
	clickCooldown = 120,

	aimEnabled = false,
	aimBind = { kind = "UserInputType", code = Enum.UserInputType.MouseButton2 },
	aimPart = "Head",
	aimFov = 120,
	aimSmoothing = 6,
	aimDistance = 500,
	aimShowFov = true,
	aimVisibleCheck = true,

	assistEnabled = false,
	assistTeamCheck = true,
	assistRadius = 80,
	assistBreakRadius = 160,
	assistStrength = 12,
	assistDistance = 500,
	assistVisibleCheck = true,
	assistShowRadius = false,

	recoilEnabled = false,
	recoilManual = true,
	recoilBot = true,
	recoilY = 4,
	recoilX = 0,
	recoilRamp = 100,

	espEnabled = false,
	espBoxes = true,
	espNames = true,
	espHealth = true,
	espDistanceText = true,
	espTracers = false,
	espHideTeam = true,
	espColor = "Red",
	espDistance = 1000,

	fbEnabled = false,
	fbBrightness = 2,
	fbDaytime = true,
	fbNoShadows = true,
	fbNoFog = true,
}

-- Reuse params so we don't allocate every frame.
local rayParams = RaycastParams.new()

--------------------------------------------------------------------------------
-- Themes
--------------------------------------------------------------------------------

---Build a full palette from a few base colors, using Dear ImGui's alpha ratios.
---@param accent Color3
---@param titleAccent Color3
---@param windowBg Color3
---@param text Color3
---@param border Color3
---@param overrides table?
---@return table
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

--------------------------------------------------------------------------------
-- GUI helpers
--------------------------------------------------------------------------------

---Create an instance with ImGui-flat defaults and the given properties.
---@param className string
---@param properties table
---@param parent Instance?
---@return Instance
local function make(className, properties, parent)
	local instance = Instance.new(className)

	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
	end

	if instance:IsA("GuiButton") then
		instance.AutoButtonColor = false
	end

	if className == "TextLabel" or className == "TextButton" then
		instance.Font = FONT
		instance.TextSize = FONT_SIZE
	end

	for key, value in pairs(properties) do
		instance[key] = value
	end

	instance.Parent = parent
	return instance
end

---Check if a screen point lies inside a GuiObject.
---@param object GuiObject
---@param point Vector2
---@return boolean
local function isInside(object, point)
	local position, size = object.AbsolutePosition, object.AbsoluteSize

	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y
end

-- Display names for bindable mouse buttons.
local MOUSE_NAMES = {
	[Enum.UserInputType.MouseButton1] = "M1",
	[Enum.UserInputType.MouseButton2] = "M2",
	[Enum.UserInputType.MouseButton3] = "M3",
}

---Convert an input into a bind descriptor, or nil if it can't be bound.
---@param input InputObject
---@return table?
local function toBind(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
		return { kind = "KeyCode", code = input.KeyCode }
	end

	if MOUSE_NAMES[input.UserInputType] then
		return { kind = "UserInputType", code = input.UserInputType }
	end

	return nil
end

---Get a display name for a bind.
---@param bind table?
---@return string
local function bindName(bind)
	if not bind then
		return "None"
	end

	if bind.kind == "UserInputType" then
		return MOUSE_NAMES[bind.code]
	end

	return bind.code.Name
end

---Check if an input matches a bind.
---@param bind table?
---@param input InputObject
---@return boolean
local function matchesBind(bind, input)
	if not bind then
		return false
	end

	if bind.kind == "KeyCode" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.code
	end

	return input.UserInputType == bind.code
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

---Create a new window.
---@param title string
---@return Gui
function Gui.new(title)
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

	local stroke = make("UIStroke", { Thickness = 1 }, self.frame)
	self:bind(stroke, "Color", "border")

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, self.frame)

	-- Title bar with collapse arrow.
	self.titleBar = make("Frame", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		LayoutOrder = 1,
	}, self.frame)
	self:bind(self.titleBar, "BackgroundColor3", "titleBgActive")

	local arrow = make("TextButton", {
		Size = UDim2.fromOffset(FRAME_HEIGHT, FRAME_HEIGHT),
		BackgroundTransparency = 1,
		Text = "▼",
		TextSize = 10,
	}, self.titleBar)
	self:bind(arrow, "TextColor3", "text")

	local titleLabel = make("TextLabel", {
		Position = UDim2.fromOffset(FRAME_HEIGHT, 0),
		Size = UDim2.new(1, -FRAME_HEIGHT, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, self.titleBar)
	self:bind(titleLabel, "TextColor3", "text")

	-- Menu bar.
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

	-- Body.
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

	-- Collapse toggle.
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

	-- Title bar drags the whole window.
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

---Register a property that follows a theme color.
---@param instance Instance
---@param property string
---@param key string
function Gui:bind(instance, property, key)
	table.insert(self.bound, { instance = instance, property = property, key = key })
	instance[property] = self.theme[key]
end

---Re-apply the current theme to every bound property.
function Gui:applyTheme()
	for _, entry in ipairs(self.bound) do
		entry.instance[entry.property] = self.theme[entry.key]
	end

	for _, restyle in ipairs(self.restylers) do
		restyle()
	end
end

---Switch to a named theme.
---@param name string
function Gui:setTheme(name)
	if not THEMES[name] then
		return
	end

	self.themeName = name
	self.theme = THEMES[name]
	self:applyTheme()
end

---Start a mouse drag; update runs on movement, finish on release.
---@param update function
---@param finish function?
function Gui:beginDrag(update, finish)
	self.activeDrag = { update = update, finish = finish }
end

---Connect the global mouse handlers shared by every widget.
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

	-- Clicking outside an open popup closes it.
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

---Close the open menu popup, if any.
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

---Feed an input to a pending keybind capture; returns true if it was consumed.
---@param input InputObject
---@return boolean
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

---Open a popup list under a menu button.
---@param owner TextButton
---@param items table
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

---Add a menu to the menu bar.
---@param name string
---@param getItems function
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

	-- Hovering another menu while one is open switches to it.
	button.MouseEnter:Connect(function()
		if self.popup and self.popupOwner ~= button then
			self:openPopup(button, getItems())
		end
	end)
end

---Check if the cursor is over the window or its popup.
---@return boolean
function Gui:isMouseOver()
	if not self.screenGui.Enabled then
		return false
	end

	local mouse = userInputService:GetMouseLocation()
	return isInside(self.frame, mouse) or (self.popup ~= nil and isInside(self.popup, mouse))
end

---Show or hide the window.
function Gui:toggle()
	self:closePopup()
	self.screenGui.Enabled = not self.screenGui.Enabled
end

---Disconnect events and destroy the window.
function Gui:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	table.clear(self.connections)
	self.screenGui:Destroy()
end

--------------------------------------------------------------------------------
-- Container (widgets)
--------------------------------------------------------------------------------

---Create a widget container inside a frame.
---@param owner Gui
---@param frame Frame
---@return Container
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

---Parent an instance into the container in creation order.
---@param instance GuiObject
---@return GuiObject
function Container:place(instance)
	self.counter += 1
	instance.LayoutOrder = self.counter
	instance.Parent = self.frame
	return instance
end

---Create a transparent full-width row.
---@param height number
---@return Frame
function Container:row(height)
	return self:place(make("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
	}))
end

---Add a text row.
---@param text string
---@param disabled boolean?
---@return TextLabel
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

---Add a horizontal separator.
function Container:separator()
	local line = self:place(make("Frame", { Size = UDim2.new(1, 0, 0, 1) }))
	self.window:bind(line, "BackgroundColor3", "separator")
end

---Add a button.
---@param text string
---@param callback function
---@return TextButton
function Container:button(text, callback)
	local window = self.window

	local button = self:place(make("TextButton", {
		Size = UDim2.fromOffset(0, FRAME_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
	}))
	window:bind(button, "BackgroundColor3", "button")
	window:bind(button, "TextColor3", "text")

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

---Add a checkbox.
---@param text string
---@param default boolean
---@param callback function
---@return table
function Container:checkbox(text, default, callback)
	local window = self.window
	local value = default

	local row = self:place(make("TextButton", {
		Size = UDim2.new(1, 0, 0, FRAME_HEIGHT),
		BackgroundTransparency = 1,
		Text = "",
	}))

	local box = make("Frame", { Size = UDim2.fromOffset(FRAME_HEIGHT, FRAME_HEIGHT) }, row)
	window:bind(box, "BackgroundColor3", "frameBg")

	-- Check mark drawn from two rotated strokes.
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

	local control = {}

	---Set the value and fire the callback.
	---@param newValue boolean
	function control.set(newValue)
		value = newValue
		shortStroke.Visible = value
		longStroke.Visible = value
		callback(value)
	end

	---Get the current value.
	---@return boolean
	function control.get()
		return value
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
		control.set(not value)
	end)

	callback(value)
	return control
end

---Add a slider with a centered value and the label on the right.
---@param text string
---@param minimum number
---@param maximum number
---@param default number
---@param step number
---@param callback function
---@param format string?
---@return table
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

	local grab = make("Frame", { Size = UDim2.fromOffset(GRAB_WIDTH, FRAME_HEIGHT - 4) }, track)
	window:bind(grab, "BackgroundColor3", "sliderGrab")

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

	---Refresh the caption and grab position.
	local function render()
		local ratio = (value - minimum) / (maximum - minimum)
		caption.Text = string.format(format, value)
		grab.Position = UDim2.new(ratio, -ratio * GRAB_WIDTH, 0, 2)
	end

	---Refresh the track and grab colors for hover/drag state.
	local function recolor()
		if dragging then
			track.BackgroundColor3 = window.theme.frameBgActive
			grab.BackgroundColor3 = window.theme.sliderGrabActive
		else
			track.BackgroundColor3 = hovered and window.theme.frameBgHovered or window.theme.frameBg
			grab.BackgroundColor3 = window.theme.sliderGrab
		end
	end

	---Convert a cursor position into a stepped value.
	---@param mouse Vector2
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

---Add a keybind picker with the label on the right.
---@param text string
---@param default table?
---@param callback function
---@return table
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

	local label = make("TextLabel", {
		Position = UDim2.new(SLIDER_RATIO, 6, 0, 0),
		Size = UDim2.new(1 - SLIDER_RATIO, -6, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	window:bind(label, "TextColor3", "text")

	---Refresh the caption and colors for the current state.
	local function render()
		button.Text = listening and "press a key..." or string.format("[ %s ]", bindName(bind))

		if listening then
			button.BackgroundColor3 = window.theme.frameBgActive
		else
			button.BackgroundColor3 = hovered and window.theme.frameBgHovered or window.theme.frameBg
		end
	end

	table.insert(window.restylers, render)

	---Set the bind and fire the callback.
	---@param newBind table?
	function control.set(newBind)
		bind = newBind
		render()
		callback(bind)
	end

	---Get the current bind.
	---@return table?
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
		-- The release of a click that just bound M1 would re-open listening.
		if listening or os.clock() - window.lastCaptureAt < 0.4 then
			return
		end

		listening = true
		render()

		window.capture = function(newBind)
			listening = false

			-- Escape cancels, Backspace clears.
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

---Add a collapsing header and return a container for its children.
---@param text string
---@param open boolean
---@return Container
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

	---Refresh the arrow and text.
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

---Add a tab bar.
---@return TabBar
function Container:tabBar()
	local window = self.window

	local wrapper = self:place(make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}))

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, wrapper)

	local barFrame = make("Frame", {
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

	local pages = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	}, wrapper)

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, pages)

	local bar = setmetatable({
		window = window,
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

--------------------------------------------------------------------------------
-- Tab bar
--------------------------------------------------------------------------------

---Add a tab and return the container for its page.
---@param name string
---@return Container
function TabBar:tab(name)
	local window = self.window

	local button = make("TextButton", {
		Size = UDim2.fromOffset(0, FRAME_HEIGHT),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = name,
		LayoutOrder = #self.tabs + 1,
	}, self.barFrame)
	window:bind(button, "TextColor3", "text")

	make("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, button)

	local page = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
	}, self.pages)

	make("UIPadding", { PaddingTop = UDim.new(0, 6) }, page)

	local entry = { button = button, page = page, hovered = false }
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
	end

	return Container.new(window, page)
end

---Select a tab.
---@param entry table
function TabBar:select(entry)
	self.active = entry

	for _, other in ipairs(self.tabs) do
		other.page.Visible = other == entry
	end

	self:restyle()
end

---Recolor tab buttons for the current theme and state.
function TabBar:restyle()
	local theme = self.window.theme

	for _, entry in ipairs(self.tabs) do
		if entry == self.active then
			entry.button.BackgroundColor3 = theme.tabActive
		elseif entry.hovered then
			entry.button.BackgroundColor3 = theme.tabHovered
		else
			entry.button.BackgroundColor3 = theme.tab
		end
	end
end

-- Forward widget methods so the window can be used directly.
for _, name in ipairs({ "label", "separator", "button", "checkbox", "slider", "keybind", "collapsingHeader", "tabBar" }) do
	Gui[name] = function(self, ...)
		return self.body[name](self.body, ...)
	end
end

--------------------------------------------------------------------------------
-- Key output
--------------------------------------------------------------------------------

-- Windows virtual-key codes for non-letter keys, keyed by Enum.KeyCode name.
local VIRTUAL_KEYS = {
	Space = 0x20, Return = 0x0D, Tab = 0x09, Backspace = 0x08, Escape = 0x1B,
	LeftShift = 0xA0, RightShift = 0xA1, LeftControl = 0xA2, RightControl = 0xA3,
	LeftAlt = 0xA4, RightAlt = 0xA5,
	Left = 0x25, Up = 0x26, Right = 0x27, Down = 0x28,
	Zero = 0x30, One = 0x31, Two = 0x32, Three = 0x33, Four = 0x34,
	Five = 0x35, Six = 0x36, Seven = 0x37, Eight = 0x38, Nine = 0x39,
}

for index = 1, 12 do
	VIRTUAL_KEYS["F" .. index] = 0x6F + index
end

---Convert an Enum.KeyCode into a Windows virtual-key code.
---@param code Enum.KeyCode
---@return number?
local function toVirtualKey(code)
	local name = code.Name

	if VIRTUAL_KEYS[name] then
		return VIRTUAL_KEYS[name]
	end

	-- Letters map to their uppercase ASCII value.
	if #name == 1 then
		return string.byte(name:upper())
	end

	return nil
end

---Check if an output bind is a mouse button.
---@param bind table?
---@return boolean
local function isMouseBind(bind)
	return bind ~= nil and bind.kind == "UserInputType"
end

---Press and keep holding an output bind.
---@param bind table?
local function pressOutput(bind)
	if bind and bind.kind == "KeyCode" then
		keypress(toVirtualKey(bind.code) or bind.code)
	elseif bind and bind.code == Enum.UserInputType.MouseButton2 then
		mouse2press()
	else
		mouse1press()
	end
end

---Release a previously pressed output bind.
---@param bind table?
local function releaseOutput(bind)
	if bind and bind.kind == "KeyCode" then
		keyrelease(toVirtualKey(bind.code) or bind.code)
	elseif bind and bind.code == Enum.UserInputType.MouseButton2 then
		mouse2release()
	else
		mouse1release()
	end
end

--------------------------------------------------------------------------------
-- Targeting helpers
--------------------------------------------------------------------------------

---Get the screen point the bot aims from.
---@return Vector2
local function getAimPoint()
	if Config.aimAt == "Center" then
		return currentCamera.ViewportSize / 2
	end

	return userInputService:GetMouseLocation()
end

---Check if a player is on the local player's team.
---@param player Player
---@return boolean
local function isTeammate(player)
	return player.Team ~= nil and player.Team == localPlayer.Team
end

---Collect every other player's character, for the no-wall-check ray.
---@return table
local function getEnemyCharacters()
	local characters = {}

	for _, player in ipairs(playersService:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			table.insert(characters, player.Character)
		end
	end

	return characters
end

---Cast the aim ray and return the first solid part it hits.
---@param origin Vector3
---@param direction Vector3
---@return RaycastResult?
local function castAimRay(origin, direction)
	local character = localPlayer.Character
	if not character then
		return nil
	end

	-- Without a wall check, only player characters can be hit, so walls are ignored.
	if not Config.wallCheck then
		rayParams.FilterType = Enum.RaycastFilterType.Include
		rayParams.FilterDescendantsInstances = getEnemyCharacters()
		return workspace:Raycast(origin, direction, rayParams)
	end

	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local ignore = { character }
	local result = nil

	-- Step through near-invisible parts so they don't count as walls.
	for _ = 1, MAX_WALL_STEPS do
		rayParams.FilterDescendantsInstances = ignore
		result = workspace:Raycast(origin, direction, rayParams)

		if not result then
			return nil
		end

		local part = result.Instance
		local model = part:FindFirstAncestorOfClass("Model")
		local isPlayerPart = model ~= nil and playersService:GetPlayerFromCharacter(model) ~= nil

		if isPlayerPart or part.Transparency < SEE_THROUGH_TRANSPARENCY then
			return result
		end

		table.insert(ignore, part)
	end

	return nil
end

---Return the enemy player under the aim point, if any and visible.
---@return Player?
local function getTargetPlayer()
	if not localPlayer.Character then
		return nil
	end

	local point = getAimPoint()
	local ray = currentCamera:ViewportPointToRay(point.X, point.Y)
	local result = castAimRay(ray.Origin, ray.Direction * Config.maxDistance)
	if not result then
		return nil
	end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model then
		return nil
	end

	local player = playersService:GetPlayerFromCharacter(model)
	if not player or player == localPlayer then
		return nil
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	if Config.teamCheck and isTeammate(player) then
		return nil
	end

	return player
end

---Check if the trigger key currently allows firing.
---@return boolean
local function isActive()
	if Config.mode == "Always" then
		return true
	end

	if Config.mode == "Hold" then
		return held
	end

	return toggled
end

---Perform one output action: M1, M2, or a keyboard key.
local function fire()
	local bind = Config.fireBind

	-- Our own output echoes back as input; ignore it briefly so binds don't self-trigger.
	ignoreInputUntil = os.clock() + 0.15 + KEY_HOLD_TIME

	if isMouseBind(bind) then
		botShotUntil = os.clock() + 0.15
	end

	if bind and bind.kind == "KeyCode" then
		local virtualKey = toVirtualKey(bind.code)

		-- Fall back to the enum if the key has no known virtual-key code.
		local keyArgument = virtualKey or bind.code

		keypress(keyArgument)
		task.wait(KEY_HOLD_TIME)
		keyrelease(keyArgument)
	elseif bind and bind.code == Enum.UserInputType.MouseButton2 then
		mouse2click()
	else
		mouse1click()
	end
end

---Start holding the output bind down.
local function startHold()
	if holding then
		return
	end

	holdBind = Config.fireBind
	holding = true

	-- Ignore the echo of our own press so binds don't self-trigger.
	ignoreInputUntil = os.clock() + 0.3
	pressOutput(holdBind)
end

---Release the held output bind.
local function stopHold()
	if not holding then
		return
	end

	holding = false
	ignoreInputUntil = os.clock() + 0.3
	releaseOutput(holdBind)
	holdBind = nil
	lastClick = os.clock()
end

--------------------------------------------------------------------------------
-- Soft aim
--------------------------------------------------------------------------------

---Pick the body part to aim at for a character.
---@param character Model
---@return BasePart?
local function getAimPart(character)
	local root = character:FindFirstChild("HumanoidRootPart")

	if Config.aimPart == "Head" then
		return character:FindFirstChild("Head") or root
	end

	return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or root
end

---Check that nothing solid sits between the camera and a part.
---@param part BasePart
---@param character Model
---@return boolean
local function isPartVisible(part, character)
	local origin = currentCamera.CFrame.Position
	local direction = part.Position - origin
	local ignore = { localPlayer.Character }

	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	for _ = 1, MAX_WALL_STEPS do
		rayParams.FilterDescendantsInstances = ignore
		local result = workspace:Raycast(origin, direction, rayParams)

		if not result then
			return true
		end

		local hit = result.Instance

		if hit:IsDescendantOf(character) then
			return true
		end

		if hit.Transparency < SEE_THROUGH_TRANSPARENCY then
			return false
		end

		table.insert(ignore, hit)
	end

	return false
end

---Find the part closest to the aim point inside the FOV circle.
---@return BasePart?
local function getAimTarget()
	if not localPlayer.Character then
		return nil
	end

	local point = getAimPoint()
	local cameraPosition = currentCamera.CFrame.Position
	local closestPart, closestDistance = nil, Config.aimFov

	for _, player in ipairs(playersService:GetPlayers()) do
		if player == localPlayer then
			continue
		end

		if Config.teamCheck and isTeammate(player) then
			continue
		end

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end

		local part = getAimPart(character)
		if not part then
			continue
		end

		if (part.Position - cameraPosition).Magnitude > Config.aimDistance then
			continue
		end

		local screen, onScreen = currentCamera:WorldToViewportPoint(part.Position)
		if not onScreen then
			continue
		end

		local distance = (Vector2.new(screen.X, screen.Y) - point).Magnitude
		if distance >= closestDistance then
			continue
		end

		if Config.aimVisibleCheck and not isPartVisible(part, character) then
			continue
		end

		closestPart, closestDistance = part, distance
	end

	return closestPart
end

---Nudge the mouse toward the best target while the aim key is held.
local function updateAim()
	if not Config.aimEnabled then
		return
	end

	-- A cleared aim key means the aim is always on.
	if Config.aimBind and not aimHeld then
		return
	end

	if not isrbxactive() then
		return
	end

	if window and window:isMouseOver() then
		return
	end

	local part = getAimTarget()
	if not part then
		return
	end

	local screen = currentCamera:WorldToViewportPoint(part.Position)
	local delta = Vector2.new(screen.X, screen.Y) - getAimPoint()

	if delta.Magnitude < AIM_DEADZONE then
		return
	end

	local step = delta / Config.aimSmoothing
	mousemoverel(math.round(step.X), math.round(step.Y))
end

--------------------------------------------------------------------------------
-- Aim assist
--------------------------------------------------------------------------------

---Return a player's aim part and its screen distance if it is a valid assist target.
---@param player Player
---@param radius number
---@return BasePart?, number?
local function getAssistPart(player, radius)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	if Config.assistTeamCheck and isTeammate(player) then
		return nil
	end

	local part = getAimPart(character)
	if not part then
		return nil
	end

	if (part.Position - currentCamera.CFrame.Position).Magnitude > Config.assistDistance then
		return nil
	end

	local screen, onScreen = currentCamera:WorldToViewportPoint(part.Position)
	if not onScreen then
		return nil
	end

	local distance = (Vector2.new(screen.X, screen.Y) - getAimPoint()).Magnitude
	if distance > radius then
		return nil
	end

	if Config.assistVisibleCheck and not isPartVisible(part, character) then
		return nil
	end

	return part, distance
end

---Drop the current assist target and block instant re-latching.
local function releaseAssist()
	assistTarget = nil
	assistRemainder = Vector2.zero
	assistReleasedUntil = os.clock() + ASSIST_REACQUIRE_DELAY
end

---Weakly pull the cursor toward a latched player near the aim point.
local function updateAssist()
	if not Config.assistEnabled or not localPlayer.Character or not isrbxactive() then
		assistTarget = nil
		return
	end

	-- Soft aim overrides assist while it is active.
	if Config.aimEnabled and (not Config.aimBind or aimHeld) then
		assistTarget = nil
		return
	end

	if window and window:isMouseOver() then
		assistTarget = nil
		return
	end

	local part, distance

	-- Keep the latch until the target leaves the break radius.
	if assistTarget then
		part, distance = getAssistPart(assistTarget, Config.assistBreakRadius)

		if not part then
			releaseAssist()
			return
		end
	end

	-- Otherwise latch onto whoever is closest inside the capture radius.
	if not assistTarget then
		if os.clock() < assistReleasedUntil then
			return
		end

		local best = Config.assistRadius

		for _, player in ipairs(playersService:GetPlayers()) do
			if player == localPlayer then
				continue
			end

			local candidate, candidateDistance = getAssistPart(player, best)

			if candidate and candidateDistance < best then
				assistTarget, part, distance, best = player, candidate, candidateDistance, candidateDistance
			end
		end

		if not assistTarget then
			return
		end
	end

	local screen = currentCamera:WorldToViewportPoint(part.Position)
	local delta = Vector2.new(screen.X, screen.Y) - getAimPoint()

	if delta.Magnitude < AIM_DEADZONE then
		return
	end

	-- Pull fades toward the edge of the break radius so it is easy to overpower.
	local falloff = 1 - math.clamp(distance / Config.assistBreakRadius, 0, 1) * 0.5
	local move = delta * (Config.assistStrength / 100) * falloff + assistRemainder

	local moveX, moveY = math.round(move.X), math.round(move.Y)
	assistRemainder = move - Vector2.new(moveX, moveY)

	if moveX ~= 0 or moveY ~= 0 then
		mousemoverel(moveX, moveY)
	end
end

---Keep the FOV and assist circles in sync with the config.
local function updateFov()
	if fovCircle then
		local visible = Config.aimEnabled and Config.aimShowFov
		fovCircle.Visible = visible

		if visible then
			fovCircle.Position = getAimPoint()
			fovCircle.Radius = Config.aimFov
		end
	end

	if assistCircle then
		assistCircle.Visible = Config.assistEnabled and Config.assistShowRadius

		if assistCircle.Visible then
			assistCircle.Position = getAimPoint()
			assistCircle.Radius = Config.assistRadius
		end
	end
end

--------------------------------------------------------------------------------
-- No recoil
--------------------------------------------------------------------------------

---Check if a shot is currently being fired, by hand or by the trigger bot.
---@return boolean
local function isShooting()
	if Config.recoilManual and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		return true
	end

	if Config.recoilBot then
		if holding and isMouseBind(holdBind) then
			return true
		end

		if os.clock() < botShotUntil then
			return true
		end
	end

	return false
end

---Pull the mouse against the recoil kick while shooting.
---@param deltaTime number
local function updateRecoil(deltaTime)
	if not Config.recoilEnabled or not isrbxactive() then
		recoilStart = nil
		recoilRemainder = Vector2.zero
		return
	end

	-- Never drag the mouse while clicking inside the menu.
	if window and window:isMouseOver() then
		recoilStart = nil
		return
	end

	if not isShooting() then
		recoilStart = nil
		recoilRemainder = Vector2.zero
		return
	end

	local now = os.clock()
	recoilStart = recoilStart or now

	-- Ramp the pull in so the first frames of a burst aren't over-corrected.
	local ramp = 1

	if Config.recoilRamp > 0 then
		ramp = math.clamp((now - recoilStart) * 1000 / Config.recoilRamp, 0, 1)
	end

	-- Strength is pixels per frame at 60 FPS, scaled so it stays constant at any frame rate.
	local move = Vector2.new(Config.recoilX, Config.recoilY) * (deltaTime * 60) * ramp + recoilRemainder

	local moveX, moveY = math.round(move.X), math.round(move.Y)
	recoilRemainder = move - Vector2.new(moveX, moveY)

	if moveX ~= 0 or moveY ~= 0 then
		mousemoverel(moveX, moveY)
	end
end

--------------------------------------------------------------------------------
-- Fullbright
--------------------------------------------------------------------------------

---Remember the lighting values the game had before fullbright touched them.
local function saveLighting()
	savedLighting = {
		Brightness = lightingService.Brightness,
		ClockTime = lightingService.ClockTime,
		FogStart = lightingService.FogStart,
		FogEnd = lightingService.FogEnd,
		GlobalShadows = lightingService.GlobalShadows,
		Ambient = lightingService.Ambient,
		OutdoorAmbient = lightingService.OutdoorAmbient,
		ExposureCompensation = lightingService.ExposureCompensation,
	}
end

---Put the original lighting back.
local function restoreLighting()
	if savedLighting then
		for property, value in pairs(savedLighting) do
			pcall(function()
				lightingService[property] = value
			end)
		end

		savedLighting = nil
	end

	for atmosphere, density in pairs(savedAtmospheres) do
		pcall(function()
			atmosphere.Density = density
		end)
	end

	table.clear(savedAtmospheres)
end

---Write a lighting property only when it differs, so we don't spam changed events.
---@param property string
---@param value any
local function setLighting(property, value)
	if lightingService[property] ~= value then
		lightingService[property] = value
	end
end

---Keep the lighting bright every frame, since games often reset it.
local function updateFullbright()
	if not Config.fbEnabled then
		if savedLighting or next(savedAtmospheres) then
			restoreLighting()
		end

		return
	end

	if not savedLighting then
		saveLighting()
	end

	setLighting("Brightness", Config.fbBrightness)
	setLighting("Ambient", FULLBRIGHT_AMBIENT)
	setLighting("OutdoorAmbient", FULLBRIGHT_AMBIENT)
	setLighting("ExposureCompensation", 0)

	if Config.fbDaytime then
		setLighting("ClockTime", FULLBRIGHT_CLOCK_TIME)
	end

	if Config.fbNoShadows then
		setLighting("GlobalShadows", false)
	end

	if Config.fbNoFog then
		setLighting("FogStart", 1e9)
		setLighting("FogEnd", 1e9)

		-- Atmosphere objects add their own haze on top of normal fog.
		for _, child in ipairs(lightingService:GetChildren()) do
			if child:IsA("Atmosphere") then
				if savedAtmospheres[child] == nil then
					savedAtmospheres[child] = child.Density
				end

				if child.Density ~= 0 then
					child.Density = 0
				end
			end
		end
	else
		-- Fog was turned off in the menu while fullbright stays on.
		for atmosphere, density in pairs(savedAtmospheres) do
			pcall(function()
				atmosphere.Density = density
			end)
		end

		table.clear(savedAtmospheres)

		if savedLighting then
			setLighting("FogStart", savedLighting.FogStart)
			setLighting("FogEnd", savedLighting.FogEnd)
		end
	end

	-- Undo shadows and time of day if those options were turned off.
	if savedLighting then
		if not Config.fbNoShadows then
			setLighting("GlobalShadows", savedLighting.GlobalShadows)
		end

		if not Config.fbDaytime then
			setLighting("ClockTime", savedLighting.ClockTime)
		end
	end
end

--------------------------------------------------------------------------------
-- ESP
--------------------------------------------------------------------------------

---Create a Drawing object with the given properties.
---@param className string
---@param properties table
---@return table
local function newDrawing(className, properties)
	local object = Drawing.new(className)

	for key, value in pairs(properties) do
		object[key] = value
	end

	return object
end

---Create the set of Drawing objects for one player.
---@return table
local function createEsp()
	return {
		boxOutline = newDrawing("Square", {
			Thickness = 3, Filled = false, Color = Color3.new(0, 0, 0), Transparency = 1, ZIndex = 1, Visible = false,
		}),
		box = newDrawing("Square", {
			Thickness = 1, Filled = false, Transparency = 1, ZIndex = 2, Visible = false,
		}),
		healthBack = newDrawing("Square", {
			Thickness = 1, Filled = true, Color = Color3.new(0, 0, 0), Transparency = 1, ZIndex = 1, Visible = false,
		}),
		healthFill = newDrawing("Square", {
			Thickness = 1, Filled = true, Transparency = 1, ZIndex = 2, Visible = false,
		}),
		name = newDrawing("Text", {
			Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.Plex, Transparency = 1, ZIndex = 3, Visible = false,
		}),
		distance = newDrawing("Text", {
			Size = 13, Center = true, Outline = true, Font = Drawing.Fonts.Plex, Transparency = 1, ZIndex = 3, Visible = false,
		}),
		tracer = newDrawing("Line", {
			Thickness = 1, Transparency = 1, ZIndex = 1, Visible = false,
		}),
	}
end

---Hide every Drawing object of one player.
---@param esp table
local function hideEsp(esp)
	for _, object in pairs(esp) do
		object.Visible = false
	end
end

---Remove and forget one player's Drawing objects.
---@param player Player
local function removeEsp(player)
	local esp = espObjects[player]
	if not esp then
		return
	end

	for _, object in pairs(esp) do
		pcall(function()
			object:Remove()
		end)
	end

	espObjects[player] = nil
end

---Update one player's ESP from their current character.
---@param player Player
---@param esp table
local function updateEspPlayer(player, esp)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoid and root and humanoid.Health > 0) then
		hideEsp(esp)
		return
	end

	local teammate = isTeammate(player)
	if teammate and Config.espHideTeam then
		hideEsp(esp)
		return
	end

	local distance = (root.Position - currentCamera.CFrame.Position).Magnitude
	if distance > Config.espDistance then
		hideEsp(esp)
		return
	end

	local top = currentCamera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.6, 0))
	local bottom = currentCamera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

	-- Behind the camera.
	if top.Z <= 0 or bottom.Z <= 0 then
		hideEsp(esp)
		return
	end

	local color = teammate and TEAM_COLOR or ESP_COLORS[Config.espColor]
	local height = math.abs(bottom.Y - top.Y)
	local width = height * 0.55
	local centerX = top.X
	local position = Vector2.new(math.floor(centerX - width / 2), math.floor(top.Y))
	local size = Vector2.new(math.floor(width), math.floor(height))

	esp.box.Visible = Config.espBoxes
	esp.boxOutline.Visible = Config.espBoxes
	esp.box.Color = color
	esp.box.Position = position
	esp.box.Size = size
	esp.boxOutline.Position = position
	esp.boxOutline.Size = size

	-- Health bar sits on the left edge of the box.
	local ratio = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
	local fillHeight = math.floor(size.Y * ratio)

	esp.healthBack.Visible = Config.espHealth
	esp.healthFill.Visible = Config.espHealth
	esp.healthBack.Position = Vector2.new(position.X - 6, position.Y - 1)
	esp.healthBack.Size = Vector2.new(4, size.Y + 2)
	esp.healthFill.Position = Vector2.new(position.X - 5, position.Y + size.Y - fillHeight)
	esp.healthFill.Size = Vector2.new(2, fillHeight)
	esp.healthFill.Color = Color3.fromRGB(255, 50, 50):Lerp(Color3.fromRGB(50, 255, 90), ratio)

	esp.name.Visible = Config.espNames
	esp.name.Text = player.Name
	esp.name.Color = color
	esp.name.Position = Vector2.new(centerX, position.Y - 16)

	esp.distance.Visible = Config.espDistanceText
	esp.distance.Text = string.format("[%d]", distance)
	esp.distance.Color = color
	esp.distance.Position = Vector2.new(centerX, position.Y + size.Y + 2)

	local viewport = currentCamera.ViewportSize

	esp.tracer.Visible = Config.espTracers
	esp.tracer.Color = color
	esp.tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
	esp.tracer.To = Vector2.new(centerX, position.Y + size.Y)
end

---Update the ESP for every other player.
local function updateEsp()
	if not Config.espEnabled then
		for _, esp in pairs(espObjects) do
			hideEsp(esp)
		end

		return
	end

	for _, player in ipairs(playersService:GetPlayers()) do
		if player == localPlayer then
			continue
		end

		local esp = espObjects[player]

		if not esp then
			esp = createEsp()
			espObjects[player] = esp
		end

		updateEspPlayer(player, esp)
	end
end

--------------------------------------------------------------------------------
-- Trigger bot
--------------------------------------------------------------------------------

---Fire clicks or hold fire while an enemy is under the aim point.
local function updateTrigger()
	local allowed = Config.enabled
		and isActive()
		and isrbxactive()
		and not (window and window:isMouseOver())

	-- Hold fire: press once, keep holding while the target stays under the aim point.
	if Config.fireStyle == "Hold" then
		local now = os.clock()

		if allowed and getTargetPlayer() then
			lastTargetSeen = now

			if not holding and not pending then
				pending = true

				task.delay(Config.reactionDelay / 1000, function()
					pending = false

					-- Re-check so we don't start holding after the target has gone.
					if Config.fireStyle == "Hold"
						and Config.enabled
						and isActive()
						and not (window and window:isMouseOver())
						and getTargetPlayer()
					then
						lastTargetSeen = os.clock()
						startHold()
					end
				end)
			end
		elseif holding and (not allowed or now - lastTargetSeen > Config.holdRelease / 1000) then
			stopHold()
		end

		return
	end

	-- Switching away from hold fire must not leave the button stuck down.
	if holding then
		stopHold()
	end

	if not allowed or pending then
		return
	end

	if (os.clock() - lastClick) * 1000 < Config.clickCooldown then
		return
	end

	if not getTargetPlayer() then
		return
	end

	pending = true

	task.delay(Config.reactionDelay / 1000, function()
		pending = false

		-- Re-check so we don't fire after the target has moved off or gone behind cover.
		if Config.enabled and isActive() and not (window and window:isMouseOver()) and getTargetPlayer() then
			lastClick = os.clock()
			fire()
		end
	end)
end

---Per-frame update for the status line, ESP, aim, recoil, fullbright and trigger.
---@param deltaTime number
local function onRenderStep(deltaTime)
	if statusLabel then
		local status = "status: " .. ((Config.enabled and isActive()) and "active" or "idle")

		if holding then
			status = status .. " (holding)"
		end

		if statusLabel.Text ~= status then
			statusLabel.Text = status
		end
	end

	updateEsp()
	updateFov()
	updateAim()
	updateAssist()
	updateTrigger()
	updateRecoil(deltaTime)
	updateFullbright()
end

---Handle keybind capture, the menu key, the aim key, and the trigger key.
---@param input InputObject
---@param processed boolean
local function onInputBegan(input, processed)
	if not window then
		return
	end

	if window:handleCapture(input) then
		return
	end

	if processed then
		return
	end

	if os.clock() < ignoreInputUntil and matchesBind(Config.fireBind, input) then
		return
	end

	if input.KeyCode == MENU_KEY then
		window:toggle()
		return
	end

	if matchesBind(Config.aimBind, input) then
		aimHeld = true
	end

	if matchesBind(Config.bind, input) then
		if Config.mode == "Toggle" then
			toggled = not toggled
		elseif Config.mode == "Hold" then
			held = true
		end
	end
end

---Release hold states when their keys come up.
---@param input InputObject
local function onInputEnded(input)
	if matchesBind(Config.aimBind, input) then
		aimHeld = false
	end

	if os.clock() < ignoreInputUntil and matchesBind(Config.fireBind, input) then
		return
	end

	if matchesBind(Config.bind, input) then
		held = false
	end
end

---Add a button that cycles a Config string through a list of options.
---@param container Container
---@param label string
---@param options table
---@param key string
---@param onChange function?
---@return TextButton
local function addCycle(container, label, options, key, onChange)
	local button

	button = container:button(label .. ": " .. tostring(Config[key]), function()
		local index = table.find(options, Config[key]) or 1

		Config[key] = options[index % #options + 1]
		button.Text = label .. ": " .. Config[key]

		if onChange then
			onChange()
		end
	end)

	return button
end

---Build the window, menus, and tabs.
local function buildWindow()
	window = Gui.new("Trigger Bot")

	window:menu("Menu", function()
		return {
			{ text = "Hide window", callback = function() window:toggle() end },
			{ text = "Unload", callback = TriggerBot.detach },
		}
	end)

	window:menu("Theme", function()
		local items = {}

		for _, name in ipairs(Gui.themeOrder) do
			table.insert(items, {
				text = name,
				checked = window.themeName == name,
				callback = function()
					window:setTheme(name)
				end,
			})
		end

		return items
	end)

	local tabs = window:tabBar()

	-- Main tab: trigger bot.
	local mainTab = tabs:tab("Main")

	mainTab:checkbox("Enabled", Config.enabled, function(value)
		Config.enabled = value
	end)

	mainTab:checkbox("Team check", Config.teamCheck, function(value)
		Config.teamCheck = value
	end)

	mainTab:checkbox("Wall check", Config.wallCheck, function(value)
		Config.wallCheck = value
	end)

	mainTab:separator()

	mainTab:keybind("trigger key", Config.bind, function(bind)
		Config.bind = bind
		held = false
	end)

	addCycle(mainTab, "mode", MODES, "mode", function()
		held = false
	end)

	statusLabel = mainTab:label("", true)

	mainTab:separator()

	mainTab:keybind("output key", Config.fireBind, function(bind)
		-- Clearing the output key falls back to M1.
		Config.fireBind = bind or { kind = "UserInputType", code = Enum.UserInputType.MouseButton1 }

		-- A held key must be released with the bind it was pressed with, then re-pressed.
		stopHold()
	end)

	addCycle(mainTab, "fire style", FIRE_STYLES, "fireStyle", function()
		stopHold()
	end)

	addCycle(mainTab, "aim at", AIM_MODES, "aimAt")

	mainTab:separator()

	mainTab:slider("max distance", 50, 2000, Config.maxDistance, 10, function(value)
		Config.maxDistance = value
	end, "%d studs")

	-- Aim tab: soft aim and aim assist.
	local aimTab = tabs:tab("Aim")

	aimTab:checkbox("Soft aim", Config.aimEnabled, function(value)
		Config.aimEnabled = value
	end)

	aimTab:checkbox("Visible check", Config.aimVisibleCheck, function(value)
		Config.aimVisibleCheck = value
	end)

	aimTab:checkbox("Show FOV", Config.aimShowFov, function(value)
		Config.aimShowFov = value
	end)

	aimTab:separator()

	aimTab:keybind("aim key", Config.aimBind, function(bind)
		Config.aimBind = bind
		aimHeld = false
	end)

	addCycle(aimTab, "target", AIM_PARTS, "aimPart")

	aimTab:separator()

	aimTab:slider("fov radius", 20, 600, Config.aimFov, 5, function(value)
		Config.aimFov = value
	end, "%d px")

	aimTab:slider("smoothing", 1, 30, Config.aimSmoothing, 1, function(value)
		Config.aimSmoothing = value
	end)

	aimTab:slider("aim distance", 50, 2000, Config.aimDistance, 10, function(value)
		Config.aimDistance = value
	end, "%d studs")

	aimTab:separator()

	aimTab:checkbox("Aim assist", Config.assistEnabled, function(value)
		Config.assistEnabled = value

		if not value then
			assistTarget = nil
		end
	end)

	aimTab:checkbox("Assist team check", Config.assistTeamCheck, function(value)
		Config.assistTeamCheck = value
	end)

	aimTab:checkbox("Assist visible check", Config.assistVisibleCheck, function(value)
		Config.assistVisibleCheck = value
	end)

	aimTab:checkbox("Show assist radius", Config.assistShowRadius, function(value)
		Config.assistShowRadius = value
	end)

	aimTab:slider("assist strength", 1, 40, Config.assistStrength, 1, function(value)
		Config.assistStrength = value
	end, "%d%%")

	aimTab:slider("capture radius", 20, 300, Config.assistRadius, 5, function(value)
		Config.assistRadius = value
	end, "%d px")

	aimTab:slider("break radius", 40, 500, Config.assistBreakRadius, 5, function(value)
		Config.assistBreakRadius = value
	end, "%d px")

	aimTab:slider("assist distance", 50, 2000, Config.assistDistance, 10, function(value)
		Config.assistDistance = value
	end, "%d studs")

	-- Recoil tab.
	local recoilTab = tabs:tab("Recoil")

	recoilTab:checkbox("No recoil", Config.recoilEnabled, function(value)
		Config.recoilEnabled = value
	end)

	recoilTab:checkbox("My shots (M1 held)", Config.recoilManual, function(value)
		Config.recoilManual = value
	end)

	recoilTab:checkbox("Trigger bot shots", Config.recoilBot, function(value)
		Config.recoilBot = value
	end)

	recoilTab:separator()

	recoilTab:slider("pull down", 0, 30, Config.recoilY, 0.5, function(value)
		Config.recoilY = value
	end, "%.1f px")

	recoilTab:slider("pull sideways", -10, 10, Config.recoilX, 0.5, function(value)
		Config.recoilX = value
	end, "%.1f px")

	recoilTab:slider("ramp up", 0, 1000, Config.recoilRamp, 25, function(value)
		Config.recoilRamp = value
	end, "%d ms")

	-- ESP tab.
	local espTab = tabs:tab("ESP")

	espTab:checkbox("ESP", Config.espEnabled, function(value)
		Config.espEnabled = value
	end)

	espTab:checkbox("Boxes", Config.espBoxes, function(value)
		Config.espBoxes = value
	end)

	espTab:checkbox("Names", Config.espNames, function(value)
		Config.espNames = value
	end)

	espTab:checkbox("Health bars", Config.espHealth, function(value)
		Config.espHealth = value
	end)

	espTab:checkbox("Distance", Config.espDistanceText, function(value)
		Config.espDistanceText = value
	end)

	espTab:checkbox("Tracers", Config.espTracers, function(value)
		Config.espTracers = value
	end)

	espTab:checkbox("Hide teammates", Config.espHideTeam, function(value)
		Config.espHideTeam = value
	end)

	espTab:separator()

	addCycle(espTab, "color", ESP_COLOR_NAMES, "espColor")

	espTab:slider("esp distance", 50, 3000, Config.espDistance, 50, function(value)
		Config.espDistance = value
	end, "%d studs")

	-- World tab: fullbright.
	local worldTab = tabs:tab("World")

	worldTab:checkbox("Fullbright", Config.fbEnabled, function(value)
		Config.fbEnabled = value
	end)

	worldTab:checkbox("Force daytime", Config.fbDaytime, function(value)
		Config.fbDaytime = value
	end)

	worldTab:checkbox("Remove shadows", Config.fbNoShadows, function(value)
		Config.fbNoShadows = value
	end)

	worldTab:checkbox("Remove fog", Config.fbNoFog, function(value)
		Config.fbNoFog = value
	end)

	worldTab:separator()

	worldTab:slider("brightness", 0, 5, Config.fbBrightness, 0.25, function(value)
		Config.fbBrightness = value
	end, "%.2f")

	-- Timing tab.
	local timingTab = tabs:tab("Timing")

	timingTab:slider("reaction delay", 0, 300, Config.reactionDelay, 5, function(value)
		Config.reactionDelay = value
	end, "%d ms")

	timingTab:slider("click cooldown", 20, 500, Config.clickCooldown, 10, function(value)
		Config.clickCooldown = value
	end, "%d ms")

	timingTab:slider("hold release delay", 0, 500, Config.holdRelease, 10, function(value)
		Config.holdRelease = value
	end, "%d ms")

	-- Settings tab.
	local settingsTab = tabs:tab("Settings")

	local themeHeader = settingsTab:collapsingHeader("Themes", true)

	for _, name in ipairs(Gui.themeOrder) do
		themeHeader:button(name, function()
			window:setTheme(name)
		end)
	end

	local helpHeader = settingsTab:collapsingHeader("Help", false)
	helpHeader:label("Trigger key: arms the bot", true)
	helpHeader:label("Output key: what it presses (M1/M2/key)", true)
	helpHeader:label("Fire style: Click taps, Hold keeps it down", true)
	helpHeader:label("Hold release delay: grace after target lost", true)
	helpHeader:label("Aim key: hold to soft aim", true)
	helpHeader:label("Aim key cleared: soft aim always on", true)
	helpHeader:label("Aim assist: weak auto-latch, look away to drop", true)
	helpHeader:label("No recoil: pulls mouse down while shooting", true)
	helpHeader:label("Fullbright: World tab, restores on disable", true)
	helpHeader:label("Insert: show / hide menu", true)
end

---Remove every Drawing object this script owns.
local function clearDrawings()
	for player in pairs(espObjects) do
		removeEsp(player)
	end

	if fovCircle then
		pcall(function()
			fovCircle:Remove()
		end)

		fovCircle = nil
	end

	if assistCircle then
		pcall(function()
			assistCircle:Remove()
		end)

		assistCircle = nil
	end
end

---Disconnect everything and clear shared state.
function TriggerBot.detach()
	-- Never leave the output button stuck down after unloading.
	stopHold()

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	clearDrawings()

	-- Give the game its original lighting back.
	restoreLighting()

	if window then
		window:destroy()
		window = nil
	end

	statusLabel = nil
	assistTarget = nil
	shared.TriggerBot = nil
end

---Hook up connections and build the GUI.
function TriggerBot.init()
	buildWindow()

	fovCircle = newDrawing("Circle", {
		Thickness = 1, NumSides = 64, Filled = false, Color = Color3.new(1, 1, 1), Transparency = 1, Visible = false,
	})

	assistCircle = newDrawing("Circle", {
		Thickness = 1, NumSides = 64, Filled = false, Color = Color3.fromRGB(255, 220, 70), Transparency = 1, Visible = false,
	})

	table.insert(connections, runService.RenderStepped:Connect(onRenderStep))
	table.insert(connections, userInputService.InputBegan:Connect(onInputBegan))
	table.insert(connections, userInputService.InputEnded:Connect(onInputEnded))
	table.insert(connections, playersService.PlayerRemoving:Connect(removeEsp))
end

---@param error string
local function onInitializeError(error)
	warn("Failed to initialize.")
	warn(error)
	warn(debug.traceback())
	TriggerBot.detach()
end

-- Replace any previous instance.
if shared.TriggerBot then
	shared.TriggerBot.detach()
end

shared.TriggerBot = TriggerBot

xpcall(TriggerBot.init, onInitializeError)
