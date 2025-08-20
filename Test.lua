-- 99 Nights Diamond Farmer | Cáo Mod (Merged Build) — Updated: Status + Spam Hop + Flashlight Hub UI
-- Features: Nonstop Farm Cycle, Server Hop (retry/spam), FPS Boost, Hop Protection, Rainbow UI, Status Label, UI image placeholder

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
    autoSpamHop = true,   -- if true, hopServer will keep trying servers until teleport succeeds or attempts exhausted
    maxHopAttempts = 12,  -- how many teleport attempts before giving up for a single hop call
    hopAttemptDelay = 0.5 -- delay between teleport attempts (seconds)
}

------------------------------------------------------------------
-- UTILITIES / STATUS
------------------------------------------------------------------
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3})
    end)
end

local STATUS = "Idle" -- Idle / Farming / Hopping
local function setStatus(newStatus)
    STATUS = newStatus
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = "Status: " .. tostring(newStatus)
    end
end

------------------------------------------------------------------
-- HOP SERVER (with retries / spam attempts)
------------------------------------------------------------------
local function hopServer()
    setStatus("Hopping")
    local gameId = game.PlaceId
    local success, body = pcall(function()
        return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
    end)

    if not success or not body then
        notify("🌐 Hop Error", "Failed to request server list.", 3)
        setStatus("Idle")
        return
    end

    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then
        notify("🌐 Hop Error", "Malformed server list.", 3)
        setStatus("Idle")
        return
    end

    local servers = {}
    for _, server in ipairs(data.data) do
        if server and server.id and server.id ~= game.JobId then
            table.insert(servers, server)
        end
    end

    if #servers == 0 then
        notify("🌐 Hop", "No available servers found.", 3)
        setStatus("Idle")
        return
    end

    -- shuffle servers (simple)
    math.randomseed(tick() + os.time())
    for i = #servers, 2, -1 do
        local j = math.random(1, i)
        servers[i], servers[j] = servers[j], servers[i]
    end

    local attempts = 0
    -- attempt teleports until success or attempts exhausted
    while attempts < CONFIG.maxHopAttempts do
        attempts = attempts + 1
        local server = servers[((attempts-1) % #servers) + 1]
        if server and server.id then
            notify("🌐 Hopping", ("Attempt %d → server %s (%d/%d)"):format(attempts, tostring(server.id), server.playing or 0, server.maxPlayers or 0), 2)
            local okTeleport, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
            end)
            if okTeleport then
                -- if teleport succeeded, player will leave; code below may not run
                return
            else
                -- teleport failed (server full / error) — continue trying
                -- small delay before next attempt
                task.wait(CONFIG.hopAttemptDelay)
            end
        else
            task.wait(0.1)
        end
    end

    notify("🌐 Hop", "All hop attempts failed — trying again later.", 3)
    setStatus("Idle")
end

------------------------------------------------------------------
-- FPS BOOST
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
-- HOP PROTECTION (Duplicate Detection)
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if CONFIG.hopProtection then
            for _, char in pairs(workspace.Characters:GetChildren()) do
                if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char.Humanoid.DisplayName == LocalPlayer.DisplayName and char ~= LocalPlayer.Character then
                        notify("⚠️ Duplicate", "Duplicate character detected! Hopping...", 3)
                        hopServer()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- UI (Flashlight Hub) + Status Label + Image Placeholder
------------------------------------------------------------------
local ui = CoreGui:FindFirstChild("CaoDiamondFarmer")
if ui then ui:Destroy() end
ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "FlashlightHub" -- renamed UI

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 260, 0, 170)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.Active, main.Draggable = true, true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
task.spawn(function()
    while task.wait() do
        for h = 0, 1, 0.01 do
            stroke.Color = Color3.fromHSV(h,1,1)
            task.wait(0.02)
        end
    end
end)

-- Image placeholder (set your image asset id below)
local icon = Instance.new("ImageLabel", main)
icon.Size = UDim2.new(0, 44, 0, 44)
icon.Position = UDim2.new(0, 8, 0, 8)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://PUT_IMAGE_ID_HERE" -- <-- replace with your decal asset id
icon.ScaleType = Enum.ScaleType.Crop
icon.ImageTransparency = 0

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-60,0,28)
title.Position = UDim2.new(0,60,0,8)
title.BackgroundTransparency = 1
title.Text = "🔦 Flashlight Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1,-10,0,24)
counter.Position = UDim2.new(0,5,0,44)
counter.BackgroundColor3 = Color3.fromRGB(0,0,0)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.new(1,1,1)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0,6)

local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(1,-10,0,20)
statusLabel.Position = UDim2.new(0,5,0,70)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: " .. STATUS
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.TextSize = 12

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1,-10,0,28)
startBtn.Position = UDim2.new(0,5,0,94)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(1,-10,0,28)
fpsBtn.Position = UDim2.new(0,5,0,128)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0,6)

------------------------------------------------------------------
-- FARMING LOGIC (main)
------------------------------------------------------------------
local farming = CONFIG.autoStart

local function farmCycle()
    while farming do
        setStatus("Farming")
        -- Wait for HRP
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character.HumanoidRootPart

        -- Find chest
        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            notify("⚠️", "Chest not found, hopping...", 3)
            hopServer()
            setStatus("Idle")
            return
        end

        -- move to chest
        pcall(function()
            hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0,5,0)))
        end)

        -- Proximity Prompt
        local proxPrompt
        repeat
            local mainPart = chest:FindFirstChild("Main")
            local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
            proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
            task.wait(0.1)
        until proxPrompt or not farming
        if not farming then setStatus("Idle") return end

        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick()-startTime)<10 and farming do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            notify("⏰", "Prompt timeout, hopping...", 3)
            hopServer()
            setStatus("Idle")
            return
        end

        -- Wait for diamonds
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then setStatus("Idle") return end

        -- Collect diamonds
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name=="Diamond" then
                pcall(function() Remote:FireServer(v) end)
            end
        end

        notify("💎", "Diamonds collected, hopping...", 3)
        task.wait(1)

        -- Hop after collecting
        if CONFIG.autoSpamHop then
            hopServer()
            -- if teleport succeeds player leaves; otherwise continue loop or stop depending on return state
        else
            hopServer() -- single attempt hop (hopServer handles attempts internally anyway)
        end

        task.wait(0.5)
    end
    setStatus("Idle")
end

-- Update counter
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            counter.Text = "Diamonds: " .. tostring(DiamondCount.Text or "0")
        end)
    end
end)

-- Button events
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
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
    fpsBtn.BackgroundColor3 = newState and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
    fpsBtn.Text = newState and "FPS: ON" or "FPS: OFF"
end)

-- Auto-start
if CONFIG.autoStart then
    task.spawn(farmCycle)
end

notify("✨ Script Loaded", "Auto-farming is ON", 5)
