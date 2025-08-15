local x2zuLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua"))()

local Window = x2zuLibrary:CreateWindow({Title = "FLASHLIGHT", SubTitle = "Blade Ball Edition"})

local MainTab = Window:AddTab({Title = "Main", Icon = "sword"})
local VisualsTab = Window:AddTab({Title = "Visuals", Icon = "eye"})
local FarmingTab = Window:AddTab({Title = "Farming", Icon = "wheat"})
local MiscTab = Window:AddTab({Title = "Misc", Icon = "settings"})

local Options = x2zuLibrary.Options

local Connections = {}

local AutoParryEnabled = false
local SpamParryEnabled = false
local SelectedParryDirection = "Camera"
local PredictionMS = 0

local BallESPEnabled = false
local RainbowTrailEnabled = false
local ViewBallEnabled = false
local CameraFOV = 70

local AutoPlayEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

local PropertyChangeOrder = {}
local HashOne, HashTwo, HashThree
local Parry_Key
local Parry = function() end

do
    for Index, Value in next, getgc() do
        if typeof(Value) == "function" and islclosure(Value) and debug.info(Value, "s"):find("SwordsController") then
            if debug.info(Value, "l") == 276 then
                HashOne = getconstant(Value, 62)
                HashTwo = getconstant(Value, 64)
                HashThree = getconstant(Value, 65)
            end
        end 
    end

    for Index, Object in next, game:GetDescendants() do
        if Object:IsA("RemoteEvent") and string.find(Object.Name, "\n") then
            Object.Changed:Once(function()
                table.insert(PropertyChangeOrder, Object)
            end)
        end
    end

    repeat task.wait() until #PropertyChangeOrder == 3

    local ShouldPlayerJump = PropertyChangeOrder[1]
    local MainRemote = PropertyChangeOrder[2]
    local GetOpponentPosition = PropertyChangeOrder[3]

    for Index, Value in pairs(getconnections(Players.LocalPlayer.PlayerGui.Hotbar.Block.Activated)) do
        if Value and Value.Function and not iscclosure(Value.Function) then
            for Index2, Value2 in pairs(getupvalues(Value.Function)) do
                if type(Value2) == "function" then
                    Parry_Key = getupvalue(getupvalue(Value2, 2), 17)
                end
            end
        end
    end

    Parry = function(...)
        ShouldPlayerJump:FireServer(HashOne, Parry_Key, ...)
        MainRemote:FireServer(HashTwo, Parry_Key, ...)
        GetOpponentPosition:FireServer(HashThree, Parry_Key, ...)
    end
end

local Auto_Parry = {}

function Auto_Parry.Get_Ball()
    for _, Instance in pairs(Workspace.Balls:GetChildren()) do
        if Instance:GetAttribute('realBall') then
            return Instance
        end
    end
end

