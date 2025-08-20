-- Improved 99 Nights Diamond Farmer | Cáo Mod (executor-friendly)
-- Paste into your executor and run

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("RequestTakeDiamonds")
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface", 5)
local DiamondCountLabel = Interface and Interface:FindFirstChild("DiamondCount") and Interface.DiamondCount:FindFirstChild("Count")

------------------------------------------------------------------
-- CONFIG (Saved in CoreGui)
------------------------------------------------------------------
local CONFIG_FOLDER_NAME = "CaoModDiamondCfg"
local CONFIG_FILE_NAME = "config.json"

local function ensureConfigFolder()
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = CONFIG_FOLDER_NAME
        folder.Parent = CoreGui
    end
    return folder
end

local function readConfig()
    local folder = ensureConfigFolder()
    local configFile = folder:FindFirstChild(CONFIG_FILE_NAME)
    if configFile and configFile:IsA("StringValue") then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, configFile.Value)
        if ok and type(data) == "table" then
            return data
        end
    end
    local default = {
        autoStart = true,
        showUI = true,
        fpsBoost = false,
        autoHopAfterCollect = true,
        hopProtection = true
    }
    local newValue = Instance.new("StringValue")
    newValue.Name = CONFIG_FILE_NAME
    newValue.Value = HttpService:JSONEncode(default)
    newValue.Parent = folder
    return default
end

local function writeConfig(tbl)
    local folder = ensureConfigFolder()
    local file = folder:FindFirstChild(CONFIG_FILE_NAME)
    if not file then
        file = Instance.new("StringValue")
        file.Name = CONFIG_FILE_NAME
        file.Parent = folder
    end
    file.Value = HttpService:JSONEncode(tbl)
end

local CONFIG = readConfig()

------------------------------------------------------------------
-- UTILITIES
------------------------------------------------------------------
local function safeNotify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local function hopServer()
    -- Try to find another server and teleport there once
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)
    if not success or not body then
        safeNotify("Hop Failed", "Couldn't query servers.", 4)
        return
    end

    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or not data or not data.data then
        safeNotify("Hop Failed", "Invalid server list.", 4)
        return
    end

    -- Prefer random server with free slots
    local candidates = {}
    for _, server in ipairs(data.data) do
        if type(server.playing) == "number" and type(server.maxPlayers) == "number" and server.id ~= game.JobId and server.playing < server.maxPlayers then
            table.insert(candidates, server.id)
        end
    end

    if #candidates == 0 then
        safeNotify("Hop", "No available servers found.", 4)
        return
    end

    local target = candidates[math.random(1, #candidates)]
    pcall(function()
        TeleportService:TeleportToPlaceInstance(gameId, target, LocalPlayer)
    end)
end

local function setFPSBoost(enabled)
    -- Wrap operations in pcall because some properties may be protected
    pcall(function()
        if game:GetService("Lighting") then
            local lighting = game:GetService("Lighting")
            if lighting:GetAttribute("OriginalGlobalShadows") == nil then
                lighting:SetAttribute("OriginalGlobalShadows", lighting.GlobalShadows)
                lighting:SetAttribute("OriginalFogEnd", lighting.FogEnd)
            end
            lighting.GlobalShadows = not enabled
            lighting.FogEnd = enabled and 100000 or 1000
        end

        -- Rendering quality may error depending on environment; wrap
        pcall(function()
            settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21
        end)

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                pcall(function() obj.Enabled = not enabled end)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() obj.Transparency = enabled and 1 or 0 end)
            end
        end
    end)
    CONFIG.fpsBoost = enabled
    writeConfig(CONFIG)
end

------------------------------------------------------------------
-- DUPLICATE CHARACTER DETECTION (Hop Protection)
------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        if CONFIG.hopProtection then
            local myName = LocalPlayer.DisplayName or LocalPlayer.Name
            for _, char in pairs(workspace:GetChildren()) do
                if typeof(char) == "Instance" and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    local display = (char.Humanoid.DisplayName ~= "" and char.Humanoid.DisplayName) or (char.Name)
                    if display == myName and char ~= LocalPlayer.Character then
                        safeNotify("⚠️ Duplicate", "Duplicate character detected! Hopping...", 3)
                        hopServer()
                        break
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- UI
------------------------------------------------------------------
local ui = CoreGui:FindFirstChild("CaoDiamondFarmerImproved")
if ui then ui:Destroy() end

ui = Instance.new("ScreenGui")
ui.Name = "CaoDiamondFarmerImproved"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 170)
main.Position = UDim2.new(0, 60, 0, 90)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2

