-- ============================================================================
-- ЧАСТЬ 1: ИНИЦИАЛИЗАЦИЯ ДВИЖКА И ШЕЙДЕРОВ ОСВЕЩЕНИЯ
-- ============================================================================
local oldGui = game:GetService("CoreGui"):FindFirstChild("CustomMenuGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CustomMenuGui")
if oldGui then oldGui:Destroy() end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Глобальные состояния и коннекты для функций
local haloObject = nil
local haloRotationConnection = nil
local currentHaloColor = Color3.fromRGB(0, 255, 255)
local currentHaloSize = 1

local noclipConnection = nil
local infJumpConnection = nil
local flyConnection = nil
local autoClickConnection = nil

local isNoclip = false
local isInfJump = false
local isFly = false
local isAutoClick = false
local flySpeed = 50

-- Подготовка кастомных шейдеров в Lighting
local menuBlur = Lighting:FindFirstChild("MenuBlurEffect") or Instance.new("BlurEffect", Lighting)
menuBlur.Name = "MenuBlurEffect"
menuBlur.Size = 0

local colorCorrection = Lighting:FindFirstChild("MenuColorCorrection") or Instance.new("ColorCorrectionEffect", Lighting)
colorCorrection.Name = "MenuColorCorrection"

local bloomEffect = Lighting:FindFirstChild("MenuBloom") or Instance.new("BloomEffect", Lighting)
bloomEffect.Name = "MenuBloom"

-- ============================================================================
-- ЧАСТЬ 2: СОЗДАНИЕ ОСНОВНЫХ ОКОН И БРЕНДИНГАИНТЕРФЕЙСА
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Фоновое затемнение игры при открытии меню
local BlurOverlay = Instance.new("Frame")
BlurOverlay.Size = UDim2.new(1, 0, 1, 0)
BlurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlurOverlay.BackgroundTransparency = 1
BlurOverlay.BorderSizePixel = 0
BlurOverlay.Parent = ScreenGui

-- Главная панель
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

-- Сайдбар (Левая панель вкладок)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Логотип Pulse Visuals by vgtimes
local MenuTitle = Instance.new("TextLabel")
MenuTitle.Text = "Pulse Visuals"
MenuTitle.Size = UDim2.new(1, 0, 0, 25)
MenuTitle.Position = UDim2.new(0, 0, 0, 12)
MenuTitle.TextColor3 = Color3.fromRGB(0, 120, 255)
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

-- Никнейм игрока внизу сайдбара
local UserLabel = Instance.new("TextLabel")
UserLabel.Text = "User: " .. LocalPlayer.Name
UserLabel.Size = UDim2.new(1, -15, 0, 25)
UserLabel.Position = UDim2.new(0, 10, 1, -30)
UserLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
UserLabel.Font = Enum.Font.SourceSansSemibold
UserLabel.TextSize = 13
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.BackgroundTransparency = 1
UserLabel.Parent = Sidebar

-- Скролл-контейнеры для вкладок и страниц
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
TabsLayout.Padding = UDim.new(0, 5)

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -160, 1, -20)
PagesContainer.Position = UDim2.new(0, 155, 0, 10)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- ============================================================================
-- ЧАСТЬ 3: БОКОВАЯ ПАНЕЛЬ ПРЕВЬЮ И КОНСТРУКТОРЫ ЭЛЕМЕНТОВ УПРАВЛЕНИЯ
-- ============================================================================
local PreviewPane = Instance.new("Frame")
PreviewPane.Name = "PreviewPane"
PreviewPane.Position = UDim2.new(1, 5, 0, 0) 
PreviewPane.Size = UDim2.new(0, 240, 1, 0)
PreviewPane.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
PreviewPane.BorderSizePixel = 0
PreviewPane.BackgroundTransparency = 1
PreviewPane.Parent = MainFrame
Instance.new("UICorner", PreviewPane).CornerRadius = UDim.new(0, 8)

local PreviewTitle = Instance.new("TextLabel")
PreviewTitle.Text = "ИНФО / ПРЕВЬЮ"
PreviewTitle.Size = UDim2.new(1, 0, 0, 30)
PreviewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PreviewTitle.Font = Enum.Font.SourceSansBold
PreviewTitle.TextSize = 16
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Parent = PreviewPane

