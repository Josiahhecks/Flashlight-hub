-- Flashlight Hub for Steal a Kpop Demon Hunter
-- Built with x2zu's Open Source UI
-- Author: Flashlight
-- Discord: https://discord.gg/TCFBCeHUaq

-- Load x2zu UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUI.lua"))()

-- Initialize Settings
_G.Settings = {
    Steal = {
        SellAfterStealing = true,
        SelectedKPDH = "Rainbow Derpy Tiger",
        SelectedPlayer = nil
    },
    Base = {
        AutoLockBase = true,
        AutoCollectCash = true,
        AutoDisableTraps = true
    },
    Character = {
        WalkSpeed = 30,
        NoClip = false
    },
    Misc = {
        InstantProximityPrompt = true,
        DisableNotificationsAndSFX = true
    }
}

-- Settings Save/Load
local HttpService = game:GetService("HttpService")
local function SaveSettings()
    if writefile and isfolder then
        if not isfolder("Flashlight Hub") then
            makefolder("Flashlight Hub")
        end
        writefile("Flashlight Hub/KpopDemonHunter_settings.json", HttpService:JSONEncode(_G.Settings))
    end
end

local function LoadSettings()
    if readfile and isfile and isfolder then
        if isfile("Flashlight Hub/KpopDemonHunter_settings.json") then
            local decoded = HttpService:JSONDecode(readfile("Flashlight Hub/KpopDemonHunter_settings.json"))
            for i, v in pairs(decoded) do
                _G.Settings[i] = v
            end
        else
            SaveSettings()
        end
        print("Settings Loaded!")
    else
        warn("Executor does not support file operations")
    end
end
LoadSettings()

-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LPlayer = Players.LocalPlayer
local Char = LPlayer.Character
local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
LPlayer.CharacterAdded:Connect(function(char)
    Char = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)
local bases = workspace.Map.Bases

-- Variables
local anyStealRunning = false
local lockThread = nil
local collectThread = nil
local trapsThread = nil
local noClipRunning = nil
local PromptButtonHoldBegan = nil

-- Auto-Execute on Teleport
if not getgenv().lolxdteleportyes then
    getgenv().lolxdteleportyes = true
    LPlayer.OnTeleport:Connect(function()
        if queue_on_teleport then
            queue_on_teleport("task.wait(1.5) loadstring(game:HttpGet('https://raw.githubusercontent.com/Josiahhecks/Flashlight-hub/refs/heads/main/KpopDemonHunter.lua'))()")
        end
    end)
end

-- Functions
local function getBase(playername)
    local result
    if Players:FindFirstChild(playername) then
        for _, base in ipairs(bases:GetChildren()) do
            local signtext = base.Important.Sign.SignPart.SurfaceGui.TextLabel.Text
            if string.find(signtext, playername, 1, true) then
                result = base.Name
                break
            end
        end
    end
    return result
end

local function getAllShits(basenumber)
    local shitstable = {}
    for _, chars in ipairs(workspace.Map.Bases[basenumber].Important.NPCPads:GetChildren()) do
        local charModel = chars:FindFirstChild("Character")
        if charModel and charModel:FindFirstChild("Head") then
            local attach = charModel.Head:FindFirstChild("OverHeadAttachment")
            if attach and attach:FindFirstChild("CharacterInfo") then
                local frame = attach.CharacterInfo:FindFirstChild("Frame")
                if frame and frame:FindFirstChild("UnitName") and frame:FindFirstChild("Price") then
                    table.insert(shitstable, {
                        object = chars,
                        name = frame.UnitName.Text,
                        price = frame.Price.Text
                    })
                end
            end
        end
    end
    return shitstable
end

local function stealFunction(shits, ownbase, stolecount)
    local shitcollect = shits.object.Collect
    local stealattempts = 0
    local maxstealattempts = 2
    task.spawn(function()
        while stealattempts <= maxstealattempts do
            stealattempts = stealattempts + 1
            task.wait(1)
        end
    end)
    repeat
        HRP.CFrame = CFrame.new(shitcollect.Position + Vector3.new(0, 3, 0))
        task.wait()
        if shits.object:FindFirstChild("Character") and not shits.object.Part:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(shits.object.Character.HumanoidRootPart:WaitForChild("SlotPrompt"))
        end
    until shits.object.Part:FindFirstChild("ProximityPrompt") or not shits.object:FindFirstChild("Character") or stealattempts >= maxstealattempts
    HRP.CFrame = bases[ownbase].Important.RobberyDeposit.CFrame
    stolecount = stolecount + 1
    return stolecount
end

