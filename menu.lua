-- ============================================================================
-- ЧАСТЬ 1: ИНИЦИАЛИЗАЦИЯ ЯДРО СИСТЕМЫ, ГЛОБАЛЬНЫЕ КОННЕКТЫ И МИРОВЫЕ ЭФФЕКТЫ
-- ============================================================================
local oldGui = game:GetService("CoreGui"):FindFirstChild("CustomMenuGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CustomMenuGui")
if oldGui then oldGui:Destroy() end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CustomWorldEffects = workspace:FindFirstChild("PulseWorldEffects") or Instance.new("Folder", workspace)
CustomWorldEffects.Name = "PulseWorldEffects"

_G.PulseConfig = {
	MenuColor = Color3.fromRGB(0, 120, 255),
	MenuTransparency = 0,
	WatermarkEnabled = true,
	WatermarkCorner = "TopRight",
	WatermarkText = "Pulse Visuals | v2.0",
	
	CameraBobbing = false,
	BobbingIntensity = 1,
	SelfHighlight = false,
	CustomFOV = 70,
	AspectRatioValue = 1.0, -- Значение для растяга экрана
	Fullbright = false,
	
	ChinaHat = false,
	HatSize = 1.2,
	HatTransparency = 0,
	HatColor = Color3.fromRGB(190, 150, 90),
	
	JumpCircle = false,
	JumpCircleSize = 6,
	JumpCircleColor = Color3.fromRGB(0, 255, 255),
	
	MotionTrails = false,
	TrailColor = Color3.fromRGB(0, 120, 255),
	
	FakeHeadless = false,
	PlayerCoords = false,
	NameTags = false,
	BoxESP = false,
	ESPRange = 1000,
	ESPColorMode = "Static",
	ESPCustomColor = Color3.fromRGB(255, 0, 0),
	
	WalkSpeed = 16,
	JumpPower = 50,
	InfJump = false,
	Noclip = false,
	Fly = false,
	
	WorldParticles = "None",
}

local ActiveConnections = {}
local LocalCosmetics = {Hat = nil, Trail = nil, TrailA0 = nil, TrailA1 = nil}
local ViewportCosmetics = {Hat = nil}
local isJumpingState = false

local function UpdateWorldParticles(mode)
	CustomWorldEffects:ClearAllChildren()
	if ActiveConnections.WorldParticles then ActiveConnections.WorldParticles:Disconnect() end
	if mode == "None" then return end
	
	local emitterPart = Instance.new("Part", CustomWorldEffects)
	emitterPart.Size = Vector3.new(200, 1, 200)
	emitterPart.Transparency = 1
	emitterPart.Anchored = true
	emitterPart.CanCollide = false
	
	local attachment = Instance.new("Attachment", emitterPart)
	local emitter = Instance.new("ParticleEmitter", attachment)
	emitter.Rate = 180
	emitter.Lifetime = NumberRange.new(3, 4)
	
	if mode == "Snow" then
		emitter.Texture = "rbxassetid://12117565345"
		emitter.Speed = NumberRange.new(12, 22)
		emitter.Size = NumberSequence.new(0.4, 0.8)
	elseif mode == "Rain" then
		emitter.Texture = "rbxassetid://134707262"
		emitter.Speed = NumberRange.new(45, 65)
		emitter.Size = NumberSequence.new(1.2, 1.8)
	end
	
	ActiveConnections.WorldParticles = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			emitterPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 35, 0)
		end
	end)
end

local menuBlur = Lighting:FindFirstChild("MenuBlurEffect") or Instance.new("BlurEffect", Lighting)
menuBlur.Name = "MenuBlurEffect"
menuBlur.Size = 0

local colorCorrection = Lighting:FindFirstChild("MenuColorCorrection") or Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Name = "MenuColorCorrection"

local bloomEffect = Lighting:FindFirstChild("MenuBloom") or Instance.new("BloomEffect", Lighting)
bloomEffect.Name = "MenuBloom"

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 0 

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local BlurOverlay = Instance.new("Frame")
BlurOverlay.Size = UDim2.new(1, 0, 1, 0)
BlurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlurOverlay.BackgroundTransparency = 1
BlurOverlay.BorderSizePixel = 0
BlurOverlay.Parent = ScreenGui

