-- Flashlight Hub — Full LocalScript (StarterPlayerScripts)
-- Integrated pre-teleport navigation → farm place → improved UI → auto-farm + server-hop
-- NOTE: Some input APIs used for toggling UI may require exploit-level runtime (VirtualInputManager).
-- Always run in a safe/test environment first.

-- ========== CONFIG ==========
local CONFIG = {
    startPlace = 79546208627805,          -- starting place (auto-teleport to farmPlace if you spawn here)
    farmPlace  = 126509999114328,         -- farming place (only run farm logic here)
    autoStartFarm = true,                 -- begin farming automatically after teleport/landing
    hopProtection = true,                 -- detect duplicate players and hop
    maxHopAttempts = 100,                 -- max attempts when trying to hop
    hopAttemptDelay = 0.6,                -- wait between hop retries
    serverFetchLimit = 100,               -- number of servers fetched per request (Roblox API)
    uiAccentColor = Color3.fromRGB(0, 230, 230),
    uiBg = Color3.fromRGB(18, 18, 22),
}

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ========== UTILITIES ==========
local function safeNotify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 3
        })
    end)
end

local function twait(s) task.wait(s or 0.03) end

-- ========== PRE-TELEPORT NAVIGATION SEQUENCE ==========
local function attemptFireTeleportEvent()
    local success, err = pcall(function()
        local rems = ReplicatedStorage:WaitForChild("RemoteEvents", 2)
        local tele = rems and rems:FindFirstChild("TeleportEvent")
        if tele and tele.FireServer then
            tele:FireServer("Add", 3) -- original args: {"Add", 3}
            return true
        end
        return false
    end)
    return success and err
end

-- Try clicking toggle UI element twice; fallback to VirtualInputManager key events (if available)
local function attemptToggleNavigationTwice()
    local done = false
    -- Attempt to find known toggle buttons in PlayerGui
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 2)
        if pg then
            -- Common possible names, try to find and invoke .Activated or .MouseButton1Click
            local candidates = {
                pg:FindFirstChild("ToggleNavigation"),
                pg:FindFirstChild("NavigationToggle"),
                pg:FindFirstChild("UIToggle"),
                pg:FindFirstChild("uiToggleNavigation"),
            }
            for _, c in ipairs(candidates) do
                if c and c:IsA("TextButton") or c:IsA("ImageButton") then
                    for i = 1, 2 do
                        pcall(function() c:Activate() end) -- modern API
                        pcall(function() c.MouseButton1Click:Fire() end)
                        task.wait(0.18)
                    end
                    done = true
                    break
                end
            end
        end
    end)

    if done then return true end

    -- Fallback: try to use VirtualInputManager (only available in some environments)
    local ok = pcall(function()
        local vim = (syn and syn.request and syn) or (getgenv and getgenv()) or nil
        -- The above is only a weak attempt; instead try the real VirtualInputManager if present:
        if game:GetService("VirtualInputManager") then
            local vm = game:GetService("VirtualInputManager")
            -- Attempt send keypress (e.g., Tab twice). We send Return later separately.
            for i = 1, 2 do
                vm:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
                vm:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
                task.wait(0.15)
            end
            return true
        end
        -- Some exploit hosts expose VirtualInputManager as global 'VirtualInputManager'
        if _G.VirtualInputManager then
            _G.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
            _G.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
            _G.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
            _G.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
            return true
        end
    end)

    return ok
end

local function attemptPressEnter()
    local ok = pcall(function()
        if game:GetService("VirtualInputManager") then
            local vm = game:GetService("VirtualInputManager")
            vm:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            vm:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            return true
        end
        if _G.VirtualInputManager then
            _G.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            _G.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            return true
        end
    end)
    return ok
end

