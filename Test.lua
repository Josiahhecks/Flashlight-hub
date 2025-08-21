-- 99 Nights Diamond Farmer | Cáo Mod (Merged Build) -- Flashlight Hub — Modern UI overhaul (keeps existing farming logic) -- NOTES: Replace PUT_IMAGE_ID_HERE with your image asset id

local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local CoreGui = game:GetService("CoreGui") local StarterGui = game:GetService("StarterGui") local TeleportService = game:GetService("TeleportService") local HttpService = game:GetService("HttpService") local ReplicatedStorage = game:GetService("ReplicatedStorage") local TweenService = game:GetService("TweenService")

local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds") local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface") local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

-- 🔒 ONLY RUN IN FARM SERVER if game.PlaceId ~= 126509999114328 then return end


---

-- CONFIG (unchanged)

local CONFIG = { autoStart = true, fpsBoost = false, hopProtection = true, autoSpamHop = true, maxHopAttempts = 12, hopAttemptDelay = 0.5 }


---

-- UTILITIES

local function notify(title, text, dur) pcall(function() StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 3}) end) end

local STATUS = "Idle" local statusLabel -- forward declaration (UI created later) local function setStatus(newStatus) STATUS = newStatus if statusLabel and statusLabel.Parent then statusLabel.Text = "Status: " .. tostring(newStatus) end end


---

-- HOP SERVER (unchanged)

local function hopServer() setStatus("Hopping") local gameId = game.PlaceId local success, body = pcall(function() return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId)) end)

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

math.randomseed(tick() + os.time())
for i = #servers, 2, -1 do
    local j = math.random(1, i)
    servers[i], servers[j] = servers[j], servers[i]
end

