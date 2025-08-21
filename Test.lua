--// Flashlight Hub - 99 Nights Auto Farm
--// Features: Dashboard UI, FPS Boost, Auto Farm, Server Hop, Duplicate Protection

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes
local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")
local DayCount = Interface:WaitForChild("DayCount"):WaitForChild("Count")
local TimeCount = Interface:WaitForChild("TimeCount"):WaitForChild("Count")

-- Config
local CONFIG = {
    autoStart = true,
    fpsBoost = false,
    hopProtection = true,
    maxHopAttempts = 10,
    hopAttemptDelay = 0.5
}

-- Utilities
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local STATUS = "Idle"
local function setStatus(newStatus)
    STATUS = newStatus
    if _G.statusLabel and _G.statusLabel.Parent then
        _G.statusLabel.Text = "Status: " .. tostring(newStatus)
    end
end

-- FPS Boost
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

-- Server Hop
local function hopServer()
    setStatus("Hopping")
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)
    if not success or not body then return setStatus("Idle") end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then return setStatus("Idle") end

    local servers = {}
    for _, server in ipairs(data.data) do
        if server and server.id and server.id ~= game.JobId then
            table.insert(servers, server)
        end
    end
    if #servers == 0 then return setStatus("Idle") end

    local attempts = 0
    while attempts < CONFIG.maxHopAttempts do
        attempts += 1
        local server = servers[((attempts - 1) % #servers) + 1]
        if server and server.id then
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
            end)
            if ok then return end
            task.wait(CONFIG.hopAttemptDelay)
        end
    end
    setStatus("Idle")
end

-- Duplicate Protection
task.spawn(function()
    while task.wait(1) do
        if CONFIG.hopProtection then
            for _, char in pairs(workspace.Characters:GetChildren()) do
                if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char.Humanoid.DisplayName == LocalPlayer.DisplayName and char ~= LocalPlayer.Character then
                        notify("⚠️ Duplicate", "Duplicate detected! Hopping...", 3)
                        hopServer()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- UI (Dashboard Style)
------------------------------------------------------------------
local ui = CoreGui:FindFirstChild("FlashlightHub")
if ui then ui:Destroy() end
ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "FlashlightHub"
ui.ResetOnSpawn = false

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 500, 0, 260)
main.Position = UDim2.new(0.5, -250, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "FLASHLIGHT HUB"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 28

-- Subtitle
local subtitle = Instance.new("TextLabel", main)
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0, 45)
subtitle.BackgroundTransparency = 1
subtitle.Text = "99 NIGHTS IN THE FOREST"
subtitle.Font = Enum.Font.Gotham
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.TextSize = 14

-- Info Container
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -40, 0, 80)
container.Position = UDim2.new(0, 20, 0, 80)
container.BackgroundTransparency = 1
local listLayout = Instance.new("UIListLayout", container)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createCard(titleText, color, icon)
    local card = Instance.new("Frame", container)
    card.Size = UDim2.new(0.3, 0, 1, 0)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = icon .. " " .. titleText
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = color
    title.TextSize = 14

    local value = Instance.new("TextLabel", card)
    value.Name = "Value"
    value.Size = UDim2.new(1, 0, 0, 40)
    value.Position = UDim2.new(0, 0, 0, 30)
    value.BackgroundTransparency = 1
    value.Text = "--"
    value.Font = Enum.Font.GothamBold
    value.TextColor3 = Color3.new(1, 1, 1)
    value.TextSize = 20

    return value
end

local diamondValue = createCard("DIAMONDS", Color3.fromRGB(0,170,255), "💎")
local dayValue     = createCard("DAY", Color3.fromRGB(255,200,0), "☀️")
local timeValue    = createCard("TIME", Color3.fromRGB(255,120,80), "🕒")

-- Status
_G.statusLabel = Instance.new("TextLabel", main)
_G.statusLabel.Size = UDim2.new(1, -40, 0, 20)
_G.statusLabel.Position = UDim2.new(0, 20, 0, 170)
_G.statusLabel.BackgroundTransparency = 1
_G.statusLabel.Text = "Status: Idle"
_G.statusLabel.Font = Enum.Font.Gotham
_G.statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
_G.statusLabel.TextSize = 14
_G.statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(0.45, -15, 0, 36)
startBtn.Position = UDim2.new(0, 20, 0, 200)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(0.45, -15, 0, 36)
fpsBtn.Position = UDim2.new(0.55, 0, 0, 200)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(90, 90, 90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------
-- Farming Logic
------------------------------------------------------------------
local farming = CONFIG.autoStart

local function farmCycle()
    while farming do
        setStatus("Farming")
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character.HumanoidRootPart

        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
        if not chest then hopServer() return end

        pcall(function()
            hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))
        end)

        local proxPrompt
        repeat
            task.wait(0.1)
            local mainPart = chest:FindFirstChild("Main")
            local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
        until proxPrompt or not farming

        if not farming then break end
        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Diamond" then
                pcall(function()
                    Remote:FireServer(v)
                end)
            end
        end
        setStatus("✅ Collected all diamonds!")
        task.wait(1)
        hopServer()
    end
    setStatus("Idle")
end

-- Update UI Live
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            diamondValue.Text = tostring(DiamondCount.Text or "0")
            dayValue.Text = tostring(DayCount.Text or "0")
            timeValue.Text = tostring(TimeCount.Text or "00:00")
        end)
    end
end)

-- Button Logic
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0)
    startBtn.Text = farming and "Stop Farming" or "Start Farming"
    if farming then
        notify("✅", "Farming started!", 3)
        task.spawn(farmCycle)
    else
        setStatus("Idle")
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
if CONFIG.autoStart then task.spawn(farmCycle) end
notify("✨ Flashlight Hub", "Auto-farming loaded.", 5)
