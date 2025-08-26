-- // Money Hub - Converted to x2zu UI Library
-- // Original script from mm22.txt converted to x2zu structure

-- // Step 1: Load the x2zu UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUI.lua"))()

-- // Services and Variables
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ws = workspace

-- // Connection variables & flags
local con4, autoGunLoop, coinReachConn
local tweenActive = false
local autoGunBusy = false
local coinOrig = {}
local coinsReachEnabled = false

-- // Global ESP flags & loop control
local innocentActive = false
local sheriffActive = false
local murdererActive = false
local gunESPActive = false
local espLoopRunning = false

-- // Dropdown selection for coin farm method
local coinFarmMethod = "Safe Method"

-- // Helper Functions for BillboardGui
local function addBill(p)
    if p.Character and p.Character:FindFirstChild("Head") and not p.Character:FindFirstChild("NameBillboard") then
        local bb = Instance.new("BillboardGui")
        bb.Name = "NameBillboard"
        bb.Adornee = p.Character.Head
        bb.Size = UDim2.new(0, 70, 0, 30)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local tl = Instance.new("TextLabel", bb)
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.BackgroundTransparency = 1
        tl.Text = p.Name
        tl.TextColor3 = Color3.new(1, 1, 1)
        tl.TextStrokeTransparency = 0.5
        tl.Font = Enum.Font.SourceSansBold
        tl.TextScaled = true
        bb.Parent = p.Character
    end
end

local function remBill(p)
    if p.Character and p.Character:FindFirstChild("NameBillboard") then
        p.Character.NameBillboard:Destroy()
    end
end

local function removeESPHighlights()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("Highlight")
            if h then h:Destroy() end
            remBill(p)
        end
    end
end

-- // Combined ESP Loop
local function startESPLoop()
    if not espLoopRunning then
        espLoopRunning = true
        spawn(function()
            while innocentActive or sheriffActive or murdererActive do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local hasGun = p.Character:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun"))
                        local hasKnife = p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))
                        if murdererActive and hasKnife then
                            if not p.Character:FindFirstChild("Highlight") then
                                local h = Instance.new("Highlight", p.Character)
                                h.Enabled = true
                                h.FillColor = Color3.new(1, 0, 0)
                            end
                            addBill(p)
                        elseif sheriffActive and hasGun then
                            if not p.Character:FindFirstChild("Highlight") then
                                local h = Instance.new("Highlight", p.Character)
                                h.Enabled = true
                                h.FillColor = Color3.new(0, 0, 1)
                            end
                            addBill(p)
                        elseif innocentActive and not (hasGun or hasKnife) then
                            if not p.Character:FindFirstChild("Highlight") then
                                local h = Instance.new("Highlight", p.Character)
                                h.Enabled = true
                                h.FillColor = Color3.new(0, 1, 0)
                            end
                            addBill(p)
                        else
                            if p.Character:FindFirstChild("Highlight") then
                                p.Character.Highlight:Destroy()
                            end
                            remBill(p)
                        end
                    end
                end
                task.wait(0.2)
            end
            espLoopRunning = false
            removeESPHighlights()
        end)
    end
end

local function stopESPLoopIfNeeded()
    if not (innocentActive or sheriffActive or murdererActive) then
        espLoopRunning = false
        removeESPHighlights()
    end
end

-- // Step 2: Create the Main Window
local Window = Library:Window({
    Title = "Money Hub (0.1)",
    Desc = "Loading Best MM2 Script by Money",
    Icon = 4483362458,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.RightShift,
        Size = UDim2.new(0, 520, 0, 550),
        Save = {
            Enabled = true,
            Folder = "Luau",
            File = "Big Bro"
        }
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Money Hub"
    },
    Discord = {
        Enabled = true,
        Invite = "KvvHREvB",
        AutoJoin = true
    },
    KeySystem = {
        Enabled = true,
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "Join our Discord for the key: https://discord.gg/KvvHREvB",
        File = "Key",
        SaveKey = true,
        GrabKeyFromSite = true,
        Keys = {"MoneyProYe"}
    }
})

-- // Step 3: Create Tabs
local Tab = Window:Tab({ Title = "ESP", Icon = "rbxassetid://4483362458" })
local Auto = Window:Tab({ Title = "Auto", Icon = "rbxassetid://4483362458" })

-- // Initial Notification
local function Notify(title, content, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = content,
        Duration = duration or 6.5
    })
end

Notify("ESP Notice", "When ESP shows all Innocent, disable them all and enable again", 6.5)

-- // Step 4: Add Sections and Components

-- // Auto Tab
Auto:Section({ Title = "Auto" })

-- // Dropdown: Coin Farm Method Selection
Auto:Dropdown({
    Title = "Coin Farm Method",
    Values = {"Safe Method", "Not Safe Method"},
    Value = "Safe Method",
    Callback = function(selected)
        coinFarmMethod = selected
    end
})

