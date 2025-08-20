-- 99 Nights Diamond Farmer – cleaned + FPS boost + hop-proof config
-- Execute ONLY this block in a fresh executor session
------------------------------------------------------------------
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local CoreGui         = game:GetService("CoreGui")
local StarterGui      = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")

------------------------------------------------------------------
-- CONFIG (survives hops)
------------------------------------------------------------------
local CONFIG_FOLDER   = "CaoDiamondCfg"
local CONFIG_FILE     = "config.json"
local function readConfig()
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER) or Instance.new("Folder", CoreGui)
    folder.Name  = CONFIG_FOLDER
    local store  = folder:FindFirstChild(CONFIG_FILE)
    if store then return HttpService:JSONDecode(store.Value) end
    local default = {autoStart = true, showUI = true, fpsBoost = false}
    local str     = Instance.new("StringValue", folder)
    str.Name      = CONFIG_FILE
    str.Value     = HttpService:JSONEncode(default)
    return default
end
local function writeConfig(tbl)
    local folder = CoreGui:FindFirstChild(CONFIG_FOLDER)
    if folder then folder[CONFIG_FILE].Value = HttpService:JSONEncode(tbl) end
end
local CONFIG = readConfig()

------------------------------------------------------------------
-- Wait for key instances
------------------------------------------------------------------
repeat task.wait() until game:IsLoaded() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local DiamondCnt = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("DiamondCount"):WaitForChild("Count")

------------------------------------------------------------------
-- FPS BOOST
------------------------------------------------------------------
local function setFPSBoost(enable)
    game.Lighting.GlobalShadows = not enable
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
-- HOP
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
-- Duplicate character hop
------------------------------------------------------------------
task.spawn(function()
    while task.wait(1) do
        for _,char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                hopServer()
            end
        end
    end
end)

------------------------------------------------------------------
-- GUI
------------------------------------------------------------------
local ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "CleanDiamondUI"
ui.ResetOnSpawn = false

local main = Instance.new("Frame", ui)
main.Size = UDim2.new(0, 220, 0, 140)
main.Position = UDim2.new(0, 80, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Diamond Farmer"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 14

local counter = Instance.new("TextLabel", main)
counter.Size = UDim2.new(1,-10,0,25)
counter.Position = UDim2.new(0,5,0,30)
counter.BackgroundColor3 = Color3.fromRGB(0,0,0)
counter.Text = "Diamonds: --"
counter.TextColor3 = Color3.fromRGB(255,255,255)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 13
Instance.new("UICorner", counter).CornerRadius = UDim.new(0,6)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1,-10,0,22)
startBtn.Position = UDim2.new(0,5,0,60)
startBtn.BackgroundColor3 = CONFIG.autoStart and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
startBtn.Text = CONFIG.autoStart and "Stop" or "Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.white
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0.48,-5,0,22)
hideBtn.Position = UDim2.new(0,5,0,90)
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = CONFIG.showUI and "Hide" or "Show"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextColor3 = Color3.white
hideBtn.TextSize = 13
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(0.48,-5,0,22)
fpsBtn.Position = UDim2.new(0.52,5,0,90)
fpsBtn.BackgroundColor3 = CONFIG.fpsBoost and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
fpsBtn.Text = CONFIG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.white
fpsBtn.TextSize = 13
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0,6)

local function setGuiVisible(v)
    main.Visible = v
    CONFIG.showUI = v
    writeConfig(CONFIG)
    hideBtn.Text = v and "Hide" or "Show"
end
setGuiVisible(CONFIG.showUI)
setFPSBoost(CONFIG.fpsBoost)

------------------------------------------------------------------
-- GUI logic
------------------------------------------------------------------
local farming = false
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CONFIG.autoStart = farming
    writeConfig(CONFIG)
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    startBtn.Text = farming and "Stop" or "Start"
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

task.spawn(function()
    while task.wait(0.2) do
        counter.Text = "Diamonds: " .. DiamondCnt.Text
    end
end)

------------------------------------------------------------------
-- Farming loop
------------------------------------------------------------------
local function farmCycle()
    while farming do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end

        chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then hopServer() return end

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
        if proxPrompt and proxPrompt.Parent then hopServer() return end

        repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true) or not farming
        if not farming then return end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Diamond" and farming then
                Remote:FireServer(v)
            end
        end
        task.wait(1)
        hopServer()
    end
end

------------------------------------------------------------------
-- Auto-start
------------------------------------------------------------------
if CONFIG.autoStart then
    farming = true
    task.spawn(farmCycle)
end

StarterGui:SetCore("SendNotification",{Title="Info",Text="Loaded – ready to farm!",Duration=3})
