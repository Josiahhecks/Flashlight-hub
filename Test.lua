-- Flashlight Hub — Fullscreen UI + Auto-Teleport + Auto-Farm
-- Place as a LocalScript (StarterPlayerScripts)

-- CONFIG
local CONFIG = {
    startPlace = 79546208627805,    -- if you spawn here, teleport to farmPlace
    farmPlace  = 126509999114328,   -- farming place (auto-start farm here)
    autoStartFarm = true,           -- auto-start farming when in farmPlace
    hopProtection = true,           -- duplicate detection -> hop
    maxHopAttempts = 100,            -- how many teleport attempts per hopServer call
    hopAttemptDelay = 0.5,          -- seconds between teleport attempts
}

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Auto-teleport from startPlace -> farmPlace
if game.PlaceId == CONFIG.startPlace then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Teleporting to farm place...",
            Duration = 4
        })
    end)
    -- this will reload the player into the farm place (script will run again there)
    TeleportService:Teleport(CONFIG.farmPlace, LocalPlayer)
    return
end

-- Utilities
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

-- Attempt to get the remote and diamond counter safely
local Remote
pcall(function()
    Remote = ReplicatedStorage:WaitForChild("RemoteEvents", 5):WaitForChild("RequestTakeDiamonds", 5)
end)

local DiamondCountText
pcall(function()
    local gui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface", 5)
    DiamondCountText = gui:WaitForChild("DiamondCount", 5):WaitForChild("Count", 5)
end)

-- UI creation (fullscreen black background + controls)
local function createUI()
    -- remove old if present
    local existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FlashlightHubUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlashlightHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BorderSizePixel = 0
    bg.Parent = screenGui

    -- Control panel (small floating panel so the screen stays mostly black)
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 280, 0, 150)
    panel.Position = UDim2.new(0, 16, 0, 22)
    panel.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    panel.BackgroundTransparency = 0.06
    panel.Parent = bg
    local corner = Instance.new("UICorner", panel)
    corner.CornerRadius = UDim.new(0, 8)

    -- UI Gradient for flashlight effect
    local uiGradient = Instance.new("UIGradient", panel)
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    uiGradient.Rotation = 90

    -- UI Stroke for rainbow effect
    local uiStroke = Instance.new("UIStroke", panel)
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.new(1,1,1)
    task.spawn(function()
        while task.wait(0.05) do
            local hue = (tick() % 5) / 5
            uiStroke.Color = Color3.fromHSV(hue, 1, 1)
        end
    end)

    -- Title
    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, -12, 0, 28)
    title.Position = UDim2.new(0, 6, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)
    title.Text = "🔦 Flashlight Hub"

    -- Diamonds counter
    local counter = Instance.new("TextLabel", panel)
    counter.Name = "Counter"
    counter.Size = UDim2.new(1, -12, 0, 22)
    counter.Position = UDim2.new(0, 6, 0, 38)
    counter.BackgroundTransparency = 1
    counter.Font = Enum.Font.GothamBold
    counter.TextSize = 14
    counter.TextColor3 = Color3.new(1,1,1)
    counter.Text = "Diamonds: --"

    -- Status label
    local statusLabel = Instance.new("TextLabel", panel)
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -12, 0, 18)
    statusLabel.Position = UDim2.new(0, 6, 0, 64)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
    statusLabel.Text = "Status: Idle"

    -- Start/Stop button
    local startBtn = Instance.new("TextButton", panel)
    startBtn.Name = "StartBtn"
    startBtn.Size = UDim2.new(1, -12, 0, 28)
    startBtn.Position = UDim2.new(0, 6, 0, 88)
    startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 14
    startBtn.TextColor3 = Color3.new(1,1,1)
    startBtn.Text = "Stop Farming" -- default will be ON if autoStartFarm true
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

    -- Hop button (new)
    local hopBtn = Instance.new("TextButton", panel)
    hopBtn.Name = "HopBtn"
    hopBtn.Size = UDim2.new(1, -12, 0, 28)
    hopBtn.Position = UDim2.new(0, 6, 0, 118)
    hopBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)
    hopBtn.Font = Enum.Font.GothamBold
    hopBtn.TextSize = 14
    hopBtn.TextColor3 = Color3.new(1,1,1)
    hopBtn.Text = "Hop Server"
    Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0,6)

    -- Hide/Show button (kept on the bottom center of screen)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 120, 0, 36)
    toggleBtn.Position = UDim2.new(0.5, -60, 1, -56)
    toggleBtn.AnchorPoint = Vector2.new(0.5, 1)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 15
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Text = "Hide UI"
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)

    -- simple exposure of key UI elements
    return {
        screenGui = screenGui,
        bg = bg,
        panel = panel,
        counter = counter,
        statusLabel = statusLabel,
        startBtn = startBtn,
        hopBtn = hopBtn,
        toggleBtn = toggleBtn
    }
