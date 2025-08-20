------------------------------------------------------------------
-- 99 Nights Diamond Farmer – guaranteed load + hop-proof config
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
local CONFIG_FOLDER = "DiamondCfg"
local CONFIG_FILE   = "cfg.json"
local function readConfig()
    local f = CoreGui:FindFirstChild(CONFIG_FOLDER) or Instance.new("Folder", CoreGui)
    f.Name = CONFIG_FOLDER
    local s = f:FindFirstChild(CONFIG_FILE)
    if s then return HttpService:JSONDecode(s.Value) end
    local d = {autoStart = false, showUI = true, fpsBoost = false}
    local v = Instance.new("StringValue", f); v.Name = CONFIG_FILE
    v.Value = HttpService:JSONEncode(d)
    return d
end
local function writeConfig(tbl)
    local f = CoreGui:FindFirstChild(CONFIG_FOLDER)
    if f then f[CONFIG_FILE].Value = HttpService:JSONEncode(tbl) end
end
local CFG = readConfig()

------------------------------------------------------------------
-- FPS BOOST
------------------------------------------------------------------
local function setFPSBoost(enable)
    game.Lighting.GlobalShadows = not enable
    settings().Rendering.QualityLevel = enable and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level21
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ParticleEmitter") then o.Enabled = not enable end
        if o:IsA("Decal") or o:IsA("Texture") then o.Transparency = enable and 1 or 0 end
    end
    CFG.fpsBoost = enable
    writeConfig(CFG)
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
-- GUI
------------------------------------------------------------------
local ui = Instance.new("ScreenGui", CoreGui)
ui.Name = "DiamondFarmerUI"
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
counter.Font = Enum.Font.GothamBold
counter.TextColor3 = Color3.fromRGB(255,255,255)
counter.TextSize = 14
Instance.new("UICorner", counter).CornerRadius = UDim.new(0,6)

local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(1,-10,0,22)
startBtn.Position = UDim2.new(0,5,0,60)
startBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
startBtn.Text = "Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.white
startBtn.TextSize = 13
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local hideBtn = Instance.new("TextButton", main)
hideBtn.Size = UDim2.new(0.48,-5,0,22)
hideBtn.Position = UDim2.new(0,5,0,90)
hideBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
hideBtn.Text = "Hide"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextColor3 = Color3.white
hideBtn.TextSize = 13
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,6)

local fpsBtn = Instance.new("TextButton", main)
fpsBtn.Size = UDim2.new(0.48,-5,0,22)
fpsBtn.Position = UDim2.new(0.52,5,0,90)
fpsBtn.BackgroundColor3 = CFG.fpsBoost and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
fpsBtn.Text = CFG.fpsBoost and "FPS: ON" or "FPS: OFF"
fpsBtn.Font = Enum.Font.GothamBold
fpsBtn.TextColor3 = Color3.white
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(0,6)

local function setVis(v)
    main.Visible = v
    CFG.showUI = v
    writeConfig(CFG)
    hideBtn.Text = v and "Hide" or "Show"
end
setVis(CFG.showUI)
setFPSBoost(CFG.fpsBoost)

------------------------------------------------------------------
-- GUI LOGIC
------------------------------------------------------------------
local farming = false
startBtn.MouseButton1Click:Connect(function()
    farming = not farming
    CFG.autoStart = farming
    writeConfig(CFG)
    startBtn.BackgroundColor3 = farming and Color3.fromRGB(150,0,0) or Color3.fromRGB(0,150,0)
    startBtn.Text = farming and "Stop" or "Start"
end)

hideBtn.MouseButton1Click:Connect(function()
    setVis(not main.Visible)
end)

fpsBtn.MouseButton1Click:Connect(function()
    local new = not CFG.fpsBoost
    setFPSBoost(new)
    fpsBtn.BackgroundColor3 = new and Color3.fromRGB(0,150,150) or Color3.fromRGB(90,90,90)
    fpsBtn.Text = new and "FPS: ON" or "FPS: OFF"
end)

task.spawn(function()
    local cnt = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("DiamondCount"):WaitForChild("Count")
    while task.wait(0.2) do
        counter.Text = "Diamonds: " .. cnt.Text
    end
end)

------------------------------------------------------------------
-- FARMING LOOP
------------------------------------------------------------------
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local function farm()
    while farming do
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then repeat task.wait() root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") until root end

        local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest") or workspace.Items:FindFirstChild("Chest")
        if not chest then hopServer() return end

        root.CFrame = chest:GetPivot() + Vector3.new(0,5,0)

        local proxPrompt
        repeat
            task.wait(0.1)
            local m = chest:FindFirstChild("Main")
            proxPrompt = m and m:FindFirstChild("ProximityAttachment") and m.ProximityAttachment:FindFirstChild("ProximityInteraction")
        until proxPrompt or not farming
        if not farming then return end

        local t0 = tick()
        while proxPrompt and proxPrompt.Parent and (tick()-t0)<10 and farming do
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
-- AUTO-START
------------------------------------------------------------------
if CFG.autoStart then
    farming = true
    task.spawn(farm)
end

StarterGui:SetCore("SendNotification",{Title="Diamond Farmer",Text="Loaded – press Start when ready!",Duration=5})