local attempts = 0
while attempts < CONFIG.maxHopAttempts do
    attempts += 1
    local server = servers[((attempts - 1) % #servers) + 1]
    if server and server.id then
        notify("🌐 Hopping", ("Attempt %d → %s (%d/%d)"):format(attempts, server.id, server.playing or 0, server.maxPlayers or 0), 2)
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
        end)
        if ok then return end
        task.wait(CONFIG.hopAttemptDelay)
    else
        task.wait(0.1)
    end
end

notify("🌐 Hop", "All attempts failed — retrying later.", 3)
setStatus("Idle")

end


---

-- FPS BOOST (unchanged)

local function setFPSBoost(enabled) local Lighting = game:GetService("Lighting") Lighting.GlobalShadows = not enabled Lighting.FogEnd = enabled and 100000 or 1000 pcall(function() settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21 end) for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("ParticleEmitter") then obj.Enabled = not enabled elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = enabled and 1 or 0 end end CONFIG.fpsBoost = enabled end


---

-- HOP PROTECTION (unchanged)

task.spawn(function() while task.wait(1) do if CONFIG.hopProtection then for _, char in pairs(workspace.Characters:GetChildren()) do if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then if char.Humanoid.DisplayName == LocalPlayer.DisplayName and char ~= LocalPlayer.Character then notify("⚠️ Duplicate", "Duplicate detected! Hopping...", 3) hopServer() end end end end end end)


---

-- UI OVERHAUL: Modern, compact, animated UI

local ui = CoreGui:FindFirstChild("FlashlightHub") if ui then ui:Destroy() end ui = Instance.new("ScreenGui") ui.Name = "FlashlightHub" ui.ResetOnSpawn = false ui.Parent = CoreGui

-- Main container local main = Instance.new("Frame") main.Name = "Main" main.Size = UDim2.new(0, 380, 0, 220) main.Position = UDim2.new(0, 80, 0, 100) main.AnchorPoint = Vector2.new(0, 0) main.BackgroundColor3 = Color3.fromRGB(20, 20, 20) main.BorderSizePixel = 0 main.Active = true main.Draggable = true main.Parent = ui Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Soft shadow (Frame hack) local shadow = Instance.new("ImageLabel") shadow.Name = "Shadow" shadow.Size = UDim2.new(1, 10, 1, 10) shadow.Position = UDim2.new(0, -5, 0, -5) shadow.BackgroundTransparency = 1 shadow.Image = "rbxassetid://2462868629" -- subtle rounded shadow (Roblox common asset) shadow.ScaleType = Enum.ScaleType.Slice shadow.SliceCenter = Rect.new(10, 10, 118, 118) shadow.ZIndex = 0 shadow.Parent = main

-- Top bar local topBar = Instance.new("Frame", main) topBar.Name = "TopBar" topBar.Size = UDim2.new(1, 0, 0, 54) topBar.Position = UDim2.new(0, 0, 0, 0) topBar.BackgroundTransparency = 1

local icon = Instance.new("ImageLabel", topBar) icon.Name = "Icon" icon.Size = UDim2.new(0, 54, 0, 54) icon.Position = UDim2.new(0, 8, 0, 0) icon.BackgroundTransparency = 1 icon.Image = "rbxassetid://PUT_IMAGE_ID_HERE" icon.ScaleType = Enum.ScaleType.Crop Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", topBar) title.Name = "Title" title.Size = UDim2.new(1, -120, 1, 0) title.Position = UDim2.new(0, 72, 0, 0) title.BackgroundTransparency = 1 title.Text = "🔦 Flashlight Hub — Cáo Mod" title.Font = Enum.Font.GothamBold title.TextColor3 = Color3.fromRGB(255, 255, 255) title.TextSize = 16 title.TextXAlignment = Enum.TextXAlignment.Left

-- Compact subtitle local subtitle = Instance.new("TextLabel", topBar) subtitle.Name = "Subtitle" subtitle.Size = UDim2.new(1, -120, 0, 18) subtitle.Position = UDim2.new(0, 72, 0, 28) subtitle.BackgroundTransparency = 1 subtitle.Text = "Auto Farm • Hop Protection • FPS Boost" subtitle.Font = Enum.Font.Gotham subtitle.TextColor3 = Color3.fromRGB(180, 180, 180) subtitle.TextSize = 12 subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Right controls (collapse + pin) local controls = Instance.new("Frame", topBar) controls.Size = UDim2.new(0, 92, 1, 0) controls.Position = UDim2.new(1, -100, 0, 0) controls.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", controls) closeBtn.Size = UDim2.new(0, 36, 0, 28) closeBtn.Position = UDim2.new(1, -40, 0, 12) closeBtn.AnchorPoint = Vector2.new(1, 0) closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) closeBtn.Text = "✕" closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 16 closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220) Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local collapseBtn = Instance.new("TextButton", controls) collapseBtn.Size = UDim2.new(0, 36, 0, 28) collapseBtn.Position = UDim2.new(1, -84, 0, 12) collapseBtn.AnchorPoint = Vector2.new(1, 0) collapseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) collapseBtn.Text = "—" collapseBtn.Font = Enum.Font.GothamBold collapseBtn.TextSize = 16 collapseBtn.TextColor3 = Color3.fromRGB(220, 220, 220) Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0, 6)

-- Content area local content = Instance.new("Frame", main) content.Name = "Content" content.Size = UDim2.new(1, -16, 1, -68) content.Position = UDim2.new(0, 8, 0, 60) content.BackgroundTransparency = 1

-- Left column (status + counter) local leftCol = Instance.new("Frame", content) leftCol.Size = UDim2.new(0.52, 0, 1, 0) leftCol.Position = UDim2.new(0, 0, 0, 0) leftCol.BackgroundTransparency = 1

-- Diamond card local diamondCard = Instance.new("Frame", leftCol) diamondCard.Size = UDim2.new(1, 0, 0, 84) diamondCard.Position = UDim2.new(0, 0, 0, 0) diamondCard.BackgroundColor3 = Color3.fromRGB(26, 26, 26) diamondCard.BorderSizePixel = 0 Instance.new("UICorner", diamondCard).CornerRadius = UDim.new(0, 8)

local diamondIcon = Instance.new("ImageLabel", diamondCard) diamondIcon.Size = UDim2.new(0, 48, 0, 48) diamondIcon.Position = UDim2.new(0, 12, 0, 18) diamondIcon.BackgroundTransparency = 1 diamondIcon.Image = "rbxthumb://type=Asset&id=1423760887&w=420&h=420" diamondIcon.ScaleType = Enum.ScaleType.Fit

local counter = Instance.new("TextLabel", diamondCard) counter.Name = "DiamondCounter" counter.Size = UDim2.new(1, -84, 0, 40) counter.Position = UDim2.new(0, 72, 0, 12) counter.BackgroundTransparency = 1 counter.Text = "Diamonds: --" counter.Font = Enum.Font.GothamBold counter.TextColor3 = Color3.fromRGB(255, 255, 255) counter.TextSize = 20 counter.TextXAlignment = Enum.TextXAlignment.Left

local smallNote = Instance.new("TextLabel", diamondCard) smallNote.Size = UDim2.new(1, -24, 0, 20) smallNote.Position = UDim2.new(0, 12, 0, 56) smallNote.BackgroundTransparency = 1 smallNote.Text = "Auto-collect when diamonds appear" smallNote.Font = Enum.Font.Gotham smallNote.TextColor3 = Color3.fromRGB(160, 160, 160) smallNote.TextSize = 12 smallNote.TextXAlignment = Enum.TextXAlignment.Left

-- Status card local statusCard = Instance.new("Frame", leftCol) statusCard.Size = UDim2.new(1, 0, 0, 54) statusCard.Position = UDim2.new(0, 0, 0, 96) statusCard.BackgroundColor3 = Color3.fromRGB(24, 24, 24) Instance.new("UICorner", statusCard).CornerRadius = UDim.new(0, 8)

statusLabel = Instance.new("TextLabel", statusCard) statusLabel.Size = UDim2.new(1, -12, 1, 0) statusLabel.Position = UDim2.new(0, 6, 0, 0) statusLabel.BackgroundTransparency = 1 statusLabel.Text = "Status: " .. STATUS statusLabel.Font = Enum.Font.GothamBold statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) statusLabel.TextSize = 14 statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Right column (controls) local rightCol = Instance.new("Frame", content) rightCol.Size = UDim2.new(0.48, 0, 1, 0) rightCol.Position = UDim2.new(0.52, 8, 0, 0) rightCol.BackgroundTransparency = 1

