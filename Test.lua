-- ⚡ Flashlight Hub (Executor Edition)
-- Auto Teleport + Farming UI
-- Made to look like ThunderHub (screenshot style)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

-- // CONFIG
local LobbyPlace = 79546208627805
local FarmPlace = 126509999114328

-- // UI Library
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlashlightHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- Hide/Show button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 35)
ToggleButton.Position = UDim2.new(1, -110, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 70, 255)
ToggleButton.Text = "Hide GUI"
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = ScreenGui
ToggleButton.AutoButtonColor = true
ToggleButton.ZIndex = 2
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.BorderSizePixel = 0
ToggleButton.TextStrokeTransparency = 0.2
ToggleButton.TextStrokeColor3 = Color3.fromRGB(0,0,0)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.6, 0, 0.35, 0)
MainFrame.Position = UDim2.new(0.2, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Parent = ScreenGui
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0

-- UICorner
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 20)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "⚡ FLASHLIGHT HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = MainFrame

-- Subtitle
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 30)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Automated Farming"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 18
SubTitle.TextColor3 = Color3.fromRGB(180,180,180)
SubTitle.Parent = MainFrame

-- Container for stats
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -40, 0, 120)
Container.Position = UDim2.new(0, 20, 0, 90)
Container.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", Container)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 20)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper function to make stat cards
local function MakeCard(icon, title, value)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0.3, 0, 1, 0)
    Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Card.BackgroundTransparency = 0.1
    Card.BorderSizePixel = 0
    local corner = Instance.new("UICorner", Card)
    corner.CornerRadius = UDim.new(0,15)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, 0, 0.3, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = icon .. " " .. title
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16
    TitleLbl.TextColor3 = Color3.fromRGB(200,200,200)
    TitleLbl.Parent = Card

    local ValueLbl = Instance.new("TextLabel")
    ValueLbl.Size = UDim2.new(1, 0, 0.7, 0)
    ValueLbl.Position = UDim2.new(0, 0, 0.3, 0)
    ValueLbl.BackgroundTransparency = 1
    ValueLbl.Text = tostring(value)
    ValueLbl.Font = Enum.Font.GothamBold
    ValueLbl.TextSize = 24
    ValueLbl.TextColor3 = Color3.fromRGB(255,255,255)
    ValueLbl.Parent = Card

    return Card, ValueLbl
end

-- Create Cards
local DiamondsCard, DiamondsValue = MakeCard("💎", "DIAMONDS", 0)
local DayCard, DayValue = MakeCard("🌞", "DAY", 0)
local TimeCard, TimeValue = MakeCard("🕒", "TIME", "00:00")

DiamondsCard.Parent = Container
DayCard.Parent = Container
TimeCard.Parent = Container

-- Toggle Function
local GuiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    GuiVisible = not GuiVisible
    MainFrame.Visible = GuiVisible
    ToggleButton.Text = GuiVisible and "Hide GUI" or "Show GUI"
end)

-- // Farming Logic
local function StartFarming()
    print("[Flashlight Hub] Farming started!")

    -- Update dummy stats
    task.spawn(function()
        local t = 0
        while task.wait(1) do
            t += 1
            DiamondsValue.Text = tostring(478 + t)
            DayValue.Text = tostring(3000 + math.floor(t/60))
            local hrs = math.floor(t/3600)
            local mins = math.floor((t%3600)/60)
            local secs = t%60
            TimeValue.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)
        end
    end)
end

-- // Teleport Logic
local function TeleportToFarm()
    print("[Flashlight Hub] Teleporting to farm place...")

    local args = {"Add", 3}
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("TeleportEvent"):FireServer(unpack(args))
    end)

    task.wait(1)
    -- Simulate "\" then "2" then Enter
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.BackSlash, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)

    task.wait(0.5)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)

    task.wait(0.5)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.2)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

    repeat task.wait(1) until game.PlaceId == FarmPlace
    StartFarming()
end

-- // Main
if game.PlaceId == LobbyPlace then
    TeleportToFarm()
elseif game.PlaceId == FarmPlace then
    StartFarming()
else
    warn("[Flashlight Hub] Unsupported PlaceId, nothing loaded.")
end
