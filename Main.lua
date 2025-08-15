--[[
    🔦 FLASH LIGHT HUB
    Game-Specific Tools from INPROGRESS.txt
    Powered by STELLAR UI (x2zu)
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
    Size     = game:GetService("UserInputService").TouchEnabled
               and UDim2.new(0, 380, 0, 260)
               or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local Auto    = Window:Tab("Auto",    "rbxassetid://10723415335")
local Teleport = Window:Tab("Teleport", "rbxassetid://10709782497")
local Quests  = Window:Tab("Quests",  "rbxassetid://10734950309")
local Misc    = Window:Tab("Misc",    "rbxassetid://10734950309")

------------------------------------------------------------------
-- 3. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

------------------------------------------------------------------
-- 4. AUTO TAB - AUTO BUY BLOCKS
------------------------------------------------------------------
Auto:Seperator("Auto Buy Blocks")

local autoBuyEnabled = false
Auto:Toggle("Auto Buy Plastic Blocks", false, "Automatically buys blocks every few seconds", function(v)
    autoBuyEnabled = v

    while autoBuyEnabled and task.wait(3) do
        local args = {"PlasticBlock", 1}
        pcall(function()
            Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer(unpack(args))
        end)
    end
end)

Auto:Seperator("Auto Farm")

local autoFarmEnabled = false
Auto:Toggle("Auto Farm Chests", false, "Buys and farms common chests", function(v)
    autoFarmEnabled = v

    while autoFarmEnabled and task.wait(3) do
        local args = {"Common Chest", 1}
        pcall(function()
            Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer(unpack(args))
        end)
    end
end)

------------------------------------------------------------------
-- 5. TELEPORT TAB - PLATFORM TELEPORTER
------------------------------------------------------------------
Teleport:Seperator("Platform Teleporter")

local isRunning = false
local spawnedPlatforms = {}
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
    Vector3.new(-57, -358, 9491)
}

local function removePlatforms()
    for _, p in ipairs(spawnedPlatforms) do
        if p and p.Parent then p:Destroy() end
    end
    table.clear(spawnedPlatforms)

    -- Clean up any leftover in workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Part") and obj.Name == "TeleportPlatform" then
            obj:Destroy()
        end
    end
end

local function placePlatform(pos)
    for _, part in ipairs(spawnedPlatforms) do
        if part and part.Parent and (part.Position - Vector3.new(pos.X, pos.Y - 3, pos.Z)).Magnitude < 0.1 then
            return -- already exists
        end
    end

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = Vector3.new(pos.X, pos.Y - 3, pos.Z)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright yellow")
    platform.Name = "TeleportPlatform"
    platform.Parent = Workspace

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.Adornee = platform
    surfaceGui.Parent = platform

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Teleport Platform"
    textLabel.TextColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = surfaceGui

    table.insert(spawnedPlatforms, platform)
end

Teleport:Toggle("Auto Teleport Loop", false, "Spawns platforms and teleports through levels", function(v)
    isRunning = v

    if isRunning then
        while isRunning and task.wait(1) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, pos in ipairs(positions) do
                if not isRunning then break end
                placePlatform(pos)
                hrp.CFrame = CFrame.new(pos)
                task.wait(2)
            end
            task.wait(16)
        end
    end

    removePlatforms()
end)

------------------------------------------------------------------
-- 6. QUESTS TAB - AUTO QUEST & TOUCH
------------------------------------------------------------------
Quests:Seperator("Auto Quest System")

-- Map team colors to cloud paths
local brickColorToCloud = {
    ["Really red"] = function() return Workspace["Really redZone"].Quest.Ramp:GetChildren()[20] end,
    ["Magenta"] = function() return Workspace["MagentaZone"].Quest.Ramp:GetChildren()[20] end,
    ["Camo"] = function() return Workspace["CamoZone"].Quest.Ramp:GetChildren()[20] end,
    ["Really blue"] = function() return Workspace["Really blueZone"].Quest.Ramp:GetChildren()[20] end,
    ["White"] = function() return Workspace["WhiteZone"].Quest.Ramp:GetChildren()[20] end,
    ["Black"] = function() return Workspace["BlackZone"].Quest.Ramp:GetChildren()[20] end,
    ["New Yeller"] = function() return Workspace["New YellerZone"].Quest.Ramp:GetChildren()[20] end
}

-- Map team colors to touch interests
local brickColorToTouchInterest = {
    ["Really red"] = function() return Workspace["Really redZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["Really redZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["Magenta"] = function() return Workspace["MagentaZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["MagentaZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["Camo"] = function() return Workspace["CamoZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["CamoZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["Really blue"] = function() return Workspace["Really blueZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["Really blueZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["White"] = function() return Workspace["WhiteZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["WhiteZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["Black"] = function() return Workspace["BlackZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["BlackZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end,
    ["New Yeller"] = function() return Workspace["New YellerZone"].Quest.Ramp:GetChildren()[20]:FindFirstChildOfClass("TouchTransmitter") or Workspace["New YellerZone"].Quest.Ramp:GetChildren()[20]:FindFirstChild("TouchInterest") end
}

local function startQuest()
    local args = { 3 } -- Quest ID
    pcall(function()
        Workspace:WaitForChild("QuestMakerEvent"):FireServer(unpack(args))
    end)
end

local function simulateTouch()
    local brickColorName = tostring(lp.Team.TeamColor)
    local touchInterestGetter = brickColorToTouchInterest[brickColorName]
    if not touchInterestGetter then warn("No TouchInterest for", brickColorName) return end

    local touchInterest = touchInterestGetter()
    if not touchInterest then warn("TouchInterest not found") return end

    local part = touchInterest:IsA("TouchTransmitter") and touchInterest.Parent or touchInterest
    firetouchinterest(char.HumanoidRootPart, part, 0)
    task.wait(0.1)
    firetouchinterest(char.HumanoidRootPart, part, 1)
    print("✅ Touched for team:", brickColorName)
end

Quests:Button("Start Quest + Touch", function()
    startQuest()
    Stellar:Notify("Quest started!", 2)
    task.delay(0.5, simulateTouch)
end)

-- Butter Click Detector
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
Misc:Seperator("Tools")

Misc:Button("Unlock Gamepasses", function()
    -- Simulate buying a gamepass
    pcall(function()
        Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer("GamepassItem", 1)
        Stellar:Notify("Gamepasses unlocked!", 3)
    end)
end)

Misc:Button("Open Infinite Yield", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Stellar:Notify("Infinite Yield loaded!", 3)
    end)
end)

Misc:Button("Unload Hub", function()
    local stellarGui = game.CoreGui:FindFirstChild("STELLAR")
    if stellarGui then stellarGui:Destroy() end
    local mobileBtn = game.CoreGui:FindFirstChild("FlashlightMobileToggle")
    if mobileBtn then mobileBtn:Destroy() end
    print("✅ Flash Light Hub unloaded.")
end)

------------------------------------------------------------------
-- 8. MOBILE TOGGLE BUTTON
------------------------------------------------------------------
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "FlashlightMobileToggle"
MobileGui.ResetOnSpawn = false
MobileGui.Parent = game.CoreGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.15, 0, 0.75, 0)
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://3926307971"
ToggleBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.ImageTransparency = 0.2
ToggleBtn.Parent = MobileGui

local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.new(0, 30, 0, 30)
Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
Icon.AnchorPoint = Vector2.new(0.5, 0.5)
Icon.BackgroundTransparency = 1
Icon.Image = "rbxassetid://10734950020"
Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
Icon.Parent = ToggleBtn

-- Drag & Toggle Logic
local dragging = false
local startPos, startMouse

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = ToggleBtn.Position
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
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

print("✨ Flash Light Hub Loaded! Use Insert key or mobile button to toggle.")