end

-- create UI
local ui = createUI()
local statusLabel = ui.statusLabel
local counterLabel = ui.counter
local startBtn = ui.startBtn
local hopBtn = ui.hopBtn
local toggleBtn = ui.toggleBtn
local panel = ui.panel

-- Status helper
local function setStatus(s)
    pcall(function() statusLabel.Text = "Status: " .. tostring(s) end)
end

-- Update diamonds counter loop
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if DiamondCountText then
                counterLabel.Text = "Diamonds: " .. tostring(DiamondCountText.Text or "0")
            end
        end)
    end
end)

-- Hide/Show logic
local visible = true
toggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    panel.Visible = visible
    toggleBtn.Text = visible and "Hide UI" or "Show UI"
end)

-- Hop button
hopBtn.MouseButton1Click:Connect(function()
    setStatus("Hopping (manual)")
    task.spawn(hopServer)
end)

-- FARMING LOGIC (chest → prompt → collect → hop)
local farming = CONFIG.autoStartFarm and (game.PlaceId == CONFIG.farmPlace) -- only auto start in farmPlace

local function farmCycle()
    setStatus("Farming")
    while farming do
        -- ensure HRP exists
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then break end

        -- find chest
        local chest = workspace:FindFirstChild("Items") and (workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest"))
        if not chest then
            notify("Chest", "Chest not found — hopping", 3)
            setStatus("Hopping (no chest)")
            hopServer()
            return
        end

        -- move to chest
        pcall(function()
            local pivot = chest:GetPivot()
            hrp:PivotTo(CFrame.new(pivot.Position + Vector3.new(0,5,0)))
        end)

        -- find prompt
        local proxPrompt
        local start = tick()
        repeat
            local mainPart = chest:FindFirstChild("Main")
            local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
            task.wait(0.1)
        until proxPrompt or (tick() - start) > 12 or not farming

        if not farming then break end

        if not proxPrompt then
            notify("Prompt", "No prompt found — hopping", 3)
            setStatus("Hopping (no prompt)")
            hopServer()
            return
        end

        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            notify("Prompt", "Prompt timed out — hopping", 3)
            setStatus("Hopping (timeout)")
            hopServer()
            return
        end

        -- wait for diamonds to spawn
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then break end

        -- collect diamonds
        local collected = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Diamond" then
                pcall(function()
                    if Remote then Remote:FireServer(v) end
                    collected = collected + 1
                end)
            end
        end

        notify("Collected", "Diamonds collected (" .. collected .. ") — hopping", 3)
        setStatus("Hopping (collected)")
        task.wait(1)
        hopServer() -- hop to next server after collect
        task.wait(0.5)
    end
    setStatus("Idle")
end

-- Start/Stop button behavior
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    startBtn.Text = farming and "Stop Farming" or "Start Farming"
    if farming then
        notify("Farming", "Farming started", 3)
        task.spawn(farmCycle)
    else
        notify("Farming", "Farming stopped", 3)
        setStatus("Idle")
    end
end)

-- Auto start farm if configured and we are in the farmPlace
if CONFIG.autoStartFarm and game.PlaceId == CONFIG.farmPlace then
    farming = true
    startBtn.Text = "Stop Farming"
    startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    task.spawn(farmCycle)
else
    farming = false
    startBtn.Text = "Start Farming"
    startBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    setStatus("Idle")
end

notify("Flashlight Hub", "Loaded — UI ready", 4)
