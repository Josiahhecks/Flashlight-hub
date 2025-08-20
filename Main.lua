-- Gem Farming Script for 99 Nights in the Forest
-- Flashlight Hub Themed UI with Rainbow Stroke Effect
-- Adapted from farm diamond 99 night.txt

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Variables
local gemRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents") and game:GetService("ReplicatedStorage").RemoteEvents:FindFirstChild("RequestTakeDiamonds")
local interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local gemCountLabel = interface:WaitForChild("DiamondCount"):WaitForChild("Count")
local configPath = "flashlight_hub_99nights.json"
local startTime = tick()
local farmingEnabled = true -- Enabled by default
local chest, proxPrompt
local initialGems = tonumber(gemCountLabel.Text) or 0
local dayCountLabel = interface:FindFirstChild("DayCount") and interface.DayCount:FindFirstChild("Count")
local timeCountLabel = interface:FindFirstChild("TimeCount") and interface.TimeCount:FindFirstChild("Count")

-- Function to create rainbow stroke effect
local function rainbowStroke(stroke)
    task.spawn(function()
        while true do
            for hue = 0, 1, 0.01 do
                stroke.Color = Color3.fromHSV(hue, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

-- Format time in hours, minutes, seconds
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Load config
local function loadConfig()
    if isfile and isfile(configPath) then
        local config = HttpService:JSONDecode(readfile(configPath))
        farmingEnabled = config.farmingEnabled
    end
end

-- Save config
local function saveConfig()
    if writefile then
        local config = {
            farmingEnabled = farmingEnabled
        }
        writefile(configPath, HttpService:JSONEncode(config))
    end
end

loadConfig()

-- Server hopping function
local function hopServer()
    local gameId = 79546208627805 -- PlaceId from search
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end
        if success then
            local data = HttpService:JSONDecode(body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    while true do
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

-- Check for character duplication and hop server
task.spawn(function()
    while task.wait(1) do
        if farmingEnabled then
            for _, char in pairs(workspace.Characters:GetChildren()) do
                if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char:FindFirstChild("Humanoid").DisplayName == LocalPlayer.DisplayName then
                        StarterGui:SetCore("SendNotification", {
                            Title = "Flashlight Hub",
                            Text = "Duplicate character detected, hopping servers...",
                            Duration = 3
                        })
                        hopServer()
                    end
                end
            end
        end
    end
end)

-- Flashlight Hub Themed UI (matching the image layout)
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "FlashlightHubGemUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Top frame for logo, title, subtitle
local topFrame = Instance.new("Frame", screenGui)
topFrame.Size = UDim2.new(1, 0, 0, 150)
topFrame.Position = UDim2.new(0, 0, 0, 0)
topFrame.BackgroundTransparency = 1

-- Logo (flashlight icon using Unicode)
local logo = Instance.new("TextLabel", topFrame)
logo.Size = UDim2.new(0, 60, 0, 60)
logo.Position = UDim2.new(0.5, -30, 0, 5)
logo.BackgroundTransparency = 1
logo.Text = "🔦"
logo.TextSize = 50
logo.Font = Enum.Font.SourceSansBold
logo.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
rainbowStroke(Instance.new("UIStroke", logo))

-- Title
local title = Instance.new("TextLabel", topFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 65)
title.BackgroundTransparency = 1
title.Text = "Flashlight Hub"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 36
title.TextStrokeTransparency = 0.5

-- Subtitle
local subtitle = Instance.new("TextLabel", topFrame)
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 105)
subtitle.BackgroundTransparency = 1
subtitle.Text = "99 Nights in the Forest"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.Font = Enum.Font.SourceSansBold
subtitle.TextSize = 24
subtitle.TextStrokeTransparency = 0.6

-- Panels frame
local panelsFrame = Instance.new("Frame", topFrame)
panelsFrame.Size = UDim2.new(0.9, 0, 0, 60)
panelsFrame.Position = UDim2.new(0.05, 0, 0, 140)
panelsFrame.BackgroundTransparency = 1

-- Diamond panel
local diamondPanel = Instance.new("Frame", panelsFrame)
diamondPanel.Size = UDim2.new(0.33, -10, 1, 0)
diamondPanel.Position = UDim2.new(0, 0, 0, 0)
diamondPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
diamondPanel.BorderSizePixel = 0
local diamondCorner = Instance.new("UICorner", diamondPanel)
diamondCorner.CornerRadius = UDim.new(0, 8)
local diamondStroke = Instance.new("UIStroke", diamondPanel)
diamondStroke.Thickness = 1
rainbowStroke(diamondStroke)

local diamondIcon = Instance.new("TextLabel", diamondPanel)
diamondIcon.Size = UDim2.new(0, 30, 0, 30)
diamondIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
diamondIcon.BackgroundTransparency = 1
diamondIcon.Text = "💎"
diamondIcon.TextSize = 20
diamondIcon.TextColor3 = Color3.fromRGB(135, 206, 235) -- Sky blue

local diamondLabel = Instance.new("TextLabel", diamondPanel)
diamondLabel.Size = UDim2.new(1, 0, 0, 20)
diamondLabel.Position = UDim2.new(0, 0, 0, 0)
diamondLabel.BackgroundTransparency = 1
diamondLabel.Text = "DIAMONDS"
diamondLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
diamondLabel.TextSize = 12
diamondLabel.Font = Enum.Font.SourceSansBold

local gemsValue = Instance.new("TextLabel", diamondPanel)
gemsValue.Size = UDim2.new(1, 0, 0, 40)
gemsValue.Position = UDim2.new(0, 0, 0, 20)
gemsValue.BackgroundTransparency = 1
gemsValue.Text = "0 (+0)"
gemsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
gemsValue.TextSize = 22
gemsValue.Font = Enum.Font.SourceSansBold

-- Day panel
local dayPanel = Instance.new("Frame", panelsFrame)
dayPanel.Size = UDim2.new(0.33, -10, 1, 0)
dayPanel.Position = UDim2.new(0.33, 5, 0, 0)
dayPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
dayPanel.BorderSizePixel = 0
local dayCorner = Instance.new("UICorner", dayPanel)
dayCorner.CornerRadius = UDim.new(0, 8)
local dayStroke = Instance.new("UIStroke", dayPanel)
dayStroke.Thickness = 1
rainbowStroke(dayStroke)

local dayIcon = Instance.new("TextLabel", dayPanel)
dayIcon.Size = UDim2.new(0, 30, 0, 30)
dayIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
dayIcon.BackgroundTransparency = 1
dayIcon.Text = "☀️"
dayIcon.TextSize = 20
dayIcon.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold

local dayLabel = Instance.new("TextLabel", dayPanel)
dayLabel.Size = UDim2.new(1, 0, 0, 20)
dayLabel.Position = UDim2.new(0, 0, 0, 0)
dayLabel.BackgroundTransparency = 1
dayLabel.Text = "DAY"
dayLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
dayLabel.TextSize = 12
dayLabel.Font = Enum.Font.SourceSansBold

local dayValue = Instance.new("TextLabel", dayPanel)
dayValue.Size = UDim2.new(1, 0, 0, 40)
dayValue.Position = UDim2.new(0, 0, 0, 20)
dayValue.BackgroundTransparency = 1
dayValue.Text = "0"
dayValue.TextColor3 = Color3.fromRGB(255, 255, 255)
dayValue.TextSize = 22
dayValue.Font = Enum.Font.SourceSansBold

-- Time panel
local timePanel = Instance.new("Frame", panelsFrame)
timePanel.Size = UDim2.new(0.33, -10, 1, 0)
timePanel.Position = UDim2.new(0.66, 10, 0, 0)
timePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
timePanel.BorderSizePixel = 0
local timeCorner = Instance.new("UICorner", timePanel)
timeCorner.CornerRadius = UDim.new(0, 8)
local timeStroke = Instance.new("UIStroke", timePanel)
timeStroke.Thickness = 1
rainbowStroke(timeStroke)

local timeIcon = Instance.new("TextLabel", timePanel)
timeIcon.Size = UDim2.new(0, 30, 0, 30)
timeIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
timeIcon.BackgroundTransparency = 1
timeIcon.Text = "⏰"
timeIcon.TextSize = 20
timeIcon.TextColor3 = Color3.fromRGB(135, 206, 235)

local timeLabel = Instance.new("TextLabel", timePanel)
timeLabel.Size = UDim2.new(1, 0, 0, 20)
timeLabel.Position = UDim2.new(0, 0, 0, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "TIME"
timeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
timeLabel.TextSize = 12
timeLabel.Font = Enum.Font.SourceSansBold

local timeValue = Instance.new("TextLabel", timePanel)
timeValue.Size = UDim2.new(1, 0, 0, 40)
timeValue.Position = UDim2.new(0, 0, 0, 20)
timeValue.BackgroundTransparency = 1
timeValue.Text = "00:00:00"
timeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
timeValue.TextSize = 22
timeValue.Font = Enum.Font.SourceSansBold

-- Hide GUI button
local hideButton = Instance.new("TextButton", topFrame)
hideButton.Size = UDim2.new(0, 80, 0, 30)
hideButton.Position = UDim2.new(0.95, -90, 0, 10)
hideButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
hideButton.Text = "Hide GUI"
hideButton.TextColor3 = Color3.fromRGB(0, 255, 255)
hideButton.Font = Enum.Font.SourceSansBold
timeLabel.TextSize = 14
local hideCorner = Instance.new("UICorner", hideButton)
hideCorner.CornerRadius = UDim.new(0, 8)

hideButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Settings frame (draggable for toggle and exit)
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0, 150, 0, 100)
settingsFrame.Position = UDim2.new(0.85, 0, 0.8, 0)
settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
settingsFrame.BorderSizePixel = 0
settingsFrame.Active = true
settingsFrame.Draggable = true
local settingsCorner = Instance.new("UICorner", settingsFrame)
settingsCorner.CornerRadius = UDim.new(0, 8)
local settingsStroke = Instance.new("UIStroke", settingsFrame)
settingsStroke.Thickness = 1
rainbowStroke(settingsStroke)

-- Toggle button
local toggleButton = Instance.new("TextButton", settingsFrame)
toggleButton.Size = UDim2.new(1, -10, 0.4, 0)
toggleButton.Position = UDim2.new(0, 5, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleButton.Text = "Stop Farming"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 6)

-- Exit button
local exitButton = Instance.new("TextButton", settingsFrame)
exitButton.Size = UDim2.new(1, -10, 0.4, 0)
exitButton.Position = UDim2.new(0, 5, 0.5, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
exitButton.Text = "Exit Script"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.Font = Enum.Font.SourceSansBold
exitButton.TextSize = 14
local exitCorner = Instance.new("UICorner", exitButton)
exitCorner.CornerRadius = UDim.new(0, 6)

-- Update gem count and runtime
task.spawn(function()
    while task.wait(0.2) do
        local currentGems = tonumber(gemCountLabel.Text) or 0
        gemsValue.Text = currentGems .. " (+" .. (currentGems - initialGems) .. ")"
        timeValue.Text = formatTime(tick() - startTime)
        if dayCountLabel then
            dayValue.Text = dayCountLabel.Text or "0"
        else
            dayValue.Text = "N/A"
        end
    end
end)

-- Farming logic with retry for timeout
local function farmGems()
    local maxRetries = 3
    local retryCount = 0
    while farmingEnabled and task.wait(0.1) do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end

        -- Find gem chest
        chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "No gem chest found, hopping servers...",
                Duration = 3
            })
            hopServer()
            return
        end

        -- Teleport to chest
        LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))

        -- Find and interact with proximity prompt with retry
        local success = false
        while retryCount < maxRetries and not success and farmingEnabled do
            retryCount = retryCount + 1
            repeat
                task.wait(0.1)
                local mainPart = chest:FindFirstChild("Main")
                if mainPart and mainPart:FindFirstChild("ProximityAttachment") then
                    proxPrompt = mainPart.ProximityAttachment:FindFirstChild("ProximityInteraction")
                end
            until proxPrompt or not farmingEnabled

            if not farmingEnabled then return end

            local interactStart = tick()
            while proxPrompt and proxPrompt.Parent and (tick() - interactStart) < 20 and not success do
                pcall(function()
                    fireproximityprompt(proxPrompt)
                    success = true
                end)
                task.wait(0.2)
            end
            if not success then
                task.wait(1) -- Wait before retry
            end
        end

        if not success then
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Chest interaction failed after retries, hopping servers...",
                Duration = 3
            })
            hopServer()
            return
        end

        -- Collect gems
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farmingEnabled

        if not farmingEnabled then return end

        for _, v in pairs(workspace:GetDescendants()) do
            if v.ClassName == "Model" and v.Name == "Diamond" and farmingEnabled then
                if gemRemote then
                    pcall(function()
                        gemRemote:FireServer(v)
                    end)
                end
            end
        end

        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Collected all gems, hopping servers...",
            Duration = 3
        })
        task.wait(1)
        hopServer()
    end
end

-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    farmingEnabled = not farmingEnabled
    toggleButton.BackgroundColor3 = farmingEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.Text = farmingEnabled and "Stop Farming" or "Start Farming"
    saveConfig()
    if farmingEnabled then
        task.spawn(farmGems)
        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Gem farming started!",
            Duration = 3
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Gem farming stopped!",
            Duration = 3
        })
    end
end)

-- Exit button functionality
exitButton.MouseButton1Click:Connect(function()
    farmingEnabled = false
    screenGui:Destroy()
    StarterGui:SetCore("SendNotification", {
        Title = "Flashlight Hub",
        Text = "Gem Farmer script terminated.",
        Duration = 3
    })
end)

-- Initial start if enabled
if farmingEnabled then
    task.spawn(farmGems)
    toggleButton.Text = "Stop Farming"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end

-- Initial notification
StarterGui:SetCore("SendNotification", {
    Title = "Flashlight Hub",
    Text = "Gem Farmer loaded for 99 Nights in the Forest. Farming is " .. (farmingEnabled and "enabled" or "disabled") .. " by default.",
    Duration = 5
})
