local exports = exports
local print = print

local sharedConfig = require 'config.shared'
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
    player.getData = function()
        if sharedConfig.Framework == 'qbx_core' then
            return QBX.PlayerData or {}
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
