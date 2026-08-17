local sharedConfig = Dank.config

-- Strip ^# color codes so box sizing only counts visible characters
---@param s any
---@return integer
local function visibleLen(s)
    return tostring(s):gsub('%^%d', ''):len()
end

---@param title string
---@param value any
---@param titleWidth integer
---@param valueWidth integer
---@return string
local function formatLine(title, value, titleWidth, valueWidth)
    local notFound = value == 'none'
    local valueText = notFound and 'Not Found' or tostring(value)
    local valueColor = notFound and '^1' or '^2'
    return ('^7| ^4%-' .. titleWidth .. 's ^7| ' .. valueColor .. '%-' .. valueWidth .. 's ^7|'):format(title, valueText)
end

-- Center a title inside the box so both sides always line up
---@param text string
---@param totalWidth integer
---@return string
local function formatTitleLine(text, totalWidth)
    local pad = totalWidth - 4 - visibleLen(text)
    local left = math.floor(pad / 2)
    local right = pad - left
    return '^5| ' .. '^6' .. string.rep(' ', left) .. text .. '^5' .. string.rep(' ', right) .. ' |'
end

-- Force load modules that contain critical server callbacks
local _ = Dank.vehicle

-- Version checker (moved from version.lua)

local versionConfig = {
    updateURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json",
    cronExpression = "0 * * * *",
    maxRetries = 3,
    retryDelay = 5000,
    originalScriptName = "Dank_Utils"
}

-- Global cache for graceful degradation: last known remote version.
local cachedRemoteVersion = nil
local lastReportedState = nil

---@param state string|nil
---@param printFn function
local function printIfStateChanged(state, printFn)
    if lastReportedState == state then
        return
    end
    lastReportedState = state
    printFn()
end

-- Convert a version string (e.g., "1.2.3") into a comparable number.
---@param version string|nil
---@return integer|nil
local function versionToNumber(version)
    if not version then return nil end
    local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    if major and minor and patch then
        return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    else
        return nil
    end
end

-- Fetch the remote version from the JSON file with retry logic.
---@param callback fun(remoteVersion: string|nil, errorState: string|nil)
local function GetVersionFromJSON(callback)
    local scriptName = GetCurrentResourceName()

    local function tryFetch(attempt)
        PerformHttpRequest(versionConfig.updateURL, function(err, text, headers)
            if err == 200 and text then
                local jsonData = json.decode(text)
                if jsonData then
                    if jsonData[scriptName] then
                        local remoteVer = jsonData[scriptName]
                        cachedRemoteVersion = remoteVer -- update our cache
                        callback(remoteVer)
                    else
                        callback(nil, "missing:" .. scriptName)
                    end
                else
                    callback(nil, "decode_failed")
                end
            else
                if attempt < versionConfig.maxRetries then
                    SetTimeout(versionConfig.retryDelay, function()
                        tryFetch(attempt + 1)
                    end)
                else
                    if cachedRemoteVersion then
                        callback(cachedRemoteVersion)
                    else
                        callback(nil, "fetch_failed:" .. tostring(err))
                    end
                end
            end
        end, "GET")
    end

    tryFetch(1)
end

-- Retrieve the local version from the resource manifest.
---@return string|nil
local function GetVersionFromManifest()
    local resourceName = GetCurrentResourceName()
    return GetResourceMetadata(resourceName, "version", 0)
        or GetResourceMetadata(resourceName, "script_version", 0)
end

---@param resourceName string
---@param curVer string
---@param remoteVersion string|nil
local function reportComparison(resourceName, curVer, remoteVersion)
    if remoteVersion then
        local curVerNum = versionToNumber(curVer)
        local remoteVerNum = versionToNumber(remoteVersion)
        if curVerNum and remoteVerNum then
            if curVerNum == remoteVerNum then
                printIfStateChanged(("current:%s:remote:%s:status:current"):format(curVer, remoteVersion), function()
                    print("^2[^6DankLife Gaming ^2- ^0" ..
                        resourceName .. "] You are up to date. Current Version: " .. curVer .. "^0")
                end)
            elseif curVerNum > remoteVerNum then
                printIfStateChanged(("current:%s:remote:%s:status:ahead"):format(curVer, remoteVersion), function()
                    print("^2[^6DankLife Gaming ^2- ^0" ..
                        resourceName .. "] Holy Shit... How did you get this? Version: " .. curVer .. "^0")
                end)
            else
                printIfStateChanged(("current:%s:remote:%s:status:update"):format(curVer, remoteVersion), function()
                    print(
                        "^6--------------------------------------------------------------------------------------------------^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] A new version is available.^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] Current Version: " .. curVer .. "^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. resourceName .. "] New Version: " .. remoteVersion .. "^0")
                    print(
                        "^6--------------------------------------------------------------------------------------------------^0")
                end)
            end
        else
            printIfStateChanged(("current:%s:remote:%s:status:invalid_format"):format(curVer, remoteVersion), function()
                print("^1[^6DankLife Gaming ^2- ^0Error: Invalid version format for comparison.^0")
            end)
        end
    else
        printIfStateChanged(("current:%s:remote:none:status:unavailable"):format(curVer), function()
            print("^1[^6DankLife Gaming ^2- ^0Could not retrieve remote version for " .. resourceName .. ".^0")
        end)
    end
end