local controlsLayout = Instance.new("UIListLayout", rightCol) controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder controlsLayout.Padding = UDim.new(0, 8)

local function makeToggle(text, initial) local card = Instance.new("Frame", rightCol) card.Size = UDim2.new(1, 0, 0, 44) card.BackgroundColor3 = Color3.fromRGB(28, 28, 28) card.BorderSizePixel = 0 Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel", card)
label.Size = UDim2.new(0.7, -8, 1, 0)
label.Position = UDim2.new(0, 12, 0, 0)
label.BackgroundTransparency = 1
label.Text = text
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.TextColor3 = Color3.fromRGB(220, 220, 220)
label.TextXAlignment = Enum.TextXAlignment.Left

local toggle = Instance.new("TextButton", card)
toggle.Size = UDim2.new(0, 88, 0, 32)
toggle.Position = UDim2.new(1, -96, 0.5, -16)
toggle.BackgroundColor3 = initial and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
toggle.Text = initial and "ON" or "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 14
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

return card, toggle

end

-- Toggles local farmCard, startBtn = makeToggle("Auto Farm", CONFIG.autoStart) local fpsCard, fpsBtn = makeToggle("FPS Boost", CONFIG.fpsBoost) local hopCard, hopBtn = makeToggle("Hop Protection", CONFIG.hopProtection) local spamCard, spamBtn = makeToggle("Auto Spam Hop", CONFIG.autoSpamHop)

-- Progress / last-collected bar local progressCard = Instance.new("Frame", rightCol) progressCard.Size = UDim2.new(1, 0, 0, 54) progressCard.BackgroundColor3 = Color3.fromRGB(26, 26, 26) Instance.new("UICorner", progressCard).CornerRadius = UDim.new(0, 8)

local progressLabel = Instance.new("TextLabel", progressCard) progressLabel.Size = UDim2.new(1, -12, 0, 18) progressLabel.Position = UDim2.new(0, 6, 0, 6) progressLabel.BackgroundTransparency = 1 progressLabel.Text = "Last action: —" progressLabel.Font = Enum.Font.Gotham progressLabel.TextSize = 12 progressLabel.TextColor3 = Color3.fromRGB(170, 170, 170) progressLabel.TextXAlignment = Enum.TextXAlignment.Left

local progressBarBg = Instance.new("Frame", progressCard) progressBarBg.Size = UDim2.new(1, -12, 0, 12) progressBarBg.Position = UDim2.new(0, 6, 0, 30) progressBarBg.BackgroundColor3 = Color3.fromRGB(36, 36, 36) Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0, 6)

