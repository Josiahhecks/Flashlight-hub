 -- // Flashlight Hub - Blox Fruits | Optimized & Fixed
-- // Based on x2zu UI + Vortex Hub Logic

-- === SAFETY CHECKS === --
if not game:IsLoaded() then game.Loaded:Wait() end
if not identifyexecutor then
    return warn("Unsupported executor. Please use a supported one (e.g., Synapse, Krnl).")
end

-- === SERVICES === --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game.Workspace
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:service("VirtualInputManager") or game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- === LOAD UI LIBRARY (x2zu) === --
local Library
local uiSuccess, uiResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUI.lua", true))()
end)

if not uiSuccess then
    warn("Failed to load x2zu UI. Check your connection or UI link.")
    Library = nil
    return
else
    Library = uiResult
end

-- === WINDOW SETUP === --
local Window = Library:Window({
    Title = "Flashlight Hub",
    Desc = "Blox Fruits - Made with ❤️",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.RightControl,
        Size = UDim2.new(0, 520, 0, 550)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Flashlight Hub"
    }
})

-- === SETTINGS SYSTEM (Vortex-Style) === --
_G.Settings = {
    Main = {
        ["Selected Weapon"] = "Sword",
        ["Auto Farm Level"] = false,
        ["Farm Level Method"] = "Quest",
        ["Auto Farm Fruit Mastery"] = false,
        ["Mastery Method"] = "Quest",
        ["Auto Farm Boss"] = false,
        ["Auto Farm All Boss"] = false,
        ["Selected Boss"] = ""
    },
    Items = {
        ["Auto Rengoku"] = false,
        ["Auto Yama Hop"] = false,
        ["Auto Saber"] = false,
        ["Auto Hallow Scythe"] = false,
        ["Auto Super Human"] = false,
        ["Auto Death Step"] = false,
        ["Auto Electric Claw"] = false,
        ["Auto Dragon Talon"] = false,
        ["Auto God Human"] = false,
        ["Auto Farm Factory"] = false,
        ["Auto Farm Chest Tween"] = false
    },
    Farm = {
        ["Auto Elite Hunter"] = false,
        ["Auto Farm Bone"] = false,
        ["Selected Bone Farm Method"] = "Quest",
        ["Auto Farm Chest Instant"] = false,
        ["Auto Stop Items"] = false
    },
    LocalPlayer = {
        ["Walk On Water"] = false,
        ["No Clip"] = false,
        ["Infinite Energy"] = false,
        ["Infinite Ability"] = false
    },
    Setting = {
        ["Auto Haki"] = true,
        ["Auto Rejoin"] = false,
        ["Hide Damage Text"] = false,
        ["Player Tween Speed"] = 350,
        ["Mastery Health"] = 50
    },
    Stats = {
        ["Auto Add Melee Stats"] = false,
        ["Auto Add Defense Stats"] = false,
        ["Auto Add Sword Stats"] = false,
        ["Auto Add Gun Stats"] = false,
        ["Auto Add Devil Fruit Stats"] = false
    },
    Raid = {
        ["Auto Raid"] = false,
        ["Price Devil Fruit"] = 100000,
        ["Selected Chip"] = ""
    },
    SeaStack = {
        ["Auto Attack Seabeasts"] = false,
        ["Auto Trade Azure Ember"] = false,
        ["Set Azure Ember"] = 1
    },
    Esp = {
        ["ESP Player"] = false,
        ["ESP Chest"] = false,
        ["ESP DevilFruit"] = false,
        ["ESP RealFruit"] = false,
        ["ESP Flower"] = false,
        ["ESP Island"] = false,
        ["ESP Npc"] = false,
        ["Highlight Mode"] = false
    },
    Fruit = {
        ["Auto Buy Random Fruit"] = false,
        ["Store Rarity Fruit"] = "Common - Mythical",
        ["Auto Store Fruit"] = false,
        ["Fruit Notification"] = false,
        ["Teleport To Fruit"] = false,
        ["Tween To Fruit"] = false
    },
    Misc = {
        ["Hide Chat"] = false,
        ["Hide Leaderboard"] = false
    }
}