local MenuParticleContainer = Instance.new("Frame")
MenuParticleContainer.Size = UDim2.new(1, 0, 1, 0)
MenuParticleContainer.BackgroundTransparency = 1
MenuParticleContainer.BorderSizePixel = 0
MenuParticleContainer.ClipsDescendants = true
MenuParticleContainer.Parent = BlurOverlay

local menuFlakes = {}
for i = 1, 35 do
	local flake = Instance.new("Frame")
	flake.Size = UDim2.new(0, math.random(3, 5), 0, math.random(3, 5))
	flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flake.BackgroundTransparency = math.random(3, 7) / 10
	flake.BorderSizePixel = 0
	flake.Position = UDim2.new(math.random(), 0, -0.05, 0)
	flake.Parent = MenuParticleContainer
	table.insert(menuFlakes, {gui = flake, speed = math.random(20, 40) / 100, drift = (math.random() - 0.5) / 150})
end

RunService.RenderStepped:Connect(function(dt)
	if BlurOverlay.BackgroundTransparency < 1 and BlurOverlay.Visible then
		for _, f in pairs(menuFlakes) do
			local curY = f.gui.Position.Y.Scale
			local curX = f.gui.Position.X.Scale
			if curY > 1.02 then
				f.gui.Position = UDim2.new(math.random(), 0, -0.02, 0)
			else
				f.gui.Position = UDim2.new(curX + f.drift, 0, curY + f.speed * dt, 0)
			end
		end
	end
end)

-- ============================================================================
-- ЧАСТЬ 2: СБОРКА ИНТЕРФЕЙСА, ПАНЕЛЕЙ И КОНСТРУКТОРЫ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ
-- ============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 400)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Text = "Pulse Visuals"
MenuTitle.Size = UDim2.new(1, 0, 0, 25)
MenuTitle.Position = UDim2.new(0, 0, 0, 12)
MenuTitle.TextColor3 = _G.PulseConfig.MenuColor
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.TextSize = 18
MenuTitle.BackgroundTransparency = 1
MenuTitle.Parent = Sidebar

local MenuSubtitle = Instance.new("TextLabel")
MenuSubtitle.Text = "by vgtimes"
MenuSubtitle.Size = UDim2.new(1, 0, 0, 15)
MenuSubtitle.Position = UDim2.new(0, 0, 0, 32)
MenuSubtitle.TextColor3 = Color3.fromRGB(130, 130, 130)
MenuSubtitle.Font = Enum.Font.SourceSansItalic
MenuSubtitle.TextSize = 12
MenuSubtitle.BackgroundTransparency = 1
MenuSubtitle.Parent = Sidebar

local TabsContainer = Instance.new("ScrollingFrame")
TabsContainer.Size = UDim2.new(1, 0, 1, -95)
TabsContainer.Position = UDim2.new(0, 0, 0, 60)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsContainer.ScrollBarThickness = 0
TabsContainer.Parent = Sidebar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Parent = TabsContainer
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 4)

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -160, 1, -20)
PagesContainer.Position = UDim2.new(0, 155, 0, 10)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local PreviewPane = Instance.new("Frame")
PreviewPane.Name = "PreviewPane"
PreviewPane.Position = UDim2.new(1, 5, 0, 0) 
PreviewPane.Size = UDim2.new(0, 240, 1, 0)
PreviewPane.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
PreviewPane.BorderSizePixel = 0
PreviewPane.BackgroundTransparency = 1
PreviewPane.Parent = MainFrame
Instance.new("UICorner", PreviewPane).CornerRadius = UDim.new(0, 8)

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -20, 1, -20)
Viewport.Position = UDim2.new(0, 10, 0, 10)
Viewport.BackgroundTransparency = 1
Viewport.Parent = PreviewPane

local vpCamera = Instance.new("Camera")
Viewport.CurrentCamera = vpCamera
vpCamera.Parent = Viewport

local vpModel = nil

