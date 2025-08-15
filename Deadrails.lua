--[[
    🔦 FLASH LIGHT HUB – Dead Rails Edition
    Powered by STELLAR UI (x2zu)
    Features: ESP, Auto Train, Auto Collect, NoClip, No Fog
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
    SubTitle = "Dead Rails Edition",
    Size = game:GetService("UserInputService").TouchEnabled
        and UDim2.new(0, 380, 0, 260)
        or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local ESP     = Window:Tab("ESP", "rbxassetid://10723407389")
local Auto    = Window:Tab("Auto Farm", "rbxassetid://10723415335")
local Train   = Window:Tab("Train", "rbxassetid://10709782497")
local Visuals = Window:Tab("Visuals", "rbxassetid://10734950309")
local Misc    = Window:Tab("Misc", "rbxassetid://10747373176")

------------------------------------------------------------------
-- 3. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

------------------------------------------------------------------
-- 4. ESP TAB
------------------------------------------------------------------
ESP:Seperator("ESP Settings")

-- ESP Variables
local ItemESPEnabled = false
local MobESPEnabled = false
local ItemESPDrawings = {}
local MobESPDrawings = {}

-- Custom Names
local CustomNames = {
    ["Model_Runner"] = "Zombie",
    ["Model_Boss1"] = "Boss",
    ["Model_Grunt"] = "Grunt",
    ["Crate"] = "Loot Crate",
    ["LootBox"] = "Treasure Box",
    ["Bond"] = "Bond"
}

-- Clear ESP
local function ClearItemESP()
    for _, v in pairs(ItemESPDrawings) do
        if v.Remove then v:Remove() end
    end
    table.clear(ItemESPDrawings)
end

local function ClearMobESP()
    for _, v in pairs(MobESPDrawings) do
        if v.Remove then v:Remove() end
    end
    table.clear(MobESPDrawings)
end

-- Create ESP
local function createESP(part, name, color)
    local tag = Drawing.new("Text")
    tag.Size = 16
    tag.Center = true
    tag.Outline = true
    tag.Color = color
    tag.Font = 2
    tag.Visible = false
    table.insert(ItemESPDrawings, tag)

    RunService.RenderStepped:Connect(function()
        if not part or not part.Parent then
            tag.Visible = false
            return
        end

        local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        if onScreen then
            tag.Position = Vector2.new(pos.X, pos.Y - 20)
            tag.Text = name
            tag.Visible = true
        else
            tag.Visible = false
        end
    end)
end

-- Item ESP Toggle
ESP:Toggle("Item ESP", false, "Show loot, crates, bonds", function(v)
    ItemESPEnabled = v
    if v then
        for _, item in ipairs(Workspace.RuntimeItems:GetChildren()) do
            local part = item:IsA("Model") and item.PrimaryPart or item
            if part and part:IsA("BasePart") then
                local displayName = CustomNames[item.Name] or item.Name
                createESP(part, displayName, Color3.fromRGB(255, 255, 0))
            end
        end

        Workspace.RuntimeItems.ChildAdded:Connect(function(item)
            task.spawn(function()
                task.wait(0.5)
                local part = item:IsA("Model") and item.PrimaryPart or item
                if part and part:IsA("BasePart") then
                    local displayName = CustomNames[item.Name] or item.Name
                    createESP(part, displayName, Color3.fromRGB(255, 255, 0))
                end
            end)
        end)
    else
        ClearItemESP()
    end
end)

-- Mob ESP Toggle
ESP:Toggle("Mob ESP", false, "Show zombies, bosses", function(v)
    MobESPEnabled = v
    if v then
        for _, mob in ipairs(Workspace.Mobs:GetChildren()) do
            if mob:FindFirstChild("HumanoidRootPart") then
                local name = CustomNames[mob.Name] or "Mob"
                createESP(mob.HumanoidRootPart, name, Color3.fromRGB(255, 0, 0))
            end
        end

        Workspace.Mobs.ChildAdded:Connect(function(mob)
            task.spawn(function()
                task.wait(0.5)
                if mob:FindFirstChild("HumanoidRootPart") then
                    local name = CustomNames[mob.Name] or "Mob"
                    createESP(mob.HumanoidRootPart, name, Color3.fromRGB(255, 0, 0))
                end
            end)
        end)
    else
        ClearMobESP()
    end
end)

------------------------------------------------------------------
-- 5. AUTO FARM TAB
------------------------------------------------------------------
Auto:Seperator("Auto Collect")

-- Settings
local collectSettings = {
    SnakeOil = false,
    Bandage = false,
    Money = false
}

Auto:Toggle("Auto Collect Money", false, "Collects nearby money bags", function(v)
    collectSettings.Money = v
    while collectSettings.Money and task.wait(0.5) do
        for _, bag in ipairs(Workspace:GetChildren()) do
            if bag.Name == "MoneyBag" and bag:FindFirstChild("Part") then
                local prompt = bag:FindFirstChild("CollectPrompt")
                if prompt and (hrp.Position - bag.Position).Magnitude <= 50 then
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)

Auto:Toggle("Auto Pick Snake Oil", false, "", function(v)
    collectSettings.SnakeOil = v
end)

Auto:Toggle("Auto Pick Bandage", false, "", function(v)
    collectSettings.Bandage = v
end)

-- Simple pickup
local function pickIfNear(name)
    for _, item in ipairs(Workspace.RuntimeItems:GetChildren()) do
        if item.Name == name then
            for _, part in pairs(item:GetChildren()) do
                if part:IsA("BasePart") and (hrp.Position - part.Position).Magnitude <= 20 then
                    ReplicatedStorage.Remotes.Tool.PickUpTool:FireServer(item)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if collectSettings.SnakeOil then pickIfNear("Snake Oil") end
    if collectSettings.Bandage then pickIfNear("Bandage") end
end)

------------------------------------------------------------------
-- 6. TRAIN TAB
------------------------------------------------------------------
Train:Seperator("Train Control")

Train:Button("Sit in Conductor Seat", function()
    if not char:FindFirstChild("Humanoid") then return end

    local seat = Workspace.Train.RequiredComponents.Controls.ConductorSeat.VehicleSeat
    if seat then
        char.Humanoid.Sit = true
        char.Humanoid.SeatPart = seat
        hrp.CFrame = seat.CFrame
        Stellar:Notify("Sitting in conductor seat!", 3)
    end
end)

Train:Button("Teleport to Maxim Gun", function()
    for _, v in pairs(Workspace.RuntimeItems:GetChildren()) do
        if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") then
            v.VehicleSeat.Disabled = false
            v.VehicleSeat:SetAttribute("Disabled", false)
            hrp.CFrame = v.VehicleSeat.CFrame
            char:FindFirstChild("Humanoid"):Sit(true)
            Stellar:Notify("Teleported to Maxim Gun!", 3)
        end
    end
end)

Train:Button("Auto Ride Train", function()
    task.spawn(function()
        local TpTrain = game:GetService("TweenService"):Create(
            hrp,
            TweenInfo.new(25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { CFrame = Workspace.Train.RequiredComponents.Controls.ConductorSeat.VehicleSeat.CFrame * CFrame.new(0, 20, 0) }
        )
        TpTrain:Play()
        TpTrain.Completed:Wait()

        task.wait(1)
        if char:FindFirstChild("Humanoid").Sit then
            local tpEnd = game:GetService("TweenService"):Create(
                hrp,
                TweenInfo.new(17, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { CFrame = CFrame.new(0.5, -78, -49429) }
            )
            tpEnd:Play()
            tpEnd.Completed:Wait()

            for _, bond in pairs(Workspace.RuntimeItems:GetChildren()) do
                if bond.Name:find("Bond") and bond:FindFirstChild("Part") then
                    repeat task.wait()
                        if bond:FindFirstChild("Part") then
                            hrp.CFrame = bond.Part.CFrame
                            ReplicatedStorage.Shared.Network.RemotePromise.Remotes.C_ActivateObject:FireServer(bond)
                        end
                    until not bond:FindFirstChild("Part")
                end
            end
        end
    end)
end)

------------------------------------------------------------------
-- 7. VISUALS TAB
------------------------------------------------------------------
Visuals:Seperator("Visual Enhancements")

-- FPS & Ping Display
local fpsText = Drawing.new("Text")
fpsText.Size = 16
fpsText.Position = Vector2.new(Workspace.CurrentCamera.ViewportSize.X - 100, 10)
fpsText.Color = Color3.fromRGB(0, 255, 0)
fpsText.Center = false
fpsText.Outline = true
fpsText.Visible = false

local msText = Drawing.new("Text")
msText.Size = 16
msText.Position = Vector2.new(Workspace.CurrentCamera.ViewportSize.X - 100, 30)
msText.Color = Color3.fromRGB(0, 255, 0)
msText.Center = false
msText.Outline = true
msText.Visible = false

local fpsCounter = 0
local fpsLastUpdate = tick()
RunService.RenderStepped:Connect(function()
    fpsCounter += 1
    if tick() - fpsLastUpdate >= 1 then
        local fps = fpsCounter
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        fpsText.Text = "FPS: " .. fps
        msText.Text = "Ping: " .. ping .. "ms"
        fpsCounter = 0
        fpsLastUpdate = tick()
    end
end)

Visuals:Toggle("Show FPS & Ping", false, "Display FPS and latency", function(v)
    fpsText.Visible = v
    msText.Visible = v
end)

-- No Fog
Visuals:Toggle("No Fog", false, "Remove fog for better visibility", function(v)
    _G.NoFog = v
    while _G.NoFog do
        local lighting = game:GetService("Lighting")
        lighting.FogStart = 100000
        lighting.FogEnd = 200000
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
                v.Haze = 0
            end
        end
        task.wait()
    end
    -- Reset
    game:GetService("Lighting").FogStart = 0
    game:GetService("Lighting").FogEnd = 1000
    for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
        if v:IsA("Atmosphere") then
            v.Density = 0.3
            v.Haze = 1
        end
    end
end)

-- Bright Mode (Night Vision)
Visuals:Toggle("Bright Mode", false, "Enable night vision", function(v)
    if v then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").TimeOfDay = "14:00:00"
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        for _, effect in pairs(game:GetService("Lighting"):GetDescendants()) do
            if effect:IsA("PostEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").TimeOfDay = "00:00:00"
        game:GetService("Lighting").FogEnd = 1000
        game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        for _, effect in pairs(game:GetService("Lighting"):GetDescendants()) do
            if effect:IsA("PostEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = true
            end
        end
    end
end)

------------------------------------------------------------------
-- 8. MISC TAB
------------------------------------------------------------------
Misc:Seperator("Utilities")

-- NoClip
local noclipEnabled = false
local function setupNoClip()
    if char and char:FindFirstChild("HumanoidRootPart") and not char.HumanoidRootPart:FindFirstChild("VelocityHandler") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "VelocityHandler"
        bv.Parent = char.HumanoidRootPart
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.new(0, 0, 0)
    end
end

Misc:Toggle("NoClip", false, "Walk through walls", function(v)
    noclipEnabled = v
    if v then
        setupNoClip()
        char:FindFirstChild("Humanoid").Sit = false
    end
    while noclipEnabled and char and char:FindFirstChild("HumanoidRootPart") do
        char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        task.wait(0.1)
    end
end)

-- Auto-reconnect on respawn
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    if noclipEnabled then
        setupNoClip()
    end
end)

Misc:Button("Copy Discord", function()
    setclipboard("https://discord.gg/flashlighthub")
    Stellar:Notify("Discord copied!", 3)
end)

Misc:Button("Unload Hub", function()
    local stellar = CoreGui:FindFirstChild("STELLAR")
    if stellar then stellar:Destroy() end
    local mobile = CoreGui:FindFirstChild("FlashlightMobileToggle")
    if mobile then mobile:Destroy() end
    Stellar:Notify("Hub unloaded.", 3)
end)

------------------------------------------------------------------
-- 9. MOBILE TOGGLE BUTTON
------------------------------------------------------------------
local mb = Instance.new("ScreenGui")
mb.Name = "FlashlightMobileToggle"
mb.ResetOnSpawn = false
mb.Parent = CoreGui

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
        local hub = CoreGui:FindFirstChild("STELLAR")
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
        local hub = CoreGui:FindFirstChild("STELLAR")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

print("✨ Flash Light Hub (Dead Rails) Loaded!")