-- === FOLDER & FILE HELPERS === --
local function isfolder(folder)
    local success, _ = pcall(function()
        return readfile(folder)
    end)
    return success
end

local function makefolder(folder)
    local success, _ = pcall(function()
        writefile(folder .. "/init.txt", "")
        delfile(folder .. "/init.txt")
    end)
    return success
end

-- === SAVE & LOAD SETTINGS === --
local function SaveSettings()
    spawn(function()
        if not isfolder("Flashlight Hub") then
            makefolder("Flashlight Hub")
        end
        writefile("Flashlight Hub/settings.json", HttpService:JSONEncode(_G.Settings))
    end)
end

local function LoadSettings()
    spawn(function()
        if isfolder("Flashlight Hub") and isfile("Flashlight Hub/settings.json") then
            local data = readfile("Flashlight Hub/settings.json")
            local loaded = HttpService:JSONDecode(data)
            for i, v in pairs(loaded) do
                if _G.Settings[i] then
                    for k, x in pairs(v) do
                        _G.Settings[i][k] = x
                    end
                end
            end
            Window:Notify({ Title = "Settings", Desc = "Loaded successfully!", Time = 4 })
        else
            Window:Notify({ Title = "Settings", Desc = "No settings found. Using defaults.", Time = 4 })
        end
    end)
end

LoadSettings()

-- === WORLD DETECTION === --
local World1, World2, World3 = false, false, false
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end

-- === TELEPORT FUNCTION === --
function TweenPlayer(cf)
    local hrp = Character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    local speed = _G.Settings.Setting["Player Tween Speed"] / 100
    local tween = TweenService:Create(hrp, TweenInfo.new(speed), { CFrame = cf })
    tween:Play()
end

-- === AUTO HAKI === --
function AutoHaki()
    if not _G.Settings.Setting["Auto Haki"] then return end
    if not Character:FindFirstChild("HasBuso") then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end)
    end
    if not Character:FindFirstChild("HasKen") then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Ken")
        end)
    end
end

-- === EQUIP WEAPON === --
function EquipWeapon(weaponName)
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.Name == weaponName and v:IsA("Tool") then
            pcall(function()
                Character:WaitForChild("Humanoid"):EquipTool(v)
            end)
            return
        end
    end
end

-- === HIGHLIGHT ESP === --
function CreateHighlight(part, color)
    if part:FindFirstChild("Flashlight_Highlight") then
        part:FindFirstChild("Flashlight_Highlight"):Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Flashlight_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.5
    highlight.Adornee = part
    highlight.Parent = part
end