-- simple rainbow stroke
task.spawn(function()
    while true do
        for h = 0, 1, 0.02 do
            pcall(function() stroke.Color = Color3.fromHSV(h, 1, 1) end)
            task.wait(0.02)
        end
    end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -60, 0, 28)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Farm Diamond | Cáo Mod"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -36, 0, 6)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(220,220,220)

local minimizeBtn = Instance.new("TextButton", main)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -66, 0, 6)
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.TextColor3 = Color3.fromRGB(220,220,220)

local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(1, -16, 0, 22)
statusLabel.Position = UDim2.new(0, 8, 0, 38)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1, -16, 0, 22)
counter.Position = UDim2.new(0, 8, 0, 62)
counter.BackgroundColor3 = Color3.fromRGB(10,10,10)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.fromRGB(255,255,255)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0,6)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1, -16, 0, 30)
startBtn.Position = UDim2.new(0, 8, 0, 92)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.TextSize = 14
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local btnRow = Instance.new("Frame", main)
btnRow.Size = UDim2.new(1, -16, 0, 28)
btnRow.Position = UDim2.new(0, 8, 0, 128)
btnRow.BackgroundTransparency = 1

local hideBtn = Instance.new("TextButton", btnRow)
hideBtn.Size = UDim2.new(0.48, -6, 1, 0)
hideBtn.Position = UDim2.new(0, 0, 0, 0)
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = CONFIG.showUI and "Hide UI" or "Show UI"
hideBtn.Font = Enum.Font.Gotham
hideBtn.TextColor3 = Color3.fromRGB(255,255,255)
hideBtn.TextSize = 13
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,6)

local fpsBtn = Instance.new("TextButton", btnRow)
fpsBtn.Size = UDim2.new(0.48, -6, 1, 0)
fpsBtn.Position = UDim2.new(0.52, 0, 0, 0)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.Gotham
fpsBtn.TextColor3 = Color3.fromRGB(255,255,255)
fpsBtn.TextSize = 13
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0,6)

-- Additional toggles
local autoHopToggle = Instance.new("TextButton", main)
autoHopToggle.Size = UDim2.new(0.48, -8, 0, 20)
autoHopToggle.Position = UDim2.new(0, 8, 0, 156) -- won't be visible unless frame taller; kept for settings storage
autoHopToggle.Text = CONFIG.autoHopAfterCollect and "Auto Hop: ON" or "Auto Hop: OFF"
autoHopToggle.Visible = false

local hopProtectToggle = Instance.new("TextButton", main)
hopProtectToggle.Size = UDim2.new(0.48, -8, 0, 20)
hopProtectToggle.Position = UDim2.new(0.52, 8, 0, 156)
hopProtectToggle.Text = CONFIG.hopProtection and "HopProt: ON" or "HopProt: OFF"
hopProtectToggle.Visible = false

------------------------------------------------------------------
-- GUI Logic
------------------------------------------------------------------
local farming = CONFIG.autoStart
local farmingThreadActive = false
local collectedRounds = 0

local function setGuiVisible(visible)
    main.Visible = visible
    CONFIG.showUI = visible
    writeConfig(CONFIG)
    hideBtn.Text = visible and "Hide UI" or "Show UI"
end

setGuiVisible(CONFIG.showUI)
setFPSBoost(CONFIG.fpsBoost)

closeBtn.MouseButton1Click:Connect(function()
    ui:Destroy()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    main.Size = (main.Size == UDim2.new(0, 260, 0, 170)) and UDim2.new(0, 220, 0, 34) or UDim2.new(0, 260, 0, 170)
end)

hideBtn.MouseButton1Click:Connect(function()
    setGuiVisible(not main.Visible)
end)

fpsBtn.MouseButton1Click:Connect(function()
    local newState = not CONFIG.fpsBoost
    setFPSBoost(newState)
    fpsBtn.BackgroundColor3 = newState and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
    fpsBtn.Text = newState and "FPS: ON" or "FPS: OFF"
end)

------------------------------------------------------------------
-- Helpers for farming
------------------------------------------------------------------
local function findChest()
    -- Look for likely chest names
    local names = {"Stronghold Diamond Chest", "Chest", "DiamondChest", "Diamond Chest"}
    -- First search top-level workspace.Items
    if workspace:FindFirstChild("Items") then
        for _, n in ipairs(names) do
            local c = workspace.Items:FindFirstChild(n)
            if c then return c end
        end
    end
    -- fallback: search entire workspace for models named like chest
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and table.find(names, obj.Name) then
            return obj
        end
    end
    return nil
end

