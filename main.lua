-- Wait for the game to load completely
repeat task.wait() until game:IsLoaded()

-- Handle previous session cleanup (if any previous session exists)
if shared.customFramework then
    shared.customFramework:Uninject()  -- Clean up from the previous session if necessary
end

-- Handle specific executor-related adjustments (optional)
if identifyexecutor and ({identifyexecutor()})[1] == "Argon" then
    getgenv().setthreadidentity = nil
end

-- Global variables setup (prevents any thread-related issues)
getgenv().setthreadidentity = function() end
getgenv().run = function(func)
    local success, err = pcall(func)
    if not success then
        warn("[Custom Framework]: Error - " .. debug.traceback(tostring(err)))
    end
end

-- UI profile and save handling (manages GUI profiles for customizations)
local guiProfile = "default"  -- Default profile name
if not isfile("profiles/gui.txt") then
    writefile("profiles/gui.txt", guiProfile)
end
guiProfile = readfile("profiles/gui.txt")
if not isfolder("assets/" .. guiProfile) then
    makefolder("assets/" .. guiProfile)
end

-- Load the necessary libraries
local Functions = loadstring(game:HttpGet("https://yourdomain.com/libraries/YourFunctions.lua", true))()
Functions.GlobaliseObject("CustomFunctions", Functions)

-- Load the GUI layout for the chosen profile
local gui = pload("guis/" .. guiProfile .. ".lua", true, true)
shared.customFramework = gui
getgenv().customFramework = gui
getgenv().GuiLibrary = gui

-- Notification system for giving feedback to the user
getgenv().InfoNotification = function(title, msg, dur)
    gui:CreateNotification(title, msg, dur)
end

-- Handle the loading of game-specific scripts
local function loadPlaceScripts()
    local placeId = game.PlaceId
    local fileName = tostring(placeId) .. ".lua"  -- Use PlaceId to determine specific scripts
    if isfile("games/" .. fileName) then
        pload("games/" .. fileName, true, true)
    end
end

-- Finish setup and handle post-load actions (saving preferences, etc.)
local function finishLoading()
    gui:Load()  -- Load the GUI
    task.spawn(function()
        repeat
            gui:Save()  -- Save settings periodically
            task.wait(10)
        until not gui.Loaded
    end)
end

-- Handle game-specific logic and execute scripts
loadPlaceScripts()

-- Call finish loading once scripts are ready
finishLoading()

-- Handle game-specific customization (optional based on PlaceId)
local bedwarsID = {
    game = {6872274481, 8444591321, 8560631822},  -- List of BedWars PlaceIds
    lobby = {6872265039}  -- Lobby PlaceIds
}

-- Check if the game matches any of the BedWars PlaceIds
local function handleGameSpecific()
    local placeId = game.PlaceId
    local CE = shared.CheatEngineMode and "CE" or ""  -- Check for Cheat Engine Mode
    local fileName1, fileName2 = placeId .. ".lua", "VW" .. placeId .. ".lua"

    local isGame = table.find(bedwarsID.game, placeId)
    local isLobby = table.find(bedwarsID.lobby, placeId)

    if isGame then
        -- Game-specific setup for BedWars
        fileName1 = CE .. "6872274481.lua"
        fileName2 = "VW6872274481.lua"
    elseif isLobby then
        -- Lobby-specific setup
        fileName1 = CE .. "6872265039.lua"
        fileName2 = "VW6872265039.lua"
    end

    warn("[Custom Framework] - File Names: ", fileName1, fileName2)
    pload('games/' .. tostring(fileName1))  -- Load the game-specific script
    pload('games/' .. tostring(fileName2))  -- Load the alternate version (if applicable)
end

handleGameSpecific()

-- Notification about script load status
warn("[Custom Framework] - Finished Loading!")
