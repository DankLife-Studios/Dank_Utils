local exports = exports
local print = print

local sharedConfig = require 'config.dankutils_shared'
local player = {}

if IsDuplicityVersion() then
    -- SERVER
    player.get = function(source)
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

    player.getAll = function()
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

    player.getCharInfo = function(source)
        local p = player.get(source)
        if not p then return { firstname = '', lastname = '' } end
        
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return {
                firstname = p.PlayerData.charinfo.firstname or '',
                lastname = p.PlayerData.charinfo.lastname or ''
            }
        elseif sharedConfig.Framework == 'es_extended' then
            return {
                firstname = p.get('firstName') or '',
                lastname = p.get('lastName') or ''
            }
        elseif sharedConfig.Framework == 'ND_Core' then
            return {
                firstname = p.getData("firstname") or '',
                lastname = p.getData("lastname") or ''
            }
        elseif sharedConfig.Framework == 'ox_core' then
            return {
                firstname = p.get('firstName') or '',
                lastname = p.get('lastName') or ''
            }
        end
        return { firstname = '', lastname = '' }
    end

    player.getMetadata = function(source, key)
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

    player.setMetadata = function(source, key, val)
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

    player.getJob = function(source)
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

    player.setJob = function(source, jobName, gradeLevel)
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

    player.getMoney = function(source, account)
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

    player.removeMoney = function(source, account, amount, reason)
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

    player.getByCitizenId = function(citizenid)
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:GetPlayerByCitizenId(citizenid)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore and QBCore.Functions.GetPlayerByCitizenId(citizenid)
        elseif sharedConfig.Framework == 'es_extended' then
            print('^3[Dank_Utils] GetPlayerByCitizenId not natively supported for ESX.^0')
            return nil
        elseif sharedConfig.Framework == 'ND_Core' then
            return exports["ND_Core"]:getPlayerById(citizenid)
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetPlayerByFilter({ charid = citizenid })
        end
    end
else
    -- CLIENT
    player.getJob = function()
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

    player.getData = function()
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
end

return player
