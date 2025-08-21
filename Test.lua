local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remote = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

-- 🔒 ONLY RUN IN FARM SERVER
if game.PlaceId ~= 126509999114328 then
    return
end

-- 🌈 Rainbow Stroke
local function rainbowStroke(stroke)
    task.spawn(function()
        while task.wait() do
            for hue = 0, 1, 0.01 do
                stroke.Color = Color3.fromHSV(hue, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

-- 🔁 Server Hop
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

-- 🚫 Duplicate Character Detection
task.spawn(function()
    while task.wait(1) do
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char:FindFirstChild("Humanoid").DisplayName == LocalPlayer.DisplayName then
                    hopServer()
                end
            end
        end
    end
end)

-- 🎨 Modern UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DiamondFarmUI"

-- Toggle Button
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 120, 0, 35)
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.Text = "⚡ Toggle UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.AutoButtonColor = true
local tbCorner = Instance.new("UICorner", ToggleButton)
tbCorner.CornerRadius = UDim.new(0, 8)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Thickness = 1.5
rainbowStroke(tbStroke)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 140)
MainFrame.Position = UDim2.new(0, 20, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
local mfCorner = Instance.new("UICorner", MainFrame)
mfCorner.CornerRadius = UDim.new(0, 12)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Thickness = 2
rainbowStroke(mfStroke)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "💎 Diamond Farm Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Diamond Counter
local DiamondLabel = Instance.new("TextLabel", MainFrame)
DiamondLabel.Size = UDim2.new(1, -20, 0, 35)
DiamondLabel.Position = UDim2.new(0, 10, 0, 50)
DiamondLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DiamondLabel.TextColor3 = Color3.new(1, 1, 1)
DiamondLabel.Font = Enum.Font.GothamBold
DiamondLabel.TextSize = 14
DiamondLabel.BorderSizePixel = 0
local dlCorner = Instance.new("UICorner", DiamondLabel)
dlCorner.CornerRadius = UDim.new(0, 8)

-- Status Label
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 95)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.Text = "⏳ Waiting..."

-- Toggle Logic
local uiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- 💎 Update Counter
task.spawn(function()
    while task.wait(0.5) do
        DiamondLabel.Text = "Diamonds: " .. DiamondCount.Text
    end
end)

-- ⚔ Farming Logic (kept same as your original)
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        StatusLabel.Text = "❌ Chest not found..."
        hopServer()
        return
    end

    LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position))

    local proxPrompt
    repeat
        task.wait(0.1)
        local prox = chest:FindFirstChild("Main")
        if prox and prox:FindFirstChild("ProximityAttachment") then
            proxPrompt = prox.ProximityAttachment:FindFirstChild("ProximityInteraction")
        end
    until proxPrompt

    local startTime = tick()
    while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 do
        pcall(function()
            fireproximityprompt(proxPrompt)
        end)
        task.wait(0.2)
    end

    if proxPrompt and proxPrompt.Parent then
        StatusLabel.Text = "🚪 Stronghold starting..."
        hopServer()
        return
    end

    repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true)

    for _, v in pairs(workspace:GetDescendants()) do
        if v.ClassName == "Model" and v.Name == "Diamond" then
            Remote:FireServer(v)
        end
    end

    StatusLabel.Text = "✅ Collected all diamonds!"
    task.wait(1)
    hopServer()
end)