local function runPreTeleportSequence()
    -- 1) Fire RemoteEvent
    pcall(function() safeNotify("Flashlight Hub", "Firing TeleportEvent...", 2) end)
    attemptFireTeleportEvent()
    task.wait(0.8)

    -- 2) Toggle navigation twice (best effort)
    pcall(function() safeNotify("Flashlight Hub", "Toggling UI navigation...", 2) end)
    attemptToggleNavigationTwice()
    task.wait(0.45)

    -- 3) Press Enter
    pcall(function() attemptPressEnter() end)
    task.wait(0.5)

    -- 4) Wait until we are in farmPlace
    safeNotify("Flashlight Hub", "Waiting for farm place...", 3)
    repeat task.wait(1) until game.PlaceId == CONFIG.farmPlace
    safeNotify("Flashlight Hub", "Arrived at farm place — loading hub", 3)
end

-- If we spawned in startPlace, immediately teleport to farmPlace (preserve localplayer)
if game.PlaceId == CONFIG.startPlace then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Flashlight Hub",
            Text = "Teleporting to farm place...",
            Duration = 4
        })
    end)
    pcall(function()
        TeleportService:Teleport(CONFIG.farmPlace, LocalPlayer)
    end)
    return
end

-- If we are not already in farmPlace, run pre-teleport sequence (non-blocking)
if game.PlaceId ~= CONFIG.farmPlace then
    -- Try pre-sequence once (in many setups the remote + UI toggles will teleport you)
    task.spawn(runPreTeleportSequence)
    -- If the pre-sequence teleports, the script will restart on arrival (and continue).
    -- But in case the pre-sequence didn't move us, proceed to load the hub anyway after a small wait.
    task.wait(3)
end

-- ========== FIND COMMON REMOTES & GUI DATA ==========
local RemoteEventsFolder
pcall(function() RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 4) end)
local TeleportEvent = RemoteEventsFolder and RemoteEventsFolder:FindFirstChild("TeleportEvent")
local RequestTakeDiamondsRemote = RemoteEventsFolder and RemoteEventsFolder:FindFirstChild("RequestTakeDiamonds")

-- Try to find a diamond counter label (from previous script)
local function findDiamondCounterLabel()
    local ok, label = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local interface = pg:FindFirstChild("Interface") or pg:FindFirstChild("MainGui") or pg:FindFirstChild("HUD")
        if interface then
            -- common nested names
            local candidates = {
                interface:FindFirstChild("DiamondCount"),
                interface:FindFirstChild("Diamonds"),
                interface:FindFirstChild("DiamondLabel"),
            }
            for _, c in ipairs(candidates) do
                if c and c:FindFirstChild("Count") and c.Count:IsA("TextLabel") then
                    return c.Count
                end
                if c and c:IsA("TextLabel") then
                    return c
                end
            end
        end
        return nil
    end)
    if ok then return label end
    return nil
end

