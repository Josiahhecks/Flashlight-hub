local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Custom UI Setup (Flashlight-inspired)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.Name = "FlashlightUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIGlow = Instance.new("UIGradient")
UIGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
})
UIGlow.Rotation = 45
UIGlow.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleLabel.Text = "Grow a Garden Autofarm"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.Neuton
TitleLabel.Parent = MainFrame

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 120, 1, -50)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -50)
ContentFrame.Position = UDim2.new(0, 120, 0, 50)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.Parent = MainFrame

local UICornerContent = Instance.new("UICorner")
UICornerContent.CornerRadius = UDim.new(0, 5)
UICornerContent.Parent = ContentFrame

-- Features
local features = {
    AutoFarmPollen = false,
    AutoCraftHoney = false,
    AutoPlantSeeds = false,
    AutoClaimRewards = false,
    SpeedBoost = false,
    Trails = false
}
local trailColor = Color3.fromRGB(255, 0, 0)
local farmSpeed = 5

-- UI Functions
local function createTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Position = UDim2.new(0, 0, 0, #TabFrame:GetChildren() * 40)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextScaled = true
    tabButton.Font = Enum.Font.Neuton
    tabButton.Parent = TabFrame
    
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = ContentFrame
    tabContent.Visible = false
    
    local UIGlowTab = Instance.new("UIGradient")
    UIGlowTab.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 255, 50))
    })
    UIGlowTab.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(ContentFrame:GetChildren()) do
            v.Visible = v == tabContent
        end
        for _, v in pairs(TabFrame:GetChildren()) do
            v.BackgroundColor3 = v == tabButton and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)
        end
    end)
    
    return tabContent
end

local function createToggle(tab, name, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 40)
    toggleFrame.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 45)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextScaled = true
    toggleLabel.Font = Enum.Font.Neuton
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.Neuton
    toggleButton.Parent = toggleFrame
    
    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 5)
    UICornerToggle.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        features[name] = not features[name]
        toggleButton.Text = features[name] and "ON" or "OFF"
        toggleButton.BackgroundColor3 = features[name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 50, 50)
        callback(features[name])
    end)
end

local function createSlider(tab, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 60)
    sliderFrame.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 65)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextScaled = true
    sliderLabel.Font = Enum.Font.Neuton
    sliderLabel.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 20)
    sliderBar.Position = UDim2.new(0, 0, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    sliderFill.Parent = sliderBar
    
    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 5)
    UICornerSlider.Parent = sliderBar
    
    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderLabel.Text = name .. ": " .. math.floor(value)
            callback(math.floor(value))
        end
    end)
end

local function createColorPicker(tab, name, callback)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, -10, 0, 100)
    pickerFrame.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 105)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Parent = tab
    
    local pickerLabel = Instance.new("TextLabel")
    pickerLabel.Size = UDim2.new(1, 0, 0, 20)
    pickerLabel.BackgroundTransparency = 1
    pickerLabel.Text = name
    pickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pickerLabel.TextScaled = true
    pickerLabel.Font = Enum.Font.Neuton
    pickerLabel.Parent = pickerFrame
    
    local rInput = Instance.new("TextBox")
    rInput.Size = UDim2.new(0.3, 0, 0, 30)
    rInput.Position = UDim2.new(0, 0, 0, 30)
    rInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    rInput.Text = "255"
    rInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rInput.TextScaled = true
    rInput.Font = Enum.Font.Neuton
    rInput.Parent = pickerFrame
    
    local gInput = Instance.new("TextBox")
    gInput.Size = UDim2.new(0.3, 0, 0, 30)
    gInput.Position = UDim2.new(0.33, 0, 0, 30)
    gInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    gInput.Text = "0"
    gInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    gInput.TextScaled = true
    gInput.Font = Enum.Font.Neuton
    gInput.Parent = pickerFrame
    
    local bInput = Instance.new("TextBox")
    bInput.Size = UDim2.new(0.3, 0, 0, 30)
    bInput.Position = UDim2.new(0.66, 0, 0, 30)
    bInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bInput.Text = "0"
    bInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    bInput.TextScaled = true
    bInput.Font = Enum.Font.Neuton
    bInput.Parent = pickerFrame
    
    local function updateColor()
        local r = tonumber(rInput.Text) or 255
        local g = tonumber(gInput.Text) or 0
        local b = tonumber(bInput.Text) or 0
        callback(Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)))
    end
    
    rInput.FocusLost:Connect(updateColor)
    gInput.FocusLost:Connect(updateColor)
    bInput.FocusLost:Connect(updateColor)
end

-- Create Tabs
local farmTab = createTab("Farming")
local craftTab = createTab("Crafting")
local rewardTab = createTab("Rewards")
local visualTab = createTab("Visuals")

