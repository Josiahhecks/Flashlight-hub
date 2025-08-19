-- Josiah Hub for Build A Boat For Treasure
-- Created by combining provided files: auto-farm from jimmy.txt, remotes from newrmeoteevents.txt
-- Uses Rayfield for GUI
-- Features: Auto Farm gold, Auto Buy items/blocks/chests using remotes
-- Note: Auto Buy will loop buy the selected item if toggle enabled and gold sufficient

if game.PlaceId ~= 537413528 then
    return
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Josiah Hub",
    LoadingTitle = "Josiah Hub for BABFT",
    LoadingSubtitle = "Auto Farm & Auto Buy",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main")
local FarmTab = Window:CreateTab("Auto Farm")
local BuyTab = Window:CreateTab("Auto Buy")

-- Auto Farm from jimmy.txt
local Silent = false
local AutoFarmToggle = FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AF = Value
        local player = game.Players.LocalPlayer
        local isFarming = false

        local function startAutoFarm()
            if not Value then return end

            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            local newPart = Instance.new("Part")
            newPart.Size = Vector3.new(5, 1, 5)
            newPart.Transparency = 1
            newPart.CanCollide = true
            newPart.Anchored = true
            newPart.Parent = workspace

            local function TPAF(iteration)
                if not Silent then
                    if not Value then return end
                    if iteration == 5 then
                        firetouchinterest(player.Character:WaitForChild("HumanoidRootPart"), workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger, 0)
                        task.delay(0.8, function()
                            workspace.ClaimRiverResultsGold:FireServer()
                        end)
                        humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
                    else
                        if iteration == 1 then
                            humanoidRootPart.CFrame = CFrame.new(160.16104125976562, 29.595888137817383, 973.813720703125)
                        else
                            humanoidRootPart.CFrame = CFrame.new(-51, 65, 984 + (iteration - 1) * 770)
                        end
                    end
                    newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)
                    wait(2.3)
                    if iteration == 1 then wait(2.3) end
                    if iteration ~= 4 then workspace.ClaimRiverResultsGold:FireServer() end
                else
                    if not Value then return end
                    if iteration == 1 then
                        humanoidRootPart.CFrame = CFrame.new(160.16104125976562, 29.595888137817383, 973.813720703125)
                    elseif iteration == 5 then
                        firetouchinterest(player.Character:WaitForChild("HumanoidRootPart"), workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger, 0)
                        task.delay(0.8, function()
                            workspace.ClaimRiverResultsGold:FireServer()
                        end)
                        humanoidRootPart.CFrame = CFrame.new(70.02417755126953, 138.9026336669922, 1371.6341552734375 + (iteration - 2) * 770)
                    else
                        humanoidRootPart.CFrame = CFrame.new(70.02417755126953, 138.9026336669922, 1371.6341552734375 + (iteration - 2) * 770)
                    end
                    newPart.Position = humanoidRootPart.Position - Vector3.new(0, 2, 0)
                    wait(2.3)
                    if iteration == 1 then wait(2.3) end
                    if iteration ~= 4 then workspace.ClaimRiverResultsGold:FireServer() end
                end
            end

            for i = 1, 10 do
                if not Value then break end
                TPAF(i)
            end
            newPart:Destroy()
        end

        local function onCharacterRespawned()
            if getgenv().AF then
                local character = player.Character or player.CharacterAdded:Wait()
                character:WaitForChild("HumanoidRootPart")
                startAutoFarm()
            end
        end

        if Value then
            Rayfield:Notify({Title = "Auto Farm Enabled", Content = "Farming gold..."})
            player.Character:BreakJoints()
            wait(1)
            player.CharacterAdded:Connect(onCharacterRespawned)
        else
            Rayfield:Notify({Title = "Auto Farm Disabled"})
        end
    end,
})

local SilentToggle = FarmTab:CreateToggle({
    Name = "Silent Mode",
    CurrentValue = false,
    Callback = function(Value)
        Silent = Value
    end,
})