-- ========== UI CREATION (polished) ==========
local function createFlashlightHubUI()
    -- Remove old UI if present
    local existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FlashlightHubUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlashlightHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Fullscreen dark background
    local bg = Instance.new("Frame", screenGui)
    bg.Name = "BG"
    bg.Size = UDim2.new(1,0,1,0)
    bg.Position = UDim2.new(0,0,0,0)
    bg.BackgroundColor3 = CONFIG.uiBg
    bg.BackgroundTransparency = 0
    bg.BorderSizePixel = 0

    -- Subtle vignette (ImageLabel optional)
    local vignette = Instance.new("ImageLabel", bg)
    vignette.Name = "Vignette"
    vignette.AnchorPoint = Vector2.new(0.5,0)
    vignette.Size = UDim2.new(0.98, 0, 0.34, 0)
    vignette.Position = UDim2.new(0.5, 0, 0.01, 0)
    vignette.BackgroundTransparency = 1
    vignette.Image = "" -- leave empty; uses gradient inside panel instead

    -- Centered header
    local header = Instance.new("Frame", bg)
    header.Name = "Header"
    header.AnchorPoint = Vector2.new(0.5, 0)
    header.Size = UDim2.new(0.85, 0, 0.22, 0)
    header.Position = UDim2.new(0.5, 0, 0.04, 0)
    header.BackgroundTransparency = 1

    local iconBg = Instance.new("Frame", header)
    iconBg.Name = "IconBg"
    iconBg.AnchorPoint = Vector2.new(0.5, 0)
    iconBg.Size = UDim2.new(0,72,0,72)
    iconBg.Position = UDim2.new(0.5, 0, 0, 0)
    iconBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    iconBg.BorderSizePixel = 0
    iconBg.ZIndex = 2
    local corner = Instance.new("UICorner", iconBg); corner.CornerRadius = UDim.new(0,16)
    local iconLabel = Instance.new("TextLabel", iconBg)
    iconLabel.Size = UDim2.new(1,0,1,0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🔦"
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 32
    iconLabel.TextColor3 = CONFIG.uiAccentColor

    local title = Instance.new("TextLabel", header)
    title.AnchorPoint = Vector2.new(0.5,0)
    title.Size = UDim2.new(1,0,0,44)
    title.Position = UDim2.new(0.5, 0, 0.52, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 44
    title.Text = "FLASHLIGHT HUB"
    title.TextColor3 = Color3.fromRGB(230,230,230)
    title.TextStrokeTransparency = 0.6

    local subtitle = Instance.new("TextLabel", header)
    subtitle.AnchorPoint = Vector2.new(0.5,0)
    subtitle.Size = UDim2.new(1,0,0,22)
    subtitle.Position = UDim2.new(0.5, 0, 0.9, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.Text = "99 nights in the forest"
    subtitle.TextColor3 = Color3.fromRGB(170,170,170)

    -- Main stat panel container
    local cardContainer = Instance.new("Frame", bg)
    cardContainer.Name = "CardContainer"
    cardContainer.AnchorPoint = Vector2.new(0.5, 0)
    cardContainer.Size = UDim2.new(0.9, 0, 0.26, 0)
    cardContainer.Position = UDim2.new(0.5, 0, 0.25, 0)
    cardContainer.BackgroundTransparency = 1

    local cardBg = Instance.new("Frame", cardContainer)
    cardBg.Name = "CardBG"
    cardBg.Size = UDim2.new(1,0,1,0)
    cardBg.Position = UDim2.new(0,0,0,0)
    cardBg.BackgroundColor3 = Color3.fromRGB(26,26,30)
    cardBg.BorderSizePixel = 0
    cardBg.ZIndex = 1
    local cardCorner = Instance.new("UICorner", cardBg); cardCorner.CornerRadius = UDim.new(0,16)
    local innerStroke = Instance.new("UIStroke", cardBg); innerStroke.Thickness = 1; innerStroke.Transparency = 0.7; innerStroke.Color = Color3.fromRGB(38,38,42)

    -- Layout: three stat cards
    local statsFrame = Instance.new("Frame", cardBg)
    statsFrame.Size = UDim2.new(1,-20,1,-20)
    statsFrame.Position = UDim2.new(0,10,0,10)
    statsFrame.BackgroundTransparency = 1

    local grid = Instance.new("UIGridLayout", statsFrame)
    grid.CellSize = UDim2.new(0.32, 0, 1, 0)
    grid.CellPadding = UDim2.new(0, 12, 0, 0)

    local function makeStatCard(titleText, iconEmoji)
        local f = Instance.new("Frame", statsFrame)
        f.BackgroundColor3 = Color3.fromRGB(30,30,36)
        f.BorderSizePixel = 0
        f.Size = UDim2.new(0.32, 0, 1, 0)
        local c = Instance.new("UICorner", f); c.CornerRadius = UDim.new(0,12)

        local top = Instance.new("TextLabel", f)
        top.Size = UDim2.new(1, -12, 0, 28)
        top.Position = UDim2.new(0, 12, 0, 10)
        top.BackgroundTransparency = 1
        top.Font = Enum.Font.GothamSemibold
        top.TextSize = 14
        top.Text = string.upper(titleText)
        top.TextColor3 = Color3.fromRGB(170,170,170)
        top.TextXAlignment = Enum.TextXAlignment.Left

        local icon = Instance.new("TextLabel", f)
        icon.Size = UDim2.new(0, 28, 0, 28)
        icon.Position = UDim2.new(1, -40, 0, 8)
        icon.BackgroundTransparency = 1
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 18
        icon.Text = iconEmoji
        icon.TextColor3 = CONFIG.uiAccentColor

        local value = Instance.new("TextLabel", f)
        value.Name = "Value"
        value.Size = UDim2.new(1, -24, 0, 60)
        value.Position = UDim2.new(0, 12, 0, 38)
        value.BackgroundTransparency = 1
        value.Font = Enum.Font.GothamBlack
        value.TextSize = 34
        value.TextColor3 = Color3.fromRGB(240,240,240)
        value.Text = "--"
        value.TextXAlignment = Enum.TextXAlignment.Left

        -- small sub-value
        local sub = Instance.new("TextLabel", f)
        sub.Name = "Sub"
        sub.Size = UDim2.new(1, -24, 0, 18)
        sub.Position = UDim2.new(0, 12, 0, 98)
        sub.BackgroundTransparency = 1
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 14
        sub.TextColor3 = Color3.fromRGB(160,160,160)
        sub.Text = ""
        sub.TextXAlignment = Enum.TextXAlignment.Left

        return f, value, sub
    end

    local diamondsCard, diamondsValue, diamondsSub = makeStatCard("Diamonds", "💎")
    local dayCard, dayValue, daySub = makeStatCard("Day", "☀️")
    local timeCard, timeValue, timeSub = makeStatCard("Time", "⏱️")

    -- Top-right Hide/Show button
    local toggleBtn = Instance.new("TextButton", bg)
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0,120,0,40)
    toggleBtn.Position = UDim2.new(1, -16, 0, 16)
    toggleBtn.AnchorPoint = Vector2.new(1,0)
    toggleBtn.Text = "Hide GUI"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    toggleBtn.BackgroundColor3 = CONFIG.uiAccentColor
    toggleBtn.TextColor3 = Color3.fromRGB(18,18,22)
    local tcorner = Instance.new("UICorner", toggleBtn); tcorner.CornerRadius = UDim.new(0,10)

    -- small footer status bar
    local statusBar = Instance.new("TextLabel", bg)
    statusBar.Name = "StatusBar"
    statusBar.AnchorPoint = Vector2.new(0.5, 1)
    statusBar.Size = UDim2.new(0.5, 0, 0, 28)
    statusBar.Position = UDim2.new(0.5, 0, 1, -12)
    statusBar.BackgroundTransparency = 1
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextSize = 14
    statusBar.TextColor3 = Color3.fromRGB(190,190,190)
    statusBar.Text = "Status: Idle"

    -- animated accent beam behind header (Frame + gradient via ImageLabel not required)
    local beam = Instance.new("Frame", header)
    beam.Name = "Beam"
    beam.AnchorPoint = Vector2.new(0.5,0)
    beam.Position = UDim2.new(0.5, 0, 0.19, 0)
    beam.Size = UDim2.new(0.7, 0, 0.5, 0)
    beam.BackgroundColor3 = CONFIG.uiAccentColor
    beam.BackgroundTransparency = 0.93
    beam.BorderSizePixel = 0
    local beamCorner = Instance.new("UICorner", beam); beamCorner.CornerRadius = UDim.new(0, 20)

    -- UI Tween helpers
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    toggleBtn.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(toggleBtn, tweenInfo, {Size = UDim2.new(0,136,0,44)}):Play()
        end)
    end)
    toggleBtn.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(toggleBtn, tweenInfo, {Size = UDim2.new(0,120,0,40)}):Play()
        end)
    end)

    -- Toggle hide/show
    local visible = true
    toggleBtn.Activated:Connect(function()
        visible = not visible
        cardContainer.Visible = visible
        header.Visible = visible
        toggleBtn.Text = visible and "Hide GUI" or "Show GUI"
        if not visible then
            statusBar.Text = "Status: Hidden"
        else
            statusBar.Text = "Status: Idle"
        end
    end)

    -- return handles for values & status
    return {
        ScreenGui = screenGui,
        DiamondsLabel = diamondsValue,
        DiamondsSub = diamondsSub,
        DayLabel = dayValue,
        TimeLabel = timeValue,
        StatusBar = statusBar,
        ToggleBtn = toggleBtn,
    }