local function getChestPosition(chest)
    if not chest then return nil end
    -- Prefer PrimaryPart or Main part or any BasePart
    if chest.PrimaryPart and chest.PrimaryPart:IsA("BasePart") then
        return chest.PrimaryPart.Position
    end
    local candidate = chest:FindFirstChild("Main") or chest:FindFirstChildWhichIsA("BasePart") or chest:FindFirstChildWhichIsA("Part")
    if candidate and candidate:IsA("BasePart") then
        return candidate.Position
    end
    -- fallback: model pivot
    local ok, pivot = pcall(function() return chest:GetPivot().Position end)
    if ok and pivot then return pivot end
    return nil
end

local function firePromptUntilCollected(prompt, timeout)
    timeout = timeout or 8
    local start = tick()
    while tick() - start < timeout do
        if not prompt or not prompt.Parent then break end
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.2)
    end
end

local function collectDiamonds()
    if not Remote then
        safeNotify("Error", "Remote not found. Can't collect diamonds.", 4)
        return
    end
    local found = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Diamond" and obj.Parent then
            found = true
            pcall(function() Remote:FireServer(obj) end)
        end
    end
    return found
end

------------------------------------------------------------------
-- Main Farming Loop
------------------------------------------------------------------
local function farmCycle()
    if farmingThreadActive then return end
    farmingThreadActive = true
    statusLabel.Text = "Status: Farming"
    while farming do
        pcall(function()
            -- Wait for character
            repeat task.wait(0.2) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not farming
            if not farming then return end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.5)
                return
            end

            -- Find chest
            local chest = findChest()
            if not chest then
                safeNotify("⚠️", "Chest not found. Hopping...", 3)
                hopServer()
                return
            end

            -- Move to chest
            local pos = getChestPosition(chest)
            if pos then
                pcall(function() hrp:PivotTo(CFrame.new(pos + Vector3.new(0,5,0))) end)
            end
            task.wait(0.2)

            -- Detect proximity prompt on chest
            local proxPrompt
            for _, d in ipairs(chest:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    proxPrompt = d
                    break
                end
            end
            -- fallback: find attachment-based prompt
            if not proxPrompt then
                for _, d in ipairs(chest:GetDescendants()) do
                    if d.Name:lower():find("prompt") or d.Name:lower():find("proximity") then
                        if d:IsA("ProximityPrompt") then proxPrompt = d; break end
                    end
                end
            end

            if proxPrompt then
                firePromptUntilCollected(proxPrompt, 8)
            else
                -- try to trigger any interactable main part if prompt missing
                pcall(function()
                    local mainPart = chest:FindFirstChild("Main") or chest:FindFirstChildWhichIsA("BasePart")
                    if mainPart then
                        -- touch simulation attempt
                        firetouchinterest(mainPart, hrp, 0)
                        task.wait(0.1)
                        firetouchinterest(mainPart, hrp, 1)
                    end
                end)
            end

            -- Wait for diamonds to spawn
            local waited = 0
            while not workspace:FindFirstChild("Diamond", true) and waited < 6 and farming do
                task.wait(0.3)
                waited = waited + 0.3
            end
            if not farming then return end

            -- Collect
            local okCollect = collectDiamonds()
            if okCollect then
                collectedRounds = collectedRounds + 1
                safeNotify("💎", "Diamonds collected!", 3)
                -- update UI counter ASAP
                counter.Text = "Diamonds: " .. (DiamondCountLabel and tostring(DiamondCountLabel.Text) or "0")
                task.wait(0.8)
                -- Hop after collect if configured
                if CONFIG.autoHopAfterCollect then
                    hopServer()
                    return
                end
            else
                safeNotify("⚠️", "No diamonds found after prompt.", 3)
                -- optional hop to find another server
                if CONFIG.autoHopAfterCollect then hopServer(); return end
            end
        end)
        task.wait(0.2)
    end
    statusLabel.Text = "Status: Idle"
    farmingThreadActive = false
end

-- Start/Stop button behaviour
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CONFIG.autoStart = farming
    writeConfig(CONFIG)
    if farming then
        startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        startBtn.Text = "Stop Farming"
        safeNotify("✅", "Farming started!", 3)
        task.spawn(farmCycle)
    else
        startBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
        startBtn.Text = "Start Farming"
        safeNotify("🛑", "Farming stopped.", 3)
    end
end)

-- Update diamond counter every 0.2s (reads from game UI if available)
task.spawn(function()
    while true do
        pcall(function()
            counter.Text = "Diamonds: " .. (DiamondCountLabel and tostring(DiamondCountLabel.Text) or "--")
        end)
        task.wait(0.2)
    end
end)

-- Auto-start
if CONFIG.autoStart then
    farming = true
    task.spawn(farmCycle)
end

safeNotify("✨ Script Loaded", "Press Start Farming or auto-farming is ON", 5)
print("[CaoMod] Improved script loaded")