local function RefreshViewportCharacter()
	Viewport:ClearAllChildren()
	vpCamera = Instance.new("Camera", Viewport)
	Viewport.CurrentCamera = vpCamera
	
	if not LocalPlayer.Character then return end
	LocalPlayer.Character.Archivable = true
	vpModel = LocalPlayer.Character:Clone()
	LocalPlayer.Character.Archivable = false
	
	for _, child in pairs(vpModel:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") then child:Destroy() end
	end
	
	vpModel.Parent = Viewport
	local hrp = vpModel:WaitForChild("HumanoidRootPart")
	vpCamera.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 5.5 + Vector3.new(0, 0.5, 0), hrp.Position)
end

local rotationAngle = 0
RunService.RenderStepped:Connect(function(dt)
	if MainFrame.Visible and vpModel and vpModel:FindFirstChild("HumanoidRootPart") then
		rotationAngle = rotationAngle + dt * 45
		local hrp = vpModel.HumanoidRootPart
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.radians(rotationAngle), 0)
	end
end)

task.spawn(function()
	if LocalPlayer.Character then RefreshViewportCharacter() end
	LocalPlayer.CharacterAdded:Connect(function() task.wait(1) RefreshViewportCharacter() end)
end)

local pages = {}
local function createTab(name, layoutOrder)
	local TabButton = Instance.new("TextButton")
	TabButton.Size = UDim2.new(1, -10, 0, 32)
	TabButton.Position = UDim2.new(0, 5, 0, 0)
	TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TabButton.Text = "  " .. name
	TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
	TabButton.Font = Enum.Font.SourceSansBold
	TabButton.TextSize = 13
	TabButton.TextXAlignment = Enum.TextXAlignment.Left
	TabButton.LayoutOrder = layoutOrder
	TabButton.Parent = TabsContainer
	Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)
	
	TabButton.MouseEnter:Connect(function()
		TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = _G.PulseConfig.MenuColor, TextColor3 = Color3.new(1,1,1)}):Play()
	end)
	TabButton.MouseLeave:Connect(function()
		TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
	end)
	
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.Visible = false
	Page.CanvasSize = UDim2.new(0, 0, 2.5, 0)
	Page.ScrollBarThickness = 2
	Page.Parent = PagesContainer
	
	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Parent = Page
	PageLayout.Padding = UDim.new(0, 5)
	
	pages[name] = Page
	TabButton.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		Page.Visible = true
	end)
	return Page
end

local function createToggle(page, text, default, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, -5, 0, 32)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	ToggleFrame.Parent = page
	Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 4)
	
	local Label = Instance.new("TextLabel")
	Label.Text = "  " .. text
	Label.Size = UDim2.new(1, -60, 1, 0)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 42, 0, 20)
	Button.Position = UDim2.new(1, -50, 0.5, -10)
	Button.BackgroundColor3 = default and _G.PulseConfig.MenuColor or Color3.fromRGB(60, 60, 60)
	Button.Text = default and "ON" or "OFF"
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = Enum.Font.SourceSansBold
	Button.TextSize = 11
	Button.Parent = ToggleFrame
	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
	
	local state = default
	Button.MouseButton1Click:Connect(function()
		state = not state
		Button.Text = state and "ON" or "OFF"
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and _G.PulseConfig.MenuColor or Color3.fromRGB(60, 60, 60)}):Play()
		callback(state)
	end)
	return ToggleFrame
end

local function createSlider(page, text, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, -5, 0, 42)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	SliderFrame.Parent = page
	Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)
	
	local Label = Instance.new("TextLabel")
	Label.Text = string.format("  %s: %d", text, default)
	Label.Size = UDim2.new(1, 0, 0, 18)
	Label.BackgroundTransparency = 1
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame
	
	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1, -20, 0, 5)
	Track.Position = UDim2.new(0, 10, 0, 26)
	Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Track.BorderSizePixel = 0
	Track.Parent = SliderFrame
	
	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	Fill.BackgroundColor3 = _G.PulseConfig.MenuColor
	Fill.BorderSizePixel = 0
	Fill.Parent = Track
	
	local IsSliding = false
	local function updateSlider(input)
		local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(pos, 0, 1, 0)
		local val = math.floor(min + (max - min) * pos)
		Label.Text = string.format("  %s: %d", text, val)
		callback(val)
	end
	
	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = true updateSlider(input) end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if IsSliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = false end
	end)