end

-- Create UI
local ui = createFlashlightHubUI()
local statusBar = ui.StatusBar
local diamondsLabel = ui.DiamondsLabel
local diamondsSub = ui.DiamondsSub
local dayLabel = ui.DayLabel
local timeLabel = ui.TimeLabel

local function setStatus(text)
    pcall(function() statusBar.Text = "Status: " .. tostring(text) end)
end

-- ========== SERVER HOPPING (robust) ==========
local function hopServer()
    setStatus("Hopping")
    local gameId = game.PlaceId
    local attempts = 0
    while attempts < CONFIG.maxHopAttempts do
        attempts = attempts + 1
        local success, body = pcall(function()
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=%d"):format(gameId, CONFIG.serverFetchLimit)
            return game:HttpGet(url)
        end)

        if not success or not body then
            safeNotify("Flashlight Hub", "Server list fetch failed (try " .. attempts .. ")", 2)
            task.wait(CONFIG.hopAttemptDelay)
            continue
        end

        local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok or not decoded or not decoded.data then
            safeNotify("Flashlight Hub", "Invalid server response (try " .. attempts .. ")", 2)
            task.wait(CONFIG.hopAttemptDelay)
            continue
        end

        local candidates = {}
        for _, s in ipairs(decoded.data) do
            if s and s.id and s.id ~= tostring(game.JobId) and (s.playing < (s.maxPlayers or 0)) then
                table.insert(candidates, s)
            end
        end

        if #candidates == 0 then
            safeNotify("Flashlight Hub", "No available servers (attempt " .. attempts .. ")", 2)
            task.wait(CONFIG.hopAttemptDelay)
            continue
        end

        -- Shuffle
        math.randomseed(tick() + attempts + os.time())
        for i = #candidates, 2, -1 do
            local j = math.random(1, i)
            candidates[i], candidates[j] = candidates[j], candidates[i]
        end

        for _, server in ipairs(candidates) do
            pcall(function() safeNotify("Flashlight Hub", "Teleporting to " .. server.id, 2) end)
            local ok2, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
            end)
            if ok2 then
                setStatus("Teleporting...")
                return
            else
                safeNotify("Flashlight Hub", "Teleport failed: " .. tostring(err) .. " — retrying", 2)
                task.wait(CONFIG.hopAttemptDelay)
            end
        end
    end

    setStatus("Idle")
    safeNotify("Flashlight Hub", "All hop attempts failed (" .. CONFIG.maxHopAttempts .. ")", 4)
