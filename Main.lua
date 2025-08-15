-- // Flash Light Hub - Starter Base
-- // Based on STELLAR UI Lib & INPROGRESS Functional Scripts
-- // Expandable, Saveable, Modern Design

repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
wait(1)

-- // Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenInfo")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- // Player Data
local PlayerName = Player.Name

-- // UI Settings
local UISettings = {
    MainColor = Color3.fromRGB(100, 200, 255), -- Light blue/cyan
    DarkColor = Color3.fromRGB(20, 20, 30),
    LightText = Color3.fromRGB(240, 240, 240),
    DarkText = Color3.fromRGB(100, 100, 100),
    AccentColor = Color3.fromRGB(0, 180, 255),
    BackgroundTransparency = 0.92,
    Font = Enum.Font.FredokaOne,
    TextSize = 14
}

-- // Config System (Load/Save)
local Config = {
    WindowSize = UDim2.new(0, 500, 0, 300),
    TabWidth = UDim2.new(0, 150, 0, 30),
    SaveSettings = true,
    LoadAnimation = true
}

-- // Create Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlashLightHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- // Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = UISettings.DarkColor
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.Size = Config.WindowSize
MainFrame.ClipsDescendants = true

-- // Rounded Corners
local function CreateRounded(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

CreateRounded(MainFrame, 14)

-- // UI Stroke (Glow Border)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UISettings.AccentColor
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- // UI List Layout (Tabs)
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- // Tab Holder
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "Tabs"
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabsFrame.BorderSizePixel = 0
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 0)
CreateRounded(TabsFrame, 12)
UIStroke.Clone().Parent = TabsFrame

-- // Pages Frame
local PagesFrame = Instance.new("Frame")
PagesFrame.Name = "Pages"
PagesFrame.Parent = MainFrame
PagesFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PagesFrame.BorderSizePixel = 0
PagesFrame.Position = UDim2.new(0, 10, 0, 50)
PagesFrame.Size = UDim2.new(1, -20, 1, -60)
CreateRounded(PagesFrame, 10)

-- // Page Container (Scrolling)
local PageContainer = Instance.new("ScrollingFrame")
PageContainer.Name = "PageContainer"
PageContainer.Parent = PagesFrame
PageContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PageContainer.BorderSizePixel = 0
PageContainer.Size = UDim2.new(1, 0, 1, 0)
PageContainer.ScrollBarThickness = 6
PageContainer.ScrollBarImageColor3 = UISettings.AccentColor

-- // Add UIListLayout for Pages
local PageLayout = Instance.new("UIListLayout")
PageLayout.Parent = PageContainer
PageLayout.Padding = UDim.new(0, 10)
PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- // Drag Function
local function MakeDraggable(ui, frame)
    frame.Active = true
    frame.Draggable = true
end

MakeDraggable(ScreenGui, MainFrame)

-- // Tab System
local Tabs = {}
local CurrentTab = nil

function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Tab"
    TabButton.Parent = TabsFrame
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TabButton.BorderSizePixel = 0
    TabButton.Size = Config.TabWidth
    TabButton.Text = tabName
    TabButton.TextColor3 = UISettings.LightText
    TabButton.TextSize = UISettings.TextSize
    TabButton.Font = UISettings.Font
    TabButton.AutoButtonColor = false
    TabButton.ClipsDescendants = true

    CreateRounded(TabButton, 8)

    -- // Indicator Line
    local Indicator = Instance.new("Frame")
    Indicator.Name = "SelectedTab"
    Indicator.Parent = TabButton
    Indicator.BackgroundColor3 = UISettings.AccentColor
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(0, 0, 1, 0)
    Indicator.Size = UDim2.new(0, 0, 0, 3)
    Indicator.Visible = false

    -- // Hover Effect
    TabButton.MouseEnter:Connect(function()
        if CurrentTab ~= TabButton then
            TabButton.TextColor3 = UISettings.AccentColor
        end
    end)

    TabButton.MouseLeave:Connect(function()
        if CurrentTab ~= TabButton then
            TabButton.TextColor3 = UISettings.LightText
        end
    end)

    -- // Page Frame
    local Page = Instance.new("Frame")
    Page.Name = tabName .. "Page"
    Page.Parent = PageContainer
    Page.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Page.BorderSizePixel = 0
    Page.Size = UDim2.new(1, 0, 0, 250)
    Page.Visible = false
    CreateRounded(Page, 8)

    -- // Add to layout
    local Padding = Instance.new("UIPadding")
    Padding.Parent = Page
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)

    local PageListLayout = Instance.new("UIListLayout")
    PageListLayout.Parent = Page
    PageListLayout.Padding = UDim.new(0, 10)
    PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- // Switch Tab
    TabButton.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.TextColor3 = UISettings.LightText
            CurrentTab.SelectedTab.Visible = false
            CurrentTab:FindFirstChild("SelectedTab").Size = UDim2.new(0, 0, 0, 3)
            CurrentTab.Parent:FindFirstChild(CurrentTab.Name:gsub("Tab", "Page")).Visible = false
        end

        CurrentTab = TabButton
        TabButton.TextColor3 = UISettings.AccentColor
        TabButton.SelectedTab.Visible = true
        TabButton.SelectedTab:TweenSize(UDim2.new(1, 0, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3)
        Page.Visible = true
    end)

    table.insert(Tabs, {
        Button = TabButton,
        Page = Page
    })

    return Page
