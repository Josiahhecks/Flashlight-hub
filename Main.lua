local Stellar = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/NewUiStellar.lua"))()

if Stellar:LoadAnimation() then
    Stellar:StartLoad()
    task.wait(2)
    Stellar:Loaded()
end

local UserInputService = game:GetService("UserInputService")
local Window = Stellar:Window({
    Title = "FLASHLIGHT",
    SubTitle = "Blade Ball Edition",
    Size = UserInputService.TouchEnabled and UDim2.new(0, 380, 0, 260) or UDim2.new(0, 500, 0, 320),
    TabWidth = 140
})

local MainTab = Window:Tab("Main", "rbxassetid://10723407389")
local VisualsTab = Window:Tab("Visuals", "rbxassetid://10723415335")
local FarmingTab = Window:Tab("Farming", "rbxassetid://10709782497")
local MiscTab = Window:Tab("Misc", "rbxassetid://10734950309")

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

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
        local Closest_Entity = nil
        local Max_Distance = math.huge
        for _, Entity in pairs(Workspace.Alive:GetChildren()) do
            if Entity ~= Player.Character and Entity.PrimaryPart then
                local Distance = (Player.Character.PrimaryPart.Position - Entity.PrimaryPart.Position).Magnitude
                if Distance < Max_Distance then
                    Max_Distance = Distance
                    Closest_Entity = Entity
                end
            end
        end
        if Closest_Entity then
            return {0, CFrame.new(Player.Character.PrimaryPart.Position, Closest_Entity.PrimaryPart.Position), Events, Vector2_Mouse_Location}
        else
            return {0, Camera.CFrame, Events, Vector2_Mouse_Location}
        end
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
            return {0, CFrame.new(Player.Character.PrimaryPart.Position, pick.character.PrimaryPart.Position), Events, pick.screenXY}
        else
            return {0, Camera.CFrame, Events, {Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2}}
        end
    end
end

function Auto_Parry.Parry(Parry_Type)
    local Data = Auto_Parry.Parry_Data(Parry_Type)
    task.wait(PredictionMS / 1000)
    Parry(Data[1], Data[2], Data[3], Data[4])
end

MainTab:Seperator("Parry Options")

MainTab:Toggle("Auto Parry", nil, function(Value)
    AutoParryEnabled = Value
    if Value then
        table.insert(Connections, RunService.RenderStepped:Connect(function()
            if not AutoParryEnabled then return end
            local Ball = Auto_Parry.Get_Ball()
            if Ball and Player.Character and Player.Character.PrimaryPart then
                local distance = (Player.Character.PrimaryPart.Position - Ball.Position).Magnitude
                if distance <= 20 then
                    Auto_Parry.Parry(SelectedParryDirection)
                end
            end
        end))
    end
end)

MainTab:Toggle("Spam Parry", nil, function(Value)
    SpamParryEnabled = Value
    if Value then
        table.insert(Connections, RunService.RenderStepped:Connect(function()
            if not SpamParryEnabled then return end
            Auto_Parry.Parry(SelectedParryDirection)
        end))
    end
end)

MainTab:Dropdown("Parry Direction", {"Camera", "Straight", "Backwards", "Left", "Right", "Random", "RandomTarget"}, "Camera", function(Option)
    SelectedParryDirection = Option
end)

MainTab:Slider("Prediction (ms)", 0, 150, 0, function(Value)
    PredictionMS = Value
end)

VisualsTab:Seperator("Visual Options")

VisualsTab:Toggle("Ball ESP", nil, function(Value)
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
end)

VisualsTab:Toggle("Rainbow Trail", nil, function(Value)
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
                trail.MinLength = 0.1
                trail.WidthScale = NumberSequence.new(1)
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
end)

VisualsTab:Toggle("View Ball", nil, function(Value)
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
end)

VisualsTab:Slider("Camera FOV", 50, 120, 70, function(Value)
    CameraFOV = Value
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        Workspace.CurrentCamera.FieldOfView = CameraFOV
    end))
end)

FarmingTab:Seperator("Farming Options")

FarmingTab:Toggle("Auto Play", nil, function(Value)
    AutoPlayEnabled = Value
    if Value then
        table.insert(Connections, RunService.RenderStepped:Connect(function()
            if not AutoPlayEnabled then return end
            local Ball = Auto_Parry.Get_Ball()
            if Ball and Player.Character and Player.Character.PrimaryPart then
                local dir = (Ball.Position - Player.Character.PrimaryPart.Position).Unit
                local dist = (Ball.Position - Player.Character.PrimaryPart.Position).Magnitude
                local targetDistance = 30
                for _, key in pairs({"W", "A", "S", "D"}) do
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
                if dist > targetDistance + 5 then
                    VirtualInputManager:SendKeyEvent(true, "W", false, game)
                elseif Ball.Velocity.Magnitude > 120 then
                    local dodgeKey = math.random(1, 2) == 1 and "A" or "D"
                    VirtualInputManager:SendKeyEvent(true, dodgeKey, false, game)
                end
            end
        end))
    else
        for _, key in pairs({"W", "A", "S", "D"}) do
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
    end
end)

MiscTab:Seperator("Miscellaneous")

MiscTab:Button("Copy Discord", function()
    setclipboard("https://discord.gg/flashlighthub")
    Stellar:Notify("Discord link copied!", 3)
end)

MiscTab:Button("Unload Script", function()
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
    Stellar:Destroy()
end)

local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "FlashlightButton"
ScreenGui.ResetOnSpawn = false
local OutlineButton = Instance.new("Frame", ScreenGui)
OutlineButton.Name = "OutlineButton"
OutlineButton.ClipsDescendants = true
OutlineButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
OutlineButton.Position = UDim2.new(0, 10, 0, 10)
OutlineButton.Size = UDim2.new(0, 50, 0, 50)
local Rounded = Instance.new("UICorner", OutlineButton)
Rounded.CornerRadius = UDim.new(0, 12)
local ImageButton = Instance.new("ImageButton", OutlineButton)
ImageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageButton.Size = UDim2.new(0, 40, 0, 40)
ImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
ImageButton.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
ImageButton.ImageColor3 = Color3.fromRGB(250, 250, 250)
ImageButton.Image = "rbxassetid://10734950020"
ImageButton.AutoButtonColor = false
local RoundedImage = Instance.new("UICorner", ImageButton)
RoundedImage.CornerRadius = UDim.new(0, 10)

local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        local Tween = game:GetService("TweenService"):Create(object, TweenInfo.new(0.15), {Position = pos})
        Tween:Play()
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

ImageButton.Activated:Connect(function()
    local stellarGui = game.CoreGui:FindFirstChild("STELLAR")
    if stellarGui then
        stellarGui.Enabled = not stellarGui.Enabled
    end
end)

Stellar:Notify("FLASHLIGHT Loaded!", 5)
