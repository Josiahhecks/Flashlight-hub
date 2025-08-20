-- Gem Farming Script for 99 Nights in the Forest
-- Flashlight Hub Themed Full-Screen UI with Rainbow Stroke Effect
-- Adapted from farm diamond 99 night.txt

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local gemRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents") and game:GetService("ReplicatedStorage").RemoteEvents:FindFirstChild("RequestTakeDiamonds")
local interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local gemCountLabel = interface:WaitForChild("DiamondCount"):WaitForChild("Count")
local startTime = tick()
local farmingEnabled = false
local chest, proxPrompt

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
    local gameId = game.PlaceId
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
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
                            Title = "Notification",
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

-- Flashlight Hub Themed Full-Screen UI
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "FlashlightHubGemUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background with flashlight beam effect (semi-transparent gradient)
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

-- Main display frame (centered, Flashlight Hub styled)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.4, 0, 0.35, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.325, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 3
rainbowStroke(mainStroke)

-- Flashlight Hub title with icon (using Unicode flashlight symbol)
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ðŸ”¦ Flashlight Hub - Gem Farmer"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextStrokeTransparency = 0.5

-- Gem count label
local gemsLabel = Instance.new("TextLabel", mainFrame)
gemsLabel.Size = UDim2.new(1, -20, 0.3, 0)
gemsLabel.Position = UDim2.new(0, 10, 0.3, 0)
gemsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
gemsLabel.BackgroundTransparency = 0.4
gemsLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Neon yellow
gemsLabel.Font = Enum.Font.SourceSansBold
gemsLabel.TextSize = 20
gemsLabel.BorderSizePixel = 0
local gemsCorner = Instance.new("UICorner", gemsLabel)
gemsCorner.CornerRadius = UDim.new(0, 10)

-- Runtime label
local timeLabel = Instance.new("TextLabel", mainFrame)
timeLabel.Size = UDim2.new(1, -20, 0.3, 0)
timeLabel.Position = UDim2.new(0, 10, 0.6, 0)
timeLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
timeLabel.BackgroundTransparency = 0.4
timeLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- Neon cyan
timeLabel.Font = Enum.Font.SourceSansBold
timeLabel.TextSize = 20
timeLabel.BorderSizePixel = 0
local timeCorner = Instance.new("UICorner", timeLabel)
timeCorner.CornerRadius = UDim.new(0, 10)

-- Settings frame (draggable, Flashlight Hub styled)
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0.2, 0, 0.25, 0)
settingsFrame.Position = UDim2.new(0.78, 0, 0.73, 0)
settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
settingsFrame.BorderSizePixel = 0
settingsFrame.Active = true
settingsFrame.Draggable = true
local settingsCorner = Instance.new("UICorner", settingsFrame)
settingsCorner.CornerRadius = UDim.new(0, 15)
local settingsStroke = Instance.new("UIStroke", settingsFrame)
settingsStroke.Thickness = 2
rainbowStroke(settingsStroke)

-- Toggle farming button
local toggleButton = Instance.new("TextButton", settingsFrame)
toggleButton.Size = UDim2.new(1, -10, 0.4, 0)
toggleButton.Position = UDim2.new(0, 5, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleButton.Text = "Start Farming"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 0) -- Neon yellow
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 10)

-- Exit button
local exitButton = Instance.new("TextButton", settingsFrame)
exitButton.Size = UDim2.new(1, -10, 0.4, 0)
exitButton.Position = UDim2.new(0, 5, 0.5, 0)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
exitButton.Text = "Exit Script"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 0) -- Neon yellow
exitButton.Font = Enum.Font.SourceSansBold
exitButton.TextSize = 16
local exitCorner = Instance.new("UICorner", exitButton)
exitCorner.CornerRadius = UDim.new(0, 10)

-- Update gem count and runtime
task.spawn(function()
    while task.wait(0.2) do
        gemsLabel.Text = "Gems: " .. (gemCountLabel.Text or "N/A")
        timeLabel.Text = "Runtime: " .. formatTime(tick() - startTime)
    end
end)

-- Farming logic
local function farmGems()
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

        -- Find proximity prompt
        repeat
            task.wait(0.1)
            local mainPart = chest:FindFirstChild("Main")
            if mainPart and mainPart:FindFirstChild("ProximityAttachment") then
                proxPrompt = mainPart.ProximityAttachment:FindFirstChild("ProximityInteraction")
            end
        until proxPrompt or not farmingEnabled

        if not farmingEnabled then return end

        -- Interact with chest
        local interactStart = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - interactStart) < 10 and farmingEnabled do
            pcall(function()
                fireproximityprompt(proxPrompt)
            end)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            StarterGui:SetCore("SendNotification", {
                Title = "Flashlight Hub",
                Text = "Chest interaction timed out, hopping servers...",
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

-- Initial notification
StarterGui:SetCore("SendNotification", {
    Title = "Flashlight Hub",
    Text = "Gem Farmer loaded for 99 Nights in the Forest. Use the settings frame to control farming.",
    Duration = 5
})