local function stealSearchShit(shitsname)
    local ownbase = getBase(LPlayer.Name)
    local stolecount = 0
    for _, fplayers in pairs(Players:GetChildren()) do
        if fplayers ~= LPlayer then
            local currenttarget = getBase(fplayers.Name)
            if currenttarget then
                for _, shits in pairs(getAllShits(currenttarget)) do
                    if shits.name == shitsname then
                        stolecount = stealFunction(shits, ownbase, stolecount)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
    return stolecount > 0, stolecount
end

local function stealAllShits(playername)
    local target = getBase(playername)
    local ownbase = getBase(LPlayer.Name)
    if target then
        for _, shits in getAllShits(target) do
            if Players:FindFirstChild(playername) then
                stealFunction(shits, ownbase, 0)
                task.wait(0.1)
            else
                continue
            end
        end
    end
end

local function sellAllPlayerShits()
    for _, shits in pairs(getAllShits(getBase(LPlayer.Name))) do
        local shitcollect = shits.object.Collect
        repeat
            task.wait()
            HRP.CFrame = CFrame.new(shitcollect.Position + Vector3.new(0, 3, 0))
            if shits.object:FindFirstChild("Character") and shits.object.Character.HumanoidRootPart:FindFirstChild("SlotPrompt") and not shits.object.Part:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(shits.object.Character.HumanoidRootPart.SlotPrompt)
            end
        until not shits.object:FindFirstChild("Character") or shits.object.Part:FindFirstChild("ProximityPrompt")
    end
end

local function lockBase()
    while _G.Settings.Base.AutoLockBase do
        task.wait()
        local playerbase = workspace.Map.Bases[getBase(LPlayer.Name)]
        local lockbutton = playerbase.Important.LockButton
        if lockbutton.BillboardAttachment.LockGui.ActionLabel.Visible then
            firetouchinterest(lockbutton, HRP, 0)
            task.wait(0.05)
            firetouchinterest(lockbutton, HRP, 1)
        end
    end
end

local function autoCollectCash()
    while _G.Settings.Base.AutoCollectCash do
        for _, npcpad in pairs(workspace.Map.Bases[getBase(LPlayer.Name)].Important.NPCPads:GetChildren()) do
            task.wait()
            firetouchinterest(npcpad.Collect, HRP, 0)
            task.wait(0.05)
            firetouchinterest(npcpad.Collect, HRP, 1)
        end
    end
end

local function DisableTraps()
    while _G.Settings.Base.AutoDisableTraps do
        for _, traps in workspace:GetChildren() do
            task.wait()
            if traps.Name == "Trap" then
                traps.HitBox.TouchInterest:Destroy()
                traps.Name = "TrapL"
            end
        end
    end
end

local function addSpacesToName(name)
    if not name or name == "" then
        return name
    end
    local result = ""
    for i = 1, #name do
        local char = name:sub(i, i)
        if i > 1 and char:match("%u") then
            result = result .. " "
        end
        result = result .. char
    end
    return result
end

local function getKPDH()
    local kpdhtable = {}
    for _, kpdh in pairs(ReplicatedStorage.Assets.Characters:GetChildren()) do
        table.insert(kpdhtable, addSpacesToName(kpdh.Name))
    end
    table.sort(kpdhtable)
    return kpdhtable
end

