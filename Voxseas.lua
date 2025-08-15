--[[
    🔦 FLASH LIGHT HUB – Vox Seas Edition
    Powered by STELLAR UI (x2zu)
    Auto Farm • Bring Mobs • ESP • Teleport • Speed
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
    SubTitle = "Vox Seas Edition",
    Size = game:GetService("UserInputService").TouchEnabled
        and UDim2.new(0, 380, 0, 260)
        or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local Auto = Window:Tab("Auto Farm", "rbxassetid://10723415335")
local Teleport = Window:Tab("Teleport", "rbxassetid://10709782497")
local Visuals = Window:Tab("Visuals", "rbxassetid://10723407389")
local Misc = Window:Tab("Misc", "rbxassetid://10734950309")

------------------------------------------------------------------
-- 3. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local Humanoid = char:WaitForChild("Humanoid")

------------------------------------------------------------------
-- 4. SETTINGS
------------------------------------------------------------------
local Settings = {
    FarmDistance = 5,
    AutoFarm = false,
    BringMobs = false,
    ESP = false,
    Speed = false,
    SpeedValue = 30
}

------------------------------------------------------------------
-- 5. AUTO FARM TAB
------------------------------------------------------------------
Auto:Seperator("Auto Farm")

Auto:Toggle("Auto Farm Mobs", false, "Automatically attacks nearby mobs", function(v)
    Settings.AutoFarm = v
    while Settings.AutoFarm and task.wait(0.5) do
        for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") and (mob.HumanoidRootPart.Position - hrp.Position).Magnitude <= 20 then
                fireproximityprompt(mob:FindFirstChild("ClickDetector"))
            end
        end
    end
end)

Auto:Toggle("Bring Mobs to Player", false, "Pulls mobs toward you", function(v)
    Settings.BringMobs = v
    while Settings.BringMobs and task.wait(0.1) do
        for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") then
                local root = mob.HumanoidRootPart
                root.Velocity = Vector3.zero
                root.CFrame = hrp.CFrame + Vector3.new(0, 0, Settings.FarmDistance)
            end
        end
    end
end)

Auto:Slider("Farm Distance", 1, 10, 5, function(v)
    Settings.FarmDistance = v
end)

------------------------------------------------------------------
-- 6. TELEPORT TAB
------------------------------------------------------------------
Teleport:Seperator("Teleport to Mobs")

for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
    if mob.Name ~= "" then
        Teleport:Button("TP to " .. mob.Name, function()
            if mob:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = mob.HumanoidRootPart.CFrame
                Stellar:Notify("Teleported to " .. mob.Name, 2)
            else
                Stellar:Notify("Mob not found!", 3)
            end
        end)
    end
end

-- Refresh Button
Teleport:Button("Refresh Mobs", function()
    -- Clear old buttons and re-add
    for _, obj in ipairs(Teleport:GetTabContent():GetChildren()) do
        if obj:IsA("TextButton") and obj.Text:find("TP to ") then
            obj:Destroy()
        end
    end

    task.delay(0.5, function()
        for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
            if mob.Name ~= "" then
                Teleport:Button("TP to " .. mob.Name, function()
                    if mob:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = mob.HumanoidRootPart.CFrame
                        Stellar:Notify("Teleported to " .. mob.Name, 2)
                    else
                        Stellar:Notify("Mob not found!", 3)
                    end
                end)
            end
        end
    end)

    Stellar:Notify("Mobs refreshed!", 2)
end)

------------------------------------------------------------------
-- 7. VISUALS TAB - ESP
------------------------------------------------------------------
Visuals:Seperator("ESP")

-- ESP Template
local EspTemplate = Instance.new("BoxHandleAdornment")
EspTemplate.Size = Vector3.new(1, 2, 1)
EspTemplate.AlwaysOnTop = true
EspTemplate.ZIndex = 10
EspTemplate.Transparency = 0

local BillboardGui = Instance.new("BillboardGui")
BillboardGui.Size = UDim2.new(0, 100, 0, 100)
BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
BillboardGui.AlwaysOnTop = true

local TextLabel = Instance.new("TextLabel")
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 0, 0, -20)
TextLabel.Size = UDim2.new(1, 0, 0, 20)
TextLabel.Font = Enum.Font.Code
TextLabel.TextSize = 14
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Text = ""
TextLabel.Parent = BillboardGui

-- ESP Objects Storage
local ESPs = {}

local function createESP(part, name)
    if not part or not part.Parent then return end

    local esp = EspTemplate:Clone()
    esp.Adornee = part
    esp.Parent = part

    local gui = BillboardGui:Clone()
    gui.Enabled = false
    gui.Parent = esp

    local text = gui:FindFirstChild("TextLabel")
    if text then text.Text = name end

    table.insert(ESPs, {
        Part = part,
        ESP = esp,
        Gui = gui
    })

    return esp
end

Visuals:Toggle("Enemy ESP", false, "Shows box & name above mobs", function(v)
    Settings.ESP = v

    if not v then
        for _, data in ipairs(ESPs) do
            if data.ESP then data.ESP:Destroy() end
        end
        table.clear(ESPs)
        return
    end

    -- Create ESPs
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("HumanoidRootPart") then
            createESP(mob.HumanoidRootPart, mob.Name)
        end
    end

    -- Track new mobs
    Workspace.Enemies.ChildAdded:Connect(function(mob)
        task.spawn(function()
            task.wait(0.5)
            if mob:FindFirstChild("HumanoidRootPart") then
                createESP(mob.HumanoidRootPart, mob.Name)
            end
        end)
    end)
end)

Visuals:Toggle("Speed", false, "Enables speed boost", function(v)
    Settings.Speed = v
    if v then
        Humanoid.WalkSpeed = Settings.SpeedValue
    else
        Humanoid.WalkSpeed = 16
    end
end)

Visuals:Slider("Speed Value", 16, 100, 30, function(v)
    Settings.SpeedValue = v
    if Settings.Speed then
        Humanoid.WalkSpeed = v
    end
end)

------------------------------------------------------------------
-- 8. MISC TAB
------------------------------------------------------------------
Misc:Seperator("Info & Tools")

Misc:Label("Flash Light Hub - Vox Seas")

Misc:Button("Copy Discord", function()
    setclipboard("https://discord.gg/7aR7kNVt4g")
    Stellar:Notify("Discord copied!", 3)
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
-- 9. MOBILE TOGGLE BUTTON
------------------------------------------------------------------
local mb = Instance.new("ScreenGui")
mb.Name = "FlashlightMobileToggle"
mb.ResetOnSpawn = false
mb.Parent = game.CoreGui

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

-- Drag & Toggle
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

print("✨ Flash Light Hub Loaded for Vox Seas!")
print("💡 Press Insert or tap mobile button to toggle.")
