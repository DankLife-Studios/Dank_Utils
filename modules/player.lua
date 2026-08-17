local exports = exports
local print = print

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug

---@class DankPlayer
local player = {}

if IsDuplicityVersion() then
    -- SERVER
    ---@param source string|integer
    ---@return table|nil
    player.get = function(source)
        LogDebug(('[player] get(source=%s) framework=%s'):format(tostring(source), tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetPlayer(source)
        elseif sharedConfig.Framework == 'qb-core' then
            return exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
        elseif sharedConfig.Framework == 'es_extended' then
            return exports['es_extended']:getSharedObject().GetPlayerFromId(source)
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getPlayer(source)
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetPlayer(source)
        end
    end

    ---@return table
    player.getAll = function()
        LogDebug(('[player] getAll framework=%s'):format(tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetQBPlayers() or {}
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Functions.GetQBPlayers() or {}
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX and ESX.GetPlayers() or {}
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getPlayers() or {}
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetPlayers() or {}
        end
        return {}
    end

    ---@param source integer
    ---@return table
    player.getCharInfo = function(source)
        LogDebug(('[player] getCharInfo(source=%s)'):format(tostring(source)))
        local p = player.get(source)
        if not p then return { firstname = '', lastname = '', birthdate = '', gender = 0, nationality = '' } end
        
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return {
                firstname = p.PlayerData.charinfo.firstname or '',
                lastname = p.PlayerData.charinfo.lastname or '',
                birthdate = p.PlayerData.charinfo.birthdate or '',
                gender = p.PlayerData.charinfo.gender or 0,
                nationality = p.PlayerData.charinfo.nationality or ''
            }
        elseif sharedConfig.Framework == 'es_extended' then
            return {
                firstname = p.get('firstName') or '',
                lastname = p.get('lastName') or '',
                birthdate = p.get('dateofbirth') or '',
                gender = p.get('sex') == 'm' and 0 or 1,
                nationality = ''
            }
        elseif sharedConfig.Framework == 'ND_Core' then
            return {
                firstname = p.getData("firstname") or '',
                lastname = p.getData("lastname") or '',
                birthdate = p.getData("dob") or '',
                gender = p.getData("gender") == 'Male' and 0 or 1,
                nationality = ''
            }
        elseif sharedConfig.Framework == 'ox_core' then
            return {
                firstname = p.get('firstName') or '',
                lastname = p.get('lastName') or '',
                birthdate = p.get('dateOfBirth') or '',
                gender = p.get('gender') == 'male' and 0 or 1,
                nationality = ''
            }
        end
        return { firstname = '', lastname = '', birthdate = '', gender = 0, nationality = '' }
    end

    ---@param source integer
    ---@param key string
    ---@return any
    player.getMetadata = function(source, key)
        LogDebug(('[player] getMetadata(source=%s, key=%s)'):format(tostring(source), tostring(key)))
        local p = player.get(source)
        if not p then return nil end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return p.PlayerData.metadata and p.PlayerData.metadata[key] or nil
        elseif sharedConfig.Framework == 'es_extended' then
            if p.getMeta then return p.getMeta(key) end
            return nil
        elseif sharedConfig.Framework == 'ND_Core' then
            return p.getData(key)
        elseif sharedConfig.Framework == 'ox_core' then
            return p.get(key)
        end
        return nil
    end

    ---@param source integer
    ---@param key string
    ---@param val any
    ---@return boolean
    player.setMetadata = function(source, key, val)
        LogDebug(('[player] setMetadata(source=%s, key=%s)'):format(tostring(source), tostring(key)))
        local p = player.get(source)
        if not p then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            p.Functions.SetMetaData(key, val)
            return true
        elseif sharedConfig.Framework == 'es_extended' then
            if p.setMeta then 
                p.setMeta(key, val)
                return true
            end
            return false
        elseif sharedConfig.Framework == 'ND_Core' then
            p.setData(key, val)
            return true
        elseif sharedConfig.Framework == 'ox_core' then
            p.set(key, val)
            return true
        end
        return false
    end

    ---@param source integer
    ---@return table
    player.getJob = function(source)
        LogDebug(('[player] getJob(source=%s)'):format(tostring(source)))
        local p = player.get(source)
        local fallback = { name = 'unemployed', grade = { name = 'Freelancer', level = 0 } }
        if not p then return fallback end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local job = p.PlayerData.job
            if not job then return fallback end
            return {
                name = job.name,
                grade = {
                    name = job.grade.name,
                    level = job.grade.level
                }
            }
        elseif sharedConfig.Framework == 'es_extended' then
            local job = p.job
            if not job then return fallback end
            return {
                name = job.name,
                grade = {
                    name = job.grade_name,
                    level = job.grade
                }
            }
        elseif sharedConfig.Framework == 'ND_Core' then
            local job = p.getJob()
            if not job then return fallback end
            return {
                name = job,
                grade = {
                    name = p.getJobRole() or 'Employee',
                    level = 0
                }
            }
        elseif sharedConfig.Framework == 'ox_core' then
            local group = p.getGroupByType('job')
            if group then
                return {
                    name = group[1],
                    grade = {
                        name = 'Grade ' .. tostring(group[2]),
                        level = group[2]
                    }
                }
            end
            return fallback
        end
        return fallback
    end

    ---@param source integer
    ---@param jobName string
    ---@param gradeLevel integer|string
    ---@return boolean
    player.setJob = function(source, jobName, gradeLevel)
        LogDebug(('[player] setJob(source=%s, job=%s, grade=%s)'):format(tostring(source), tostring(jobName), tostring(gradeLevel)))
        local p = player.get(source)
        if not p then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return p.Functions.SetJob(jobName, gradeLevel)
        elseif sharedConfig.Framework == 'es_extended' then
            p.setJob(jobName, gradeLevel)
            return true
        elseif sharedConfig.Framework == 'ND_Core' then
            p.setJob(jobName, gradeLevel)
            return true
        elseif sharedConfig.Framework == 'ox_core' then
            p.setGroup(jobName, gradeLevel)
            return true
        end
        return false
    end

    ---@param source integer
    ---@param account string
    ---@return number
    player.getMoney = function(source, account)
        LogDebug(('[player] getMoney(source=%s, account=%s)'):format(tostring(source), tostring(account)))
        local p = player.get(source)
        if not p then return 0 end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return p.PlayerData.money[account] or 0
        elseif sharedConfig.Framework == 'es_extended' then
            if account == 'cash' then account = 'money' end
            local acc = p.getAccount(account)
            return acc and acc.money or 0
        elseif sharedConfig.Framework == 'ND_Core' then
            if account == 'cash' then return p.getData('cash') or 0
            elseif account == 'bank' then return p.getData('bank') or 0 end
            return 0
        elseif sharedConfig.Framework == 'ox_core' then
            if account == 'cash' then account = 'money' end
            return exports.ox_inventory:Search(source, 'count', account) or 0
        end
        return 0
    end

    ---@param source integer
    ---@param account string
    ---@param amount number
    ---@param reason? string
    ---@return boolean
    player.removeMoney = function(source, account, amount, reason)
        LogDebug(('[player] removeMoney(source=%s, account=%s, amount=%s)'):format(tostring(source), tostring(account), tostring(amount)))
        local p = player.get(source)
        if not p then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return p.Functions.RemoveMoney(account, amount, reason)
        elseif sharedConfig.Framework == 'es_extended' then
            if account == 'cash' then account = 'money' end
            if p.getAccount(account) and p.getAccount(account).money >= amount then
                p.removeAccountMoney(account, amount, reason)
                return true
            end
            return false
        elseif sharedConfig.Framework == 'ND_Core' then
            return p.deductMoney(account, amount, reason)
        elseif sharedConfig.Framework == 'ox_core' then
            if account == 'cash' then account = 'money' end
            local count = exports.ox_inventory:Search(source, 'count', account)
            if count and count >= amount then
                return exports.ox_inventory:RemoveItem(source, account, amount)
            end
            return false
        end
        return false
    end

    ---@param source integer
    ---@param account string
    ---@param amount number
    ---@param reason? string
    ---@return boolean
    player.addMoney = function(source, account, amount, reason)
        LogDebug(('[player] addMoney(source=%s, account=%s, amount=%s)'):format(tostring(source), tostring(account), tostring(amount)))
        local p = player.get(source)
        if not p then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            if p.Functions and p.Functions.AddMoney then
                return p.Functions.AddMoney(account, amount, reason)
            end
        elseif sharedConfig.Framework == 'es_extended' then
            if account == 'cash' then account = 'money' end
            if p.addAccountMoney then
                p.addAccountMoney(account, amount, reason)
                return true
            end
        elseif sharedConfig.Framework == 'ND_Core' then
            if p.addMoney then return p.addMoney(account, amount, reason) end
        elseif sharedConfig.Framework == 'ox_core' then
            if account == 'cash' then account = 'money' end
            return exports.ox_inventory:AddItem(source, account, amount)
        end
        return false
    end

    ---@param citizenid string
    ---@return table|nil
    player.getByCitizenId = function(citizenid)
        LogDebug(('[player] getByCitizenId(citizenid=%s)'):format(tostring(citizenid)))
        if sharedConfig.Framework == 'qbx_core' then
            local ply = exports.qbx_core:GetPlayerByCitizenId(citizenid)
            if ply then return ply end
            local ok, offlinePlayer = pcall(function()
                return exports.qbx_core:GetOfflinePlayer(citizenid)
            end)
            if ok then return offlinePlayer end
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            if not QBCore then return nil end
            local ply = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if ply then return ply end
            if QBCore.Player and QBCore.Player.GetOfflinePlayer then
                local ok, offlinePlayer = pcall(function()
                    return QBCore.Player.GetOfflinePlayer(citizenid)
                end)
                if ok then return offlinePlayer end
            end
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX and (ESX.GetPlayerFromIdentifier(citizenid) or ESX.GetPlayerFromId(tonumber(citizenid)))
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getPlayerById(citizenid)
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetPlayerByFilter({ charid = citizenid })
        end
    end

    ---@param identifier string
    ---@param charInfoKey string
    ---@param value any
    ---@return boolean
    player.setCharInfo = function(identifier, charInfoKey, value)
        LogDebug(('[player] setCharInfo(identifier=%s, key=%s)'):format(tostring(identifier), tostring(charInfoKey)))
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:SetCharInfo(identifier, charInfoKey, value)
        elseif sharedConfig.Framework == 'qb-core' then
            local p = player.get(identifier)
            if p then
                local charinfo = p.PlayerData.charinfo
                charinfo[charInfoKey] = value
                p.Functions.SetPlayerData("charinfo", charinfo)
                return true
            end
        end
        return false
    end

    ---@param source integer
    ---@return boolean
    player.isOnDuty = function(source)
        LogDebug(('[player] isOnDuty(source=%s)'):format(tostring(source)))
        local p = player.get(source)
        if not p then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return (p.PlayerData and p.PlayerData.job and p.PlayerData.job.onduty) or false
        elseif sharedConfig.Framework == 'es_extended' then
            if p.getMeta then
                local duty = p.getMeta('duty')
                if duty ~= nil then return duty end
            end
            return true
        elseif sharedConfig.Framework == 'ND_Core' then
            if exports["ND_Core"] and exports["ND_Core"].isPlayerOnDuty then
                return exports["ND_Core"]:isPlayerOnDuty(source)
            end
            return true
        elseif sharedConfig.Framework == 'ox_core' then
            return true
        end
        return false
    end

    ---@param source integer
    ---@return string|nil
    player.getIdentifier = function(source)
        LogDebug(('[player] getIdentifier(source=%s)'):format(tostring(source)))
        local p = player.get(source)
        if not p then return nil end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return p.PlayerData.citizenid
        elseif sharedConfig.Framework == 'es_extended' then
            return p.identifier
        elseif sharedConfig.Framework == 'ND_Core' then
            return p.id
        elseif sharedConfig.Framework == 'ox_core' then
            return p.charid
        end
        return nil
    end
else
    -- CLIENT
    ---@return boolean
    player.isOnDuty = function()
        LogDebug('[player] isOnDuty [client]')
        local data = player.getData()
        if not data then return false end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return (data.job and data.job.onduty) or false
        elseif sharedConfig.Framework == 'es_extended' then
            return true
        elseif sharedConfig.Framework == 'ND_Core' then
            return true
        elseif sharedConfig.Framework == 'ox_core' then
            return true
        end
        return false
    end

    ---@return table
    player.getJob = function()
        LogDebug('[player] getJob [client]')
        local data = player.getData()
        local fallback = { name = 'unemployed', grade = { name = 'Freelancer', level = 0 } }
        if not data then return fallback end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local job = data.job
            if not job then return fallback end
            return {
                name = job.name,
                grade = {
                    name = job.grade.name,
                    level = job.grade.level
                }
            }
        elseif sharedConfig.Framework == 'es_extended' then
            local job = data.job
            if not job then return fallback end
            return {
                name = job.name,
                grade = {
                    name = job.grade_name,
                    level = job.grade
                }
            }
        elseif sharedConfig.Framework == 'ND_Core' then
            local job = data.job
            if not job then return fallback end
            return {
                name = job,
                grade = {
                    name = data.jobRole or 'Employee',
                    level = 0
                }
            }
        elseif sharedConfig.Framework == 'ox_core' then
            local groups = data.groups
            if groups and groups['job'] then
                -- This is a simplification for client side ox_core groups
                return {
                    name = groups['job'],
                    grade = {
                        name = 'Grade ' .. tostring(groups['job']),
                        level = groups['job']
                    }
                }
            end
            return fallback
        end
        return fallback
    end

    ---@return table
    player.getData = function()
        LogDebug(('[player] getData framework=%s [client]'):format(tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetPlayerData() or {}
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            return core and core.Functions.GetPlayerData() or {}
        elseif sharedConfig.Framework == 'es_extended' then
            local esx = exports['es_extended']:getSharedObject()
            return esx and esx.GetPlayerData() or {}
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getCharacter() or {}
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetPlayerData() or {}
        end
        print('^3[Dank_Utils] GetPlayerData: No framework detected.^0')
        return {}
    end

    ---@return string|nil
    player.getIdentifier = function()
        LogDebug('[player] getIdentifier [client]')
        local data = player.getData()
        if not data then return nil end

        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return data.citizenid
        elseif sharedConfig.Framework == 'es_extended' then
            return data.identifier
        elseif sharedConfig.Framework == 'ND_Core' then
            return data.id
        elseif sharedConfig.Framework == 'ox_core' then
            return data.charid
        end
        return nil
    end
end

return player