end

-- ========== DUPLICATE DETECTION (hop protection) ==========
if CONFIG.hopProtection then
    task.spawn(function()
        while task.wait(1.2) do
            local myName = LocalPlayer.DisplayName
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    local ok, dname = pcall(function() return obj.Humanoid.DisplayName end)
                    if ok and dname == myName and obj ~= LocalPlayer.Character then
                        safeNotify("Flashlight Hub", "Duplicate detected — hopping", 2)
                        hopServer()
                        break
                    end
                end
            end
        end
    end)
end

-- ========== FARM LOGIC ==========
local farming = false
local DiamondCounterLabel = findDiamondCounterLabel()

local function firePrompt(prompt)
    pcall(function()
        if typeof(prompt) == "Instance" then
            -- Try built-in fire proximity helper
            if fireproximityprompt then
                pcall(fireproximityprompt, prompt)
            elseif prompt:FindFirstChildWhichIsA then
                pcall(function() prompt:InputHoldBegin() end)
            end
        end
    end)
end

local function collectDiamonds()
    local collected = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Diamond" then
            pcall(function()
                if RequestTakeDiamondsRemote and RequestTakeDiamondsRemote.FireServer then
                    RequestTakeDiamondsRemote:FireServer(v)
                else
                    -- fallback: try moving to diamond and touching
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        if v.PrimaryPart then
                            hrp.CFrame = v:GetPivot()
                        end
                    end
                end
            end)
            collected = collected + 1
            task.wait(0.03)
        end
    end
    return collected