-- Anti-AFK
local function antiAFK()
    while true do
        pcall(function()
            player.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
        end)
        wait(60)
    end
end
spawn(antiAFK)

-- Feature Functions
local function findPollenSources()
    local sources = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("collectable") or v.Name == "Moving_Plant") then
            table.insert(sources, v)
        end
    end
    return sources
end

local function autoFarmPollen()
    while features.AutoFarmPollen do
        local sources = findPollenSources()
        for _, source in pairs(sources) do
            humanoidRootPart.CFrame = source.CFrame + Vector3.new(0, 5, 0)
            wait(farmSpeed)
            local collectRemote = ReplicatedStorage:FindFirstChild("CollectPollen") or ReplicatedStorage:WaitForChild("CollectPollen", 5)
            if collectRemote then
                collectRemote:FireServer(source)
            end
        end
        wait(0.1)
    end
end

local function autoCraftHoney()
    while features.AutoCraftHoney do
        for _, remoteName in pairs({"HoneyCraft_SubmitPlant", "HoneyCraft_SubmitHoney", "Craft_SubmitItem"}) do
            local honeyRemote = ReplicatedStorage:FindFirstChild(remoteName) or ReplicatedStorage:WaitForChild(remoteName, 5)
            if honeyRemote then
                honeyRemote:FireServer()
            end
        end
        wait(1)
    end
end

local function autoPlantSeeds()
    while features.AutoPlantSeeds do
        local plantRemote = ReplicatedStorage:FindFirstChild("PlantSeed") or ReplicatedStorage:WaitForChild("PlantSeed", 5)
        if plantRemote then
            plantRemote:FireServer(humanoidRootPart.Position)
        end
        wait(5)
    end
end

local function autoClaimRewards()
    while features.AutoClaimRewards do
        local rewardRemote = ReplicatedStorage:FindFirstChild("Reward") or ReplicatedStorage:WaitForChild("Reward", 5)
        if rewardRemote then
            rewardRemote:FireServer()
        end
        local gui = player.PlayerGui:FindFirstChild("MainUI") or player.PlayerGui:WaitForChild("MainUI", 5)
        if gui then
            for _, button in pairs(gui:GetDescendants()) do
                if button:IsA("TextButton") and button.Name:lower():find("claim") then
                    fireclickdetector(button:FindFirstChildOfClass("ClickDetector") or button)
                end
            end
        end
        wait(3)
    end
end

local function applySpeedBoost(enabled)
    humanoid.WalkSpeed = enabled and 50 or 16
end

local trail
local function setupTrail(enabled)
    if trail then trail:Destroy() end
    if not enabled then return end
    
    trail = Instance.new("Trail")
    trail.Attachment0 = Instance.new("Attachment", humanoidRootPart)
    trail.Attachment1 = Instance.new("Attachment", humanoidRootPart)
    trail.Attachment1.Position = Vector3.new(0, -2, 0)
    trail.Color = ColorSequence.new(trailColor)
    trail.WidthScale = NumberSequence.new(1)
    trail.Lifetime = 0.5
    trail.Enabled = true
    trail.Parent = humanoidRootPart
    
    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:WaitForChild("RemoteEvent", 5)
    if remote then
        remote:FireServer("CreateTrail", humanoidRootPart, trailColor)
    end
end

-- UI Setup
createToggle(farmTab, "AutoFarmPollen", function(state)
    features.AutoFarmPollen = state
    if state then spawn(autoFarmPollen) end
end)

createSlider(farmTab, "Farm Speed", 1, 10, 5, function(value)
    farmSpeed = value
end)

createToggle(craftTab, "AutoCraftHoney", function(state)
    features.AutoCraftHoney = state
    if state then spawn(autoCraftHoney) end
end)

createToggle(farmTab, "AutoPlantSeeds", function(state)
    features.AutoPlantSeeds = state
    if state then spawn(autoPlantSeeds) end
end)

createToggle(rewardTab, "AutoClaimRewards", function(state)
    features.AutoClaimRewards = state
    if state then spawn(autoClaimRewards) end
end)

createToggle(visualTab, "SpeedBoost", function(state)
    features.SpeedBoost = state
    applySpeedBoost(state)
end)

createToggle(visualTab, "Trails", function(state)
    features.Trails = state
    setupTrail(state)
end)

createColorPicker(visualTab, "Trail Color", function(color)
    trailColor = color
    if features.Trails then
        setupTrail(true)
    end
end)

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Notify User
StarterGui:SetCore("SendNotification", {
    Title = "Flashlight Autofarm Loaded",
    Text = "Press E to toggle GUI!",
    Duration = 5
})
