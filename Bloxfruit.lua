--[[
    🔦 FLASH LIGHT HUB – Blox Fruits
    Powered by COMPKILLER UI (4lpaca)
    Features: Auto Farm, Fruit ESP, Auto Store, Teleport, Auto Skills, Settings
--]]

-- // Load Compkiller UI
local Success, Compkiller = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
end)

if not Success then
    return warn("❌ Failed to load Compkiller UI")
end

-- // Notification System
local Notifier = Compkiller.newNotify()

-- // Config Manager
local ConfigManager = Compkiller:ConfigManager({
    Directory = "FlashLightHub",
    Config = "BloxFruits_Config"
})

-- // Loader
Compkiller:Loader("rbxassetid://120245531583106", 2.5).yield()

-- // Main Window
local Window = Compkiller.new({
    Name = "FLASH LIGHT HUB",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://120245531583106",
    Scale = Compkiller.Scale.Window,
    TextSize = 15
})

-- // Watermark
local Watermark = Window:Watermark()
Watermark:AddText({ Icon = "user", Text = "Flash Light" })
Watermark:AddText({ Icon = "clock", Text = Compkiller:GetDate() })

local TimeLabel = Watermark:AddText({ Icon = "timer", Text = "TIME" })
task.spawn(function()
    while true do
        TimeLabel:SetText(Compkiller:GetTimeNow())
        task.wait()
    end
end)

Watermark:AddText({ Icon = "server", Text = Compkiller.Version })

------------------------------------------------------------------
-- 2. SERVICES & PLAYER
------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

------------------------------------------------------------------
-- 3. SETTINGS & CONFIG
------------------------------------------------------------------
_G.Settings = {
    Main = {
        ["Auto Farm"] = false,
        ["Auto Farm Fast"] = false,
        ["Auto Farm Boss"] = false,
        ["Auto Farm All Boss"] = false,
        ["Auto Farm Mob"] = false,
        ["Auto Farm Sword Mastery"] = false,
        ["Auto Farm Gun Mastery"] = false,
        ["Auto Farm Fruit Mastery"] = false,
        ["Auto Observation"] = false,
        ["Auto Haki"] = true,
        ["Auto Rejoin"] = true,
        ["Bypass Anti Cheat"] = true,
        ["Auto Set Spawn Point"] = true
    },
    Farm = {
        ["Auto Farm Chest Tween"] = false,
        ["Auto Farm Observation"] = false
    },
    Fruit = {
        ["Auto Buy Random Fruit"] = false,
        ["Store Rarity Fruit"] = "Common - Mythical",
        ["Auto Store Fruit"] = false,
        ["Fruit Notification"] = false,
        ["Teleport To Fruit"] = false,
        ["Tween To Fruit"] = false
    },
    Raid = {
        ["Auto Dungeon"] = false,
        ["Auto Boss"] = false,
        ["Price Devil Fruit"] = 500000
    },
    Items = {
        ["Auto Electric Claw"] = false
    },
    Esp = {
        ["ESP Mob"] = false,
        ["ESP DevilFruit"] = false,
        ["ESP RealFruit"] = false
    },
    SettingSea = {
        ["Sea Gun Skill Z"] = true,
        ["Sea Gun Skill X"] = true,
        ["Sea Gun Skill C"] = true,
        ["Sea Gun Skill V"] = true,
        ["Sea Gun Skill F"] = false,
        ["Skill Devil Fruit"] = false
    },
    Stats = {
        ["Auto Add Melee Stats"] = false,
        ["Auto Add Defense Stats"] = false,
        ["Auto Add Sword Stats"] = false,
        ["Auto Add Gun Stats"] = false,
        ["Auto Add Fruit Stats"] = false
    },
    Misc = {
        ["Hide Chat"] = false,
        ["Hide Leaderboard"] = false,
        ["Highlight Mode"] = false
    }
}

-- Save & Load Settings
function SaveSetting()
    if readfile and writefile and isfile and isfolder then
        if not isfolder("FlashLightHub") then makefolder("FlashLightHub") end
        if not isfolder("FlashLightHub/BloxFruits") then makefolder("FlashLightHub/BloxFruits") end

        local filePath = "FlashLightHub/BloxFruits/" .. lp.Name .. ".json"
        writefile(filePath, HttpService:JSONEncode(_G.Settings))
    end
end

function LoadSetting()
    if readfile and writefile and isfile and isfolder then
        local filePath = "FlashLightHub/BloxFruits/" .. lp.Name .. ".json"
        if isfile(filePath) then
            local data = HttpService:JSONDecode(readfile(filePath))
            for i, v in pairs(data) do
                _G.Settings[i] = v
            end
        end
    end
end

LoadSetting()

------------------------------------------------------------------
-- 4. TABS
------------------------------------------------------------------
Window:DrawCategory({ Name = "Blox Fruits" })