local PreviewStatus = Instance.new("TextLabel")
PreviewStatus.Size = UDim2.new(1, -20, 1, -40)
PreviewStatus.Position = UDim2.new(0, 10, 0, 35)
PreviewStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
PreviewStatus.Font = Enum.Font.SourceSans
PreviewStatus.TextSize = 14
PreviewStatus.TextXAlignment = Enum.TextXAlignment.Left
PreviewStatus.TextYAlignment = Enum.TextYAlignment.Top
PreviewStatus.BackgroundTransparency = 1
PreviewStatus.Parent = PreviewPane

local pages = {}

local function updatePreviewText()
	PreviewStatus.Text = string.format(
		"Нимб: %s\nNoclip: %s\nFly: %s\nInfJump: %s\nAutoClick: %s\n\nAnti-AFK: %s\nAnti-Fling: %s",
		haloObject and "Активен" or "Выкл",
		isNoclip and "ВКЛ" or "Выкл",
		isFly and "ВКЛ" or "Выкл",
		isInfJump and "ВКЛ" or "Выкл",
		isAutoClick and "ВКЛ" or "Выкл",
		_G.AntiAFKActive and "ВКЛ" or "Выкл",
		_G.AntiFlingActive and "ВКЛ" or "Выкл"
	)
end

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
	
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.Visible = false
	Page.CanvasSize = UDim2.new(0, 0, 2, 0)
	Page.ScrollBarThickness = 3
	Page.Parent = PagesContainer
	
	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Parent = Page
	PageLayout.Padding = UDim.new(0, 5)
	
	pages[name] = Page
	TabButton.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		Page.Visible = true
		updatePreviewText()
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
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 42, 0, 20)
	Button.Position = UDim2.new(1, -50, 0.5, -10)
	Button.BackgroundColor3 = default and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 60)
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
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 60)}):Play()
		callback(state)
		updatePreviewText()
	end)
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
	Label.TextSize = 13
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
	Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
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
-- ЧАСТЬ 4: НАПОЛНЕНИЕ ГРАФИЧЕСКИХ РАЗДЕЛОВ (VISUALS, EFFECTS, WORLD)
-- ============================================================================
local tabVisuals = createTab("Visuals", 1)
local tabEffects = createTab("Screen Effects", 2)
local tabWorld = createTab("World / Render", 3)
pages["Visuals"].Visible = true

-- Логика рендеринга 3D Нимба на персонаже
local function ToggleHalo(bool)
	if bool then
		if haloObject then haloObject:Destroy() end
		if haloRotationConnection then haloRotationConnection:Disconnect() end
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local head = character:WaitForChild("Head", 5)
		if not head then return end
		haloObject = Instance.new("Part", character)
		haloObject.Name = "ClientHalo"
		haloObject.Shape = Enum.PartType.Cylinder
		haloObject.Material = Enum.Material.Neon
		haloObject.CanCollide = false
		haloObject.Anchored = true
		local angle = 0
		haloRotationConnection = RunService.RenderStepped:Connect(function(dt)
			if character and head and haloObject and haloObject.Parent then
				angle = angle + dt * 140
				haloObject.Size = Vector3.new(2 * currentHaloSize, 0.08, 2 * currentHaloSize)
				haloObject.Color = currentHaloColor
				haloObject.CFrame = head.CFrame * CFrame.new(0, 1.8, 0) * CFrame.Angles(0, math.radians(angle), math.radians(90))
			else
				ToggleHalo(false)
			end
		end)
	else
		if haloObject then haloObject:Destroy() haloObject = nil end
		if haloRotationConnection then haloRotationConnection:Disconnect() haloRotationConnection = nil end
	end
end

-- Наполнение: Visuals
createToggle(tabVisuals, "Включить Нимб (Halo)", false, function(v) ToggleHalo(v) end)
createSlider(tabVisuals, "Размер Нимба", 1, 6, 2, function(v) currentHaloSize = v / 2 end)
createSlider(tabVisuals, "Minecraft FOV Камеры", 70, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end)
createToggle(tabVisuals, "Цвет Нимба: Красный", false, function(v) currentHaloColor = v and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255) end)
createToggle(tabVisuals, "Цвет Нимба: Зеленый", false, function(v) currentHaloColor = v and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 255, 255) end)