function Auto_Parry.Parry_Data(Parry_Type)
    local Camera = Workspace.CurrentCamera
    local Mouse_Location = UserInputService:GetMouseLocation()
    local Vector2_Mouse_Location = {Mouse_Location.X, Mouse_Location.Y}
    local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    if isMobile then
        Vector2_Mouse_Location = {Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2}
    end

    local Events = {}
    for _, v in pairs(Workspace.Alive:GetChildren()) do
        if v ~= Player.Character then
            local worldPos = v.PrimaryPart.Position
            local screenPos = Camera:WorldToScreenPoint(worldPos)
            Events[tostring(v)] = screenPos
        end
    end

    if Parry_Type == 'Camera' then
        return {0, Camera.CFrame, Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'Backwards' then
        local Backwards_Direction = Camera.CFrame.LookVector * -10000
        Backwards_Direction = Vector3.new(Backwards_Direction.X, 0, Backwards_Direction.Z)
        return {0, CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Backwards_Direction), Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'Straight' then
        local Closest = nil
        local MinDist = math.huge
        for _, v in pairs(Workspace.Alive:GetChildren()) do
            if v ~= Player.Character then
                local Dist = (Player.Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
                if Dist < MinDist then
                    MinDist = Dist
                    Closest = v
                end
            end
        end
        return {0, CFrame.new(Player.Character.PrimaryPart.Position, Closest and Closest.PrimaryPart.Position or Camera.CFrame.Position), Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'Random' then
        return {0, CFrame.new(Camera.CFrame.Position, Vector3.new(math.random(-4000, 4000), math.random(-4000, 4000), math.random(-4000, 4000))), Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'Left' then
        local Left_Direction = Camera.CFrame.RightVector * -10000
        return {0, CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Left_Direction), Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'Right' then
        local Right_Direction = Camera.CFrame.RightVector * 10000
        return {0, CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Right_Direction), Events, Vector2_Mouse_Location}
    elseif Parry_Type == 'RandomTarget' then
        local candidates = {}
        for _, v in pairs(Workspace.Alive:GetChildren()) do
            if v ~= Player.Character and v.PrimaryPart then
                local screenPos, isOnScreen = Camera:WorldToScreenPoint(v.PrimaryPart.Position)
                if isOnScreen then
                    table.insert(candidates, {
                        character = v,
                        screenXY = {screenPos.X, screenPos.Y}
                    })
                end
            end
        end
        if #candidates > 0 then
            local pick = candidates[math.random(1, #candidates)]
            local lookCFrame = CFrame.new(Player.Character.PrimaryPart.Position, pick.character.PrimaryPart.Position)
            return {0, lookCFrame, Events, pick.screenXY}
        else
            return {0, Camera.CFrame, Events, {Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2}}
        end
    end
end

function Auto_Parry.Parry(Parry_Type)
    local Data = Auto_Parry.Parry_Data(Parry_Type)
    if Data then
        task.wait(PredictionMS / 1000)
        Parry(Data[1], Data[2], Data[3], Data[4])
    end
end

local MainSection = MainTab:AddSection({Title = "Parry Controls"})

MainSection:AddToggle("AutoParry", {
    Title = "Auto Parry",
    Default = false,
    Callback = function(Value)
        AutoParryEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not AutoParryEnabled then return end
                local Ball = Auto_Parry.Get_Ball()
                if Ball and Player.Character and Player.Character.PrimaryPart and (Player.Character.PrimaryPart.Position - Ball.Position).Magnitude <= 20 then
                    Auto_Parry.Parry(SelectedParryDirection)
                end
            end))
        end
    end
})

MainSection:AddToggle("SpamParry", {
    Title = "Spam Parry",
    Default = false,
    Callback = function(Value)
        SpamParryEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not SpamParryEnabled then return end
                Auto_Parry.Parry(SelectedParryDirection)
            end))
        end
    end
})

MainSection:AddDropdown("ParryDirection", {
    Title = "Parry Direction",
    Values = {"Camera", "Straight", "Backwards", "Left", "Right", "Random", "RandomTarget"},
    Default = "Camera",
    Callback = function(Value)
        SelectedParryDirection = Value
    end
})

MainSection:AddSlider("Prediction", {
    Title = "Prediction (ms)",
    Default = 0,
    Min = 0,
    Max = 150,
    Rounding = 1,
    Callback = function(Value)
        PredictionMS = Value
    end
})

local VisualsSection = VisualsTab:AddSection({Title = "Visual Enhancements"})

VisualsSection:AddToggle("BallESP", {
    Title = "Ball ESP",
    Default = false,
    Callback = function(Value)
        BallESPEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not BallESPEnabled then return end
                local Ball = Auto_Parry.Get_Ball()
                if Ball then
                    local ESP = Ball:FindFirstChild("ESP") or Instance.new("Highlight", Ball)
                    ESP.Name = "ESP"
                    ESP.FillColor = Color3.fromRGB(255, 0, 0)
                    ESP.OutlineColor = Color3.fromRGB(255, 255, 255)
                    ESP.Enabled = true
                end
            end))
        else
            for _, Ball in pairs(Workspace.Balls:GetChildren()) do
                if Ball:FindFirstChild("ESP") then
                    Ball.ESP:Destroy()
                end
            end
        end
    end
})

VisualsSection:AddToggle("RainbowTrail", {
    Title = "Rainbow Trail",
    Default = false,
    Callback = function(Value)
        RainbowTrailEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not RainbowTrailEnabled then return end
                local Ball = Auto_Parry.Get_Ball()
                if Ball and not Ball:FindFirstChild("RainbowTrail") then
                    local at1 = Instance.new("Attachment", Ball)
                    local at2 = Instance.new("Attachment", Ball)
                    at1.Position = Vector3.new(0, 0.5, 0)
                    at2.Position = Vector3.new(0, -0.5, 0)
                    local trail = Instance.new("Trail", Ball)
                    trail.Name = "RainbowTrail"
                    trail.Attachment0 = at1
                    trail.Attachment1 = at2
                    trail.Lifetime = 0.3
                    trail.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 127, 0)),
                        ColorSequenceKeypoint.new(0.32, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.64, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(75, 0, 130)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211))
                    })
                end
            end))
        else
            for _, Ball in pairs(Workspace.Balls:GetChildren()) do
                if Ball:FindFirstChild("RainbowTrail") then
                    Ball.RainbowTrail:Destroy()
                end
                for _, att in pairs(Ball:GetChildren()) do
                    if att:IsA("Attachment") then att:Destroy() end
                end
            end
        end
    end
})

