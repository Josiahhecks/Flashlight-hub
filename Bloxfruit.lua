--[[
    🔦 FLASH LIGHT HUB – Blox Fruits
    Powered by x2zu's Stellar UI (DummyUI.lua)
    Features: Auto Farm, Fruit, Raid, ESP, Settings, Mobile Toggle
--]]

-- // Load x2zu's Stellar UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUI.lua"))()

-- // Create Main Window
local Window = Library:Window({
    Title = "FLASH LIGHT HUB",
    Desc = "Blox Fruits Edition",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 600, 0, 450)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

-- // Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

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
        if not isfolder("FlashLightHub/Blox Fruits") then makefolder("FlashLightHub/Blox Fruits") end

        local filePath = "FlashLightHub/Blox Fruits/" .. lp.Name .. ".json"
        writefile(filePath, HttpService:JSONEncode(_G.Settings))
    end
end

function LoadSetting()
    if readfile and writefile and isfile and isfolder then
        local filePath = "FlashLightHub/Blox Fruits/" .. lp.Name .. ".json"
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
local MainTab = Window:Tab({Title = "Main", Icon = "star"})
local FruitTab = Window:Tab({Title = "Fruit", Icon = "apple"})
local RaidTab = Window:Tab({Title = "Raid", Icon = "shield"})
local EspTab = Window:Tab({Title = "ESP", Icon = "eye"})
local SettingsTab = Window:Tab({Title = "Settings", Icon = "wrench"})

------------------------------------------------------------------
-- 5. MAIN TAB
------------------------------------------------------------------
MainTab:Section({Title = "Auto Farm"})

MainTab:Toggle({
    Title = "Auto Farm",
    Desc = "Auto farm mobs",
    Value = _G.Settings.Main["Auto Farm"],
    Callback = function(v)
        _G.Settings.Main["Auto Farm"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Farm Fast",
    Desc = "Fast auto farm",
    Value = _G.Settings.Main["Auto Farm Fast"],
    Callback = function(v)
        _G.Settings.Main["Auto Farm Fast"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Farm Boss",
    Desc = "Farm boss only",
    Value = _G.Settings.Main["Auto Farm Boss"],
    Callback = function(v)
        _G.Settings.Main["Auto Farm Boss"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Farm All Boss",
    Desc = "Farm all bosses",
    Value = _G.Settings.Main["Auto Farm All Boss"],
    Callback = function(v)
        _G.Settings.Main["Auto Farm All Boss"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Observation",
    Desc = "Auto Observation Mastery",
    Value = _G.Settings.Main["Auto Observation"],
    Callback = function(v)
        _G.Settings.Main["Auto Observation"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Haki",
    Desc = "Auto use Haki",
    Value = _G.Settings.Main["Auto Haki"],
    Callback = function(v)
        _G.Settings.Main["Auto Haki"] = v
        SaveSetting()
    end
})

MainTab:Toggle({
    Title = "Auto Rejoin",
    Desc = "Rejoin on death",
    Value = _G.Settings.Main["Auto Rejoin"],
    Callback = function(v)
        _G.Settings.Main["Auto Rejoin"] = v
        SaveSetting()
    end
})

------------------------------------------------------------------
-- 6. FRUIT TAB
------------------------------------------------------------------
FruitTab:Section({Title = "Devil Fruits"})

FruitTab:Toggle({
    Title = "Auto Buy Random Fruit",
    Desc = "Auto buy random fruit",
    Value = _G.Settings.Fruit["Auto Buy Random Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Auto Buy Random Fruit"] = v
        SaveSetting()
    end
})

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Fruit["Auto Buy Random Fruit"] then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        end
    end
end)

FruitTab:Button({
    Title = "Random Fruit",
    Desc = "Buy one random fruit",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end
})

FruitTab:Button({
    Title = "Open Devil Shop",
    Desc = "Open fruit shop UI",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
        lp.PlayerGui.Main.FruitShop.Visible = true
    end
})

local RarityFruits = {
    Common = {"Rocket Fruit","Spin Fruit","Chop Fruit","Spring Fruit","Bomb Fruit","Smoke Fruit","Spike Fruit"},
    Uncommon = {"Flame Fruit","Falcon Fruit","Ice Fruit","Sand Fruit","Diamond Fruit","Dark Fruit"},
    Rare = {"Light Fruit","Rubber Fruit","Barrier Fruit","Ghost Fruit","Magma Fruit"},
    Legendary = {"Quake Fruit","Budha Fruit","Love Fruit","Spider Fruit","Sound Fruit","Phoenix Fruit","Portal Fruit","Rumble Fruit","Pain Fruit","Blizzard Fruit"},
    Mythical = {"Gravity Fruit","Mammoth Fruit","T-Rex Fruit","Dough Fruit","Shadow Fruit","Venom Fruit","Control Fruit","Spirit Fruit","Dragon Fruit","Leopard Fruit","Kitsune Fruit"}
}

local SelectRarityFruits = {"Common - Mythical","Uncommon - Mythical","Rare - Mythical","Legendary - Mythical","Mythical"}

function CheckFruits()
    local result = {}
    local min, max = string.match(_G.Settings.Fruit["Store Rarity Fruit"], "(%a+) %- (%a+)")
    local inRange = false
    for rarity, list in pairs(RarityFruits) do
        for _, fruit in pairs(list) do
            if fruit == min then inRange = true end
            if inRange then table.insert(result, fruit) end
            if fruit == max then break end
        end
    end
    return result
end

FruitTab:Dropdown({
    Title = "Store Rarity Fruit",
    List = SelectRarityFruits,
    Value = _G.Settings.Fruit["Store Rarity Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Store Rarity Fruit"] = v
        SaveSetting()
    end
})

FruitTab:Toggle({
    Title = "Auto Store Fruit",
    Desc = "Auto store fruits by rarity",
    Value = _G.Settings.Fruit["Auto Store Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Auto Store Fruit"] = v
        SaveSetting()
    end
})

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

FruitTab:Toggle({
    Title = "Fruit Notification",
    Desc = "Notify when fruit spawns",
    Value = _G.Settings.Fruit["Fruit Notification"],
    Callback = function(v)
        _G.Settings.Fruit["Fruit Notification"] = v
        SaveSetting()
    end
})

spawn(function()
    while task.wait(2) do
        if _G.Settings.Fruit["Fruit Notification"] then
            for _, fruit in ipairs(Workspace:GetChildren()) do
                if string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle") then
                    Window:Notify({
                        Title = "Fruit Spawned",
                        Desc = fruit.Name,
                        Time = 5
                    })
                end
            end
        end
    end
end)

FruitTab:Toggle({
    Title = "Teleport To Fruit",
    Desc = "Teleport to fruit instantly",
    Value = _G.Settings.Fruit["Teleport To Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Teleport To Fruit"] = v
        SaveSetting()
    end
})

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

FruitTab:Button({
    Title = "Grab All Fruits",
    Desc = "Pull all fruits to you",
    Callback = function()
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit:IsA("Tool") and fruit:FindFirstChild("Handle") then
                fruit.Handle.CFrame = hrp.CFrame
            end
        end
    end
})

------------------------------------------------------------------
-- 7. RAID TAB
------------------------------------------------------------------
RaidTab:Section({Title = "Auto Raid"})

RaidTab:Toggle({
    Title = "Auto Dungeon",
    Desc = "Auto enter dungeon",
    Value = _G.Settings.Raid["Auto Dungeon"],
    Callback = function(v)
        _G.Settings.Raid["Auto Dungeon"] = v
        SaveSetting()
    end
})

spawn(function()
    while task.wait(0.2) do
        if _G.Settings.Raid["Auto Dungeon"] then
            if not lp.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartRaid")
            end
        end
    end
end)

RaidTab:Slider({
    Title = "Max Price for Fruit",
    Min = 100000,
    Max = 5000000,
    Rounding = 0,
    Value = _G.Settings.Raid["Price Devil Fruit"],
    Callback = function(v)
        _G.Settings.Raid["Price Devil Fruit"] = v
        SaveSetting()
    end
})

------------------------------------------------------------------
-- 8. ESP TAB
------------------------------------------------------------------
EspTab:Section({Title = "ESP"})

EspTab:Toggle({
    Title = "ESP Mob",
    Desc = "Show mob ESP",
    Value = _G.Settings.Esp["ESP Mob"],
    Callback = function(v)
        _G.Settings.Esp["ESP Mob"] = v
        -- Add ESP logic if needed
    end
})

EspTab:Toggle({
    Title = "ESP Devil Fruit",
    Desc = "Show Devil Fruit ESP",
    Value = _G.Settings.Esp["ESP DevilFruit"],
    Callback = function(v)
        _G.Settings.Esp["ESP DevilFruit"] = v
        -- Add ESP logic
    end
})

EspTab:Toggle({
    Title = "ESP Real Fruit",
    Desc = "Show Real Fruit ESP",
    Value = _G.Settings.Esp["ESP RealFruit"],
    Callback = function(v)
        _G.Settings.Esp["ESP RealFruit"] = v
        -- Add ESP logic
    end
})

------------------------------------------------------------------
-- 9. SETTINGS TAB
------------------------------------------------------------------
SettingsTab:Section({Title = "General"})

SettingsTab:Toggle({
    Title = "Hide Chat",
    Desc = "Hide chat UI",
    Value = _G.Settings.Misc["Hide Chat"],
    Callback = function(v)
        _G.Settings.Misc["Hide Chat"] = v
        SaveSetting()
    end
})

SettingsTab:Toggle({
    Title = "Hide Leaderboard",
    Desc = "Hide leaderboard",
    Value = _G.Settings.Misc["Hide Leaderboard"],
    Callback = function(v)
        _G.Settings.Misc["Hide Leaderboard"] = v
        SaveSetting()
    end
})

SettingsTab:Button({
    Title = "Unload Hub",
    Desc = "Destroy GUI",
    Callback = function()
        local gui = game.CoreGui:FindFirstChild("Stellar")
        if gui then gui:Destroy() end
        local mobile = game.CoreGui:FindFirstChild("FlashlightMobileToggle")
        if mobile then mobile:Destroy() end
        Window:Notify({ Title = "Unloaded", Desc = "Hub closed.", Time = 3 })
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
        local hub = game.CoreGui:FindFirstChild("Stellar")
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
        local hub = game.CoreGui:FindFirstChild("Stellar")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

-- Final Notify
Window:Notify({
    Title = "Loaded",
    Desc = "Flash Light Hub for Blox Fruits is ready!",
    Time = 5
})

print("✨ Flash Light Hub (Blox Fruits) Loaded!")