end

local function farmCycle()
    setStatus("Farming")
    while farming do
        -- ensure character and HRP
        repeat task.wait(0.12) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then break end

        -- find chest
        local chest
        pcall(function()
            if workspace:FindFirstChild("Items") then
                chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest") or workspace:FindFirstChild("Chest")
            else
                chest = workspace:FindFirstChild("Stronghold Diamond Chest") or workspace:FindFirstChild("Chest")
            end
        end)

        if not chest then
            safeNotify("Flashlight Hub", "Chest not found — hopping", 2)
            setStatus("Hopping (no chest)")
            hopServer()
            return
        end

        -- move to chest
        pcall(function()
            if chest:GetPivot then
                local pivot = chest:GetPivot()
                hrp:PivotTo(CFrame.new(pivot.Position + Vector3.new(0, 5, 0)))
            else
                hrp.CFrame = chest.PrimaryPart and chest.PrimaryPart.CFrame or hrp.CFrame
            end
        end)

        -- find proximity prompt
        local proxPrompt
        local startTick = tick()
        repeat
            proxPrompt = nil
            if chest then
                local mainPart = chest:FindFirstChild("Main") or chest:FindFirstChild("PromptPart") or chest:FindFirstChildWhichIsA and chest:FindFirstChildWhichIsA("BasePart")
                if mainPart then
                    for _, att in ipairs(mainPart:GetDescendants()) do
                        if att:IsA("ProximityPrompt") then
                            proxPrompt = att
                            break
                        end
                    end
                end
            end
            task.wait(0.12)
        until proxPrompt or (tick() - startTick) > 12 or not farming

        if not proxPrompt then
            safeNotify("Flashlight Hub", "No prompt found — hopping", 2)
            setStatus("Hopping (no prompt)")
            hopServer()
            return
        end

        -- fire prompt repeatedly
        local t0 = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - t0) < 10 and farming do
            firePrompt(proxPrompt)
            task.wait(0.18)
        end

        -- wait for diamonds spawn (simple loop)
        local spawned = false
        local t1 = tick()
        repeat
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("Model") and d.Name == "Diamond" then
                    spawned = true
                    break
                end
            end
            task.wait(0.15)
        until spawned or (tick() - t1) > 8 or not farming

        if not farming then break end
        if not spawned then
            safeNotify("Flashlight Hub", "No diamonds spawned — hopping", 2)
            hopServer()
            return
        end

        -- collect
        local c = collectDiamonds()
        safeNotify("Flashlight Hub", "Collected diamonds: " .. tostring(c), 2)
        setStatus("Collected " .. tostring(c) .. " diamonds — hopping")
        task.wait(0.8)
        hopServer()
        task.wait(0.5)
    end
    setStatus("Idle")
end

