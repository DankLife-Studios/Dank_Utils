local exports = exports
local print = print
local string = string
local tonumber = tonumber
local type = type

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@class DankCore
local core = {}

-- Provide access to raw framework functions just in case
---@return table|nil
core.getFunctions = function()
    LogDebug(('[core] getFunctions framework=%s'):format(tostring(sharedConfig.Framework)))
    if sharedConfig.Framework == 'qbx_core' then return exports.qbx_core
    elseif sharedConfig.Framework == 'qb-core' then
        local qb = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
        return qb and qb.Functions
    elseif sharedConfig.Framework == 'es_extended' then return exports['es_extended']:getSharedObject()
    elseif sharedConfig.Framework == 'ND_Core' then return exports["ND_Core"]
    elseif sharedConfig.Framework == 'ox_core' then return exports.ox_core
    end
end

if IsDuplicityVersion() then
    -- SERVER
    ---@param jobname string
    ---@return table|nil
    core.getJob = function(jobname)
        LogDebug(('[core] getJob(job=%s) framework=%s'):format(tostring(jobname), tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            local jobs = exports.qbx_core:GetJobs()
            return jobs and jobs[jobname]
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Shared.Jobs and QBCore.Shared.Jobs[jobname]
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            if not ESX then return nil end
            local jobs = (ESX.GetJobs and ESX.GetJobs()) or ESX.Jobs
            return jobs and jobs[jobname]
        elseif sharedConfig.Framework == 'ND_Core' then
            local ND = exports["ND_Core"]
            if ND.getJobs then
                local jobs = ND:getJobs()
                return jobs and jobs[jobname]
            elseif ND.getGroups then
                local groups = ND:getGroups()
                return groups and groups[jobname]
            end
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetGroup(jobname)
        end
    end

    ---@return table
    core.getAllJobs = function()
        LogDebug(('[core] getAllJobs framework=%s'):format(tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetJobs() or {}
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Shared.Jobs or {}
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            if not ESX then return {} end
            return (ESX.GetJobs and ESX.GetJobs()) or ESX.Jobs or {}
        elseif sharedConfig.Framework == 'ND_Core' then
            local ND = exports["ND_Core"]
            if ND.getJobs then return ND:getJobs() or {} end
            if ND.getGroups then return ND:getGroups() or {} end
            return {}
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetGroups() or {}
        end
        return {}
    end

    ---@param name string
    ---@param description? string
    ---@param args? table
    ---@param restricted? boolean
    ---@param callback function
    ---@param group? string
    core.addCommand = function(name, description, args, restricted, callback, group)
        LogDebug(('[core] addCommand(name=%s, group=%s) framework=%s'):format(tostring(name), tostring(group), tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            if lib and lib.addCommand then
                lib.addCommand(name, { help = description, params = args, permission = group or "user" }, callback)
            else
                RegisterCommand(name, function(source, rawArgs)
                    if callback then callback(source, rawArgs) end
                end, restricted or false)
            end
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Commands then
                QBCore.Commands.Add(name, description, args, restricted, callback, group)
            else
                RegisterCommand(name, function(source, rawArgs)
                    if callback then callback(source, rawArgs) end
                end, restricted or false)
            end
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            if ESX and ESX.RegisterCommand then
                ESX.RegisterCommand(name, group or 'user', callback, restricted, {help = description})
            else
                RegisterCommand(name, function(source, rawArgs)
                    if callback then callback(source, rawArgs) end
                end, restricted or false)
            end
        else
            RegisterCommand(name, function(source, rawArgs)
                if callback then callback(source, rawArgs) end
            end, restricted or false)
        end
    end

    -- Convert a version string (e.g., "1.2.3", "1.0", "v2.0-beta") into a comparable number.
    ---@param version string|nil
    ---@return integer|nil
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
        return tonumber(version)
    end

    -- Reusable Version Checker
    -- @param options table: { updateURL = string, originalScriptName = string (optional), checkInterval = number (optional ms, default 1 hr) }
    ---@param options? string|table
    core.versionCheck = function(options)
        local scriptName = GetCurrentResourceName()
        LogDebug(('[core] versionCheck(script=%s, options=%s)'):format(tostring(scriptName), type(options)))
        local originalName = scriptName
        local updateURL = "https://raw.githubusercontent.com/DankLife-Studios/scripts_version/Live/scripts_version.json"
        local checkInterval = 60 * 60 * 1000 -- Default 1 hour

        if type(options) == 'string' then
            originalName = options
        elseif type(options) == 'table' then
            originalName = options.originalScriptName or originalName
            updateURL = options.updateURL or updateURL
            checkInterval = tonumber(options.checkInterval) or checkInterval
        end
        checkInterval = math.max(1000, checkInterval)
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
                            local ok, jsonData = pcall(json.decode, text)
                            if ok and jsonData then
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
                            else
                                reportComparison(curVer, nil)
                            end
                        end
                    end, "GET")
                end
                Wait(checkInterval)
            end
        end)
    end

    ---@param cb function
    core.onPlayerLoaded = function(cb)
        if type(cb) ~= 'function' then return end
        LogDebug(('[core] onPlayerLoaded framework=%s (Server)'):format(tostring(sharedConfig.Framework)))
        local function wrapCb(...)
            local src = source
            local args = {...}
            if not src or src == '' or src == 0 then
                if type(args[1]) == 'table' and args[1].PlayerData and args[1].PlayerData.source then
                    src = args[1].PlayerData.source
                elseif type(args[1]) == 'number' then
                    src = args[1]
                end
            end
            cb(src, ...)
        end

        if sharedConfig.Framework == 'qbx_core' then
            AddEventHandler('qbx_core:server:onPlayerLoaded', wrapCb)
        elseif sharedConfig.Framework == 'qb-core' then
            AddEventHandler('QBCore:Server:PlayerLoaded', wrapCb)
            AddEventHandler('QBCore:Server:OnPlayerLoaded', wrapCb)
        elseif sharedConfig.Framework == 'es_extended' then
            AddEventHandler('esx:playerLoaded', wrapCb)
        elseif sharedConfig.Framework == 'ND_Core' then
            AddEventHandler('ND:characterLoaded', wrapCb)
        elseif sharedConfig.Framework == 'ox_core' then
            AddEventHandler('ox:playerLoaded', wrapCb)
        else
            AddEventHandler('QBCore:Server:PlayerLoaded', wrapCb)
            AddEventHandler('QBCore:Server:OnPlayerLoaded', wrapCb)
            AddEventHandler('qbx_core:server:onPlayerLoaded', wrapCb)
            AddEventHandler('esx:playerLoaded', wrapCb)
            AddEventHandler('ND:characterLoaded', wrapCb)
            AddEventHandler('ox:playerLoaded', wrapCb)
        end
    end
else
    -- CLIENT
    ---@param cb function
    core.onPlayerLoaded = function(cb)
        if type(cb) ~= 'function' then return end
        LogDebug(('[core] onPlayerLoaded framework=%s'):format(tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            AddEventHandler('qbx_core:client:playerLoaded', cb)
        elseif sharedConfig.Framework == 'qb-core' then
            AddEventHandler('QBCore:Client:OnPlayerLoaded', cb)
        elseif sharedConfig.Framework == 'es_extended' then
            AddEventHandler('esx:playerLoaded', cb)
        elseif sharedConfig.Framework == 'ND_Core' then
            AddEventHandler('ND:characterLoaded', cb)
        elseif sharedConfig.Framework == 'ox_core' then
            AddEventHandler('ox:playerLoaded', cb)
        else
            AddEventHandler('QBCore:Client:OnPlayerLoaded', cb)
            AddEventHandler('qbx_core:client:playerLoaded', cb)
            AddEventHandler('esx:playerLoaded', cb)
            AddEventHandler('ND:characterLoaded', cb)
            AddEventHandler('ox:playerLoaded', cb)
        end
    end
end

return core
