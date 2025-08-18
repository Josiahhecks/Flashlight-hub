-- // 🔦 Flashlight Hub - Lightweight Loader
-- // No UI Framework | Fast & Clean
-- // Supports: Blox Fruits (W1/W2/W3) and Slap Battles

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- // Supported Games
local BLOX_FRUITS_W1 = 2753915549
local BLOX_FRUITS_W2 = 4442272183
local BLOX_FRUITS_W3 = 7449423635
local SLAP_BATTLES = 6403373529

-- // GitHub Raw Script Links (Replace with your own)
local BLOX_FRUITS_SCRIPT_URL = "https://raw.githubusercontent.com/Josiahhecks/Flashlight-hub/refs/heads/main/Bloxfruit.lua"
local SLAP_BATTLES_SCRIPT_URL = "https://raw.githubusercontent.com/Josiahhecks/Flashlight-hub/refs/heads/main/Slapbattles.lua"

-- // Simple Notification Function
local function Notify(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Flashlight Hub]: " .. msg,
        Color = Color3.fromRGB(255, 255, 100),
        FontSize = 20
    })
    print("[Flashlight Hub] " .. msg)
end

-- // Detect Game
if PlaceId == BLOX_FRUITS_W1 or PlaceId == BLOX_FRUITS_W2 or PlaceId == BLOX_FRUITS_W3 then
    Notify("Blox Fruits detected...")
    Notify("Loading Flashlight Hub...")

    spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(BLOX_FRUITS_SCRIPT_URL))()
        end)
        if success then
            Notify("Blox Fruits Hub loaded! Press RightCtrl.")
        else
            warn("Blox Fruits Load Error:", err)
            Notify("Failed to load Blox Fruits script.")
            setclipboard(BLOX_FRUITS_SCRIPT_URL)
            Notify("Link copied to clipboard.")
        end
    end)

elseif PlaceId == SLAP_BATTLES then
    Notify("Slap Battles detected...")
    Notify("Loading Flashlight Hub...")

    spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(SLAP_BATTLES_SCRIPT_URL))()
        end)
        if success then
            Notify("Slap Battles Hub loaded! Press RightCtrl.")
        else
            warn("Slap Battles Load Error:", err)
            Notify("Failed to load Slap Battles script.")
            setclipboard(SLAP_BATTLES_SCRIPT_URL)
            Notify("Link copied to clipboard.")
        end
    end)

else
    LocalPlayer:Kick("❌ Flashlight Hub: Unsupported game.\n\nSupported games:\n- Blox Fruits\n- Slap Battles\n\nPlace ID: " .. PlaceId)
end
