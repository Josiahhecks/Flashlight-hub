-- Gem Farmer for 99 Nights – cleaned UI + hop-proof config
-- Services
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

------------------------------------------------------------------
-- CONFIG (persists across server hops)
------------------------------------------------------------------
local CONFIG_FOLDER   = "FlashlightHub_GemConfig"
local CONFIG_FILE     = "config.json"

local function readConfig()
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER) or Instance.new("Folder", CoreGui)
    folder.Name  = CONFIG_FOLDER
    local store  = folder:FindFirstChild(CONFIG_FILE)

    if store then
        return HttpService:JSONDecode(store.Value)
    else
        local default = {autoStart=true, visible=true}
        local str     = Instance.new("StringValue", folder)
        str.Name      = CONFIG_FILE
        str.Value     = HttpService:JSONEncode(default)
        return default
    end
end

local function writeConfig(tbl)
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER)
    if folder then
        folder[CONFIG_FILE].Value = HttpService:JSONEncode(tbl)
    end
end

local CONFIG = readConfig()

------------------------------------------------------------------
-- Remote & variables
------------------------------------------------------------------
local gemRemote   = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents") and
                    game:GetService("ReplicatedStorage").RemoteEvents:FindFirstChild("RequestTakeDiamonds")
local interface   = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local gemLabel    = interface:WaitForChild("DiamondCount"):WaitForChild("Count")
local startTime   = tick()
local farming     = false
local chest, proxPrompt

------------------------------------------------------------------
-- Utility
------------------------------------------------------------------
local function formatTime(s)
    local h = math.floor(s/3600)
    local m = math.floor((s%3600)/60)
    local sec = math.floor(s%60)
    return string.format("%02d:%02d:%02d",h,m,sec)
end

local function hopServer()
    local gid = game.PlaceId
    while true do
        local ok,body = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/"..gid.."/servers/Public?sortOrder=Asc&limit=100")
        end)
        if ok then
            local data = HttpService:JSONDecode(body)
            for _,srv in ipairs(data.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    -- teleport will carry the config folder
                    TeleportService:TeleportToPlaceInstance(gid, srv.id, LocalPlayer)
                    while true do task.wait(0.1) end
                end
            end
        end
        task.wait(0.3)
    end
end

------------------------------------------------------------------
-- Duplicate-character detector
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if farming then
            for _,c in pairs(workspace.Characters:GetChildren()) do
                if c:FindFirstChild("Humanoid") and c:FindFirstChild("HumanoidRootPart") then
                    if c.Humanoid.DisplayName == LocalPlayer.DisplayName then
                        StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Duplicate char – hopping…",Duration=3})
                        hopServer()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- GUI BUILD
------------------------------------------------------------------
local ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "FlashlightHub_GemUI"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background
local bg = Instance.new("Frame", ui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(10,10,20)
bg.BorderSizePixel = 0
local g = Instance.new("UIGradient", bg)
g.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10,10,20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25,25,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,20))
}
g.Rotation = 45
bg.BackgroundTransparency = 0.55

-- Main card
local card = Instance.new("Frame", ui)
card.Size = UDim2.new(0.36,0,0.32,0)
card.Position = UDim2.new(0.32,0,0.34,0)
card.BackgroundColor3 = Color3.fromRGB(30,30,40)
card.BorderSizePixel = 0
Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", card)
stroke.Thickness = 3
task.spawn(function()
    while true do
        for h=0,1,0.01 do
            stroke.Color = Color3.fromHSV(h,1,1)
            task.wait(0.02)
        end
    end
end)

