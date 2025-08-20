------------------------------------------------------------------
-- 99 Nights Diamond Farmer | Cáo Mod
-- Features: Auto Farm, Hop Protection, FPS Boost, Persistent UI
------------------------------------------------------------------

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
-- CONFIGURATION (Saved in CoreGui)
------------------------------------------------------------------
local CONFIG_FOLDER_NAME = "CaoModDiamondCfg"
local CONFIG_FILE_NAME = "config.json"

local function readConfig()
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder", CoreGui)
        folder.Name = CONFIG_FOLDER_NAME
    end

    local configFile = folder:FindFirstChild(CONFIG_FILE_NAME)
    if configFile and configFile:IsA("StringValue") then
        local success, data = pcall(HttpService.JSONDecode, HttpService, configFile.Value)
        if success then
            return data
        end
    end

    -- Default config
    local default = {
        autoStart = true,
        showUI = true,
        fpsBoost = false
    }
    local newValue = Instance.new("StringValue")
    newValue.Name = CONFIG_FILE_NAME
    newValue.Value = HttpService:JSONEncode(default)
    newValue.Parent = folder
    return default
end

local function writeConfig(tbl)
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER_NAME)
    if folder then
        local file = folder:FindFirstChild(CONFIG_FILE_NAME)
        if file then
            file.Value = HttpService:JSONEncode(tbl)
        end
    end
end

local CONFIG = readConfig()

------------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------------
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
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(gameId, server.id)
                    end)
                    while true do task.wait(1) end -- Prevent fallthrough
                end
            end
        end
        task.wait(0.3)
    end
end

------------------------------------------------------------------
-- FPS Boost Toggle
------------------------------------------------------------------
local function setFPSBoost(enabled)
    game.Lighting.GlobalShadows = not enabled
    game.Lighting.FogEnd = enabled and 100000 or 1000
    settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Enabled = not enabled
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = enabled and 1 or 0
        end
    end

    CONFIG.fpsBoost = enabled
    writeConfig(CONFIG)
end

------------------------------------------------------------------
-- Rainbow Border Animation
------------------------------------------------------------------
local function rainbowStroke(stroke)
    task.spawn(function()
        while true do
            for h = 0, 1, 0.01 do
                stroke.Color = Color3.fromHSV(h, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

------------------------------------------------------------------
-- Duplicate Character Detection (Hop Protection)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                    StarterGui:SetCore("SendNotification", {
                        Title = "⚠️ Duplicate",
                        Text = "Duplicate character detected! Hopping...",
                        Duration = 3
                    })
                    hopServer()
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- UI Setup
------------------------------------------------------------------
local ui = CoreGui:FindFirstChild("CaoDiamondFarmer")
if ui then ui:Destroy() end

ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "CaoDiamondFarmer"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 220, 0, 135)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
rainbowStroke(stroke)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Farm Diamond | Cáo Mod"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.TextStrokeTransparency = 0.6

-- Diamond Counter
local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1, -10, 0, 25)
counter.Position = UDim2.new(0, 5, 0, 30)
counter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.fromRGB(255, 255, 255)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0, 6)

-- Buttons
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1, -10, 0, 22)
startBtn.Position = UDim2.new(0, 5, 0, 60)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0.48, -5, 0, 22)
hideBtn.Position = UDim2.new(0, 5, 0, 87)
hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hideBtn.Text = CONFIG.showUI and "Hide UI" or "Show UI"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.TextSize = 13
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(0.48, -5, 0, 22)
fpsBtn.Position = UDim2.new(0.52, 5, 0, 87)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsBtn.TextSize = 13
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------
-- GUI Logic
------------------------------------------------------------------
local farming = CONFIG.autoStart

local function setGuiVisible(visible)
    main.Visible = visible
    CONFIG.showUI = visible
    writeConfig(CONFIG)
    hideBtn.Text = visible and "Hide UI" or "Show UI"
end

setGuiVisible(CONFIG.showUI)
setFPSBoost(CONFIG.fpsBoost) -- Apply FPS boost if enabled

startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CONFIG.autoStart = farming
    writeConfig(CONFIG)

    if farming then
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startBtn.Text = "Stop Farming"
        StarterGui:SetCore("SendNotification", {Title = "✅", Text = "Farming started!", Duration = 3})
        task.spawn(farmCycle)
    else
        startBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        startBtn.Text = "Start Farming"
        StarterGui:SetCore("SendNotification", {Title = "🛑", Text = "Farming stopped.", Duration = 3})
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    setGuiVisible(not main.Visible)
end)

fpsBtn.MouseButton1Click:Connect(function()
    local newState = not CONFIG.fpsBoost
    setFPSBoost(newState)
    fpsBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
    fpsBtn.Text = newState and "FPS: ON" or "FPS: OFF"
end)

------------------------------------------------------------------
-- Update Diamond Counter
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        counter.Text = "Diamonds: " .. tostring(DiamondCount.Text or "0")
    end
end)

------------------------------------------------------------------
-- Main Farming Loop
------------------------------------------------------------------
local function farmCycle()
    while farming do
        -- Wait for character
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

        -- Find chest
        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            StarterGui:SetCore("SendNotification", {Title = "⚠️", Text = "Chest not found! Hopping...", Duration = 3})
            hopServer()
            return
        end

        -- Teleport to chest
        hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))

        -- Wait for proximity prompt
        repeat
            task.wait(0.1)
            local mainPart = chest:FindFirstChild("Main")
            local attachment = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attachment and attachment:FindFirstChild("ProximityInteraction")
        until proxPrompt or not farming

        if not farming then return end

        -- Activate prompt
        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            StarterGui:SetCore("SendNotification", {Title = "⏰", Text = "Prompt timeout! Hopping...", Duration = 3})
            hopServer()
            return
        end

        -- Wait for diamonds to spawn
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then return end

        -- Collect all diamonds
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Diamond" and obj.Parent then
                Remote:FireServer(obj)
            end
        end

        StarterGui:SetCore("SendNotification", {Title = "💎", Text = "All diamonds taken! Hopping...", Duration = 3})
        task.wait(1)
        hopServer()
    end
end

-- Auto-start if enabled
if CONFIG.autoStart then
    farming = true
    task.spawn(farmCycle)
end

-- Notify script loaded
StarterGui:SetCore("SendNotification", {
    Title = "✨ Script Loaded",
    Text = "Press 'Start Farming' or auto-farming is ON",
    Duration = 5
})
