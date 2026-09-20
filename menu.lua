-- Проверяем, запущен ли скрипт в игре. Если GUI уже существует, удаляем старый, чтобы не плодить копии.
local oldGui = game:GetService("CoreGui"):FindFirstChild("CustomMenuGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CustomMenuGui")
if oldGui then oldGui:Destroy() end

-- 1. Создаем основу интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false

-- Автоматический выбор папки в зависимости от среды исполнения (CoreGui или PlayerGui)
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- 2. Создаем Главное Меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Темно-серая основа
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать меню мышкой
MainFrame.Parent = ScreenGui

-- Закругление углов для Главного Меню
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 3. Создаем Боковое Меню (PreviewPane), привязанное к Главному
local PreviewPane = Instance.new("Frame")
PreviewPane.Name = "PreviewPane"
PreviewPane.Size = UDim2.new(0, 240, 1, -2) 
PreviewPane.Position = UDim2.new(1, -240, 0, 2) 
PreviewPane.BackgroundColor3 = Color3.fromRGB(7, 7, 7) -- Глубокий черный цвет
PreviewPane.BorderSizePixel = 0
PreviewPane.Parent = MainFrame -- Важно: родитель MainFrame, чтобы двигались вместе

-- Закругление углов для Бокового Меню
local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 8)
PreviewCorner.Parent = PreviewPane