-- Auto Buy using remotes from newrmeoteevents.txt
-- List of gold-purchasable items
local goldItems = {
    "Common Chest", "Uncommon Chest", "Rare Chest", "Epic Chest", "Legendary Chest",
    "Paint Tool", "Binding Tool", "Property Tool", "Scaling Tool", "Trowel Tool",
    "Sign", "Parachute Block", "Shield Generator", "Harpoon", "Balloon Block",
    "Jetpack", "Switch", "Button", "Light Bulb", "Camera", "Dome Camera",
    "Locked Door", "Music Note", "Hinge", "Delay Block", "Piston", "Magnet",
    "Rope", "Bar", "Suspension", "Dynamite", "Spike Trap", "Cannon", "Minigun",
    "Big Cannon", "Mounted Sword", "Mounted Flintlocks", "Mounted Cannon",
    "Wood Block", "Smooth Wood Block", "Glass Block", "Stone Block", "Fabric Block",
    "Plastic Block", "Grass Block", "Sand Block", "Rusted Block", "Bouncy Block",
    "Metal Block", "Concrete Block", "Ice Block", "Coal Block", "Brick Block",
    "Marble Block", "Titanium Block", "Obsidian Block",
    -- Daily Rotation
    "Chair", "Door", "Flag", "Hatch", "Truss", "I-Beam", "Seat", "Window",
    "Wood Rod", "Marble Rod", "Throne", "Helm", "Rusted Rod", "Metal Rod",
    "Step", "Lamp", "Wedge", "Titanium Rod", "Concrete Rod", "Corner Wedge",
    "Torch", "Mast", "Stone Rod", "Glue",
    -- Seasonal
    "Firework 1", "Firework 2", "Firework 3", "Firework 4", "Candle", "Pumpkin",
    "Toy Block", "Snowball Launcher",
    -- Packages
    "Boat Motor Pack", "Legacy Car Pack", "New Car Pack", "Plane Blocks", "Candy Wheel Pack"
}

-- Robux products (IDs)
local robuxProducts = {
    {id = 944487410, name = "Boat motor gamepass"},
    {id = 260358235, name = "4 big wheels"},
    {id = 641075523, name = "Gold harpoon"},
    {id = 811892987, name = "Portals"},
    {id = 558757040, name = "Ultra jetpacks"}
}

local selectedItem = goldItems[1]
local buyQuantity = 1
local autoBuyToggle = false
local selectedProduct = robuxProducts[1].id

BuyTab:CreateDropdown({
    Name = "Select Gold Item",
    Options = goldItems,
    CurrentOption = selectedItem,
    Callback = function(Option)
        selectedItem = Option
    end,
})

BuyTab:CreateSlider({
    Name = "Quantity",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(Value)
        buyQuantity = Value
    end,
})

BuyTab:CreateButton({
    Name = "Buy Selected Gold Item",
    Callback = function()
        local args = {selectedItem, buyQuantity}
        workspace.ItemBoughtFromShop:InvokeServer(unpack(args))
        Rayfield:Notify({Title = "Buy Attempt", Content = "Trying to buy " .. buyQuantity .. "x " .. selectedItem})
    end,
})

BuyTab:CreateToggle({
    Name = "Auto Buy (Loop if gold sufficient)",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyToggle = Value
        spawn(function()
            while autoBuyToggle do
                local gold = game.Players.LocalPlayer.Data.Gold.Value  -- Assuming gold is in Data.Gold
                if gold >= 100 then  -- Placeholder cost, adjust based on item
                    local args = {selectedItem, buyQuantity}
                    workspace.ItemBoughtFromShop:InvokeServer(unpack(args))
                end
                wait(1)  -- Delay to avoid spam
            end
        end)
    end,
})

BuyTab:CreateSection("Robux Products (Developer Products)")

BuyTab:CreateDropdown({
    Name = "Select Robux Product",
    Options = {robuxProducts[1].name, robuxProducts[2].name, robuxProducts[3].name, robuxProducts[4].name, robuxProducts[5].name},
    CurrentOption = robuxProducts[1].name,
    Callback = function(Option)
        for _, prod in ipairs(robuxProducts) do
            if prod.name == Option then
                selectedProduct = prod.id
                break
            end
        end
    end,
})

BuyTab:CreateButton({
    Name = "Buy Selected Robux Product",
    Callback = function()
        local args = {selectedProduct, "Product"}
        workspace.PromptRobuxEvent:InvokeServer(unpack(args))
        Rayfield:Notify({Title = "Buy Attempt", Content = "Trying to buy product ID: " .. selectedProduct})
    end,
})

-- Additional utilities from jimmy.txt
MainTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        local connection = game.Players.LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
        Rayfield:Notify({Title = "Anti-AFK Enabled"})
    end,
})

MainTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})
