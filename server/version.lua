local jsonURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json"

-- Convert version string (e.g., "1.2.3") to a number for comparison
local function versionToNumber(version)
    local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    if major and minor and patch then
        return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
    else
        print("^1Invalid version format: " .. version .. "^0")
        return nil
    end
end

-- Fetch remote version from JSON with retry logic
local function GetVersionFromJSON(callback)
    local scriptName = GetCurrentResourceName()
    local maxRetries = 3
    local retryDelay = 5000 -- 5 seconds

    local function tryFetch(attempt)
        PerformHttpRequest(jsonURL, function(err, text, headers)
            if err == 200 and text then
                local jsonData, decodeErr = json.decode(text)
                if jsonData then
                    for _, job in ipairs(jsonData) do
                        if job.scriptName == scriptName then
                            callback(job.version)
                            return
                        end
                    end
                    print("^1No version found for " .. scriptName .. " in scripts_version.json.^0")
                    callback(nil)
                else
                    print("^1Failed to decode JSON: " .. tostring(decodeErr) .. "^0")
                    callback(nil)
                end
            else
                if attempt < maxRetries then
                    print("^1Error fetching scripts_version.json: " .. tostring(err) .. ". Retrying in " .. (retryDelay / 1000) .. " seconds...^0")
                    SetTimeout(retryDelay, function()
                        tryFetch(attempt + 1)
                    end)
                else
                    print("^1Failed to fetch scripts_version.json after " .. maxRetries .. " attempts.^0")
                    callback(nil)
                end
            end
        end, "GET")
    end

    tryFetch(1)
end

-- Get local version from manifest using GetResourceMetadata
local function GetVersionFromManifest()
    return GetResourceMetadata(GetCurrentResourceName(), "script_version", 0)
end

-- Check for updates and compare versions
local function CheckForUpdates()
    Wait(5000) -- Keep the delay to ensure server initialization
    local curVer = GetVersionFromManifest()
    if not curVer then
        print("^1Error: script_version not found in resource manifest for " .. GetCurrentResourceName() .. "^0")
        return
    end

    GetVersionFromJSON(function(remoteVersion)
        if remoteVersion then
            local curVerNum = versionToNumber(curVer)
            local remoteVerNum = versionToNumber(remoteVersion)
            if curVerNum and remoteVerNum then
                if curVerNum == remoteVerNum then
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2You are up to date. ^5Current Version: ^3" .. curVer .. "^0")
                elseif curVerNum > remoteVerNum then
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2Holy Shit... How did you get this?. ^5Version: ^3" .. curVer .. "^0")
                else
                    print("^6--------------------------------------------------------------------------------------------------^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^3A new version is available.^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^5Current Version: ^3" .. curVer .. "^0")
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2New Version: ^3" .. remoteVersion .. "^0")
                    print("^6--------------------------------------------------------------------------------------------------^0")
                end
            else
                print("^1Error: Invalid version format for comparison.^0")
            end
        else
            print("^1Could not retrieve remote version for " .. GetCurrentResourceName() .. ".^0")
        end
    end)
end

-- Start the update check in a thread
CreateThread(function()
    local currentResourceName = GetCurrentResourceName()
    if currentResourceName ~= "Dank_Utils" then
        print("^1ERROR: Resource name is not Dank_Utils. Please ensure the resource name is Dank_Utils.^0")
        return
    end
    CheckForUpdates()
end)