-- Наполнение: Screen Effects
createSlider(tabEffects, "Размытие движения (Motion Blur)", 0, 40, 0, function(v) menuBlur.Size = v end)
createToggle(tabEffects, "Ночное Зрение (Night Vision)", false, function(v) Lighting.Ambient = v and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(128, 128, 128) end)
createSlider(tabEffects, "Насыщенность Цвета (Saturation)", 0, 4, 1, function(v) colorCorrection.Saturation = v - 1 end)
createSlider(tabEffects, "Контраст Экрана (Contrast)", 0, 4, 1, function(v) colorCorrection.Contrast = v - 1 end)
createToggle(tabEffects, "Усиленное Свечение (Bloom)", false, function(v) bloomEffect.Intensity = v and 4 or 1 end)

-- Наполнение: World / Render
createSlider(tabWorld, "Время суток (Часы)", 0, 24, 12, function(v) Lighting.ClockTime = v end)
createToggle(tabWorld, "Удалить игровой туман", false, function(v) Lighting.FogEnd = v and 999999 or 100000 end)
createToggle(tabWorld, "Убрать Тени (FPS Boost)", false, function(v) Lighting.GlobalShadows = not v end)

local xrayHighlights = {}
createToggle(tabWorld, "Подсветка игроков (X-Ray)", false, function(v)
	if v then
		for _, ply in pairs(Players:GetPlayers()) do
			if ply ~= LocalPlayer and ply.Character then
				local hl = Instance.new("Highlight", ply.Character)
				hl.FillColor = Color3.fromRGB(255, 0, 0)
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				xrayHighlights[ply] = hl
			end
		end
	else
		for _, hl in pairs(xrayHighlights) do if hl then hl:Destroy() end end
		table.clear(xrayHighlights)
	end
end)

createToggle(tabWorld, "Космическое Звездное Небо", false, function(v)
	if v then
		local sky = Lighting:FindFirstChild("CustomMenuSky") or Instance.new("Sky", Lighting)
		sky.Name = "CustomMenuSky"
		sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "rbxassetid://6008304462", "rbxassetid://6008304462", "rbxassetid://6008304462", "rbxassetid://6008304462", "rbxassetid://6008304462", "rbxassetid://6008304462"
		sky.StarCount = 5000
	else
		if Lighting:FindFirstChild("CustomMenuSky") then Lighting.CustomMenuSky:Destroy() end
	end
end)

-- ============================================================================
-- ЧАСТЬ 5: НАПОЛНЕНИЕ РАЗДЕЛОВ ДВИЖЕНИЯ И СИСТЕМНЫХ УТИЛИТ (MOVEMENT, UTILS)
-- ============================================================================
local tabMovement = createTab("Movement", 4)
local tabUtils = createTab("Utilities", 5)

-- Наполнение: Movement
createSlider(tabMovement, "Скорость бега (WalkSpeed)", 16, 150, 16, function(v)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
	end
end)

createSlider(tabMovement, "Высота Прыжка (JumpPower)", 50, 250, 50, function(v)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		hum.UseJumpPower = true hum.JumpPower = v
	end
end)

createToggle(tabMovement, "Бесконечный Прыжок", false, function(v)
	isInfJump = v
	if v then
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			if isInfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
				LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
			end
		end)
	else
		if infJumpConnection then infJumpConnection:Disconnect() end
	end
end)

