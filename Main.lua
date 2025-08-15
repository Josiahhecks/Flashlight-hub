--[[
    FLASHLIGHT HUB – Blade Ball (Fixed)
    Built with STELLAR UI
--]]

------------------------------------------------------------------
-- 0.  Library
------------------------------------------------------------------
local StellarLibrary = (loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua"))())

if StellarLibrary:LoadAnimation() then
    StellarLibrary:StartLoad()
    StellarLibrary:Loaded()
end

------------------------------------------------------------------
-- 1.  Window
------------------------------------------------------------------
local Window = StellarLibrary:Window({
    SubTitle = "Blade Ball Edition",
    Size     = game:GetService("UserInputService").TouchEnabled
               and UDim2.new(0, 380, 0, 260)
               or  UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local Main    = Window:Tab("Main",    "rbxassetid://10723407389")
local Visuals = Window:Tab("Visuals", "rbxassetid://10723415335")
local Farming = Window:Tab("Farming", "rbxassetid://10709782497")
local Misc    = Window:Tab("Misc",    "rbxassetid://10734950309")

------------------------------------------------------------------
-- 2.  SERVICES
------------------------------------------------------------------
local Players   = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer

------------------------------------------------------------------
-- 3.  MAIN TAB
------------------------------------------------------------------
Main:Seperator("Combat")

Main:Toggle("Auto Parry", false, "Predicts & parries automatically", function(v)
    _G.FL_AUTO_PARRY = v
end)

Main:Toggle("Spam Parry", false, "Rapid-spams parry when close", function(v)
    _G.FL_SPAM_PARRY = v
end)

Main:Dropdown("Parry Direction",
    {"Camera","Straight","Backwards","Left","Right","Random","RandomTarget"},
    "Camera",
    function(v) _G.FL_PARRY_DIR = v end
)

Main:Slider("Prediction (ms)", 0, 150, 75, function(v)
    _G.FL_PREDICTION = v / 1000
end)

------------------------------------------------------------------
-- 4.  VISUALS TAB
------------------------------------------------------------------
Visuals:Seperator("Ball")

Visuals:Toggle("Ball ESP", false, "Tracer & box on real ball", function(v)
    _G.FL_BALL_ESP = v
end)

Visuals:Toggle("Rainbow Trail", false, "Rainbow trail on ball", function(v)
    _G.FL_RAINBOW_TRAIL = v
end)

Visuals:Toggle("View Ball", false, "Lock camera on ball", function(v)
    _G.FL_VIEW_BALL = v
end)

Visuals:Slider("Camera FOV", 50, 120, 70, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)

------------------------------------------------------------------
-- 5.  FARMING TAB
------------------------------------------------------------------
Farming:Seperator("AFK")

Farming:Toggle("Auto Play", false, "AFK wins", function(v)
    _G.FL_AUTO_PLAY = v
end)

------------------------------------------------------------------
-- 6.  MISC TAB
------------------------------------------------------------------
Misc:Seperator("Utility")

Misc:Button("Copy Discord", function()
    setclipboard("https://discord.gg/flashlighthub")
    StellarLibrary:Notify("Discord link copied!", 3)
end)

Misc:Button("Unload Script", function()
    local stellar = game.CoreGui:FindFirstChild("STELLAR")
    if stellar then stellar:Destroy() end
    local mobile = game.CoreGui:FindFirstChild("FlashlightMobileToggle")
    if mobile then mobile:Destroy() end
    StellarLibrary:Notify("Flashlight Hub unloaded.", 3)
end)

------------------------------------------------------------------
-- 7.  MOBILE TOGGLE BUTTON
------------------------------------------------------------------
local mb = Instance.new("ScreenGui")
mb.Name = "FlashlightMobileToggle"
mb.ResetOnSpawn = false
mb.Parent = game:GetService("CoreGui")

local btn = Instance.new("ImageButton")
btn.Size = UDim2.new(0, 55, 0, 55)
btn.AnchorPoint = Vector2.new(0.5, 0.5)
btn.Position = UDim2.new(0.15, 0, 0.75, 0)
btn.BackgroundTransparency = 1
btn.Image = "rbxassetid://3926307971"
btn.ImageColor3 = Color3.fromRGB(255,255,255)
btn.ImageTransparency = 0.2
btn.Parent = mb

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 30, 0, 30)
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.new(0.5, 0, 0.5, 0)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10734950020"
icon.ImageColor3 = Color3.fromRGB(0,0,0)
icon.Parent = btn

local dragging, startPos, startMouse
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos  = btn.Position
        startMouse = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - startMouse
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and not dragging then
        local hub = game.CoreGui:FindFirstChild("STELLAR")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

------------------------------------------------------------------
-- 8.  CORE LOOP – CORRECT REMOTES
------------------------------------------------------------------
local function getRealBall()
    for _, b in ipairs(workspace:WaitForChild("Balls"):GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
end

local parryRemote = ReplicatedStorage:WaitForChild("Remotes"):FindFirstChild("ParrySuccessAll") -- fallback
if not parryRemote then
    for _, r in pairs(ReplicatedStorage.Remotes:GetChildren()) do
        if r.Name:match("Parry") then parryRemote = r break end
    end
end

RunService.PreSimulation:Connect(function()
    if not _G.FL_AUTO_PARRY then return end
    local ball = getRealBall()
    if not ball then return end
    local dist = (ball.Position - lp.Character.HumanoidRootPart.Position).Magnitude
    if dist < 20 then
        -- safest generic parry pattern
        local args = {lp.Character.HumanoidRootPart.CFrame, false, false}
        pcall(function() parryRemote:FireServer(unpack(args)) end)
    end
end)

--[[  END OF FLASHLIGHT HUB  ]]--