-- === ESP SYSTEM === --
spawn(function()
    while wait(0.2) do
        if _G.Settings.Esp["Highlight Mode"] then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if not hrp:FindFirstChild("Flashlight_Highlight") then
                        CreateHighlight(hrp, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
        end

        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:FindFirstChild("Handle") then
                local name = obj.Name:lower()
                local handle = obj.Handle

                if _G.Settings.Esp["ESP DevilFruit"] and string.find(name, "fruit") then
                    if not handle:FindFirstChild("Flashlight_Highlight") then
                        CreateHighlight(handle, Color3.fromRGB(255, 255, 0))
                    end
                elseif _G.Settings.Esp["ESP Chest"] and string.find(name, "chest") then
                    if not handle:FindFirstChild("Flashlight_Highlight") then
                        CreateHighlight(handle, Color3.fromRGB(0, 255, 255))
                    end
                end
            end
        end
    end
end)

-- === MAIN TAB === --
local MainTab = Window:Tab({ Title = "Main", Icon = "star" })
MainTab:Section({ Title = "Auto Farm Level" })

MainTab:Toggle({
    Title = "Auto Farm Level",
    Value = _G.Settings.Main["Auto Farm Level"],
    Callback = function(v)
        _G.Settings.Main["Auto Farm Level"] = v
        SaveSettings()
    end
})

MainTab:Dropdown({
    Title = "Farm Method",
    Values = World3 and { "Quest", "Nearest", "No Quest", "Elite Hunter", "Bone Farm" } or { "Quest", "Nearest", "No Quest", "Elite Hunter" },
    Value = _G.Settings.Main["Farm Level Method"],
    Callback = function(v)
        _G.Settings.Main["Farm Level Method"] = v
        SaveSettings()
    end
})

MainTab:Dropdown({
    Title = "Select Weapon",
    Values = { "Sword", "Gun", "Melee", "Fruit" },
    Value = _G.Settings.Main["Selected Weapon"],
    Callback = function(v)
        _G.Settings.Main["Selected Weapon"] = v
        SaveSettings()
    end
})

-- === ITEMS TAB === --
local ItemsTab = Window:Tab({ Title = "Items", Icon = "sword" })
for item, state in pairs(_G.Settings.Items) do
    ItemsTab:Toggle({
        Title = "Auto " .. item:sub(6),
        Value = state,
        Callback = function(v)
            _G.Settings.Items[item] = v
            SaveSettings()
        end
    })
end

-- === PLAYER TAB === --
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
PlayerTab:Section({ Title = "Movement & Abilities" })

for _, opt in pairs({ "Walk On Water", "No Clip", "Infinite Energy", "Infinite Ability" }) do
    PlayerTab:Toggle({
        Title = opt,
        Value = _G.Settings.LocalPlayer[opt],
        Callback = function(v)
            _G.Settings.LocalPlayer[opt] = v
            SaveSettings()
        end
    })
end

PlayerTab:Button({
    Title = "Join Pirates",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end)
    end
})

PlayerTab:Button({
    Title = "Join Marines",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
    end
})

-- === STATS TAB === --
local StatsTab = Window:Tab({ Title = "Stats", Icon = "award" })
for stat, state in pairs(_G.Settings.Stats) do
    if stat:find("Auto Add") then
        local name = stat:sub(9, -7)
        StatsTab:Toggle({
            Title = "Auto Add " .. name,
            Value = state,
            Callback = function(v)
                _G.Settings.Stats[stat] = v
                SaveSettings()
            end
        })
    end
end

-- === FRUIT TAB === --
local FruitTab = Window:Tab({ Title = "Fruit", Icon = "vegan" })
FruitTab:Toggle({
    Title = "Auto Buy Random Fruit",
    Value = _G.Settings.Fruit["Auto Buy Random Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Auto Buy Random Fruit"] = v
        SaveSettings()
    end
})

FruitTab:Dropdown({
    Title = "Store Rarity",
    Values = { "Common - Mythical", "Uncommon - Mythical", "Rare - Mythical", "Legendary - Mythical", "Mythical" },
    Value = _G.Settings.Fruit["Store Rarity Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Store Rarity Fruit"] = v
        SaveSettings()
    end
})

FruitTab:Toggle({
    Title = "Auto Store Fruit",
    Value = _G.Settings.Fruit["Auto Store Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Auto Store Fruit"] = v
        SaveSettings()
    end
})

FruitTab:Toggle({
    Title = "Teleport To Fruit",
    Value = _G.Settings.Fruit["Teleport To Fruit"],
    Callback = function(v)
        _G.Settings.Fruit["Teleport To Fruit"] = v
        SaveSettings()
    end
})

-- Auto Fruit Loop
spawn(function()
    while wait(0.2) do
        if _G.Settings.Fruit["Teleport To Fruit"] then
            for _, fruit in pairs(Workspace:GetChildren()) do
                if fruit:FindFirstChild("Handle") and string.find(fruit.Name:lower(), "fruit") then
                    TweenPlayer(fruit.Handle.CFrame)
                    break
                end
            end
        end
    end
end)

