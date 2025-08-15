--[[
    🔦 FLASH LIGHT HUB
    Powered by STELLAR UI (x2zu)
    Based on INPROGRESS.txt & message.txt
    Auto Farm • Auto Buy • Quest Tools • Mobile Support
--]]

------------------------------------------------------------------
-- 1. LOAD STELLAR UI LIBRARY
------------------------------------------------------------------
local function loadStellar()
    local url = "https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua"
    local Success, Library = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)

    if not Success then
        warn("❌ Failed to load STELLAR UI:", Library)
        return nil
    end

    return Library
end

local Stellar = loadStellar()
if not Stellar then return end

-- Show loading animation
if Stellar:LoadAnimation() then
    Stellar:StartLoad()
    task.wait(0.5)
    Stellar:Loaded()
end

------------------------------------------------------------------
-- 2. CREATE WINDOW & TABS
------------------------------------------------------------------
local Window = Stellar:Window({
    SubTitle = "Flash Light Hub",
    Size = game:GetService("UserInputService").TouchEnabled
        and UDim2.new(0, 380, 0, 260)
        or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local AutoFarm = Window:Tab("Auto Farm", "rbxassetid://10709782497")
local AutoBuy = Window:Tab("Auto Buy", "rbxassetid://10723415335")
local Quests  = Window:Tab("Quests", "rbxassetid://10734950309")
local Misc    = Window:Tab("Misc", "rbxassetid://10747373176")

------------------------------------------------------------------
-- 3. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

------------------------------------------------------------------
-- 4. AUTO FARM TAB - TELEPORT LOOP
------------------------------------------------------------------
AutoFarm:Seperator("Auto Farm Path")

local isRunning = false
local spawnedPlatforms = {}

-- Final chest zone = auto-reward
local positions = {
    Vector3.new(-62, 67, 1363),
    Vector3.new(-65, 58, 2135),
    Vector3.new(-52, 73, 2903),
    Vector3.new(-58, 76, 3672),
    Vector3.new(-60, 80, 4445),
    Vector3.new(-55, 73, 5217),
    Vector3.new(-53, 64, 5984),
    Vector3.new(-63, 63, 6751),
    Vector3.new(-50, 28, 7527),
    Vector3.new(-104, 37, 8298),
    Vector3.new(-57, -358, 9491) -- Chest auto-claim here
}

local function placePlatform(pos)
    for _, p in ipairs(spawnedPlatforms) do
        if p and p.Position == Vector3.new(pos.X, pos.Y - 3, pos.Z) then
            return -- already exists
        end
    end

    local platform = Instance.new("Part")
    platform.Name = "TeleportPlatform"
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = Vector3.new(pos.X, pos.Y - 3, pos.Z)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright yellow")
    platform.Parent = Workspace

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.Adornee = platform
    surfaceGui.Parent = platform

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Auto Farm Path"
    textLabel.TextColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = surfaceGui

    table.insert(spawnedPlatforms, platform)
end

local function removePlatforms()
    for _, p in ipairs(spawnedPlatforms) do
        if p and p.Parent then p:Destroy() end
    end
    table.clear(spawnedPlatforms)
end

AutoFarm:Toggle("Auto Farm Loop", false, "Farms chest automatically, resets 1s after", function(v)
    isRunning = v

    if isRunning then
        task.spawn(function()
            while isRunning do
                for i, pos in ipairs(positions) do
                    if not isRunning then break end
                    placePlatform(pos)
                    hrp.CFrame = CFrame.new(pos)
                    task.wait(0.3)
                end

                -- ✅ Chest auto-claimed
                Stellar:Notify("Chest claimed! Resetting in 1s...", 2)
                task.wait(1) -- Wait 1 second after auto-claim
                removePlatforms()
                task.wait(9) -- 10s total loop
            end
        end)
    else
        removePlatforms()
    end
end)

------------------------------------------------------------------
-- 5. AUTO BUY TAB
------------------------------------------------------------------
AutoBuy:Seperator("Auto Buy Items")

AutoBuy:Toggle("Auto Buy Plastic Blocks", false, "Buys 1 block every 3 seconds", function(v)
    while v and task.wait(3) do
        pcall(function()
            Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer("PlasticBlock", 1)
        end)
    end
end)

AutoBuy:Toggle("Auto Buy Common Chest", false, "Farms common chests", function(v)
    while v and task.wait(3) do
        pcall(function()
            Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer("Common Chest", 1)
        end)
    end
end)

------------------------------------------------------------------
-- 6. QUESTS TAB
------------------------------------------------------------------
Quests:Seperator("Quest Automation")

-- Team → Cloud & TouchInterest
local brickColorToCloud = {
    ["Really red"] = function() return Workspace["Really redZone"].Quest.Ramp:GetChildren()[20] end,
    ["Magenta"] = function() return Workspace["MagentaZone"].Quest.Ramp:GetChildren()[20] end,
    ["Camo"] = function() return Workspace["CamoZone"].Quest.Ramp:GetChildren()[20] end,
    ["Really blue"] = function() return Workspace["Really blueZone"].Quest.Ramp:GetChildren()[20] end,
    ["White"] = function() return Workspace["WhiteZone"].Quest.Ramp:GetChildren()[20] end,
    ["Black"] = function() return Workspace["BlackZone"].Quest.Ramp:GetChildren()[20] end,
    ["New Yeller"] = function() return Workspace["New YellerZone"].Quest.Ramp:GetChildren()[20] end
}

local brickColorToTouchInterest = {
    ["Really red"] = function() return brickColorToCloud["Really red"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["Really red"]():FindFirstChild("TouchInterest") end,
    ["Magenta"] = function() return brickColorToCloud["Magenta"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["Magenta"]():FindFirstChild("TouchInterest") end,
    ["Camo"] = function() return brickColorToCloud["Camo"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["Camo"]():FindFirstChild("TouchInterest") end,
    ["Really blue"] = function() return brickColorToCloud["Really blue"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["Really blue"]():FindFirstChild("TouchInterest") end,
    ["White"] = function() return brickColorToCloud["White"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["White"]():FindFirstChild("TouchInterest") end,
    ["Black"] = function() return brickColorToCloud["Black"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["Black"]():FindFirstChild("TouchInterest") end,
    ["New Yeller"] = function() return brickColorToCloud["New Yeller"]():FindFirstChildOfClass("TouchTransmitter") or brickColorToCloud["New Yeller"]():FindFirstChild("TouchInterest") end
}

local function startQuest()
    pcall(function()
        Workspace:WaitForChild("QuestMakerEvent"):FireServer(3)
    end)
end

local function simulateTouch()
    local teamColor = tostring(lp.Team.TeamColor)
    local touchInterestGetter = brickColorToTouchInterest[teamColor]
    if not touchInterestGetter then return end

    local touchInterest = touchInterestGetter()
    if not touchInterest then return end

    local part = touchInterest:IsA("TouchTransmitter") and touchInterest.Parent or touchInterest
    firetouchinterest(hrp, part, 0)
    task.wait(0.1)
    firetouchinterest(hrp, part, 1)
end

Quests:Button("Start Quest + Touch", function()
    startQuest()
    Stellar:Notify("Quest started!", 2)
    task.delay(0.5, simulateTouch)
end)

-- Click Butter
local function getButterClickDetector()
    local zoneMap = {
        ["New Yeller"] = "New YellerZone",
        ["Really red"] = "Really redZone",
        ["Magenta"] = "MagentaZone",
        ["Camo"] = "CamoZone",
        ["Really blue"] = "Really blueZone",
        ["White"] = "WhiteZone",
        ["Black"] = "BlackZone"
    }
    local zoneName = zoneMap[tostring(lp.Team.TeamColor)]
    if not zoneName then return end

    local zone = Workspace:FindFirstChild(zoneName)
    if not zone then return end

    local quest = zone:FindFirstChild("Quest")
    if not quest then return end

    local butter = quest:FindFirstChild("Butter")
    if not butter then return end

    local ppart = butter:FindFirstChild("PPart")
    if not ppart then return end

    return ppart:FindFirstChildOfClass("ClickDetector")
end

Quests:Button("Click Butter", function()
    local cd = getButterClickDetector()
    if cd then
        fireclickdetector(cd)
        Stellar:Notify("Butter clicked!", 2)
    else
        Stellar:Notify("Butter not found!", 3)
    end
end)

------------------------------------------------------------------
-- 7. MISC TAB
------------------------------------------------------------------
Misc:Seperator("Tools & Utilities")

Misc:Button("Unlock Gamepasses", function()
    pcall(function()
        Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer("GamepassItem", 1)
        Stellar:Notify("Gamepasses unlocked!", 3)
    end)
end)

Misc:Button("Free 200 Slots", function()
    pcall(function()
        Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer("200MoreSlots", 1)
        Stellar:Notify("200 slots unlocked!", 3)
    end)
end)

Misc:Button("Open Infinite Yield", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Stellar:Notify("Infinite Yield loaded!", 3)
    end)
end)

Misc:Button("Unload Hub", function()
    local stellar = game.CoreGui:FindFirstChild("STELLAR")
    if stellar then stellar:Destroy() end
    local mobile = game.CoreGui:FindFirstChild("FlashlightMobileToggle")
    if mobile then mobile:Destroy() end
    Stellar:Notify("Hub unloaded.", 3)
end)

------------------------------------------------------------------
-- 8. MOBILE TOGGLE BUTTON
------------------------------------------------------------------
local mb = Instance.new("ScreenGui")
mb.Name = "FlashlightMobileToggle"
mb.ResetOnSpawn = false
mb.Parent = game:GetService("CoreGui")

local btn = Instance.new("ImageButton")
btn.Size = UDim2.new(0, 55, 0, 55)
btn.AnchorPoint = Vector2.new(0.5, 0.5)
btn.Position = UDim2.new(0.15, 0, 0.75, 0)
btn.BackgroundTransparency = 1
btn.Image = "rbxassetid://3926307971"
btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
btn.ImageTransparency = 0.2
btn.Parent = mb

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.new(0.5, 0, 0.5, 0)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10734950020"
icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
icon.Parent = btn

-- Drag + Toggle
local dragging = false
local startPos, startMouse
local UIS = game:GetService("UserInputService")

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = btn.Position
        startMouse = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        local hub = game.CoreGui:FindFirstChild("STELLAR")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - startMouse
        btn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and not dragging then
        local hub = game.CoreGui:FindFirstChild("STELLAR")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

print("✨ Flash Light Hub Loaded Successfully!")
print("💡 Press Insert or tap mobile button to toggle.") 
