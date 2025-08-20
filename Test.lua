--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Remote & UI Elements
local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

------------------------------------------------------------------
-- 🔧 CONFIGURATION
------------------------------------------------------------------
local CONFIG = {
    autoStart = true,
    fpsBoost = false,
    hopProtection = true,
    autoSpamHop = true,
    maxHopAttempts = 12,
    hopAttemptDelay = 0.5
}

------------------------------------------------------------------
-- 🛠 UTILITIES
------------------------------------------------------------------
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local STATUS = "Idle"
local function setStatus(newStatus)
    STATUS = newStatus
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = "Status: " .. tostring(newStatus)
    end
end

------------------------------------------------------------------
-- 🌐 SERVER HOP (WITH RETRY)
------------------------------------------------------------------
local function hopServer()
    setStatus("Hopping")
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)

    if not success or not body then
        notify("🌐 Hop Error", "Failed to fetch server list.", 3)
        setStatus("Idle")
        return
    end

    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then
        notify("🌐 Hop Error", "Malformed server data.", 3)
        setStatus("Idle")
        return
    end

    local servers = {}
    for _, server in ipairs(data.data) do
        if server.id and server.id ~= game.JobId then
            table.insert(servers, server)
        end
    end

    if #servers == 0 then
        notify("🌐 Hop", "No servers available.", 3)
        setStatus("Idle")
        return
    end

    -- Shuffle servers
    for i = #servers, 2, -1 do
        local j = math.random(1, i)
        servers[i], servers[j] = servers[j], servers[i]
    end

    for i = 1, CONFIG.maxHopAttempts do
        local server = servers[((i - 1) % #servers) + 1]
        notify("🌐 Hopping", ("Attempt %d → %s (%d/%d)"):format(i, server.id, server.playing or 0, server.maxPlayers or 0), 2)

        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
        end)

        if ok then return end -- Exit on success
        task.wait(CONFIG.hopAttemptDelay)
    end

    notify("🌐 Hop Failed", "All attempts exhausted.", 3)
    setStatus("Idle")
end

------------------------------------------------------------------
-- 🚀 FPS BOOST
------------------------------------------------------------------
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
-- 🛡️ HOP PROTECTION (Duplicate Character Detection)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if CONFIG.hopProtection then
            for _, char in pairs(workspace.Characters:GetChildren()) do
                local humanoid = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if humanoid and hrp and char ~= LocalPlayer.Character then
                    if humanoid.DisplayName == LocalPlayer.DisplayName then
                        notify("⚠️ Duplicate", "Detected! Hopping...", 3)
                        hopServer()
                        return
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- 🎨 UI (Flashlight Hub Style)
------------------------------------------------------------------
local ui = CoreGui:FindFirstChild("CaoDiamondFarmer") or Instance.new("ScreenGui", CoreGui)
ui.Name = "CaoDiamondFarmer"

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 260, 0, 170)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
task.spawn(function()
    while task.wait() do
        for h = 0, 1, 0.01 do
            stroke.Color = Color3.fromHSV(h, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- 🔦 Image Placeholder
local icon = Instance.new("ImageLabel", main)
icon.Size = UDim2.new(0, 44, 0, 44)
icon.Position = UDim2.new(0, 8, 0, 8)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://PUT_IMAGE_ID_HERE" -- 🔁 Replace with your image ID
icon.ScaleType = Enum.ScaleType.Crop

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -60, 0, 28)
title.Position = UDim2.new(0, 60, 0, 8)
title.BackgroundTransparency = 1
title.Text = "🔦 Flashlight Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

-- Diamond Counter
local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1, -10, 0, 24)
counter.Position = UDim2.new(0, 5, 0, 44)
counter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.new(1, 1, 1)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0, 6)

-- Status Label
local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 70)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: " .. STATUS
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12

-- Start/Stop Button
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1, -10, 0, 28)
startBtn.Position = UDim2.new(0, 5, 0, 94)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

-- FPS Button
local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(1, -10, 0, 28)
fpsBtn.Position = UDim2.new(0, 5, 0, 128)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------
-- 🧰 MAIN FARMING LOOP
------------------------------------------------------------------
local farming = CONFIG.autoStart

local function farmCycle()
    while farming do
        setStatus("Farming")

        -- Wait for character
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character.HumanoidRootPart

        -- Find chest
        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            notify("⚠️", "Chest not found!", 3)
            hopServer()
            continue
        end

        -- Teleport to chest
        pcall(function()
            hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))
        end)

        -- Wait for proximity prompt
        local proxPrompt = nil
        repeat
            local mainPart = chest:FindFirstChild("Main")
            local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
            task.wait(0.1)
        until proxPrompt or not farming

        if not farming then break end

        -- Fire prompt for up to 10 seconds
        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            notify("⏰", "Timeout! Hopping...", 3)
            hopServer()
            continue
        end

        -- Wait for diamonds to spawn
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then break end

        -- Collect all diamonds
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name == "Diamond" then
                pcall(function()
                    Remote:FireServer(model)
                end)
            end
        end

        notify("💎", "Collected! Hopping...", 3)
        task.wait(1)

        -- Server hop
        hopServer()
        task.wait(0.5)
    end
    setStatus("Idle")
end

-- Update diamond counter
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            counter.Text = "Diamonds: " .. tostring(DiamondCount.Text or "0")
        end)
    end
end)

-- Button Listeners
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

-- Auto-start
if CONFIG.autoStart then
    task.spawn(farmCycle)
end

-- Load notification
notify("✨ Script Loaded", "Auto-farming is ON", 5)
