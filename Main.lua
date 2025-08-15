--[[
    FLASHLIGHT HUB  –  Blade Ball Edition
    Built with the STELLAR UI library
    Loader → Paste anywhere and execute
--]]

--// 0.  Load STELLAR UI Library (unchanged)
local StellarLibrary = (loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua")))()

--// 1.  Loader animation (optional)
if StellarLibrary:LoadAnimation() then
    StellarLibrary:StartLoad()
end
if StellarLibrary:LoadAnimation() then
    StellarLibrary:Loaded()
end

--// 2.  Create Window
local Window = StellarLibrary:Window({
    SubTitle = "Blade Ball Edition",
    Size = game:GetService("UserInputService").TouchEnabled and UDim2.new(0, 380, 0, 260) or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

--// 3.  Tabs
local Main    = Window:Tab("Main",    "rbxassetid://10723407389")
local Visuals = Window:Tab("Visuals", "rbxassetid://10723415335")
local Farming = Window:Tab("Farming", "rbxassetid://10709782497")
local Misc    = Window:Tab("Misc",    "rbxassetid://10734950309")

--// 4.  MAIN TAB
Main:Seperator("Combat")
Main:Toggle("Auto Parry", false, "Predicts incoming ball and parries automatically.", function(v)
    getgenv().FL_AUTO_PARRY = v
end)
Main:Toggle("Spam Parry", false, "Rapidly spams parry when ball is close.", function(v)
    getgenv().FL_SPAM_PARRY = v
end)
Main:Dropdown("Parry Direction", {"Camera","Straight","Backwards","Left","Right","Random","RandomTarget"}, "Camera", function(v)
    getgenv().FL_PARRY_DIR = v
end)
Main:Slider("Prediction (ms)", 0, 150, 75, function(v)
    getgenv().FL_PREDICTION = v/1000
end)

--// 5.  VISUALS TAB
Visuals:Seperator("Ball")
Visuals:Toggle("Ball ESP", false, "Tracer & box around the real ball.", function(v)
    getgenv().FL_BALL_ESP = v
end)
Visuals:Toggle("Rainbow Trail", false, "Adds a rainbow trail to the ball.", function(v)
    getgenv().FL_RAINBOW_TRAIL = v
end)
Visuals:Toggle("View Ball", false, "Locks camera on the ball.", function(v)
    getgenv().FL_VIEW_BALL = v
end)
Visuals:Slider("Camera FOV", 50, 120, 70, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)

--// 6.  FARMING TAB
Farming:Seperator("AFK")
Farming:Toggle("Auto Play", false, "Wins rounds automatically.", function(v)
    getgenv().FL_AUTO_PLAY = v
end)

--// 7.  MISC TAB
Misc:Seperator("UI")
Misc:Button("Copy Discord", function()
    setclipboard("https://discord.gg/flashlighthub")
    StellarLibrary:Notify("Discord link copied!", 3)
end)
Misc:Button("Unload Script", function()
    for _,c in pairs(getconnections(game:GetService("UserInputService").InputBegan)) do
        c:Disable()
    end
    game:GetService("CoreGui"):FindFirstChild("STELLAR"):Destroy()
    game:GetService("CoreGui"):FindFirstChild("FlashlightMobileToggle"):Destroy()
end)

--// 8.  Mobile-friendly floating button (draggable)
local UIS = game:GetService("UserInputService")
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

-- Drag logic
local dragging, startPos, startMouse
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = btn.Position
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

-- Tap to toggle
btn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and not dragging then
        local hub = game.CoreGui:FindFirstChild("STELLAR")
        if hub then hub.Enabled = not hub.Enabled end
    end
end)

--// 9.  CORE LOGIC (tiny example loop)
task.spawn(function()
    while true do task.wait()
        if getgenv().FL_AUTO_PARRY then
            -- example: fire parry when ball distance < 20
            local ball = workspace:FindFirstChild("Balls") and workspace.Balls:FindFirstChildWhichIsA("BasePart")
            if ball and (ball.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
                game:GetService("ReplicatedStorage").Remotes.ParryRequest:FireServer()
            end
        end
    end
end)

--// End of FLASHLIGHT HUB