end

-- ============================================================================
-- ЧАСТЬ 3: ИМПОРТИРОВАННЫЙ ФУНКЦИОНАЛ, РАСТЯГ ЭКРАНА, НАСТРОЙКИ И АНИМАЦИИ
-- ============================================================================
local tabVisuals = createTab("Visuals", 1)
local tabESP = createTab("ESP", 2)
local tabMovement = createTab("Movement", 3)
local tabWorld = createTab("World", 4)
local tabSettings = createTab("Settings", 5)
pages["Visuals"].Visible = true

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -5, 0, 30)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "🔍 Поиск функций визуалов..."
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.SourceSans
SearchBox.Parent = tabVisuals
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local filter = SearchBox.Text:lower()
	for _, element in pairs(tabVisuals:GetChildren()) do
		if element:IsA("Frame") then
			local lbl = element:FindFirstChildOfClass("TextLabel")
			if lbl then element.Visible = lbl.Text:lower():find(filter) and true or false end
		end
	end
end)

local function SyncChinaHat()
	if LocalCosmetics.Hat then LocalCosmetics.Hat:Destroy(); LocalCosmetics.Hat = nil end
	if ViewportCosmetics.Hat then ViewportCosmetics.Hat:Destroy(); ViewportCosmetics.Hat = nil end
	if not _G.PulseConfig.ChinaHat then return end
	
	local function createHatCone()
		local part = Instance.new("Part")
		part.Size = Vector3.new(1.8 * _G.PulseConfig.HatSize, 0.4 * _G.PulseConfig.HatSize, 1.8 * _G.PulseConfig.HatSize)
		part.Color = _G.PulseConfig.HatColor
		part.Material = Enum.Material.Wood
		part.Transparency = _G.PulseConfig.HatTransparency
		part.CanCollide = false
		part.Massless = true
		local mesh = Instance.new("SpecialMesh", part)
		mesh.MeshType = Enum.MeshType.Cone
		return part
	end
	
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
		LocalCosmetics.Hat = createHatCone()
		LocalCosmetics.Hat.Parent = LocalPlayer.Character
		local w = Instance.new("Weld", LocalCosmetics.Hat)
		w.Part0 = LocalPlayer.Character.Head; w.Part1 = LocalCosmetics.Hat; w.C0 = CFrame.new(0, 0.95, 0)
	end
	if vpModel and vpModel:FindFirstChild("Head") then
		ViewportCosmetics.Hat = createHatCone()
		ViewportCosmetics.Hat.Parent = vpModel
		local w = Instance.new("Weld", ViewportCosmetics.Hat)
		w.Part0 = vpModel.Head; w.Part1 = ViewportCosmetics.Hat; w.C0 = CFrame.new(0, 0.95, 0)
	end
end

-- Логика кастомного Растяга Экрана (Aspect Ratio Modifier)
local function SetAspectRatio(val)
	local scale = val / 100
	-- Модифицируем матрицу проекции камеры через коррекцию FOV и Scale
	Camera.FieldOfView = _G.PulseConfig.CustomFOV * (1 / math.clamp(scale, 0.1, 3))
end

-- Наполнение вкладок
createToggle(tabVisuals, "Покачивание камеры", false, function(v)
	_G.PulseConfig.CameraBobbing = v
	if v then
		ActiveConnections.Bobbing = RunService.RenderStepped:Connect(function()
			if _G.PulseConfig.CameraBobbing and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				local speed = LocalPlayer.Character.Humanoid.MoveDirection.Magnitude
				if speed > 0 then
					local t = os.clock() * 12
					Camera.CFrame = Camera.CFrame * CFrame.new(math.sin(t)*0.035 * _G.PulseConfig.BobbingIntensity, math.abs(math.cos(t))*0.025 * _G.PulseConfig.BobbingIntensity, 0)
				end
			end
		end)
	else
		if ActiveConnections.Bobbing then ActiveConnections.Bobbing:Disconnect() end
	end
end)

