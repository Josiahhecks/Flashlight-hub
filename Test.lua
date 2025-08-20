-- 99 Nights Diamond Farmer | Flashlight Hub (Modern UI)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

------------------------------------------------------------------
-- CONFIG
------------------------------------------------------------------

local CONFIG = {
    autoStart = true,
    fpsBoost = false,
    hopProtection = true,
    showGUI = true -- Toggle GUI visibility
}

------------------------------------------------------------------
-- UTILITIES
------------------------------------------------------------------

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local function hopServer()
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)
    if success then
        local data = HttpService:JSONDecode(body)
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                notify("🌐 Hopping", "Moving to another server...", 3)
                TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                return
            end
        end
    end
    notify("❌", "No available servers found.", 3)
end

local function setFPSBoost(enabled)
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = not enabled
    Lighting.FogEnd = enabled and 100000 or 1000
    pcall(function()
        settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = not enabled
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = enabled and 1 or 0
        end
    end
    CONFIG.fpsBoost = enabled
end

------------------------------------------------------------------
-- HOP PROTECTION (Duplicate Detection)
------------------------------------------------------------------

task.spawn(function()
    while task.wait(1) do
        if CONFIG.hopProtection then
            for _, char in pairs(workspace.Characters:GetChildren()) do
                if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                        notify("⚠️ Duplicate", "Duplicate character detected! Hopping...", 3)
                        hopServer()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- UI DESIGN (THUNDER HUB STYLE)
------------------------------------------------------------------

local ui = CoreGui:FindFirstChild("FlashlightHub")
if ui then ui:Destroy() end

ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "FlashlightHub"
ui.Enabled = CONFIG.showGUI

local mainFrame = Instance.new("Frame", ui)
mainFrame.Size = UDim2.new(0, 350, 0, 180)
mainFrame.Position = UDim2.new(0, 40, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Rainbow border effect
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 100, 100)
stroke.Thickness = 2

task.spawn(function()
    while task.wait() do
        for h = 0, 1, 0.01 do
            stroke.Color = Color3.fromHSV(h, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FLASHLIGHT HUB"
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Center

-- Logo (Icon placeholder)
local logo = Instance.new("ImageLabel", mainFrame)
logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 15, 0, 10)
logo.Image = "rbxassetid://1234567890" -- Replace with actual icon ID (e.g., flashlight or diamond)
logo.ImageColor3 = Color3.new(1, 1, 1)
logo.BackgroundTransparency = 1

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.SourceSansSemiBold
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Diamond Count Section
local diamondsBox = Instance.new("Frame", mainFrame)
diamondsBox.Size = UDim2.new(0, 100, 0, 60)
diamondsBox.Position = UDim2.new(0, 10, 0, 75)
diamondsBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
diamondsBox.BorderSizePixel = 0
Instance.new("UICorner", diamondsBox).CornerRadius = UDim.new(0, 8)

local diamondIcon = Instance.new("ImageLabel", diamondsBox)
diamondIcon.Size = UDim2.new(0, 20, 0, 20)
diamondIcon.Position = UDim2.new(0, 10, 0, 10)
diamondIcon.Image = "rbxassetid://1234567890" -- Diamond icon
diamondIcon.ImageColor3 = Color3.new(0.5, 0.7, 1)
diamondIcon.BackgroundTransparency = 1

local diamondsText = Instance.new("TextLabel", diamondsBox)
diamondsText.Size = UDim2.new(1, -10, 0, 20)
diamondsText.Position = UDim2.new(0, 0, 0, 30)
diamondsText.BackgroundTransparency = 1
diamondsText.Text = "DIAMONDS"
diamondsText.Font = Enum.Font.SourceSansSemiBold
diamondsText.TextColor3 = Color3.new(0.5, 0.7, 1)
diamondsText.TextSize = 12
diamondsText.TextXAlignment = Enum.TextXAlignment.Center

local diamondsValue = Instance.new("TextLabel", diamondsBox)
diamondsValue.Size = UDim2.new(1, -10, 0, 20)
diamondsValue.Position = UDim2.new(0, 0, 0, 50)
diamondsValue.BackgroundTransparency = 1
diamondsValue.Text = "0"
diamondsValue.Font = Enum.Font.SourceSansBold
diamondsValue.TextColor3 = Color3.new(1, 1, 1)
diamondsValue.TextSize = 16
diamondsValue.TextXAlignment = Enum.TextXAlignment.Center

-- Day Count Section
local dayBox = Instance.new("Frame", mainFrame)
dayBox.Size = UDim2.new(0, 100, 0, 60)
dayBox.Position = UDim2.new(0, 120, 0, 75)
dayBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
dayBox.BorderSizePixel = 0
Instance.new("UICorner", dayBox).CornerRadius = UDim.new(0, 8)

local sunIcon = Instance.new("ImageLabel", dayBox)
sunIcon.Size = UDim2.new(0, 20, 0, 20)
sunIcon.Position = UDim2.new(0, 10, 0, 10)
sunIcon.Image = "rbxassetid://1234567890" -- Sun icon
sunIcon.ImageColor3 = Color3.new(1, 0.7, 0)
sunIcon.BackgroundTransparency = 1

local dayText = Instance.new("TextLabel", dayBox)
dayText.Size = UDim2.new(1, -10, 0, 20)
dayText.Position = UDim2.new(0, 0, 0, 30)
dayText.BackgroundTransparency = 1
dayText.Text = "DAY"
dayText.Font = Enum.Font.SourceSansSemiBold
dayText.TextColor3 = Color3.new(1, 0.7, 0)
dayText.TextSize = 12
dayText.TextXAlignment = Enum.TextXAlignment.Center

local dayValue = Instance.new("TextLabel", dayBox)
dayValue.Size = UDim2.new(1, -10, 0, 20)
dayValue.Position = UDim2.new(0, 0, 0, 50)
dayValue.BackgroundTransparency = 1
dayValue.Text = "0"
dayValue.Font = Enum.Font.SourceSansBold
dayValue.TextColor3 = Color3.new(1, 1, 1)
dayValue.TextSize = 16
dayValue.TextXAlignment = Enum.TextXAlignment.Center

-- Time Section
local timeBox = Instance.new("Frame", mainFrame)
timeBox.Size = UDim2.new(0, 100, 0, 60)
timeBox.Position = UDim2.new(0, 230, 0, 75)
timeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
timeBox.BorderSizePixel = 0
Instance.new("UICorner", timeBox).CornerRadius = UDim.new(0, 8)

local clockIcon = Instance.new("ImageLabel", timeBox)
clockIcon.Size = UDim2.new(0, 20, 0, 20)
clockIcon.Position = UDim2.new(0, 10, 0, 10)
clockIcon.Image = "rbxassetid://1234567890" -- Clock icon
clockIcon.ImageColor3 = Color3.new(1, 0.5, 0.2)
clockIcon.BackgroundTransparency = 1

local timeText = Instance.new("TextLabel", timeBox)
timeText.Size = UDim2.new(1, -10, 0, 20)
timeText.Position = UDim2.new(0, 0, 0, 30)
timeText.BackgroundTransparency = 1
timeText.Text = "TIME"
timeText.Font = Enum.Font.SourceSansSemiBold
timeText.TextColor3 = Color3.new(1, 0.5, 0.2)
timeText.TextSize = 12
timeText.TextXAlignment = Enum.TextXAlignment.Center

local timeValue = Instance.new("TextLabel", timeBox)
timeValue.Size = UDim2.new(1, -10, 0, 20)
timeValue.Position = UDim2.new(0, 0, 0, 50)
timeValue.BackgroundTransparency = 1
timeValue.Text = "00:00"
timeValue.Font = Enum.Font.SourceSansBold
timeValue.TextColor3 = Color3.new(1, 1, 1)
timeValue.TextSize = 16
timeValue.TextXAlignment = Enum.TextXAlignment.Center

-- Hide Button
local hideBtn = Instance.new("TextButton", mainFrame)
hideBtn.Size = UDim2.new(0, 80, 0, 25)
hideBtn.Position = UDim2.new(0, 250, 0, 15)
hideBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 255)
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.Text = "Hide GUI"
hideBtn.TextScaled = true
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

-- FPS Boost Button
local fpsBtn = Instance.new("TextButton", mainFrame)
fpsBtn.Size = UDim2.new(0, 80, 0, 25)
fpsBtn.Position = UDim2.new(0, 10, 0, 15)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
fpsBtn.TextColor3 = Color3.new(1, 1, 1)
fpsBtn.Font = Enum.Font.SourceSansBold
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.TextScaled = true
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0, 6)

-- Start/Stop Button
local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(0, 80, 0, 25)
startBtn.Position = UDim2.new(0, 145, 0, 15)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.TextScaled = true
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------
-- FARMING LOGIC
------------------------------------------------------------------

local farming = CONFIG.autoStart
local lastHopTime = 0

local function farmCycle()
    while farming do
        -- Wait for character
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character.HumanoidRootPart

        -- Find chest
        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            notify("⚠️", "Chest not found, hopping...", 3)
            hopServer()
            continue
        end

        -- Move to chest
        hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))

        -- Proximity prompt
        local proxPrompt
        repeat
            local mainPart = chest:FindFirstChild("Main")
            local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
            task.wait(0.1)
        until proxPrompt or not farming

        if not farming then return end

        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            notify("⏰", "Prompt timeout, hopping...", 3)
            hopServer()
            continue
        end

        -- Wait for diamonds
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then return end

        -- Collect diamonds
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Diamond" then
                pcall(function() Remote:FireServer(v) end)
            end
        end

        notify("💎", "Diamonds collected, hopping...", 3)
        task.wait(1)
        hopServer()

        -- Ensure we don't hop too fast
        lastHopTime = tick()
    end
