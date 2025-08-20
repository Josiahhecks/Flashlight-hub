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
local interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface", 10) -- Wait up to 10 seconds
local gemCountLabel = interface and interface:FindFirstChild("DiamondCount") and interface.DiamondCount:FindFirstChild("Count")
local startTime = tick()
local farmingEnabled = true -- Enabled by default
local chest, proxPrompt
local initialGems = gemCountLabel and tonumber(gemCountLabel.Text) or 0
local dayCountLabel = interface and interface:FindFirstChild("DayCount") and interface.DayCount:FindFirstChild("Count")
local timeCountLabel = interface and interface:FindFirstChild("TimeCount") and interface.TimeCount:FindFirstChild("Count")

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

-- Server hopping function
local function hopServer()
    local gameId = 795462086 -- Placeholder PlaceId for 99 Nights in the Forest; adjust if needed
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
        if success then
            local data = HttpService:JSONDecode(body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                    end)
                    break
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

-- Flashlight Hub Themed UI
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "FlashlightHubGemUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background with flashlight beam effect
local bgFrame = Instance.new("Frame", screenGui)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
local bgGradient = Instance.new("UIGradient", bgFrame)
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
}
bgGradient.Rotation = 45
bgFrame.BackgroundTransparency = 0.6
bgFrame.BorderSizePixel = 0

-- Main header frame
local headerFrame = Instance.new("Frame", screenGui)
headerFrame.Size = UDim2.new(1, 0, 0, 180)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundTransparency = 1

-- Logo with cursed letter
local logo = Instance.new("TextLabel", headerFrame)
logo.Size = UDim2.new(0, 80, 0, 80)
logo.Position = UDim2.new(0.05, 0, 0, 10)
logo.BackgroundTransparency = 1
logo.Text = "â‚©ðŸ”¦" -- Cursed letter â‚© followed by flashlight
logo.TextSize = 60
logo.Font = Enum.Font.SourceSansBold
logo.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Thickness = 2
rainbowStroke(logoStroke)

-- Title
local title = Instance.new("TextLabel", headerFrame)
title.Size = UDim2.new(0.9, 0, 0, 50)
title.Position = UDim2.new(0.15, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Flashlight Hub"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 40
title.TextStrokeTransparency = 0.4
local titleGradient = Instance.new("UIGradient", title)
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
}
titleGradient.Rotation = 90

-- Subtitle
local subtitle = Instance.new("TextLabel", headerFrame)
subtitle.Size = UDim2.new(0.9, 0, 0, 40)
subtitle.Position = UDim2.new(0.15, 0, 0, 60)
subtitle.BackgroundTransparency = 1
subtitle.Text = "99 Nights in the Forest"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.Font = Enum.Font.SourceSansBold
subtitle.TextSize = 28
subtitle.TextStrokeTransparency = 0.6

-- Panels frame
local panelsFrame = Instance.new("Frame", screenGui)
panelsFrame.Size = UDim2.new(0.9, 0, 0, 100)
panelsFrame.Position = UDim2.new(0.05, 0, 0, 190)
panelsFrame.BackgroundTransparency = 1

-- Diamond panel
local diamondPanel = Instance.new("Frame", panelsFrame)
diamondPanel.Size = UDim2.new(0.3, -15, 1, 0)
diamondPanel.Position = UDim2.new(0, 0, 0, 0)
diamondPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
diamondPanel.BorderSizePixel = 0
local diamondCorner = Instance.new("UICorner", diamondPanel)
diamondCorner.CornerRadius = UDim.new(0, 12)
local diamondStroke = Instance.new("UIStroke", diamondPanel)
diamondStroke.Thickness = 2
rainbowStroke(diamondStroke)

local diamondIcon = Instance.new("TextLabel", diamondPanel)
diamondIcon.Size = UDim2.new(0, 40, 0, 40)
diamondIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
diamondIcon.BackgroundTransparency = 1
diamondIcon.Text = "ðŸ’Ž"
diamondIcon.TextSize = 30
diamondIcon.TextColor3 = Color3.fromRGB(135, 206, 235) -- Sky blue

local gemsValue = Instance.new("TextLabel", diamondPanel)
gemsValue.Size = UDim2.new(0.8, 0, 0.8, 0)
gemsValue.Position = UDim2.new(0.3, 0, 0.1, 0)
gemsValue.BackgroundTransparency = 1
gemsValue.Text = "0 (+0)"
gemsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
gemsValue.TextSize = 28
gemsValue.Font = Enum.Font.SourceSansBold

-- Day panel
local dayPanel = Instance.new("Frame", panelsFrame)
dayPanel.Size = UDim2.new(0.3, -15, 1, 0)
dayPanel.Position = UDim2.new(0.35, 5, 0, 0)
dayPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
dayPanel.BorderSizePixel = 0
local dayCorner = Instance.new("UICorner", dayPanel)
dayCorner.CornerRadius = UDim.new(0, 12)
local dayStroke = Instance.new("UIStroke", dayPanel)
dayStroke.Thickness = 2
rainbowStroke(dayStroke)

local dayIcon = Instance.new("TextLabel", dayPanel)
dayIcon.Size = UDim2.new(0, 40, 0, 40)
dayIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
dayIcon.BackgroundTransparency = 1
dayIcon.Text = "â˜€ï¸"
dayIcon.TextSize = 30
dayIcon.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold

local dayValue = Instance.new("TextLabel", dayPanel)
dayValue.Size = UDim2.new(0.8, 0, 0.8, 0)
dayValue.Position = UDim2.new(0.3, 0, 0.1, 0)
dayValue.BackgroundTransparency = 1
dayValue.Text = "0"
dayValue.TextColor3 = Color3.fromRGB(255, 255, 255)
dayValue.TextSize = 28
dayValue.Font = Enum.Font.SourceSansBold

-- Time panel
local timePanel = Instance.new("Frame", panelsFrame)
timePanel.Size = UDim2.new(0.3, -15, 1, 0)
timePanel.Position = UDim2.new(0.70, 10, 0, 0)
timePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
timePanel.BorderSizePixel = 0
local timeCorner = Instance.new("UICorner", timePanel)
timeCorner.CornerRadius = UDim.new(0, 12)
local timeStroke = Instance.new("UIStroke", timePanel)
timeStroke.Thickness = 2
rainbowStroke(timeStroke)

local timeIcon = Instance.new("TextLabel", timePanel)
timeIcon.Size = UDim2.new(0, 40, 0, 40)
timeIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
timeIcon.BackgroundTransparency = 1
timeIcon.Text = "â°"
timeIcon.TextSize = 30
timeIcon.TextColor3 = Color3.fromRGB(135, 206, 235)

local timeValue = Instance.new("TextLabel", timePanel)
timeValue.Size = UDim2.new(0.8, 0, 0.8, 0)
timeValue.Position = UDim2.new(0.3, 0, 0.1, 0)
timeValue.BackgroundTransparency = 1
timeValue.Text = "00:00:00"
timeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
timeValue.TextSize = 28
timeValue.Font = Enum.Font.SourceSansBold

-- Hide GUI button
local hideButton = Instance.new("TextButton", headerFrame)
hideButton.Size = UDim2.new(0, 100, 0, 40)
hideButton.Position = UDim2.new(0.9, -110, 0, 10)
hideButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
hideButton.Text = "Hide GUI"
hideButton.TextColor3 = Color3.fromRGB(0, 255, 255)
hideButton.Font = Enum.Font.SourceSansBold
hideButton.TextSize = 18
local hideCorner = Instance.new("UICorner", hideButton)
hideCorner.CornerRadius = UDim.new(0, 10)

hideButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Settings frame (draggable for toggle, exit, and status)
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0, 180, 0, 140)
settingsFrame.Position = UDim2.new(0.85, 0, 0.75, 0)
settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
settingsFrame.BorderSizePixel = 0
settingsFrame.Active = true
settingsFrame.Draggable = true
local settingsCorner = Instance.new("UICorner", settingsFrame)
settingsCorner.CornerRadius = UDim.new(0, 12)
local settingsStroke = Instance.new("UIStroke", settingsFrame)
settingsStroke.Thickness = 2
rainbowStroke(settingsStroke)

-- Status label
local statusLabel = Instance.new("TextLabel", settingsFrame)
statusLabel.Size = UDim2.new(1, -10, 0.3, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Farming: On"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 16

-- Toggle button
local toggleButton = Instance.new("TextButton", settingsFrame)
toggleButton.Size = UDim2.new(1, -10, 0.3, 0)
toggleButton.Position = UDim2.new(0, 5, 0.35, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleButton.Text = "Stop Farming"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 8)

-- Exit button
local exitButton = Instance.new("TextButton", settingsFrame)
exitButton.Size = UDim2.new(1, -10, 0.3, 0)
exitButton.Position = UDim2.new(0, 5, 0.65, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
exitButton.Text = "Exit Script"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.Font = Enum.Font.SourceSansBold
exitButton.TextSize = 16
local exitCorner = Instance.new("UICorner", exitButton)
exitCorner.CornerRadius = UDim.new(0, 8)

-- Update gem count and runtime
task.spawn(function()
    while task.wait(0.2) do
        local currentGems = gemCountLabel and tonumber(gemCountLabel.Text) or 0
        gemsValue.Text = currentGems .. " (+" .. (currentGems - initialGems) .. ")"
        timeValue.Text = timeCountLabel and timeCountLabel.Text or formatTime(tick() - startTime)
        if dayCountLabel then
            dayValue.Text = dayCountLabel.Text or "N/A"
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

        -- Find gem chest (using path from your file)
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

        -- Teleport to chest (confirmed from your file)
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
            if not success and retryCount < maxRetries then
                StarterGui:SetCore("SendNotification", {
                    Title = "Flashlight Hub",
                    Text = "Retry " .. retryCount .. "/" .. maxRetries .. " for chest interaction...",
                    Duration = 2
                })
                task.wait(1) -- Wait before retry
            end
        end

        if not success then
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Chest interaction failed after " .. maxRetries .. " retries, hopping servers...",
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
    statusLabel.Text = "Farming: " .. (farmingEnabled and "On" or "Off")
    statusLabel.TextColor3 = farmingEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
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
    statusLabel.Text = "Farming: On"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end

-- Initial notification
StarterGui:SetCore("SendNotification", {
    Title = "Flashlight Hub",
    Text = "Gem Farmer loaded for 99 Nights in the Forest. Farming is enabled by default.",
    Duration = 5
})
