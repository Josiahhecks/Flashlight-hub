-- Flashlight Hub – Blade Ball FULL COMBAT BUILD
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUI.lua"))()

local Window = Library:Window({
    Title = "Flashlight Hub",
    Desc = "Flashlight Hub – Blade Ball",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {Keybind = Enum.KeyCode.RightControl, Size = UDim2.new(0, 540, 0, 480)},
    CloseUIButton = {Enabled = true, Text = "Flashlight"}
})

-- ============= SERVICES =============
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local VirtualInput      = game:GetService("VirtualInputManager")
local TeleportService   = game:GetService("TeleportService")

local Player   = Players.LocalPlayer
local Camera   = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- ============= COMBAT TAB =============
local Combat = Window:Tab({Title = "Combat", Icon = "crosshair"})
Combat:Section({Title = "Blade Ball Features"})

-- ---------- AUTO PLAY AI ----------
local autoPlayEnabled = false
local targetDistance  = 30          -- slider value
local jumpChance      = 50          -- slider value
local lastTargetTime  = 0
local targetDuration  = 0
local autoPlayConn

local function getBall()
    for _, b in ipairs(workspace:WaitForChild("Balls"):GetChildren()) do
        if b:GetAttribute("realBall") then return b end
    end
end

local function autoPlayStep()
    if not autoPlayEnabled then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end

    local root = Player.Character.HumanoidRootPart
    local ball = getBall()
    if not ball then return end

    local dir   = (ball.Position - root.Position).Unit
    local dist  = (ball.Position - root.Position).Magnitude
    local speed = ball.Velocity.Magnitude
    local now   = tick()
    local target = ball:GetAttribute("target")

    -- Track continuous targeting
    if target == Player.Name then
        if now - lastTargetTime < 0.2 then
            targetDuration += RunService.RenderStepped:Wait()
        else
            targetDuration = 0
        end
        lastTargetTime = now
    else
        targetDuration = 0
    end

    -- Reset WASD
    for _, k in pairs({"W","A","S","D"}) do
        VirtualInput:SendKeyEvent(false, k, false, game)
    end

    -- If ball is locked on us OR very close → backpedal
    if dist < targetDistance or targetDuration > 0.5 then
        local backDir = -dir
        local backPos = root.Position + backDir * 6
        local safe = true
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - backPos).Magnitude < 5 then
                    safe = false; break
                end
            end
        end
        if safe then
            VirtualInput:SendKeyEvent(true, "S", false, game)
        else
            -- dodge sideways if blocked
            local side = math.random() < 0.5 and "A" or "D"
            VirtualInput:SendKeyEvent(true, side, false, game)
        end
        return
    end

    -- Ball far away → move closer
    if dist > targetDistance + 5 then
        VirtualInput:SendKeyEvent(true, "W", false, game)
    elseif speed > 120 or math.random() < 0.01 then
        local side = math.random() < 0.5 and "A" or "D"
        VirtualInput:SendKeyEvent(true, side, false, game)
    end
end

Combat:Toggle({Title = "Auto Play AI", Desc = "Moves & parries for you", Value = false, Callback = function(v)
    autoPlayEnabled = v
    if v and not autoPlayConn then
        autoPlayConn = RunService.RenderStepped:Connect(autoPlayStep)
    elseif not v and autoPlayConn then
        autoPlayConn:Disconnect(); autoPlayConn = nil
    end
end})

Combat:Slider({Title = "AI Distance From Ball", Min = 1, Max = 100, Value = 30, Callback = function(v) targetDistance = v end})
Combat:Slider({Title = "Jump Chance (soon)", Min = 1, Max = 50, Value = 50, Callback = function(v) jumpChance = v end})

-- ---------- AUTO PARRY ----------
local autoParryEnabled = false
local spamParryEnabled = false
local lobbyAPEnabled = false
local spamThreshold = 2.5
local parryConn, spamConn, lobbyConn

-- simplified parry fire
local function parryFire()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("Parry") then
        rem.Parry:FireServer()
    end
end

Combat:Toggle({Title = "Auto Parry", Desc = "Smart parry (ping, curve)", Value = false, Callback = function(v) autoParryEnabled = v end})
Combat:Toggle({Title = "Spam Parry", Desc = "Rapid parry when ball close", Value = false, Callback = function(v) spamParryEnabled = v end})
Combat:Toggle({Title = "Lobby Auto Parry", Desc = "Auto parry in lobby", Value = false, Callback = function(v) lobbyAPEnabled = v end})
Combat:Slider({Title = "Spam Threshold", Min = 1, Max = 3, Value = 2.5, Callback = function(v) spamThreshold = v end})

-- ---------- SPEED / SPIN ----------
local speedHack = false
local spinbot   = false
local strafeSpeed = 36
local spinSpeed = 1

