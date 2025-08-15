--[[
    🔦 FLASH LIGHT HUB – Breeze Edition
    Powered by STELLAR UI (x2zu)
    Features: Heroes, Tools, FPS Boost, Mobile Toggle
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
    SubTitle = "Breeze Edition",
    Size = game:GetService("UserInputService").TouchEnabled
        and UDim2.new(0, 380, 0, 260)
        or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local FPS     = Window:Tab("FPS Booster", "rbxassetid://10723415335")
local Heroes  = Window:Tab("Any Hero", "rbxassetid://10709782497")
local Saitama = Window:Tab("Saitama", "rbxassetid://10734950309")
local Garou   = Window:Tab("Garou", "rbxassetid://10747373176")
local Misc    = Window:Tab("Misc", "rbxassetid://98216376967992")

------------------------------------------------------------------
-- 3. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

------------------------------------------------------------------
-- 4. FPS BOOSTER TAB
------------------------------------------------------------------
FPS:Seperator("Performance")

FPS:Button("FPS Booster | TSB", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MerebennieOfficial/ExoticJn/refs/heads/main/FpsBooster"))()
        Stellar:Notify("FPS Booster loaded!", 3)
    end)
end)

------------------------------------------------------------------
-- 5. ANY HERO TAB
------------------------------------------------------------------
Heroes:Seperator("Unlock Any Hero")

Heroes:Button("Trashcan Man", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man", true))()
        Stellar:Notify("Trashcan Man loaded!", 3)
    end)
end)

Heroes:Button("Flight Tool", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Flight%20Tool%20Obfuscated.txt", true))()
        Stellar:Notify("Flight Tool loaded!", 3)
    end)
end)

------------------------------------------------------------------
-- 6. SAITAMA TAB
------------------------------------------------------------------
Saitama:Seperator("Saitama Tools")

Saitama:Button("Teleport Guy", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Teleport%20Guy.txt", true))()
        Stellar:Notify("Teleport Guy loaded!", 3)
    end)
end)

Saitama:Button("Void Reaper", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Void%20Reaper%20Obfuscated.txt"))()
        Stellar:Notify("Void Reaper loaded!", 3)
    end)
end)

Saitama:Label("⚠️ Notice: Void reaper can't void anymore :(")

------------------------------------------------------------------
-- 7. GAROU TAB
------------------------------------------------------------------
Garou:Seperator("Garou Tools")

Garou:Button("Chainsaw Man", function()
    task.spawn(function()
        -- Settings
        getgenv().RunSpeed = 100
        getgenv().RunJump = 100
        getgenv().InstaKill = true
        getgenv().RevivePercent = 100
        getgenv().ChangeWalk = true
        getgenv().ChangeIdle = true
        getgenv().Night = false
        getgenv().DashNoCooldown = true
        getgenv().ExtraSkills = true

        -- Load script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/CHAINSAW%20MAN/Chainsaw%20Man%20(Obfuscated).txt"))()

        Stellar:Notify("Chainsaw Man loaded!", 3)
    end)
end)

Garou:Label("⚠️ NOTICE: Chainsaw man will lag low-performing devices !!")

Garou:Button("A-Train Moveset", function()
    task.spawn(function()
        getgenv().settings = {
            morph = {
                enabled = false,
                dontchangeskincolor = false
            },
            ult_forcewalkspeed = true,
            ult_walkspeed = 60,
            tp_duration = 0.15
        }
        loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ATrainSounds/refs/heads/main/ATrain.lua"))()
        Stellar:Notify("A-Train loaded!", 3)
    end)
end)

Garou:Button("Goku Moveset", function()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Goku%20Moveset%20(Obfuscated).txt"))()
        Stellar:Notify("Goku Moveset loaded!", 3)
    end)
end)

------------------------------------------------------------------
-- 8. MISC TAB
------------------------------------------------------------------
Misc:Seperator("Utilities")

Misc:Button("Copy Discord", function()
    setclipboard("https://discord.gg/flashlighthub")
    Stellar:Notify("Discord link copied!", 3)
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

-- Drag + Toggle Logic
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

print("✨ Flash Light Hub (Breeze Edition) Loaded!")
print("💡 Press Insert or tap mobile button to toggle.")