-- UI Setup
local Window = Library:Window({
    Title = "Flashlight Hub",
    Desc = "Steal a Kpop Demon Hunter - Made with ❤️",
    Icon = 105059922903197, -- Star icon
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

-- Watermark
Window:Watermark({ Text = "Flashlight Hub | " .. LPlayer.Name .. " | v1.0.0" })

-- Welcome Notification
Window:Notify({ Title = "Loaded", Desc = "Flashlight Hub ready! Join our Discord: https://discord.gg/TCFBCeHUaq", Time = 5 })

-- Tabs
local Tabs = {
    StealTab = Window:Tab({ Title = "Steal", Icon = "hand-coins" }),
    BaseTab = Window:Tab({ Title = "Base", Icon = "home" }),
    CharTab = Window:Tab({ Title = "Character", Icon = "user" }),
    MiscTab = Window:Tab({ Title = "Misc", Icon = "layout-grid" }),
    UITab = Window:Tab({ Title = "UI", Icon = "settings" })
}

-- Steal Tab
local StealSection = Tabs.StealTab:Section({ Title = "Steal KPDH" })
StealSection:Button({
    Title = "Steal All KPDH",
    Callback = function()
        if not anyStealRunning then
            anyStealRunning = true
            for _, players in pairs(Players:GetChildren()) do
                if players.Name ~= LPlayer.Name then
                    stealAllShits(players.Name)
                    if _G.Settings.Steal.SellAfterStealing then
                        sellAllPlayerShits()
                    end
                end
            end
            anyStealRunning = false
            Window:Notify({ Title = "Success", Desc = "Finished stealing all KPDH", Time = 3 })
        else
            Window:Notify({ Title = "Info", Desc = "Wait until the previous steal is finished.", Time = 3 })
        end
    end
})
StealSection:Toggle({
    Title = "Sell After Stealing All",
    Value = _G.Settings.Steal.SellAfterStealing,
    Callback = function(bool)
        _G.Settings.Steal.SellAfterStealing = bool
        SaveSettings()
        Window:Notify({ Title = "Success", Desc = "Selling after stealing all is now " .. (bool and "enabled" or "disabled"), Time = 3 })
    end
})
StealSection:Dropdown({
    Title = "Select KPDH",
    Values = getKPDH(),
    Value = _G.Settings.Steal.SelectedKPDH,
    Callback = function(value)
        _G.Settings.Steal.SelectedKPDH = value
        SaveSettings()
    end
})
StealSection:Button({
    Title = "Steal Specific KPDH",
    Callback = function()
        if not anyStealRunning then
            anyStealRunning = true
            local feedback, stolecount = stealSearchShit(_G.Settings.Steal.SelectedKPDH)
            if feedback then
                Window:Notify({ Title = "Success", Desc = "Stolen " .. stolecount .. " of " .. _G.Settings.Steal.SelectedKPDH, Time = 3 })
            else
                Window:Notify({ Title = "Error", Desc = "No " .. _G.Settings.Steal.SelectedKPDH .. " found.", Time = 3 })
            end
            anyStealRunning = false
        else
            Window:Notify({ Title = "Info", Desc = "Wait until the previous steal is finished.", Time = 3 })
        end
    end
})
local PlayerDropdown = StealSection:Dropdown({
    Title = "Select Player",
    Values = {},
    Value = _G.Settings.Steal.SelectedPlayer,
    Callback = function(value)
        _G.Settings.Steal.SelectedPlayer = value
        SaveSettings()
    end
})
StealSection:Button({
    Title = "Steal From Player",
    Callback = function()
        if not anyStealRunning then
            anyStealRunning = true
            if _G.Settings.Steal.SelectedPlayer then
                stealAllShits(_G.Settings.Steal.SelectedPlayer)
                if _G.Settings.Steal.SellAfterStealing then
                    sellAllPlayerShits()
                end
                Window:Notify({ Title = "Success", Desc = "Finished stealing from " .. _G.Settings.Steal.SelectedPlayer, Time = 3 })
            else
                Window:Notify({ Title = "Error", Desc = "No player selected.", Time = 3 })
            end
            anyStealRunning = false
        else
            Window:Notify({ Title = "Info", Desc = "Wait until the previous steal is finished.", Time = 3 })
        end
    end
})
StealSection:Button({
    Title = "Refresh Player Selector",
    Callback = function()
        local currentPlayers = {}
        for _, player in pairs(Players:GetChildren()) do
            if player ~= LPlayer then
                table.insert(currentPlayers, player.Name)
            end
        end
        PlayerDropdown:Clear()
        for _, playerName in ipairs(currentPlayers) do
            PlayerDropdown:Add(playerName)
        end
        Window:Notify({ Title = "Success", Desc = "Player selector refreshed.", Time = 3 })
    end
})

-- Base Tab
local BaseSection = Tabs.BaseTab:Section({ Title = "Base Management" })
BaseSection:Button({
    Title = "Sell All KPDH",
    Callback = function()
        sellAllPlayerShits()
        Window:Notify({ Title = "Success", Desc = "Sold all KPDH in your base.", Time = 3 })
    end
})
BaseSection:Toggle({
    Title = "Auto Lock Base",
    Value = _G.Settings.Base.AutoLockBase,
    Callback = function(bool)
        _G.Settings.Base.AutoLockBase = bool
        SaveSettings()
        Window:Notify({ Title = "Success", Desc = "Auto locking is now " .. (bool and "enabled" or "disabled"), Time = 3 })
        if bool then
            lockThread = task.spawn(lockBase)
        else
            if lockThread then
                task.cancel(lockThread)
                lockThread = nil
            end
        end
    end
})
BaseSection:Toggle({
    Title = "Auto Collect Cash",
    Value = _G.Settings.Base.AutoCollectCash,
    Callback = function(bool)
        _G.Settings.Base.AutoCollectCash = bool
        SaveSettings()
        Window:Notify({ Title = "Success", Desc = "Auto collect cash is now " .. (bool and "enabled" or "disabled"), Time = 3 })
        if bool then
            collectThread = task.spawn(autoCollectCash)
        else
            if collectThread then
                task.cancel(collectThread)
                collectThread = nil
            end
        end
    end
})
BaseSection:Toggle({
    Title = "Auto Disable Traps",
    Value = _G.Settings.Base.AutoDisableTraps,
    Callback = function(bool)
        _G.Settings.Base.AutoDisableTraps = bool
        SaveSettings()
        Window:Notify({ Title = "Success", Desc = "Auto disable traps is now " .. (bool and "enabled" or "disabled"), Time = 3 })
        if bool then
            trapsThread = task.spawn(DisableTraps)
        else
            if trapsThread then
                task.cancel(trapsThread)
                trapsThread = nil
            end
        end
    end
})

-- Character Tab
local CharSection = Tabs.CharTab:Section({ Title = "Character Settings" })
CharSection:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Value = _G.Settings.Character.WalkSpeed,
    Callback = function(value)
        _G.Settings.Character.WalkSpeed = value
        SaveSettings()
        getgenv().desiredWalkSpeed = value
    end
})
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LPlayer.Character and LPlayer.Character.Humanoid then
            LPlayer.Character.Humanoid.WalkSpeed = _G.Settings.Character.WalkSpeed
        end
    end)