-- === MISC TAB === --
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
MiscTab:Toggle({
    Title = "Hide Chat",
    Value = _G.Settings.Misc["Hide Chat"],
    Callback = function(v)
        _G.Settings.Misc["Hide Chat"] = v
        LocalPlayer.PlayerGui.Chat.Enabled = not v
        SaveSettings()
    end
})

MiscTab:Button({
    Title = "FPS Boost",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") then
                if v.Transparency < 1 then
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
        end
        game.Lighting.FogEnd = 100000
        Window:Notify({ Title = "FPS Boost", Desc = "Optimized!", Time = 3 })
    end
})

MiscTab:Button({
    Title = "Remove Fog",
    Callback = function()
        game.Lighting.FogEnd = 100000
        Window:Notify({ Title = "Fog", Desc = "Removed!", Time = 3 })
    end
})

MiscTab:Button({
    Title = "Rejoin",
    Callback = function()
        game.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

MiscTab:Button({
    Title = "Server Hop",
    Callback = function()
        local success, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and res and res.data then
            for _, v in pairs(res.data) do
                if v.playing < v.maxPlayers then
                    game.TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
                    break
                end
            end
        else
            Window:Notify({ Title = "Error", Desc = "Failed to fetch servers.", Time = 4 })
        end
    end
})

-- === INFO TAB === --
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })
InfoTab:Paragraph({
    Title = "Flashlight Hub",
    Content = "Blox Fruits Script\nMade with ❤️\nVersion: 1.0\nUI: x2zu Open Source\nAuthor: Flashlight"
})

InfoTab:Button({
    Title = "Discord",
    Callback = function()
        setclipboard("https://discord.gg/TCFBCeHUaq")
        Window:Notify({ Title = "Copied", Desc = "Join our Discord!", Time = 3 })
    end
})

-- === BACKGROUND LOOP === --
spawn(function()
    while wait(1) do
        if _G.Settings.Setting["Auto Rejoin"] then
            pcall(function()
                game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(prompt)
                    if prompt.Name == "ErrorPrompt" then
                        game.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                end)
            end)
        end

        if _G.Settings.Fruit["Auto Buy Random Fruit"] then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
            end)
        end

        if _G.Settings.LocalPlayer["Infinite Energy"] then
            pcall(function()
                LocalPlayer.Data.Energy.Value = 200
            end)
        end

        if _G.Settings.LocalPlayer["Infinite Ability"] then
            for _, v in pairs(LocalPlayer.Data:GetChildren()) do
                if v.Name == "Ability" then
                    v.Value = 100
                end
            end
        end
    end
end)

-- === AUTO FARM LEVEL LOOP === --
spawn(function()
    while wait(0.2) do
        if _G.Settings.Main["Auto Farm Level"] then
            AutoHaki()
            EquipWeapon(_G.Settings.Main["Selected Weapon"])

            if _G.Settings.Main["Farm Level Method"] == "Quest" then
                if World1 then
                    TweenPlayer(CFrame.new(-2080.24, 69.77, -1133.18))
                elseif World2 then
                    TweenPlayer(CFrame.new(1100.68, 70.22, -1447.7))
                elseif World3 then
                    TweenPlayer(CFrame.new(-5069.62, 105.07, -2795.43))
                end
            elseif _G.Settings.Main["Farm Level Method"] == "Nearest" then
                local nearest = nil
                local dist = math.huge
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") then
                        local d = (enemy.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = enemy
                        end
                    end
                end
                if nearest then
                    TweenPlayer(nearest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                end
            end
        end
    end
end)

-- === WELCOME NOTIFICATION === --
Window:Notify({
    Title = "Flashlight Hub",
    Desc = "Welcome back, " .. LocalPlayer.Name .. "!",
    Time = 5
})