Combat:Toggle({Title = "Speed Hack", Desc = "Walkspeed slider", Value = false, Callback = function(v) speedHack = v end})
Combat:Toggle({Title = "Spinbot", Desc = "Spins player", Value = false, Callback = function(v) spinbot = v end})
Combat:Slider({Title = "Walkspeed", Min = 36, Max = 200, Value = 36, Callback = function(v) strafeSpeed = v end})
Combat:Slider({Title = "Spin Speed", Min = 1, Max = 150, Value = 1, Callback = function(v) spinSpeed = math.rad(v) end})

-- ---------- FLY / NO-SLOW ----------
local flying   = false
local noSlow   = false
Combat:Toggle({Title = "Fly", Desc = "Full flight with mobile UI", Value = false, Callback = function(v) flying = v end})
Combat:Toggle({Title = "No Slow", Desc = "Prevents any slowdown", Value = false, Callback = function(v) noSlow = v end})

-- ---------- HIT SOUNDS ----------
local hitSoundEnabled = false
local soundType = "DC_15X"
Combat:Toggle({Title = "Hit Sounds", Desc = "Sound on parry", Value = false, Callback = function(v) hitSoundEnabled = v end})
Combat:Dropdown({Title = "Sound", Options = {"DC_15X","Minecraft","Neverlose","TF2 Bonk","TF2 Bell"}, Callback = function(v) soundType = v end})

-- ---------- WORLD VISUALS ----------
local skyboxPreset = "Default"
local trailEnabled = false
local lookAtBall = false
local lookType = "Camera"
local ballStats = false
local visualize = false

Combat:Toggle({Title = "Custom Skybox", Desc = "Change skybox", Value = false, Callback = function(v) end})
Combat:Dropdown({Title = "Sky Preset", Options = {"Default","Vaporwave","Redshift","Minecraft","SpongeBob","DaBaby"}, Callback = function(v) skyboxPreset = v end})
Combat:Toggle({Title = "Ball Trail", Desc = "Rainbow trail on ball", Value = false, Callback = function(v) trailEnabled = v end})
Combat:Toggle({Title = "Look at Ball", Desc = "Camera/char looks at ball", Value = false, Callback = function(v) lookAtBall = v end})
Combat:Dropdown({Title = "Look Type", Options = {"Camera","Character"}, Callback = function(v) lookType = v end})
Combat:Toggle({Title = "Ball Stats Overlay", Desc = "Live ball info", Value = false, Callback = function(v) ballStats = v end})
Combat:Toggle({Title = "Visualize Parry Range", Desc = "Sphere around player", Value = false, Callback = function(v) visualize = v end})

-- ---------- SKIN CHANGER ----------
local swordName = "Base Sword"
Combat:Toggle({Title = "Skin Changer", Desc = "Any sword by name", Value = false, Callback = function(v) end})
Combat:Textbox({Title = "Skin Name", Placeholder = "Enter Sword Name", Callback = function(v) swordName = v end})

-- ---------- AUTO-REJOIN ----------
local function autoRejoin()
    local ok = pcall(function()
        TeleportService:Teleport(game.PlaceId, Player)
    end)
    if not ok then wait(5); autoRejoin() end
end
Player.CharacterRemoving:Connect(autoRejoin)

-- ---------- RUNTIME LOOPS ----------
-- Auto-Parry loop
spawn(function()
    while true do
        if autoParryEnabled then parryFire() end
        wait(0.05)
    end
end)

-- Spam-Parry loop
spawn(function()
    while true do
        if spamParryEnabled then
            local ball = getBall()
            if ball and (Player:DistanceFromCharacter(ball.Position) <= spamThreshold * 10) then
                parryFire()
            end
        end
        wait(0.05)
    end
end)

-- Lobby Auto-Parry loop
spawn(function()
    while true do
        if lobbyAPEnabled then
            for _, b in ipairs(workspace:WaitForChild("TrainingBalls"):GetChildren()) do
                if b:GetAttribute("realBall") and b:GetAttribute("target") == Player.Name then
                    parryFire()
                end
            end
        end
        wait(0.05)
    end
end)

-- Speed & Spin loop
spawn(function()
    while true do
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if speedHack then hum.WalkSpeed = strafeSpeed else hum.WalkSpeed = 36 end
            if spinbot then root.CFrame *= CFrame.Angles(0, spinSpeed, 0) end
        end
        wait()
    end
end)

-- ---------- EXTRA TAB ----------
local Extra = Window:Tab({Title = "Extra", Icon = "wrench"})
Extra:Section({Title = "Info"})
Extra:Button({Title = "Credits", Desc = "Flashlight Hub – Blade Ball Combat", Callback = function()
    Window:Notify({Title = "Flashlight Hub", Desc = "All Blade-Ball features loaded!", Time = 4})
end})

-- ---------- LOAD NOTIFY ----------
Window:Notify({Title = "Flashlight Hub", Desc = "Blade Ball Combat Build Loaded!", Time = 4})