-- Title
local title = Instance.new("TextLabel", card)
title.Size = UDim2.new(1,0,0.25,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.Text = "🔦 Flashlight Hub"
title.TextColor3 = Color3.fromRGB(0,255,255)
title.TextSize = 22
title.TextStrokeTransparency = 0.5

-- Gem counter
local gems = Instance.new("TextLabel", card)
gems.Size = UDim2.new(1,-20,0.22,0)
gems.Position = UDim2.new(0,10,0.28,0)
gems.BackgroundColor3 = Color3.fromRGB(20,20,30)
gems.BorderSizePixel = 0
gems.Text = "Gems: --"
gems.Font = Enum.Font.SourceSansBold
gems.TextColor3 = Color3.fromRGB(255,255,0)
gems.TextSize = 18
Instance.new("UICorner", gems).CornerRadius = UDim.new(0,8)

-- Runtime
local runtime = Instance.new("TextLabel", card)
runtime.Size = UDim2.new(1,-20,0.22,0)
runtime.Position = UDim2.new(0,10,0.52,0)
runtime.BackgroundColor3 = Color3.fromRGB(20,20,30)
runtime.BorderSizePixel = 0
runtime.Text = "Runtime: 00:00:00"
runtime.Font = Enum.Font.SourceSansBold
runtime.TextColor3 = Color3.fromRGB(0,255,255)
runtime.TextSize = 18
Instance.new("UICorner", runtime).CornerRadius = UDim.new(0,8)

-- Settings panel
local set = Instance.new("Frame", ui)
set.Size = UDim2.new(0.2,0,0.22,0)
set.Position = UDim2.new(0.78,0,0.75,0)
set.BackgroundColor3 = Color3.fromRGB(30,30,40)
set.BorderSizePixel = 0
set.Active = true
set.Draggable = true
Instance.new("UICorner", set).CornerRadius = UDim.new(0,12)
local stroke2 = Instance.new("UIStroke", set)
stroke2.Thickness = 2
task.spawn(function()
    while true do
        for h=0,1,0.01 do
            stroke2.Color = Color3.fromHSV(h,1,1)
            task.wait(0.03)
        end
    end
end)

-- Buttons
local startBtn = Instance.new("TextButton", set)
startBtn.Size = UDim2.new(1,-10,0.35,0)
startBtn.Position = UDim2.new(0,5,0.08,0)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextColor3 = Color3.fromRGB(255,255,0)
startBtn.TextSize = 15
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

local hideBtn = Instance.new("TextButton", set)
hideBtn.Size = UDim2.new(1,-10,0.35,0)
hideBtn.Position = UDim2.new(0,5,0.48,0)
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = CONFIG.visible and "Hide GUI" or "Show GUI"
hideBtn.Font = Enum.Font.SourceSansBold
hideBtn.TextColor3 = Color3.fromRGB(255,255,255)
hideBtn.TextSize = 15
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,8)

------------------------------------------------------------------
-- GUI logic
------------------------------------------------------------------
local function setGuiVisible(v)
    card.Visible = v
    set.Visible = true -- always keep the mini-panel
    CONFIG.visible = v
    writeConfig(CONFIG)
    hideBtn.Text = v and "Hide GUI" or "Show GUI"
end

setGuiVisible(CONFIG.visible)

startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CONFIG.autoStart = farming
    writeConfig(CONFIG)
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
    startBtn.Text = farming and "Stop Farming" or "Start Farming"
    if farming then
        StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Started farming",Duration=3})
        task.spawn(function()
            while farming do
                -- farming loop body (unchanged)
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                end
                chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
                if not chest then hopServer() return end
                LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position+Vector3.new(0,5,0)))
                repeat task.wait(0.1)
                    local m = chest:FindFirstChild("Main")
                    proxPrompt = m and m:FindFirstChild("ProximityAttachment") and m.ProximityAttachment:FindFirstChild("ProximityInteraction")
                until proxPrompt or not farming
                if not farming then return end
                local t0=tick()
                while proxPrompt and proxPrompt.Parent and (tick()-t0)<10 and farming do
                    pcall(function() fireproximityprompt(proxPrompt) end)
                    task.wait(0.2)
                end
                if proxPrompt and proxPrompt.Parent then hopServer() return end
                repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
                if not farming then return end
                for _,v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v.Name=="Diamond" and farming and gemRemote then
                        pcall(function() gemRemote:FireServer(v) end)
                    end
                end
                StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Gems collected – hopping…",Duration=3})
                task.wait(1)
                hopServer()
            end
        end)
    else
        StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Stopped farming",Duration=3})
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    setGuiVisible(not card.Visible)
end)

-- Update labels
task.spawn(function()
    while task.wait(0.2) do
        gems.Text = "Gems: "..(gemLabel.Text or "N/A")
        runtime.Text = "Runtime: "..formatTime(tick()-startTime)
    end
end)

------------------------------------------------------------------
-- Auto-start if config says so
------------------------------------------------------------------
if CONFIG.autoStart then
    farming = true
    startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    startBtn.Text = "Stop Farming"
    StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Auto-starting farming…",Duration=3})
    task.wait(0.5)
    startBtn.MouseButton1Click:Fire() -- trigger the farming coroutine
end

StarterGui:SetCore("SendNotification",{Title="Flashlight Hub",Text="Script loaded!",Duration=5})
