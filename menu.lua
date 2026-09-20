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

-- 2. Создаем Главное Меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 400)
-- Начальная позиция для анимации (смещено чуть вниз, чтобы плавно взлететь)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -150) 
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
-- Прячем рамку и делаем прозрачной перед началом анимации загрузки
MainFrame.BackgroundTransparency = 1 
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Закругление углов для Главного Меню
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
PreviewPane.BackgroundTransparency = 1 -- Также скрываем для анимации
PreviewPane.Parent = MainFrame

-- Закругление углов для Бокового Меню
local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 8)
PreviewCorner.Parent = PreviewPane


-- === ФУНКЦИОНАЛ: ОДНОКРАТНАЯ АНИМАЦИЯ ПРИ ЗАПУСКЕ ===
local introInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Анимация проявления и движения на финишную позицию
local mainTween = TweenService:Create(MainFrame, introInfo, {
	Position = UDim2.new(0.5, -325, 0.5, -200), -- Финишная позиция по центру
	BackgroundTransparency = 0
})

local previewTween = TweenService:Create(PreviewPane, introInfo, {
	BackgroundTransparency = 0
})

-- Запускаем анимацию появления один раз при загрузке скрипта
mainTween:Play()
previewTween:Play()


-- === ФУНКЦИОНАЛ: СТРЕЛА И ОТКРЫТИЕ НА RIGHT SHIFT ===
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- Проверяем нажатие именно на Правый Shift
	if input.KeyCode == Enum.KeyCode.RightShift then
		MainFrame.Visible = not MainFrame.Visible
	end
end)