local MainTab = Window:DrawTab({
    Name = "Main",
    Icon = "home",
    EnableScrolling = true
})

local FruitTab = Window:DrawTab({
    Name = "Fruit",
    Icon = "apple",
    EnableScrolling = true
})

local RaidTab = Window:DrawTab({
    Name = "Raid",
    Icon = "shield",
    EnableScrolling = true
})

local EspTab = Window:DrawTab({
    Name = "ESP",
    Icon = "eye",
    EnableScrolling = true
})

local SettingsTab = Window:DrawTab({
    Name = "Settings",
    Icon = "settings-3",
    Type = "Single",
    EnableScrolling = true
})

------------------------------------------------------------------
-- 5. MAIN TAB
------------------------------------------------------------------
MainTab:Seperator("Auto Farm")

MainTab:Toggle("Auto Farm", _G.Settings.Main["Auto Farm"], "Auto farm mobs", function(v)
    _G.Settings.Main["Auto Farm"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Farm Fast", _G.Settings.Main["Auto Farm Fast"], "Fast auto farm", function(v)
    _G.Settings.Main["Auto Farm Fast"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Farm Boss", _G.Settings.Main["Auto Farm Boss"], "Farm boss only", function(v)
    _G.Settings.Main["Auto Farm Boss"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Farm All Boss", _G.Settings.Main["Auto Farm All Boss"], "Farm all bosses", function(v)
    _G.Settings.Main["Auto Farm All Boss"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Observation", _G.Settings.Main["Auto Observation"], "Auto Observation Mastery", function(v)
    _G.Settings.Main["Auto Observation"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Haki", _G.Settings.Main["Auto Haki"], "Auto use Haki", function(v)
    _G.Settings.Main["Auto Haki"] = v
    SaveSetting()
end)

MainTab:Toggle("Auto Rejoin", _G.Settings.Main["Auto Rejoin"], "Rejoin on death", function(v)
    _G.Settings.Main["Auto Rejoin"] = v
    SaveSetting()
end)

------------------------------------------------------------------
-- 6. FRUIT TAB
------------------------------------------------------------------
FruitTab:Seperator("Devil Fruits")

FruitTab:Toggle("Auto Buy Random Fruit", _G.Settings.Fruit["Auto Buy Random Fruit"], "Auto buy random fruit", function(v)
    _G.Settings.Fruit["Auto Buy Random Fruit"] = v
    SaveSetting()
end)

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Fruit["Auto Buy Random Fruit"] then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        end
    end
end)

FruitTab:Button("Random Fruit", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
end)

FruitTab:Button("Open Devil Shop", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
    lp.PlayerGui.Main.FruitShop.Visible = true
end)

local RarityFruits = {
    Common = {"Rocket Fruit","Spin Fruit","Chop Fruit","Spring Fruit","Bomb Fruit","Smoke Fruit","Spike Fruit"},
    Uncommon = {"Flame Fruit","Falcon Fruit","Ice Fruit","Sand Fruit","Diamond Fruit","Dark Fruit"},
    Rare = {"Light Fruit","Rubber Fruit","Barrier Fruit","Ghost Fruit","Magma Fruit"},
    Legendary = {"Quake Fruit","Budha Fruit","Love Fruit","Spider Fruit","Sound Fruit","Phoenix Fruit","Portal Fruit","Rumble Fruit","Pain Fruit","Blizzard Fruit"},
    Mythical = {"Gravity Fruit","Mammoth Fruit","T-Rex Fruit","Dough Fruit","Shadow Fruit","Venom Fruit","Control Fruit","Spirit Fruit","Dragon Fruit","Leopard Fruit","Kitsune Fruit"}
}

local SelectRarityFruits = {"Common - Mythical","Uncommon - Mythical","Rare - Mythical","Legendary - Mythical","Mythical"}

FruitTab:Dropdown("Store Rarity Fruit", SelectRarityFruits, _G.Settings.Fruit["Store Rarity Fruit"], function(v)
    _G.Settings.Fruit["Store Rarity Fruit"] = v
    SaveSetting()
end)

function CheckFruits()
    -- Logic to filter fruits by rarity
    local result = {}
    local min, max = string.match(_G.Settings.Fruit["Store Rarity Fruit"], "(%a+) %- (%a+)")
    local inRange = false
    for _, list in pairs(RarityFruits) do
        for _, fruit in pairs(list) do
            if fruit == _G.Settings.Fruit["Store Rarity Fruit"] then
                inRange = true
            end
            if inRange then table.insert(result, fruit) end
            if fruit == max then break end
        end
    end
    return result
end

FruitTab:Toggle("Auto Store Fruit", _G.Settings.Fruit["Auto Store Fruit"], "Auto store fruits", function(v)
    _G.Settings.Fruit["Auto Store Fruit"] = v
    SaveSetting()
end)

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Fruit["Auto Store Fruit"] then
            for _, tool in ipairs(lp.Backpack:GetChildren()) do
                if string.find(tool.Name, "Fruit") then
                    local fruitsToStore = CheckFruits()
                    for _, fruitName in ipairs(fruitsToStore) do
                        if tool.Name == fruitName then
                            local baseName = string.gsub(tool.Name, " Fruit", "")
                            if lp.Backpack:FindFirstChild(tool.Name) then
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", baseName .. "-" .. baseName, tool)
                            end
                        end
                    end
                end
            end
        end
    end
end)

FruitTab:Toggle("Fruit Notification", _G.Settings.Fruit["Fruit Notification"], "Notify when fruit spawns", function(v)
    _G.Settings.Fruit["Fruit Notification"] = v
    SaveSetting()
end)

spawn(function()
    while task.wait(2) do
        if _G.Settings.Fruit["Fruit Notification"] then
            for _, fruit in ipairs(Workspace:GetChildren()) do
                if string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle") then
                    Notifier.new({
                        Title = "Fruit Spawned",
                        Content = fruit.Name,
                        Duration = 5,
                        Icon = "rbxassetid://120245531583106"
                    })
                end
            end
        end
    end
end)

FruitTab:Toggle("Teleport To Fruit", _G.Settings.Fruit["Teleport To Fruit"], "Teleport to fruit instantly", function(v)
    _G.Settings.Fruit["Teleport To Fruit"] = v
    SaveSetting()
end)

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Fruit["Teleport To Fruit"] then
            for _, fruit in ipairs(Workspace:GetChildren()) do
                if string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle") then
                    hrp.CFrame = fruit.Handle.CFrame
                end
            end
        end
    end
end)

FruitTab:Button("Grab All Fruits", function()
    for _, fruit in ipairs(Workspace:GetChildren()) do
        if fruit:IsA("Tool") and fruit:FindFirstChild("Handle") then
            fruit.Handle.CFrame = hrp.CFrame
        end
    end
end)

------------------------------------------------------------------
-- 7. RAID TAB
------------------------------------------------------------------
RaidTab:Seperator("Auto Raid")

RaidTab:Toggle("Auto Dungeon", _G.Settings.Raid["Auto Dungeon"], "Auto enter dungeon", function(v)
    _G.Settings.Raid["Auto Dungeon"] = v
    SaveSetting()
end)

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Raid["Auto Dungeon"] then
            if not lp.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartRaid")
            end
        end
    end
end)

RaidTab:Slider("Max Price for Fruit", 100000, 5000000, _G.Settings.Raid["Price Devil Fruit"], function(v)
    _G.Settings.Raid["Price Devil Fruit"] = v
    SaveSetting()
end)

------------------------------------------------------------------
-- 8. ESP TAB
------------------------------------------------------------------
EspTab:Seperator("ESP")

EspTab:Toggle("ESP Mob", _G.Settings.Esp["ESP Mob"], "Show mob ESP", function(v)
    _G.Settings.Esp["ESP Mob"] = v
    -- ESP Logic Here
end)

EspTab:Toggle("ESP Devil Fruit", _G.Settings.Esp["ESP DevilFruit"], "Show Devil Fruit ESP", function(v)
    _G.Settings.Esp["ESP DevilFruit"] = v
    -- ESP Logic Here
end)

EspTab:Toggle("ESP Real Fruit", _G.Settings.Esp["ESP RealFruit"], "Show Real Fruit ESP", function(v)
    _G.Settings.Esp["ESP RealFruit"] = v
    -- ESP Logic Here
end)

------------------------------------------------------------------
-- 9. SETTINGS TAB
------------------------------------------------------------------
local General = SettingsTab:DrawSection({ Name = "General" })

General:Toggle("Hide Chat", _G.Settings.Misc["Hide Chat"], "Hide chat UI", function(v)
    _G.Settings.Misc["Hide Chat"] = v
    SaveSetting()
end)

General:Toggle("Hide Leaderboard", _G.Settings.Misc["Hide Leaderboard"], "Hide leaderboard", function(v)
    _G.Settings.Misc["Hide Leaderboard"] = v
    SaveSetting()
end)

local Theme = SettingsTab:DrawSection({ Name = "Theme" })

Theme:AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Values = { "Default", "Dark Green", "Dark Blue", "Purple Rose", "Skeet" },
    Callback = function(v)
        Compkiller:SetTheme(v)
    end
})

------------------------------------------------------------------
-- 10. MOBILE TOGGLE BUTTON
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
        local hub = CoreGui:FindFirstChild("Compkiller-UI")
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
        local hub = CoreGui:FindFirstChild("Compkiller-UI")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

print("✨ Flash Light Hub (Blox Fruits) Loaded!")