-- // Toggle: Beta Auto Farm Coins
Auto:Toggle({
    Title = "Beta Auto Farm Coins",
    Value = false,
    Callback = function(val)
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Notify("Error", "Character or HumanoidRootPart not found!", 5)
            return
        end
        if val then
            if not coinsReachEnabled then
                Notify("Warning", "Enable 'Coins Reach' first for Auto Farm!", 5)
                return
            end
            ws.Gravity = 0
            con4 = rs.Heartbeat:Connect(function()
                local coin, dist = nil, math.huge
                for _, v in pairs(ws:GetDescendants()) do
                    if v.Name == "Coin_Server" and v:IsA("BasePart") then
                        local d = (v.Position - hrp.Position).Magnitude
                        if d < dist then
                            dist = d
                            coin = v
                        end
                    end
                end
                if coin and not tweenActive then
                    tweenActive = true
                    local dest, dur
                    if coinFarmMethod == "Safe Method" then
                        dest = coin.CFrame * CFrame.new(0, -3.5, 0)
                        dur = math.min(dist / 22, 3.5)
                    else
                        dest = coin.CFrame
                        dur = 0.1
                    end
                    local tw = ts:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = dest})
                    tw:Play()
                    task.spawn(function()
                        task.wait(0.05)
                        tweenActive = false
                    end)
                end
            end)
        else
            if con4 then
                con4:Disconnect()
                con4 = nil
            end
            ws.Gravity = 187
        end
    end
})

-- // Button: Send Murderer and Sheriff In Chat
Auto:Button({
    Title = "Send Murderer and Sheriff In Chat",
    Callback = function()
        local mNames, sNames = {}, {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local isM = p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife"))
                local isS = p.Character:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun"))
                if isM then
                    table.insert(mNames, p.Name)
                elseif isS then
                    table.insert(sNames, p.Name)
                end
            end
        end
        local mTxt = (#mNames > 0) and table.concat(mNames, ", ") or "None"
        local sTxt = (#sNames > 0) and table.concat(sNames, ", ") or "None"
        local msg = "Murderer: " .. mTxt .. " | Sheriff: " .. sTxt
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if remote and remote:FindFirstChild("SayMessageRequest") then
            remote.SayMessageRequest:FireServer(msg, "All")
        else
            Notify("Error", "Chat remote not found!", 5)
        end
    end
})

-- // Toggle: Auto Get Gun
Auto:Toggle({
    Title = "Auto Get Gun",
    Value = false,
    Callback = function(val)
        if val then
            autoGunLoop = rs.Heartbeat:Connect(function()
                if autoGunBusy then return end
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local gun
                for _, v in pairs(ws:GetDescendants()) do
                    if v.Name == "GunDrop" and v:IsA("BasePart") then
                        gun = v
                        break
                    end
                end
                if gun then
                    autoGunBusy = true
                    local oldC = hrp.CFrame
                    local d = (hrp.Position - gun.Position).Magnitude
                    local dur = d / 22
                    local tw1 = ts:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = gun.CFrame})
                    tw1:Play()
                    tw1.Completed:Connect(function()
                        wait(0.5)
                        local tw2 = ts:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = oldC})
                        tw2:Play()
                        tw2.Completed:Connect(function()
                            autoGunBusy = false
                        end)
                    end)
                end
            end)
        else
            if autoGunLoop then
                autoGunLoop:Disconnect()
                autoGunLoop = nil
            end
        end
    end
})

-- // Toggle: Coins Reach
Auto:Toggle({
    Title = "Coins Reach",
    Value = false,
    Callback = function(val)
        if val then
            coinsReachEnabled = true
            for _, v in pairs(ws:GetDescendants()) do
                if v.Name == "Coin_Server" and v:IsA("BasePart") then
                    if not coinOrig[v] then coinOrig[v] = v.Size end
                    v.Size = coinOrig[v] * 4
                end
            end
            coinReachConn = ws.DescendantAdded:Connect(function(v)
                if v.Name == "Coin_Server" and v:IsA("BasePart") then
                    if not coinOrig[v] then coinOrig[v] = v.Size end
                    v.Size = coinOrig[v] * 4
                end
            end)
        else
            coinsReachEnabled = false
            for _, v in pairs(ws:GetDescendants()) do
                if v.Name == "Coin_Server" and v:IsA("BasePart") and coinOrig[v] then
                    v.Size = coinOrig[v]
                    coinOrig[v] = nil
                end
            end
            if coinReachConn then
                coinReachConn:Disconnect()
                coinReachConn = nil
            end
        end
    end
})

-- // ESP Tab
Tab:Section({ Title = "ESP Controls" })

-- // Toggle: Innocent ESP
Tab:Toggle({
    Title = "Innocent ESP",
    Value = false,
    Callback = function(val)
        innocentActive = val
        if val then
            startESPLoop()
        else
            stopESPLoopIfNeeded()
        end
    end
})

-- // Toggle: Sheriff ESP
Tab:Toggle({
    Title = "Sheriff ESP",
    Value = false,
    Callback = function(val)
        sheriffActive = val
        if val then
            startESPLoop()
        else
            stopESPLoopIfNeeded()
        end
    end
})

-- // Toggle: Murderer ESP
Tab:Toggle({
    Title = "Murderer ESP",
    Value = false,
    Callback = function(val)
        murdererActive = val
        if val then
            startESPLoop()
        else
            stopESPLoopIfNeeded()
        end
    end
})

-- // Toggle: Gun ESP
Tab:Toggle({
    Title = "Gun ESP",
    Value = false,
    Callback = function(val)
        gunESPActive = val
        if val then
            spawn(function()
                while gunESPActive do
                    for _, v in pairs(ws:GetDescendants()) do
                        if v.Name == "GunDrop" and v:IsA("BasePart") then
                            if not v:FindFirstChild("Highlight") then
                                local h = Instance.new("Highlight", v)
                                h.FillColor = Color3.new(0, 0, 1)
                                h.Enabled = true
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            for _, v in pairs(ws:GetDescendants()) do
                if v.Name == "GunDrop" and v:IsA("BasePart") and v:FindFirstChild("Highlight") then
                    v.Highlight:Destroy()
                end
            end
        end
    end
})

-- // Load Configuration
Library:LoadConfig("Luau", "Big Bro")