createToggle(tabVisuals, "China Hat (Конус над головой)", false, function(v) _G.PulseConfig.ChinaHat = v SyncChinaHat() end)
createSlider(tabVisuals, "Размер конуса", 1, 3, 1, function(v) _G.PulseConfig.HatSize = v SyncChinaHat() end)

RunService.Heartbeat:Connect(function()
	if not _G.PulseConfig.JumpCircle or not LocalPlayer.Character then return end
	local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		local state = hum:GetState()
		if state == Enum.HumanoidStateType.Jumping and not isJumpingState then
			isJumpingState = true
			local p = Instance.new("Part", workspace)
			p.Size = Vector3.new(_G.PulseConfig.JumpCircleSize, 0.1, _G.PulseConfig.JumpCircleSize)
			p.Shape = Enum.PartType.Cylinder
			p.Color = _G.PulseConfig.JumpCircleColor
			p.Material = Enum.Material.Neon
			p.Anchored = true; p.CanCollide = false
			p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.6, 0) * CFrame.Angles(0,0,math.radians(90))
			TweenService:Create(p, TweenInfo.new(0.45), {Size = Vector3.new(0.05, 16, 16), Transparency = 1}):Play()
			task.delay(0.45, function() p:Destroy() end)
		elseif state ~= Enum.HumanoidStateType.Jumping and isJumpingState then
			isJumpingState = false
		end
	end
end)

createToggle(tabVisuals, "Jump Circle (Круги при прыжке)", false, function(v) _G.PulseConfig.JumpCircle = v end)

-- НАСТРОЙКА РАСТЯГА ЭКРАНА В WORLD/RENDER
createSlider(tabWorld, "Растяг экрана (Aspect Ratio)", 50, 200, 100, function(v) SetAspectRatio(v) end)
createSlider(tabWorld, "Поле зрения FOV камеры", 70, 120, 70, function(v) _G.PulseConfig.CustomFOV = v Camera.FieldOfView = v end)
createToggle(tabWorld, "Эффект мира: Снегопад", false, function(v) UpdateWorldParticles(v and "Snow" or "None") end)

createSlider(tabMovement, "WalkSpeed (Скорость)", 16, 220, 16, function(v)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
end)
createToggle(tabMovement, "Noclip (Сквозь текстуры)", false, function(v)
	_G.PulseConfig.Noclip = v
	if v then
		ActiveConnections.Noclip = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if ActiveConnections.Noclip then ActiveConnections.Noclip:Disconnect() end
	end
end)

-- === МИНЕКРАФТ ИНТРО-АНИМАЦИЯ И КЛИЕНТСКИЙ ЦИКЛ ===
local toggleInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isMenuOpen = true

local function setGuiTransparency(targetTransparency)
	TweenService:Create(MainFrame, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	TweenService:Create(Sidebar, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	TweenService:Create(PreviewPane, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	local overlayTarget = targetTransparency == 0 and 0.45 or 1
	TweenService:Create(BlurOverlay, toggleInfo, {BackgroundTransparency = overlayTarget}):Play()
end

-- Реальное плавное кастомное Minecraft-интро вылета при инжекте
local introInfo = TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, 300) -- Старт далеко внизу
TweenService:Create(MainFrame, introInfo, {Position = UDim2.new(0.5, -325, 0.5, -200), BackgroundTransparency = 0}):Play()
TweenService:Create(Sidebar, introInfo, {BackgroundTransparency = 0}):Play()
TweenService:Create(PreviewPane, introInfo, {BackgroundTransparency = 0}):Play()
TweenService:Create(BlurOverlay, TweenInfo.new(0.5), {BackgroundTransparency = 0.45}):Play()

UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.RightShift then
		isMenuOpen = not isMenuOpen
		if isMenuOpen then
			BlurOverlay.Visible = true
			MainFrame.Visible = true 
			setGuiTransparency(0)
		else
			setGuiTransparency(1)
			task.delay(0.3, function() 
				if not isMenuOpen then 
					MainFrame.Visible = false 
					BlurOverlay.Visible = false -- Снег полностью отключается
				end 
			end)
		end
	end
end)

-- Плавное кастомное перемещение (Smooth Drag) для Главного Меню
local dragging = false; local dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		TweenService:Create(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		}):Play()
	end
end)