end)
CharSection:Toggle({
    Title = "No Clip",
    Value = _G.Settings.Character.NoClip,
    Callback = function(bool)
        _G.Settings.Character.NoClip = bool
        SaveSettings()
        Window:Notify({ Title = "Success", Desc = "No clip " .. (bool and "enabled" or "disabled"), Time = 3 })
        if bool then
            local function NoclipLoop()
                if LPlayer.Character then
                    for _, child in pairs(LPlayer.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end
            end
            noClipRunning = RunService.Stepped:Connect(NoclipLoop)
        else
            if noClipRunning then
                noClipRunning:Disconnect()
                noClipRunning = nil
            end
        end
    end
})

-- Misc Tab
local MiscSection = Tabs.MiscTab:Section({ Title = "Miscellaneous" })
MiscSection:Paragraph({ Title = "Credits", Content = "Made with <3 by Flashlight" })
MiscSection:Toggle({
    Title = "Instant Proximity Prompt",
    Value = _G.Settings.Misc.InstantProximityPrompt,
    Callback = function(bool)
        _G.Settings.Misc.InstantProximityPrompt = bool
        SaveSettings()
        if bool then
            if fireproximityprompt then
                PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
                    fireproximityprompt(prompt)
                end)
                Window:Notify({ Title = "Success", Desc = "Enabled instant proximity prompt.", Time = 3 })
            else
                Window:Notify({ Title = "Error", Desc = "Your exploit is incompatible with fireproximityprompt.", Time = 3 })
            end
        else
            if PromptButtonHoldBegan then
                PromptButtonHoldBegan:Disconnect()
                PromptButtonHoldBegan = nil
            end
            Window:Notify({ Title = "Success", Desc = "Disabled instant proximity prompt.", Time = 3 })
        end
    end
})
MiscSection:Button({
    Title = "Remove Fog",
    Callback = function()
        Lighting.FogEnd = 10000
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
        Window:Notify({ Title = "Success", Desc = "Fog removed.", Time = 3 })
    end
})
MiscSection:Button({
    Title = "Server Hop",
    Callback = function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LPlayer)
            Window:Notify({ Title = "Success", Desc = "Hopping to a new server...", Time = 3 })
        else
            Window:Notify({ Title = "Error", Desc = "No available servers found.", Time = 3 })
        end
    end
})
MiscSection:Toggle({
    Title = "Disable Notifications and SFX",
    Value = _G.Settings.Misc.DisableNotificationsAndSFX,
    Callback = function(bool)
        _G.Settings.Misc.DisableNotificationsAndSFX = bool
        SaveSettings()
        LPlayer.PlayerGui.MainHud.Notifications.Visible = not bool
        LPlayer.PlayerScripts.SFX.Enabled = not bool
        Window:Notify({ Title = "Success", Desc = (bool and "Disabled" or "Enabled") .. " notifications and SFX.", Time = 3 })
    end
})

-- UI Tab
local UISection = Tabs.UITab:Section({ Title = "UI Settings" })
UISection:Button({
    Title = "Destroy UI",
    Callback = function()
        Library:Remove()
        Window:Notify({ Title = "Success", Desc = "UI destroyed.", Time = 3 })
    end
})
UISection:Paragraph({ Title = "Note", Content = "Working on adding more UI customization options." })
