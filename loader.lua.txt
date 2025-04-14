-- WHITELIST CHECK
local function getWhitelist()
    local success, data = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/whitelist.lua")
    end)
    return success and loadstring(data)() or {}
end

local whitelist = getWhitelist()
local player = game:GetService("Players").LocalPlayer
if not whitelist[player.Name] and not whitelist[player.UserId] then
    player:Kick("You are not whitelisted.")
    return
end

-- FILE SYSTEM
local isfile = isfile or function(file)
    local suc, res = pcall(function() return readfile(file) end)
    return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
    writefile(file, '')
end

-- DOWNLOAD FILE FUNCTION
local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            local commit = readfile('newvape/profiles/commit.txt')
            local url = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/' .. commit .. '/' .. path:gsub('newvape/', '')
            return game:HttpGet(url, true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        if path:find('.lua') then
            res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

-- WIPE OLD CACHED FILES
local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in listfiles(path) do
        if file:find('loader') then continue end
        local content = readfile(file)
        if isfile(file) and content:find('^%-%-This watermark is used') then
            delfile(file)
        end
    end
end

-- ENSURE FOLDERS EXIST
for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
    if not isfolder(folder) then makefolder(folder) end
end

-- COMMIT CHECKING
if not shared.VapeDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet('https://github.com/YOUR_USERNAME/YOUR_REPO')
    end)
    local commit = subbed:find('currentOid')
    commit = commit and subbed:sub(commit + 13, commit + 52) or nil
    commit = commit and #commit == 40 and commit or 'main'
    local storedCommit = isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or ''
    if commit == 'main' or storedCommit ~= commit then
        wipeFolder('newvape')
        wipeFolder('newvape/games')
        wipeFolder('newvape/guis')
        wipeFolder('newvape/libraries')
    end
    writefile('newvape/profiles/commit.txt', commit)
end

-- LOAD MAIN SCRIPT
return loadstring(downloadFile('newvape/main.lua'), 'main')()