end

-- // Save & Load System
local ConfigFolder = "FlashLightHub"
local ConfigFile = ConfigFolder .. "/" .. PlayerName .. ".json"

local DefaultSettings = {
    WindowSize = {X = 500, Y = 300},
    Theme = "LightBlue",
    AutoLoad = true
}

local Settings = {}

local function SaveConfig()
    if not isfolder then return warn("Executor not supported") end
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

    for i, v in pairs(DefaultSettings) do
        if Settings[i] == nil then
            Settings[i] = v
        end
    end

    writefile(ConfigFile, HttpService:JSONEncode(Settings))
    print("⚙️ Flash Light Hub: Config saved!")
end

local function LoadConfig()
    if not isfolder or not readfile then return warn("Executor not supported") end
    if isfile(ConfigFile) then
        local data = HttpService:JSONDecode(readfile(ConfigFile))
        Settings = data
        print("✅ Flash Light Hub: Config loaded!")
    else
        Settings = DefaultSettings
        SaveConfig()
    end
end

LoadConfig()

-- // Example Tabs & Buttons
local MainTab = CreateTab("Home")
local AutoTab = CreateTab("Auto Farm")
local MiscTab = CreateTab("Misc")

-- // Auto-Select First Tab
spawn(function()
    wait(0.5)
    TabsFrame:WaitForChild("HomeTab").MouseButton1Click:Fire()
end)

-- // Button Creator Function
function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.Text = text
    Button.TextColor3 = UISettings.LightText
    Button.TextSize = UISettings.TextSize + 2
    Button.Font = UISettings.Font
    Button.AutoButtonColor = false

    CreateRounded(Button, 6)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end)

    Button.MouseButton1Click:Connect(function()
        Button.BackgroundColor3 = UISettings.AccentColor
        task.wait(0.1)
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        pcall(callback)
    end)
end

-- // Example Buttons
CreateButton(MainTab, "Welcome to Flash Light Hub!", function()
    print("Hello " .. PlayerName .. "!")
end)

CreateButton(AutoTab, "Auto Buy Common Chest", function()
    local running = not running
    if running then
        while running and task.wait(3) do
            local args = {"Common Chest", 1}
            Workspace:WaitForChild("ItemBoughtFromShop"):InvokeServer(unpack(args))
        end
    end
end)

CreateButton(MiscTab, "Open Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

CreateButton(MiscTab, "Destroy GUI", function()
    ScreenGui:Destroy()
end)

-- // Finalize
print("✨ Flash Light Hub Loaded Successfully!")
print("📁 Config: " .. ConfigFile)

-- // Allow future additions
-- You can now send more scripts (e.g. auto-farm, teleport, quest complete)
-- I will integrate them into new tabs/buttons

return {
    CreateTab = CreateTab,
    CreateButton = CreateButton,
    Save = SaveConfig,
    Load = LoadConfig,
    Settings = Settings,
    ScreenGui = ScreenGui
}
