------------------------------------------------------------------
-- 99 Nights Diamond Farmer – cleaned + FPS boost + hop-proof config
------------------------------------------------------------------
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local CoreGui         = game:GetService("CoreGui")
local StarterGui      = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")

------------------------------------------------------------------
-- CONFIG (stored in CoreGui, survives TeleportService)
------------------------------------------------------------------
local CONFIG_FOLDER   = "CaoModDiamondCfg"
local CONFIG_FILE     = "config.json"

local function readConfig()
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER) or Instance.new("Folder", CoreGui)
    folder.Name  = CONFIG_FOLDER
    local store  = folder:FindFirstChild(CONFIG_FILE)
    if store then
        return HttpService:JSONDecode(store.Value)
    else
        local default = {autoStart = true, showUI = true, fpsBoost = false}
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
local Remote      = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
local Interface   = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCnt  = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")
local farming     = false
local chest, proxPrompt

------------------------------------------------------------------
-- Utility
------------------------------------------------------------------
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
                    TeleportService:TeleportToPlaceInstance(gid, srv.id, LocalPlayer)
                    while true do task.wait(0.1) end
                end
            end
        end
        task.wait(0.3)
    end
end

------------------------------------------------------------------
-- Duplicate-character hop
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        if farming then
            for _,char in pairs(workspace.Characters:GetChildren()) do
                if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                        StarterGui:SetCore("SendNotification", {Title="Info",Text="Duplicate char – hopping…",Duration=3})
                        hopServer()
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- FPS Boost toggler
------------------------------------------------------------------
local function setFPSBoost(enable)
    -- Lighting
    game.Lighting.GlobalShadows = not enable
    game.Lighting.FogEnd = enable and 100000 or 1000
    -- Workspace
    settings().Rendering.QualityLevel = enable and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21
    for _,v in ipairs(workspace:GetDescendants()) do
        if enable then
            if v:IsA("ParticleEmitter") then v.Enabled = false end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        else
            if v:IsA("ParticleEmitter") then v.Enabled = true end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
    end
    CONFIG.fpsBoost = enable
    writeConfig(CONFIG)
end

------------------------------------------------------------------
-- UI build
------------------------------------------------------------------
local ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "CaoDiamondFarmer"
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 220, 0, 135)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
task.spawn(function()
    while true do
        for h=0,1,0.01 do
            stroke.Color = Color3.fromHSV(h,1,1)
            task.wait(0.02)
        end
    end
end)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Farm Diamond | Cáo Mod"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 14

-- Diamond counter
local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1,-10,0,25)
counter.Position = UDim2.new(0,5,0,30)
counter.BackgroundColor3 = Color3.fromRGB(0,0,0)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.fromRGB(255,255,255)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0,6)

-- Buttons
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1,-10,0,22)
startBtn.Position = UDim2.new(0,5,0,60)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
startBtn.Text = CONFIG.autoStart and "Stop Farming" or "Start Farming"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0.48,-5,0,22)
hideBtn.Position = UDim2.new(0,5,0,87)
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = CONFIG.showUI and "Hide UI" or "Show UI"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextColor3 = Color3.fromRGB(255,255,255)
hideBtn.TextSize = 13
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(0.48,-5,0,22)
fpsBtn.Position = UDim2.new(0.52,5,0,87)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.fromRGB(255,255,255)
fpsBtn.TextSize = 13
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0,6)

------------------------------------------------------------------
-- GUI logic
------------------------------------------------------------------
local function setGuiVisible(vis)
    main.Visible = vis
    CONFIG.showUI = vis
    writeConfig(CONFIG)
    hideBtn.Text = vis and "Hide UI" or "Show UI"
end

setGuiVisible(CONFIG.showUI)
setFPSBoost(CONFIG.fpsBoost) -- apply on load

startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CONFIG.autoStart = farming
    writeConfig(CONFIG)
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    startBtn.Text = farming and "Stop Farming" or "Start Farming"
    if farming then
        StarterGui:SetCore("SendNotification",{Title="Info",Text="Started farming",Duration=3})
    else
        StarterGui:SetCore("SendNotification",{Title="Info",Text="Stopped farming",Duration=3})
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    setGuiVisible(not main.Visible)
end)

fpsBtn.MouseButton1Click:Connect(function()
    local new = not CONFIG.fpsBoost
    setFPSBoost(new)
    fpsBtn.BackgroundColor3 = new and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
    fpsBtn.Text = new and "FPS: ON" or "FPS: OFF"
end)

------------------------------------------------------------------
-- Update diamond counter
------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        counter.Text = "Diamonds: " .. DiamondCnt.Text
    end
end)

------------------------------------------------------------------
-- Main farming coroutine
------------------------------------------------------------------
local function farmCycle()
    while farming do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end

        chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then
            StarterGui:SetCore("SendNotification",{Title="Info",Text="Chest not found – hopping…",Duration=3})
            hopServer()
            return
        end

        LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position + Vector3.new(0,5,0)))

        repeat
            task.wait(0.1)
            local m = chest:FindFirstChild("Main")
            proxPrompt = m and m:FindFirstChild("ProximityAttachment") and m.ProximityAttachment:FindFirstChild("ProximityInteraction")
        until proxPrompt or not farming
        if not farming then return end

        local t0 = tick()
        while proxPrompt and proxPrompt.Parent and (tick()-t0) < 10 and farming do
            pcall(function() fireproximityprompt(proxPrompt) end)
            task.wait(0.2)
        end
        if proxPrompt and proxPrompt.Parent then
            StarterGui:SetCore("SendNotification",{Title="Info",Text="Prompt timeout – hopping…",Duration=3})
            hopServer()
            return
        end

        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then return end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Diamond" and farming then
                Remote:FireServer(v)
            end
        end

        StarterGui:SetCore("SendNotification",{Title="Info",Text="All diamonds taken – hopping…",Duration=3})
        task.wait(1)
        hopServer()
    end
end

------------------------------------------------------------------
-- Auto-start if enabled in config
------------------------------------------------------------------
if CONFIG.autoStart then
    farming = true
    task.spawn(farmCycle)
end

StarterGui:SetCore("SendNotification",{Title="Info",Text="Script loaded!",Duration=5})