end

-- Update counters
task.spawn(function()
    while task.wait(0.2) do
        local count = tonumber(DiamondCount.Text) or 0
        diamondsValue.Text = tostring(count)
    end
end)

-- Update status label
task.spawn(function()
    while task.wait(0.5) do
        if farming then
            statusLabel.Text = "Status: Farming"
        else
            statusLabel.Text = "Status: Idle"
        end
    end
end)

-- Buttons
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
    startBtn.Text = farming and "Stop Farming" or "Start Farming"
    if farming then
        notify("✅", "Farming started!", 3)
        task.spawn(farmCycle)
    else
        notify("🛑", "Farming stopped.", 3)
    end
end)

fpsBtn.MouseButton1Click:Connect(function()
    local newState = not CONFIG.fpsBoost
    setFPSBoost(newState)
    fpsBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
    fpsBtn.Text = newState and "FPS: ON" or "FPS: OFF"
end)

hideBtn.MouseButton1Click:Connect(function()
    ui.Enabled = not ui.Enabled
    hideBtn.Text = ui.Enabled and "Hide GUI" or "Show GUI"
end)

-- Auto-start
if CONFIG.autoStart then
    task.spawn(farmCycle)
end

notify("✨ Flashlight Hub Loaded", "Auto-farming is ON", 5)
