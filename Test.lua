-- ⚡ 99 Nights Diamond Farmer
-- Auto Teleport + Farming | No UI Nav | No Commands
-- Just works.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- 🔧 CONFIG
local FARM_PLACE_ID = 126509999114328 -- Farm server
local REMOTE_NAME = "RequestTakeDiamonds"

-- 🔁 Check if already running (avoid duplicates)
if CoreGui:FindFirstChild("gg") then
    return
end

-- 🌐 Remote & UI elements (will be set after teleport)
local Remote, DiamondCount

-- 🎨 UI Setup (Persists across teleports if executor supports it)
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "gg"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 200, 0, 90)
    Frame.Position = UDim2.new(0, 80, 0, 100)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true

    -- Corner
    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 8)

    -- Rainbow Border
    local UIStroke = Instance.new("UIStroke", Frame)
    UIStroke.Thickness = 1.5
    UIStroke.Color = Color3.fromRGB(255, 0, 0)

    -- Title
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Farm Diamond | Cáo Mod"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextStrokeTransparency = 0.6

    -- Diamond Counter
    local Counter = Instance.new("TextLabel", Frame)
    Counter.Size = UDim2.new(1, -20, 0, 35)
    Counter.Position = UDim2.new(0, 10, 0, 40)
    Counter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Counter.TextColor3 = Color3.fromRGB(255, 255, 255)
    Counter.Font = Enum.Font.GothamBold
    Counter.TextSize = 14
    Counter.BorderSizePixel = 0

    local CounterCorner = Instance.new("UICorner", Counter)
    CounterCorner.CornerRadius = UDim.new(0, 6)

    -- Rainbow animation
    task.spawn(function()
        while task.wait(0.05) do
            if not Frame.Parent then break end
            local hue = tick() % 5 / 5
            UIStroke.Color = Color3.fromHSV(hue, 1, 1)
        end
    end)

    return ScreenGui, Frame, Counter
end

-- 🌈 Rainbow Stroke (alternative)
local function rainbowStroke(stroke)
    task.spawn(function()
        while task.wait(0.05) do
            if not stroke.Parent then break end
            stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    end)
end

-- 🔁 Server Hop Function
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
                    while true do task.wait(1) end
                end
            end
        end
        task.wait(0.3)
    end
end

-- 🔒 Duplicate Character Detection
task.spawn(function()
    while task.wait(1) do
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                    StarterGui:SetCore("SendNotification", {
                        Title = "⚠️ Duplicate",
                        Text = "Duplicate character! Hopping...",
                        Duration = 3
                    })
                    hopServer()
                end
            end
        end
    end
end)

-- 🧠 MAIN FARMING LOGIC
local function startFarming()
    -- Wait for character
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hrp = LocalPlayer.Character.HumanoidRootPart

    -- Get remote and UI
    Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
    local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
    DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

    -- UI
    local _, _, Counter = createUI()

    -- Update counter
    task.spawn(function()
        while task.wait(0.2) do
            Counter.Text = "Diamonds: " .. tostring(DiamondCount.Text)
        end
    end)

    -- Main loop
    while true do
        -- Find chest
        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            StarterGui:SetCore("SendNotification", {
                Title = "🔍 Not Found",
                Text = "Chest not found! Hopping...",
                Duration = 3
            })
            hopServer()
            return
        end

        -- Teleport to chest
        hrp:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))

        -- Wait for prompt
        local proxPrompt = nil
        repeat
            task.wait(0.1)
            local main = chest:FindFirstChild("Main")
            local attachment = main and main:FindFirstChild("ProximityAttachment")
            proxPrompt = attachment and attachment:FindFirstChild("ProximityInteraction")
        until proxPrompt

        -- Activate prompt
        local startTime = tick()
        while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 do
            pcall(fireproximityprompt, proxPrompt)
            task.wait(0.2)
        end

        if proxPrompt and proxPrompt.Parent then
            StarterGui:SetCore("SendNotification", {
                Title = "⏰ Timeout",
                Text = "Prompt failed! Hopping...",
                Duration = 3
            })
            hopServer()
            return
        end

        -- Wait for diamonds to spawn
        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true)

        -- Collect all diamonds
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Diamond" and obj.Parent then
                pcall(Remote.FireServer, Remote, obj)
            end
        end

        StarterGui:SetCore("SendNotification", {
            Title = "💎 Collected",
            Text = "All diamonds taken! Hopping...",
            Duration = 3
        })
        task.wait(1)
        hopServer()
    end
end

-- 🚀 MAIN: Check Place ID and Start
if game.PlaceId == FARM_PLACE_ID then
    -- Already in farm
    startFarming()
else
    -- Teleport to farm
    pcall(function()
        TeleportService:TeleportToPlaceInstance(FARM_PLACE_ID)
    end)
    -- If teleport fails, try public servers
    hopServer()
end
