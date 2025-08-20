local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

-- Clean up old UI
pcall(function()
    game.CoreGui:FindFirstChild("gg") and game.CoreGui:FindFirstChild("gg"):Destroy()
end)

------------------------------------------------------------------
-- Rainbow Stroke Fix
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
-- Server Hop Function
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
                    return -- Exit after teleport
                end
            end
        end
        task.wait(0.3)
    end
end

------------------------------------------------------------------
-- Duplicate Character Detection
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                    StarterGui:SetCore("SendNotification", {
                        Title = "⚠️ Duplicate",
                        Text = "Duplicate detected! Hopping...",
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
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "gg"

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 200, 0, 90)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 1.5
rainbowStroke(stroke)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Farm Diamond | Cáo Mod"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextStrokeTransparency = 0.6

local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1, -20, 0, 35)
counter.Position = UDim2.new(0, 10, 0, 40)
counter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
counter.TextColor3 = Color3.new(1, 1, 1)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
counter.BorderSizePixel = 0
Instance.new("UICorner", counter).CornerRadius = UDim.new(0, 6)

-- Update counter
task.spawn(function()
    while task.wait(0.2) do
        counter.Text = "Diamonds: " .. tostring(DiamondCount.Text)
    end
end)

------------------------------------------------------------------
-- Main Farming Logic
------------------------------------------------------------------
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
if not chest then
    StarterGui:SetCore("SendNotification", {
        Title = "❌ Error",
        Text = "Chest not found! Hopping...",
        Duration = 3
    })
    hopServer()
    return
end

-- Teleport to chest
LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0, 5, 0)))

-- Wait for prompt
repeat
    task.wait(0.1)
    local mainPart = chest:FindFirstChild("Main")
    local attachment = mainPart and mainPart:FindFirstChild("ProximityAttachment")
    local proxPrompt = attachment and attachment:FindFirstChild("ProximityInteraction")
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

-- Wait for diamonds
repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true)

-- Collect all
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj.Name == "Diamond" then
        Remote:FireServer(obj)
    end
end

StarterGui:SetCore("SendNotification", {
    Title = "💎 Done",
    Text = "All diamonds taken! Hopping...",
    Duration = 3
})
task.wait(1)
hopServer()