-- ========== UI UPDATES (live) ==========
task.spawn(function()
    while task.wait(0.35) do
        -- diamonds
        pcall(function()
            if DiamondCounterLabel and DiamondCounterLabel.Text then
                diamondsLabel.Text = DiamondCounterLabel.Text
            end
        end)
        -- fallback: show something else
        if not pcall(function() return DiamondCounterLabel and DiamondCounterLabel.Text end) then
            -- try reading from workspace (if there is a leaderstats or value)
            local fallback = "0"
            pcall(function()
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                if ls and ls:FindFirstChild("Diamonds") then fallback = tostring(ls.Diamonds.Value) end
            end)
            diamondsLabel.Text = fallback
        end

        -- day & time (best-effort detection)
        pcall(function()
            local dayVal = "--"
            local timeVal = "--:--"
            -- common server values
            if workspace:FindFirstChild("Day") and workspace.Day:IsA("IntValue") then
                dayVal = tostring(workspace.Day.Value)
            elseif workspace:FindFirstChild("GameStats") and workspace.GameStats:FindFirstChild("Day") then
                dayVal = tostring(workspace.GameStats.Day.Value)
            else
                -- try to find a TextLabel named Day in PlayerGui interface
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    local interface = pg:FindFirstChild("Interface") or pg:FindFirstChild("HUD")
                    if interface and interface:FindFirstChild("DayLabel") then
                        dayVal = tostring(interface.DayLabel.Text)
                    end
                end
            end

            if workspace:FindFirstChild("Time") and workspace.Time:IsA("StringValue") then
                timeVal = workspace.Time.Value
            else
                -- find label
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    local iface = pg:FindFirstChild("Interface") or pg:FindFirstChild("HUD")
                    if iface and iface:FindFirstChild("TimeLabel") then
                        timeVal = tostring(iface.TimeLabel.Text)
                    end
                end
            end

            dayLabel.Text = dayVal or "--"
            timeLabel.Text = timeVal or "--:--"
        end)

    end
end)

-- ========== UI INTERACTIONS: manual Hop & Start/Stop ==========
-- Create floating buttons in the UI for Hop and Start/Stop inside the ScreenGui (simple small controls)
local function attachControlButtons()
    local screenGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("FlashlightHubUI")
    if not screenGui then return end
    local existing = screenGui:FindFirstChild("ControlPanel")
    if existing then existing:Destroy() end

    local cp = Instance.new("Frame", screenGui)
    cp.Name = "ControlPanel"
    cp.AnchorPoint = Vector2.new(0, 1)
    cp.Position = UDim2.new(0, 12, 1, -12)
    cp.Size = UDim2.new(0, 220, 0, 64)
    cp.BackgroundTransparency = 1

    local startBtn = Instance.new("TextButton", cp)
    startBtn.Name = "StartBtn"
    startBtn.Size = UDim2.new(0, 120, 0, 46)
    startBtn.Position = UDim2.new(0, 0, 0, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(16, 140, 16)
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 16
    startBtn.TextColor3 = Color3.new(1,1,1)
    startBtn.Text = "Start Farm"
    local scorner = Instance.new("UICorner", startBtn); scorner.CornerRadius = UDim.new(0,10)

    local hopBtn = Instance.new("TextButton", cp)
    hopBtn.Name = "HopBtn"
    hopBtn.Size = UDim2.new(0, 90, 0, 46)
    hopBtn.Position = UDim2.new(0, 126, 0, 0)
    hopBtn.BackgroundColor3 = Color3.fromRGB(28, 120, 200)
    hopBtn.Font = Enum.Font.GothamBold
    hopBtn.TextSize = 16
    hopBtn.TextColor3 = Color3.new(1,1,1)
    hopBtn.Text = "Hop"
    Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0,10)

    startBtn.Activated:Connect(function()
        farming = not farming
        if farming then
            startBtn.Text = "Stop Farm"
            startBtn.BackgroundColor3 = Color3.fromRGB(140,28,28)
            setStatus("Farming (manual)")
            task.spawn(farmCycle)
        else
            startBtn.Text = "Start Farm"
            startBtn.BackgroundColor3 = Color3.fromRGB(16,140,16)
            setStatus("Idle")
        end
    end)

    hopBtn.Activated:Connect(function()
        setStatus("Manual hop")
        task.spawn(hopServer)
    end)
end

attachControlButtons()

-- ========== AUTO-START FARM IF CONFIGURED ==========
if CONFIG.autoStartFarm and game.PlaceId == CONFIG.farmPlace then
    farming = true
    task.spawn(farmCycle)
else
    farming = false
    setStatus("Idle")
end

safeNotify("Flashlight Hub", "Loaded — UI ready", 4)
