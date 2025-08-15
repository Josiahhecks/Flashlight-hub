-- Custom Grow a Garden Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Load Wind UI
local ui = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Settings
local settings = {
    autoCollect = false,
    collectRate = 500,
    autoSell = false,
    sellOnFruits = 50,
    selectedSeeds = {"Carrot"}
}

-- Notify function
local function notify(title, msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = msg,
        Duration = 3
    })
end

-- Helper functions
local function getGarden()
    for _, garden in pairs(workspace.Farm:GetChildren()) do
        if garden:FindFirstChild("Important") and garden.Important:FindFirstChild("Data") and
           garden.Important.Data:FindFirstChild("Owner") and
           garden.Important.Data.Owner.Value == LocalPlayer.Name then
            return garden
        end
    end
end

local function collectAll(range)
    local garden = getGarden()
    if not garden then return notify("Error", "Garden not found") end
    local plants = garden.Important.Plants_Physical
    for _, plant in pairs(plants:GetDescendants()) do
        if plant.ClassName == "Part" and plant:FindFirstChildOfClass("ProximityPrompt") then
            local proximity = plant:FindFirstChildOfClass("ProximityPrompt")
            local root = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
            if root and (plant.Position - root.Position).Magnitude < range then
                fireproximityprompt(proximity)
            end
        end
    end
end

local function getSellables()
    local sellables = {}
    local currentItem = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(item.Name, "kg") and not item:GetAttribute("Favorite") then
            table.insert(sellables, item.Name)
        end
    end
    if currentItem and string.find(currentItem.Name, "kg") and not currentItem:GetAttribute("Favorite") then
        table.insert(sellables, currentItem.Name)
    end
    return sellables
end

local function sellInventory()
    local sellCords = CFrame.new(61.589, 3, 0.427)
    if #getSellables() >= 1 then
        local root = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart
        if not root then return notify("Error", "Player character not found") end
        local oldCFrame = root.CFrame
        root.CFrame = sellCords
        repeat
            ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
            wait()
        until #getSellables() == 0
        root.CFrame = oldCFrame
        notify("Sell", "Inventory sold")
    end
end

-- Create UI
local window = ui:CreateWindow({
    Title = "CandyHub - Grow a Garden",
    Size = UDim2.fromOffset(450, 550),
    Theme = "Dark"
})

local mainTab = window:Tab({Title = "Main", Icon = "home"})

-- Collector Section
mainTab:CreateSection("Collector")
mainTab:Toggle({
    Title = "Auto Collect",
    Default = false,
    Callback = function(state)
        settings.autoCollect = state
        if state then
            spawn(function()
                while settings.autoCollect do
                    collectAll(17)
                    wait(settings.collectRate / 1000)
                end
            end)
        end
    end
})

mainTab:Slider({
    Title = "Collect Rate (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    Callback = function(val)
        settings.collectRate = val
    end
})

-- Seed Sniper Section
mainTab:CreateSection("Seed Sniper")
mainTab:Dropdown({
    Title = "Select Seeds",
    Options = {"Carrot", "Tomato", "Potato"}, -- Replace with dynamic seed list if possible
    Default = "Carrot",
    Callback = function(val)
        settings.selectedSeeds = {val}
    end
})

mainTab:Toggle({
    Title = "Auto Buy Seeds",
    Default = false,
    Callback = function(state)
        if state then
            spawn(function()
                while state do
                    for _, seed in pairs(settings.selectedSeeds) do
                        ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seed)
                    end
                    wait(1)
                end
            end)
        end
    end
})

-- Auto Sell Section
mainTab:CreateSection("Auto Sell")
mainTab:Toggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(state)
        settings.autoSell = state
        if state then
            spawn(function()
                while settings.autoSell do
                    if #getSellables() >= settings.sellOnFruits then
                        sellInventory()
                    end
                    wait(1)
                end
            end)
        end
    end
})

mainTab:Slider({
    Title = "Sell on Fruits",
    Min = 0,
    Max = 200,
    Default = 50,
    Callback = function(val)
        settings.sellOnFruits = val
    end
})

mainTab:Button({
    Title = "Sell All Once",
    Callback = sellInventory
})

notify("Script", "CandyHub - Grow a Garden loaded successfully")