-- Runs a full version check.
-- onResult(status, curVer, remoteVer) is called once the check finishes.
-- verbose = true prints the comparison messages to console (used by cron).
---@param onResult? fun(status: string, curVer: string|nil, remoteVer: string|nil)
---@param verbose? boolean
local function RunVersionCheck(onResult, verbose)
    local resourceName = GetCurrentResourceName()
    local curVer = GetVersionFromManifest()

    if not curVer then
        local status = "manifest_missing"
        if verbose then
            printIfStateChanged(status .. ":" .. resourceName, function()
                print("^1[^6DankLife Gaming ^2- ^0Error: version not found in resource manifest for " .. resourceName .. "^0")
            end)
        end
        if onResult then onResult(status, nil, nil) end
        return
    end

    GetVersionFromJSON(function(remoteVersion, errorState)
        local status

        if errorState == "missing:" .. resourceName then
            status = "missing"
            if verbose then
                printIfStateChanged(errorState, function()
                    print("^1[^6DankLife Gaming ^2- ^0No version found for " .. resourceName .. " in scripts_version.json.^0")
                    print("^1[^6DankLife Gaming ^2- ^0Please rename your resource to '" ..
                        versionConfig.originalScriptName .. "' to keep using DankLife Gaming's Custom Version Checker.^0")
                end)
            end
        elseif errorState == "decode_failed" then
            status = "decode_failed"
            if verbose then
                printIfStateChanged(errorState, function()
                    print("^1[^6DankLife Gaming ^2- ^0Failed to decode JSON.^0")
                end)
            end
        elseif errorState and errorState:find("^fetch_failed:") then
            status = "fetch_failed"
            if verbose then
                printIfStateChanged(errorState, function()
                    print("^1[^6DankLife Gaming ^2- ^0Failed to fetch scripts_version.json after " ..
                        versionConfig.maxRetries .. " attempts.^0")
                end)
                if cachedRemoteVersion then
                    reportComparison(resourceName, curVer, cachedRemoteVersion)
                end
            end
        else
            local curVerNum = versionToNumber(curVer)
            local remoteVerNum = versionToNumber(remoteVersion)
            if curVerNum and remoteVerNum then
                if curVerNum == remoteVerNum then
                    status = "current"
                elseif curVerNum > remoteVerNum then
                    status = "ahead"
                else
                    status = "update"
                end
            else
                status = "invalid_format"
            end
            if verbose then
                reportComparison(resourceName, curVer, remoteVersion)
            end
        end

        if onResult then onResult(status, curVer, remoteVersion) end
    end)
end

-- Startup banner

-- Runs the version check and formats the banner line.
---@return string
local function getVersionLine()
    local status, curVer, remoteVer
    local done = false

    RunVersionCheck(function(s, c, r)
        status = s
        curVer = c
        remoteVer = r
        done = true
    end, false)

    -- Wait up to ~10 seconds for the HTTP check to finish
    local waited = 0
    while not done and waited < 10000 do
        Wait(100)
        waited = waited + 100
    end

    if not done then return 'Timed out' end

    if status == 'current' then
        return ('%s (Up to date)'):format(curVer)
    elseif status == 'update' then
        return ('%s -> %s (Update available)'):format(curVer, remoteVer)
    elseif status == 'ahead' then
        return ('%s (Ahead of remote)'):format(curVer)
    elseif status == 'fetch_failed' then
        return ('%s (Offline?)'):format(curVer or '?')
    elseif status == 'missing' then
        return ('%s (Not in version JSON)'):format(curVer or '?')
    elseif status == 'manifest_missing' then
        return 'Not in manifest'
    else
        return curVer or 'Unknown'
    end
end

CreateThread(function()
    Wait(5000) -- Wait a brief moment to ensure all state bags are resolved

    local rows = {
        { 'Framework', sharedConfig.Framework },
        { 'Inventory', sharedConfig.Inventory },
        { 'Banking',   sharedConfig.Banking },
        { 'Target',    sharedConfig.Target },
        { 'Menu',      sharedConfig.Menu },
        { 'Phone',     sharedConfig.Phone },
        { 'Fuel',      sharedConfig.Fuel },
        { 'Keys',      sharedConfig.Keys },
        { 'Garage',    sharedConfig.Garage },
        { 'Debug',     sharedConfig.Debug },
        { 'Version',   getVersionLine() },
    }

    -- Size both columns and the border from the longest visible text
    local titleWidth, valueWidth = 0, 0
    for _, row in ipairs(rows) do
        titleWidth = math.max(titleWidth, #row[1])
        local valueText = row[2] == 'none' and 'Not Found' or tostring(row[2])
        valueWidth = math.max(valueWidth, visibleLen(valueText))
    end

    -- Each row is: | + space + title + space + | + space + value + space + |  (7 extra chars)
    local totalWidth = titleWidth + valueWidth + 7
    local border = '^5' .. string.rep('=', totalWidth)

    local banner = {
        border,
        formatTitleLine('DankLife Utilities', totalWidth),
        border,
    }
    for _, row in ipairs(rows) do
        banner[#banner + 1] = formatLine(row[1], row[2], titleWidth, valueWidth)
    end
    banner[#banner + 1] = border

    print('^7')
    for _, line in ipairs(banner) do
        print(line)
    end
    print('^7')
end)

-- Hourly scheduled check (prints to console).
lib.cron.new(versionConfig.cronExpression, function(task, date)
    RunVersionCheck(nil, true)
end, { debug = false })