createToggle(tabMovement, "Проход сквозь стены (Noclip)", false, function(v)
	isNoclip = v
	if v then
		noclipConnection = RunService.Stepped:Connect(function()
			if isNoclip and LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() end
	end
end)

createToggle(tabMovement, "Режим Полета (Fly)", false, function(v)
	isFly = v
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	if v then
		local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		local bg = Instance.new("BodyGyro", hrp) bg.Name = "FlyGyro" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.CFrame = hrp.CFrame
		flyConnection = RunService.RenderStepped:Connect(function()
			if not isFly or not hrp.Parent then return end
			local cam = workspace.CurrentCamera
			local moveDir = Vector3.new(0,0,0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			bv.Velocity = moveDir * flySpeed bg.CFrame = cam.CFrame
		end)
	else
		if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
		if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
		if flyConnection then flyConnection:Disconnect() end
	end
end)

-- Наполнение: Utilities
_G.AntiAFKActive = false
createToggle(tabUtils, "Анти-АФК (Anti-AFK)", false, function(v)
	_G.AntiAFKActive = v
	if v then
		local vu = game:GetService("VirtualUser")
		_G.AntiAfkConnection = LocalPlayer.Idled:Connect(function()
			if _G.AntiAFKActive then
				vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5)
				vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			end
		end)
	else
		if _G.AntiAfkConnection then _G.AntiAfkConnection:Disconnect() end
	end
end)

_G.AntiFlingActive = false
createToggle(tabUtils, "Анти-Флинг (Anti-Fling)", false, function(v)
	_G.AntiFlingActive = v
	if v then
		_G.AntiFlingConnection = RunService.Heartbeat:Connect(function()
			if not _G.AntiFlingActive or not LocalPlayer.Character then return end
			for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false part.Velocity = Vector3.new(0,0,0) part.RotVelocity = Vector3.new(0,0,0)
				end
			end
		end)
	else
		if _G.AntiFlingConnection then _G.AntiFlingConnection:Disconnect() end
	end
end)

local perfLabel = Instance.new("TextLabel")
perfLabel.Size = UDim2.new(1, -20, 0, 20) perfLabel.Position = UDim2.new(0, 10, 1, -65)
perfLabel.TextColor3 = Color3.fromRGB(0, 255, 120) perfLabel.Font = Enum.Font.SourceSansBold
perfLabel.TextSize = 13 perfLabel.BackgroundTransparency = 1 perfLabel.TextXAlignment = Enum.TextXAlignment.Left
perfLabel.Visible = false perfLabel.Parent = PreviewPane

local fpsConnect = nil
createToggle(tabUtils, "Показывать FPS / Пинг", false, function(v)
	perfLabel.Visible = v
	if v then
		fpsConnect = RunService.RenderStepped:Connect(function(dt)
			perfLabel.Text = string.format("FPS: %d | Ping: %d ms", math.floor(1/dt), math.floor(LocalPlayer:GetNetworkPing() * 1000))
		end)
	else
		if fpsConnect then fpsConnect:Disconnect() end
	end
end)

createToggle(tabUtils, "Быстрый автокликер мыши", false, function(v)
	isAutoClick = v
	if v then
		autoClickConnection = RunService.RenderStepped:Connect(function()
			if isAutoClick and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				local virtualUser = game:GetService("VirtualUser")
				virtualUser:CaptureController() virtualUser:ClickButton1(Vector2.new(0, 0))
			end
		end)
	else
		if autoClickConnection then autoClickConnection:Disconnect() end
	end
end)

createToggle(tabUtils, "Безопасный сброс всех эффектов", false, function(v)
	if v then
		menuBlur.Size = 0 colorCorrection.Saturation = 0 colorCorrection.Contrast = 0
		Lighting.Ambient = Color3.fromRGB(128, 128, 128) Lighting.GlobalShadows = true
	end
end)

-- ============================================================================
-- ЧАСТЬ 6: СИСТЕМА ДИНАМИЧЕСКИХ АНИМАЦИЙ, RIGHTSHIFT И SMOOTH DRAGGING
-- ============================================================================
local toggleInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isMenuOpen = true

local function setGuiTransparency(targetTransparency)
	TweenService:Create(MainFrame, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	TweenService:Create(Sidebar, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	TweenService:Create(PreviewPane, toggleInfo, {BackgroundTransparency = targetTransparency}):Play()
	local overlayTarget = targetTransparency == 0 and 0.45 or 1
	TweenService:Create(BlurOverlay, toggleInfo, {BackgroundTransparency = overlayTarget}):Play()
end

-- Красивое интро при первом инжекте чита
local introInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, introInfo, {Position = UDim2.new(0.5, -325, 0.5, -200), BackgroundTransparency = 0}):Play()
TweenService:Create(Sidebar, introInfo, {BackgroundTransparency = 0}):Play()
TweenService:Create(PreviewPane, introInfo, {BackgroundTransparency = 0}):Play()
TweenService:Create(BlurOverlay, introInfo, {BackgroundTransparency = 0.45}):Play()
updatePreviewText()

-- Отслеживание горячей клавиши RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.RightShift then
		isMenuOpen = not isMenuOpen
		if isMenuOpen then
			MainFrame.Visible = true setGuiTransparency(0)
		else
			setGuiTransparency(1)
			task.delay(0.3, function() if not isMenuOpen then MainFrame.Visible = false end end)
		end
	end
end)

-- Плавное кастомное перетаскивание окон мышью (Smooth Drag)
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	local delta = input.Position - dragStart
	local targetPosition = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X, 
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
	TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {Position = targetPosition}):Play()
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true dragStart = input.Position startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then updateDrag(input) end
end)
