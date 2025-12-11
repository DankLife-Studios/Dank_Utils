local jsonURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json"
local RESOURCE_NAME = "Dank_Utils"
local MAX_RETRIES = 3
local RETRY_DELAY = 5000 -- 5 seconds

-- Convert version string (e.g., "1.2.3") to a table for comparison
local function parseVersion(version)
    local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
    if major and minor and patch then
        return {
            major = tonumber(major),
            minor = tonumber(minor),
            patch = tonumber(patch)
        }
    else
        print("^1Invalid version format: " .. tostring(version) .. "^0")
        return nil
    end
end

-- Compare two version tables. Returns 0 if equal, 1 if v1 > v2, -1 if v1 < v2
local function compareVersions(v1, v2)
    if v1.major ~= v2.major then return v1.major > v2.major and 1 or -1 end
    if v1.minor ~= v2.minor then return v1.minor > v2.minor and 1 or -1 end
    if v1.patch ~= v2.patch then return v1.patch > v2.patch and 1 or -1 end
    return 0
end

-- Fetch remote version from JSON with retry logic
local function GetVersionFromJSON(callback)
    local scriptName = GetCurrentResourceName()

    local function tryFetch(attempt)
        PerformHttpRequest(jsonURL, function(status, text, headers)
            if status == 200 and text then
                local success, jsonData = pcall(json.decode, text)
                if success and jsonData then
                    for _, job in ipairs(jsonData) do
                        if job.scriptName == scriptName then
                            callback(job.version)
                            return
                        end
                    end
                    print("^1No version found for " .. scriptName .. " in scripts_version.json.^0")
                    callback(nil)
                else
                    print("^1Failed to decode JSON: " .. tostring(jsonData) .. "^0")
                    callback(nil)
                end
            else
                if attempt < MAX_RETRIES then
                    print("^1Error fetching scripts_version.json: " .. tostring(status) .. ". Retrying in " .. (RETRY_DELAY / 1000) .. " seconds...^0")
                    SetTimeout(RETRY_DELAY, function()
                        tryFetch(attempt + 1)
                    end)
                else
                    print("^1Failed to fetch scripts_version.json after " .. MAX_RETRIES .. " attempts.^0")
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
            local curVerObj = parseVersion(curVer)
            local remoteVerObj = parseVersion(remoteVersion)
            
            if curVerObj and remoteVerObj then
                local comparison = compareVersions(curVerObj, remoteVerObj)
                
                if comparison == 0 then
                    print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2You are up to date. ^5Current Version: ^3" .. curVer .. "^0")
                elseif comparison == 1 then
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
    if currentResourceName ~= RESOURCE_NAME then
        print("^1ERROR: Resource name is not " .. RESOURCE_NAME .. ". Please ensure the resource name is " .. RESOURCE_NAME .. ".^0")
        return
    end
    CheckForUpdates()
end)
