local exports = exports
local print = print
local string = string
local tonumber = tonumber
local type = type

local sharedConfig = require 'config.dankutils_shared'
local core = {}

-- Provide access to raw framework functions just in case
core.getFunctions = function()
    if sharedConfig.Framework == 'qbx_core' then return exports.qbx_core
    elseif sharedConfig.Framework == 'qb-core' then return exports['qb-core']:GetCoreObject().Functions 
    elseif sharedConfig.Framework == 'ND_Core' then return exports["ND_Core"]
    elseif sharedConfig.Framework == 'ox_core' then return exports.ox_core
    end
end

if IsDuplicityVersion() then
    -- SERVER
    core.getJob = function(jobname)
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetJob(jobname)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Shared.Jobs[jobname]
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX and ESX.Jobs[jobname]
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getGroups()[jobname]
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetGroup(jobname)
        end
    end

    core.getAllJobs = function()
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetJobs() or {}
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Shared.Jobs or {}
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX and ESX.Jobs or {}
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getGroups() or {}
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetGroups() or {}
        end
        return {}
    end

    core.addCommand = function(name, description, args, restricted, callback, group)
        if sharedConfig.Framework == 'qbx_core' then
            if not lib then return end
            lib.addCommand(name, { help = description, params = args, permission = group or "user" }, callback)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Commands.Add(name, description, args, restricted, callback, group)
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.RegisterCommand(name, group or 'user', callback, restricted, {help = description})
        elseif sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            if not lib then return end
            lib.addCommand(name, { help = description, params = args, permission = group or "user" }, callback)
        end
    end

    -- Convert a version string (e.g., "1.2.3", "1.0", "v2.0-beta") into a comparable number.
    local function versionToNumber(version)
        if not version then return nil end
        -- Remove any non-numeric and non-dot characters
        version = string.gsub(version, "[^%d%.]", "")
        local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")
        if major and minor and patch then
            return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
        end
        major, minor = string.match(version, "(%d+)%.(%d+)")
        if major and minor then
            return tonumber(major) * 10000 + tonumber(minor) * 100
        end
        major = string.match(version, "^(%d+)$")
        if major then
            return tonumber(major) * 10000
        end
        return tonumber(version) or 0
    end

    -- Reusable Version Checker
    -- @param options table: { updateURL = string, originalScriptName = string (optional), checkInterval = number (optional ms, default 1 hr) }
    core.versionCheck = function(options)
        local scriptName = GetCurrentResourceName()
        local originalName = scriptName
        local updateURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json"
        local checkInterval = 60 * 60 * 1000 -- Default 1 hour

        if type(options) == 'string' then
            originalName = options
        elseif type(options) == 'table' then
            originalName = options.originalScriptName or originalName
            updateURL = options.updateURL or updateURL
            checkInterval = options.checkInterval or checkInterval
        end
        local cachedRemoteVersion = nil
        local lastReportedState = nil

        local function printIfStateChanged(state, printFn)
            if lastReportedState == state then return end
            lastReportedState = state
            printFn()
        end

        local function getLocalVersion()
            return GetResourceMetadata(scriptName, "version", 0) or GetResourceMetadata(scriptName, "script_version", 0)
        end

        local function reportComparison(curVer, remoteVersion)
            if remoteVersion then
                local curVerNum = versionToNumber(curVer)
                local remoteVerNum = versionToNumber(remoteVersion)
                if curVerNum and remoteVerNum then
                    if curVerNum == remoteVerNum then
                        printIfStateChanged(("current:%s:remote:%s:status:current"):format(curVer, remoteVersion), function()
                            print("^2[^6DankLife Gaming ^2- ^0" .. scriptName .. "] You are up to date. Current Version: " .. curVer .. "^0")
                        end)
                    elseif curVerNum > remoteVerNum then
                        printIfStateChanged(("current:%s:remote:%s:status:ahead"):format(curVer, remoteVersion), function()
                            print("^2[^6DankLife Gaming ^2- ^0" .. scriptName .. "] Holy Shit... How did you get this? Version: " .. curVer .. "^0")
                        end)
                    else
                        printIfStateChanged(("current:%s:remote:%s:status:update"):format(curVer, remoteVersion), function()
                            print("^6--------------------------------------------------------------------------------------------------^0")
                            print("^2[^6DankLife Gaming ^2- ^0" .. scriptName .. "] A new version is available.^0")
                            print("^2[^6DankLife Gaming ^2- ^0" .. scriptName .. "] Current Version: " .. curVer .. "^0")
                            print("^2[^6DankLife Gaming ^2- ^0" .. scriptName .. "] New Version: " .. remoteVersion .. "^0")
                            print("^6--------------------------------------------------------------------------------------------------^0")
                        end)
                    end
                else
                    printIfStateChanged(("current:%s:remote:%s:status:invalid_format"):format(curVer, remoteVersion), function()
                        print("^1[^6DankLife Gaming ^2- ^0" .. scriptName .. "] Error: Invalid version format for comparison.^0")
                    end)
                end
            else
                printIfStateChanged(("current:%s:remote:none:status:unavailable"):format(curVer), function()
                    print("^1[^6DankLife Gaming ^2- ^0Could not retrieve remote version for " .. scriptName .. ".^0")
                end)
            end
        end

        CreateThread(function()
            Wait(5000) -- Init delay
            while true do
                local curVer = getLocalVersion()
                if not curVer then
                    printIfStateChanged("manifest:missing", function()
                        print("^1[^6DankLife Gaming ^2- ^0Error: version not found in resource manifest for " .. scriptName .. "^0")
                    end)
                else
                    PerformHttpRequest(updateURL, function(err, text, headers)
                        if err == 200 and text then
                            local jsonData = json.decode(text)
                            if jsonData then
                                if jsonData[originalName] then
                                    cachedRemoteVersion = jsonData[originalName]
                                    reportComparison(curVer, cachedRemoteVersion)
                                else
                                    printIfStateChanged("missing:" .. originalName, function()
                                        print("^1[^6DankLife Gaming ^2- ^0No version found for " .. originalName .. " in JSON.^0")
                                    end)
                                end
                            else
                                printIfStateChanged("decode_failed", function()
                                    print("^1[^6DankLife Gaming ^2- ^0Failed to decode JSON.^0")
                                end)
                            end
                        else
                            if cachedRemoteVersion then
                                reportComparison(curVer, cachedRemoteVersion)
                            end
                        end
                    end, "GET")
                end
                Wait(checkInterval)
            end
        end)
    end
else
    -- CLIENT
    -- Generic wrapper for player loaded events
    if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            TriggerEvent('Dank:Client:OnPlayerLoaded')
        end)
    elseif sharedConfig.Framework == 'es_extended' then
        AddEventHandler('esx:playerLoaded', function()
            TriggerEvent('Dank:Client:OnPlayerLoaded')
        end)
    end
end

return core