local progressBar = Instance.new("Frame", progressBarBg) progressBar.Size = UDim2.new(0, 0, 1, 0) progressBar.Position = UDim2.new(0, 0, 0, 0) progressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255) Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 6)


---

-- UI Behavior & connections (keeps original logic)

-- Collapse behavior local collapsed = false local fullSize = main.Size collapseBtn.MouseButton1Click:Connect(function() collapsed = not collapsed if collapsed then main:TweenSize(UDim2.new(0, 380, 0, 64), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true) collapseBtn.Text = "+" else main:TweenSize(fullSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true) collapseBtn.Text = "—" end end)

-- Close (toggle visibility) local visible = true closeBtn.MouseButton1Click:Connect(function() visible = not visible ui.Enabled = visible if visible then notify("✨", "Flashlight Hub opened", 2) else notify("🔒", "Flashlight Hub hidden", 2) end end)

-- Smooth progress helper local function setProgress(pct) pct = math.clamp(pct or 0, 0, 1) TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(pct, 0, 1, 0)}):Play() end

-- Update counter loop (keeps behavior) task.spawn(function() while task.wait(0.2) do pcall(function() counter.Text = "Diamonds: " .. tostring(DiamondCount.Text or "0") end) end end)


---

-- Farming logic (kept intact)

local farming = CONFIG.autoStart

local function farmCycle() while farming do setStatus("Farming")

-- Wait for character
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hrp = LocalPlayer.Character.HumanoidRootPart

    -- Find chest
    local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        notify("❌", "Chest not found, hopping...")
        setStatus("Hopping")
        hopServer()
        return
    end

    -- Teleport to chest
    pcall(function()
        hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))
    end)

    -- Wait for proximity prompt
    local proxPrompt = nil
    repeat
        task.wait(0.1)
        local mainPart = chest:FindFirstChild("Main")
        local attach = mainPart and mainPart:FindFirstChild("ProximityAttachment")
        proxPrompt = attach and attach:FindFirstChild("ProximityInteraction")
    until proxPrompt or not farming

    if not farming then break end

    -- Fire prompt
    local startTime = tick()
    while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 and farming do
        pcall(fireproximityprompt, proxPrompt)
        task.wait(0.2)
        setProgress((tick() - startTime) / 10)
    end

    if proxPrompt and proxPrompt.Parent then
        notify("⏰", "Stronghold started! Hopping...")
        setStatus("Hopping")
        hopServer()
        return
    end

    -- Wait for diamonds
    repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
    if not farming then break end

    -- Collect diamonds
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Diamond" then
            pcall(function()
                Remote:FireServer(v)
            end)
        end
    end

    setStatus("✅ Collected all diamonds!")
    progressLabel.Text = "Last action: Collected diamonds"
    setProgress(1)
    notify("💎", "Collected! Hopping...", 3)
    task.wait(1)
    hopServer()
end
setStatus("Idle")

end

-- UI Buttons behavior hooking into existing logic startBtn.MouseButton1Click:Connect(function() farming = not farming startBtn.BackgroundColor3 = farming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(120, 0, 0) startBtn.Text = farming and "ON" or "OFF" if farming then notify("✅", "Farming started!", 3) task.spawn(farmCycle) else setStatus("Idle") notify("🛑", "Farming stopped.", 3) end end)

fpsBtn.MouseButton1Click:Connect(function() local newState = not CONFIG.fpsBoost setFPSBoost(newState) CONFIG.fpsBoost = newState fpsBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80) fpsBtn.Text = newState and "ON" or "OFF" end)

hopBtn.MouseButton1Click:Connect(function() CONFIG.hopProtection = not CONFIG.hopProtection hopBtn.BackgroundColor3 = CONFIG.hopProtection and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80) hopBtn.Text = CONFIG.hopProtection and "ON" or "OFF" end)

spamBtn.MouseButton1Click:Connect(function() CONFIG.autoSpamHop = not CONFIG.autoSpamHop spamBtn.BackgroundColor3 = CONFIG.autoSpamHop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80) spamBtn.Text = CONFIG.autoSpamHop and "ON" or "OFF" end)

-- Auto-start if CONFIG.autoStart then task.spawn(farmCycle) end

notify("✨ Script Loaded", "Flashlight Hub — modern UI loaded", 5)

