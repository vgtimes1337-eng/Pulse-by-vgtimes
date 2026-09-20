-- Проверяем, запущен ли скрипт в игре. Если GUI уже существует, удаляем старый.
local oldGui = game:GetService("CoreGui"):FindFirstChild("CustomMenuGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CustomMenuGui")
if oldGui then oldGui:Destroy() end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 1. Создаем основу интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 0 
ScreenGui.IgnoreGuiInset = true

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- === ФОНОВОЙ ОВЕРЛЕЙ ДЛЯ ЗАТЕМНЕНИЯ ИГРЫ ===
local BlurOverlay = Instance.new("Frame")
BlurOverlay.Name = "BlurOverlay"
BlurOverlay.Size = UDim2.new(1, 0, 1, 0)
BlurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlurOverlay.BackgroundTransparency = 1 -- Изначально полностью прозрачный
BlurOverlay.BorderSizePixel = 0
BlurOverlay.Parent = ScreenGui

-- 2. Создаем Главное Меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 400)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -150) -- Чуть смещено для интро
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BackgroundTransparency = 1 -- Изначально прозрачное
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 3. Создаем Боковое Меню (PreviewPane)
local PreviewPane = Instance.new("Frame")
PreviewPane.Name = "PreviewPane"
PreviewPane.Position = UDim2.new(1, 5, 0, 0) 
PreviewPane.Size = UDim2.new(0, 240, 1, 0)
PreviewPane.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
PreviewPane.BorderSizePixel = 0
PreviewPane.BackgroundTransparency = 1 -- Изначально прозрачное
PreviewPane.Parent = MainFrame

local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 8)
PreviewCorner.Parent = PreviewPane


-- === НАСТРОЙКА АНИМАЦИЙ (TWEEN) ===
local toggleInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isMenuOpen = true -- Состояние меню (при запуске открыто)

-- Функция для плавного изменения прозрачности всех элементов (включая будущие кнопки)
local function setGuiTransparency(targetTransparency)
	local mainTween = TweenService:Create(MainFrame, toggleInfo, {BackgroundTransparency = targetTransparency})
	local previewTween = TweenService:Create(PreviewPane, toggleInfo, {BackgroundTransparency = targetTransparency})
	
	-- Анимация для заднего фона: при открытии прозрачность 0.45 (затемнение), при закрытии 1 (чистый экран)
	local overlayTarget = targetTransparency == 0 and 0.45 or 1
	local overlayTween = TweenService:Create(BlurOverlay, toggleInfo, {BackgroundTransparency = overlayTarget})
	
	mainTween:Play()
	previewTween:Play()
	overlayTween:Play()
end

-- === ПЕРВЫЙ ЗАПУСК (ИНТРО АНИМАЦИЯ) ===
-- Красивое появление из центра при инжекте
local introInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
TweenService:Create(MainFrame, introInfo, {Position = UDim2.new(0.5, -325, 0.5, -200), BackgroundTransparency = 0}):Play()
TweenService:Create(PreviewPane, introInfo, {BackgroundTransparency = 0}):Play()
TweenService:Create(BlurOverlay, introInfo, {BackgroundTransparency = 0.45}):Play()


-- === ФУНКЦИОНАЛ ПЕРЕКЛЮЧЕНИЯ НА RIGHT SHIFT ===
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.RightShift then
		isMenuOpen = not isMenuOpen
		
		if isMenuOpen then
			-- Осветление / Включение меню и затемнение фона игры
			MainFrame.Visible = true
			setGuiTransparency(0) -- 0 = полностью видимое меню
		else
			-- Затемнение / Выключение меню и осветление фона игры обратно
			setGuiTransparency(1) -- 1 = полностью прозрачное меню
			task.delay(0.3, function()
				if not isMenuOpen then MainFrame.Visible = false end
			end)
		end
	end
end)