VisualsSection:AddToggle("ViewBall", {
    Title = "View Ball",
    Default = false,
    Callback = function(Value)
        ViewBallEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not ViewBallEnabled then return end
                local Ball = Auto_Parry.Get_Ball()
                if Ball then
                    Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, Ball.Position)
                end
            end))
        else
            Workspace.CurrentCamera.CameraSubject = Player.Character and Player.Character.Humanoid or nil
        end
    end
})

VisualsSection:AddSlider("CameraFOV", {
    Title = "Camera FOV",
    Default = 70,
    Min = 50,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        CameraFOV = Value
        Workspace.CurrentCamera.FieldOfView = Value
    end
})

local FarmingSection = FarmingTab:AddSection({Title = "Automation"})

FarmingSection:AddToggle("AutoPlay", {
    Title = "Auto Play",
    Default = false,
    Callback = function(Value)
        AutoPlayEnabled = Value
        if Value then
            table.insert(Connections, RunService.RenderStepped:Connect(function()
                if not AutoPlayEnabled then return end
                local Ball = Auto_Parry.Get_Ball()
                if Ball and Player.Character and Player.Character.PrimaryPart then
                    local dir = (Ball.Position - Player.Character.PrimaryPart.Position).Unit
                    local dist = (Ball.Position - Player.Character.PrimaryPart.Position).Magnitude
                    if dist > 30 then
                        VirtualInputManager:SendKeyEvent(true, "W", false, game)
                    else
                        VirtualInputManager:SendKeyEvent(false, "W", false, game)
                        local dodgeKey = math.random(1, 2) == 1 and "A" or "D"
                        VirtualInputManager:SendKeyEvent(true, dodgeKey, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, dodgeKey, false, game)
                    end
                end
            end))
        else
            for _, key in pairs({"W", "A", "D"}) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end
    end
})

local MiscSection = MiscTab:AddSection({Title = "Miscellaneous"})

MiscSection:AddButton({
    Title = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/flashlighthub")
        x2zuLibrary:Notify({
            Title = "Success",
            Content = "Copied Discord link!",
            Duration = 3
        })
    end
})

MiscSection:AddButton({
    Title = "Unload Script",
    Callback = function()
        for _, conn in pairs(Connections) do
            conn:Disconnect()
        end
        Connections = {}
        for _, Ball in pairs(Workspace.Balls:GetChildren()) do
            if Ball:FindFirstChild("ESP") then
                Ball.ESP:Destroy()
            end
            if Ball:FindFirstChild("RainbowTrail") then
                Ball.RainbowTrail:Destroy()
            end
            for _, att in pairs(Ball:GetChildren()) do
                if att:IsA("Attachment") then att:Destroy() end
            end
        end
        Workspace.CurrentCamera.FieldOfView = 70
        Workspace.CurrentCamera.CameraSubject = Player.Character and Player.Character.Humanoid or nil
        x2zuLibrary:Destroy()
    end
})

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FloatingButton"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local OutlineButton = Instance.new("Frame", ScreenGui)
OutlineButton.Name = "OutlineButton"
OutlineButton.ClipsDescendants = true
OutlineButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
OutlineButton.Position = UDim2.new(0, 10, 0, 10)
OutlineButton.Size = UDim2.new(0, 50, 0, 50)
local Rounded = Instance.new("UICorner", OutlineButton)
Rounded.CornerRadius = UDim.new(0, 25)

local ImageButton = Instance.new("ImageButton", OutlineButton)
ImageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageButton.Size = UDim2.new(0, 40, 0, 40)
ImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
ImageButton.BackgroundTransparency = 1
ImageButton.Image = "rbxassetid://10734950020"
ImageButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.AutoButtonColor = false

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        object.Position = pos
    end
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

MakeDraggable(ImageButton, OutlineButton)

ImageButton.MouseButton1Click:Connect(function()
    local gui = game.CoreGui:FindFirstChild("x2zu")
    if gui then
        gui.Enabled = not gui.Enabled
    end
end)

task.spawn(function()
    wait(0.5)
    x2zuLibrary:Notify({
        Title = "FLASHLIGHT",
        Content = "Loaded successfully!",
        Duration = 5
    })
end)
