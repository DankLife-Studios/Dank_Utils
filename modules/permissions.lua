local exports = exports
local IsPlayerAceAllowed = IsPlayerAceAllowed
local ExecuteCommand = ExecuteCommand
local type = type
local ipairs = ipairs
local pairs = pairs
local tostring = tostring

local sharedConfig = require 'config.dankutils_shared'
local playerModule = require 'modules.player'
local LogDebug = LogDebug

---@class DankPermissions
local permissions = {}

if IsDuplicityVersion() then
    -- SERVER
    --- Check explicit FiveM ACE permission for a player
    ---@param source integer
    ---@param ace string
    ---@return boolean
    permissions.hasAce = function(source, ace)
        if not source or source == 0 or not ace then return false end
        LogDebug(('[permissions] hasAce(source=%s, ace=%s)'):format(tostring(source), tostring(ace)))
        local strAce = tostring(ace)

        if IsPlayerAceAllowed(tostring(source), strAce) then return true end
        if IsPlayerAceAllowed(tostring(source), 'group.' .. strAce) then return true end
        if IsPlayerAceAllowed(tostring(source), 'command.' .. strAce) then return true end
        if IsPlayerAceAllowed(tostring(source), 'command') then return true end

        return false
    end

    --- Check permission (ACE first, then framework)
    ---@param source integer
    ---@param perm string
    ---@return boolean
    permissions.hasPermission = function(source, perm)
        if not source or source == 0 or not perm then return false end
        LogDebug(('[permissions] hasPermission(source=%s, perm=%s)'):format(tostring(source), tostring(perm)))

        -- 1. ACE permission check (Primary)
        if permissions.hasAce(source, perm) then
            return true
        end

        -- 2. Framework specific fallback checks
        if sharedConfig.Framework == 'qbx_core' then
            -- Qbox deprecated HasPermission in v1.8.0+; relies on FiveM ACE permissions
            return permissions.hasAce(source, perm)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Functions and QBCore.Functions.HasPermission then
                if QBCore.Functions.HasPermission(source, perm) then
                    return true
                end
            end
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended'] and exports['es_extended']:getSharedObject()
            if ESX then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer and xPlayer.getGroup then
                    local grp = xPlayer.getGroup()
                    if grp == perm then return true end
                end
            end
        elseif sharedConfig.Framework == 'ND_Core' then
            local ND = exports['ND_Core']
            if ND and ND.getPlayer then
                local p = ND.getPlayer(source)
                if p and p.getGroup and p.getGroup() == perm then
                    return true
                end
            end
        elseif sharedConfig.Framework == 'ox_core' then
            local ox = exports.ox_core
            if ox and ox.GetPlayer then
                local p = ox:GetPlayer(source)
                if p and p.hasGroup and p:hasGroup(perm) then
                    return true
                end
            end
        end

        return false
    end

    --- Get permission level for player
    ---@param source integer
    ---@return string
    permissions.getPermission = function(source)
        if not source or source == 0 then return 'user' end
        LogDebug(('[permissions] getPermission(source=%s)'):format(tostring(source)))

        if sharedConfig.Framework == 'qbx_core' then
            -- Qbox deprecated GetPermission in v1.8.0+; uses ACE checking
            if permissions.isAdmin(source) then return 'admin' end
            return 'user'
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Functions and QBCore.Functions.GetPermission then
                return QBCore.Functions.GetPermission(source)
            end
        end
        if permissions.isAdmin(source) then return 'admin' end
        return 'user'
    end

    --- Add permission to a player or target
    ---@param target integer|string
    ---@param perm string
    ---@return boolean
    permissions.addPermission = function(target, perm)
        if not target or not perm then return false end
        LogDebug(('[permissions] addPermission(target=%s, perm=%s)'):format(tostring(target), tostring(perm)))

        if sharedConfig.Framework == 'qbx_core' then
            -- Qbox v1.8.0+ uses FiveM ACE permissions: add_principal / add_ace
            if type(target) == 'number' then
                local principal = ('player.%s'):format(target)
                ExecuteCommand(('add_principal %s group.%s'):format(principal, perm))
                ExecuteCommand(('add_ace %s %s allow'):format(principal, perm))
            elseif type(target) == 'string' then
                ExecuteCommand(('add_principal %s group.%s'):format(target, perm))
                ExecuteCommand(('add_ace %s %s allow'):format(target, perm))
            end
            return true
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Functions and QBCore.Functions.AddPermission then
                QBCore.Functions.AddPermission(target, perm)
                return true
            end
        end
        return false
    end

    --- Remove permission from a player or target
    ---@param target integer|string
    ---@param perm string
    ---@return boolean
    permissions.removePermission = function(target, perm)
        if not target or not perm then return false end
        LogDebug(('[permissions] removePermission(target=%s, perm=%s)'):format(tostring(target), tostring(perm)))

        if sharedConfig.Framework == 'qbx_core' then
            -- Qbox v1.8.0+ uses FiveM ACE permissions: remove_principal / remove_ace
            if type(target) == 'number' then
                local principal = ('player.%s'):format(target)
                ExecuteCommand(('remove_principal %s group.%s'):format(principal, perm))
                ExecuteCommand(('remove_ace %s %s allow'):format(principal, perm))
            elseif type(target) == 'string' then
                ExecuteCommand(('remove_principal %s group.%s'):format(target, perm))
                ExecuteCommand(('remove_ace %s %s allow'):format(target, perm))
            end
            return true
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core'] and exports['qb-core']:GetCoreObject()
            if QBCore and QBCore.Functions and QBCore.Functions.RemovePermission then
                QBCore.Functions.RemovePermission(target, perm)
                return true
            end
        end
        return false
    end

    --- Check Admin permission via ACE & framework
    ---@param source integer
    ---@return boolean
    permissions.isAdmin = function(source)
        if not source or source == 0 then return false end
        LogDebug(('[permissions] isAdmin(source=%s)'):format(tostring(source)))

        -- Primary: ACE permissions
        local aceAdmins = { 'command', 'admin', 'god', 'group.admin', 'group.god', 'group.superadmin' }
        for _, ace in ipairs(aceAdmins) do
            if IsPlayerAceAllowed(tostring(source), ace) then
                return true
            end
        end

        -- Fallback: check permissions array
        local adminGroups = { 'admin', 'god', 'superadmin', 'mod', 'owner' }
        for _, group in ipairs(adminGroups) do
            if permissions.hasPermission(source, group) then
                return true
            end
        end

        return false
    end

    --- Check job permissions for player
    ---@param source integer
    ---@param jobs string|table
    ---@return boolean
    permissions.hasAnyJob = function(source, jobs)
        if not source or not jobs then return false end
        LogDebug(('[permissions] hasAnyJob(source=%s, jobs=%s)'):format(tostring(source), tostring(jobs)))
        local jobData = playerModule.getJob(source)
        if not jobData or not jobData.name then return false end

        if type(jobs) == 'string' then
            return jobData.name == jobs
        elseif type(jobs) == 'table' then
            if jobs[jobData.name] then return true end
            for _, jName in ipairs(jobs) do
                if jName == jobData.name then return true end
            end
        end
        return false
    end

    --- Comprehensive authorization check
    ---@param source integer
    ---@param options table
    ---@return boolean
    permissions.isAuthorized = function(source, options)
        if not source or not options then return false end
        LogDebug(('[permissions] isAuthorized(source=%s)'):format(tostring(source)))

        -- 1. Check ACE / Admin permissions if allowed
        if options.allowAdmins == true or options.allowAce == true then
            if permissions.isAdmin(source) then
                return true
            end
        end

        -- 2. Check explicit ACE permission string/array if provided
        if options.ace then
            if type(options.ace) == 'string' then
                if permissions.hasAce(source, options.ace) then return true end
            elseif type(options.ace) == 'table' then
                for _, ace in ipairs(options.ace) do
                    if permissions.hasAce(source, ace) then return true end
                end
            end
        end

        -- 3. Check explicit generic permissions string/array if provided
        if options.permissions then
            if type(options.permissions) == 'string' then
                if permissions.hasPermission(source, options.permissions) then return true end
            elseif type(options.permissions) == 'table' then
                for _, perm in ipairs(options.permissions) do
                    if permissions.hasPermission(source, perm) then return true end
                end
            end
        end

        -- 4. Check job permissions if provided
        if options.jobs then
            if permissions.hasAnyJob(source, options.jobs) then
                return true
            end
        end

        return false
    end
else
    -- CLIENT
    ---@param jobs string|table
    ---@return boolean
    permissions.hasAnyJob = function(jobs)
        if not jobs then return false end
        LogDebug(('[permissions] hasAnyJob(jobs=%s) [client]'):format(tostring(jobs)))
        local jobData = playerModule.getJob()
        if not jobData or not jobData.name then return false end

        if type(jobs) == 'string' then
            return jobData.name == jobs
        elseif type(jobs) == 'table' then
            if jobs[jobData.name] then return true end
            for _, jName in ipairs(jobs) do
                if jName == jobData.name then return true end
            end
        end
        return false
    end

    ---@param options table
    ---@return boolean
    permissions.isAuthorized = function(options)
        if not options then return false end
        LogDebug('[permissions] isAuthorized [client]')
        if options.jobs then
            return permissions.hasAnyJob(options.jobs)
        end
        return true
    end
end

return permissions
