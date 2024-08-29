local jsonURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json"

-- Function to get the version from the JSON file hosted on GitHub
function GetVersionFromJSON(callback)
    local scriptName = GetCurrentResourceName()

    PerformHttpRequest(jsonURL, function(err, text, headers)
        if err == 200 and text then
            local jsonData = json.decode(text)
            if jsonData then
                for _, job in ipairs(jsonData) do
                    if job.scriptName == scriptName then
                        callback(job.version)
                        return
                    end
                end
                print("^1No version found for " .. scriptName .. " in scripts_version.json.^0")
            else
                print("^1Failed to decode JSON data from scripts_version.json.^0")
            end
        else
            print("^1Error fetching scripts_version.json: " .. tostring(err) .. "^0")
        end
    end, "GET")
end

-- Function to get the version from the fxmanifest.lua file
function GetVersionFromManifest()
    local fxManifestPath = "fxmanifest.lua"
    local localFile = LoadResourceFile(GetCurrentResourceName(), fxManifestPath)
    if localFile then
        local scriptVersion = localFile:match("script_version%s+'(.-)'")
        if scriptVersion then
            return scriptVersion
        else
            print("^1Error extracting script_version from fxmanifest.lua.^0")
        end
    else
        print("^1Failed to load fxmanifest.lua.^0")
    end
    return nil
end

-- Function to check for updates and log messages
function CheckForUpdates()
    Wait(5000)  -- Ensures this is the last thing displayed after everything starts

    local curVer = GetVersionFromManifest()
    if not curVer then return end

    GetVersionFromJSON(function(remoteVersion)
        if remoteVersion then
            if remoteVersion == curVer then
                print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2You are up to date. ^5Current Version: ^3" .. curVer .. "^0")
            else
                print("^6--------------------------------------------------------------------------------------------------^0")
                print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^3A new version is available on Github.^0")
                print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^5Current Version: ^3" .. curVer .. "^0")
                print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2New Version: ^3" .. remoteVersion .. "^0")
                print("^6--------------------------------------------------------------------------------------------------^0")
            end
        else
            print("^1Error extracting version information from scripts_version.json.^0")
        end
    end)
end

-- Event handler to check the resource name and perform version check
AddEventHandler('onResourceStart', function(resourceName)
    local currentResourceName = GetCurrentResourceName()

    if currentResourceName ~= "Dank_Utils" then
        print("^1ERROR: Resource name is not Dank_Utils. To avoid issues, please ensure the resource name is Dank_Utils.^0")
        return
    end

    if resourceName ~= currentResourceName then
        print("^1ERROR: Resource name (" .. resourceName .. ") does not match the expected name (" .. currentResourceName .. "). Please rename the resource to avoid issues.^0")
        return
    end

    CheckForUpdates()
end)
