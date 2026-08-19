local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local exports = exports
local print = print
local Wait = Wait

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@class DankUi
local ui = {}

if IsDuplicityVersion() then
    -- SERVER
    ---@param source integer
    ---@param message string
    ---@param messageType? string
    ---@param timeLength? number
    ui.notify = function(source, message, messageType, timeLength)
        local time = timeLength or 5000
        LogDebug(('[ui] notify(source=%s, type=%s) framework=%s'):format(tostring(source), tostring(messageType), tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:Notify(source, message, messageType, time)
        elseif sharedConfig.Framework == 'qb-core' then
            TriggerClientEvent('QBCore:Notify', source, message, messageType, time)
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerClientEvent('esx:showNotification', source, message, messageType, time)
        elseif sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            TriggerClientEvent('ox_lib:notify', source, {
                description = message,
                type = messageType,
                duration = time,
            })
        else
            LogDebug('[ui] notify: chat fallback (no framework detected)')
            TriggerClientEvent('chat:addMessage', source, { args = {message} })
        end
    end
else
    -- CLIENT
    ---@param message string
    ---@param type string
    ---@param timeLength? number
    ui.notify = function(message, type, timeLength)
        local time = timeLength or 5000
        LogDebug(('[ui] notify(type=%s) framework=%s'):format(tostring(type), tostring(sharedConfig.Framework)))
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:Notify(message, type, time)
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            if core then core.Functions.Notify(message, type, time) end
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerEvent('esx:showNotification', message, type, time)
        elseif sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            if lib then
                lib.notify({ description = message, type = type, duration = time })
            else
                TriggerEvent('chat:addMessage', { args = {message} })
            end
        else
            TriggerEvent('chat:addMessage', { args = {message} })
        end
    end

    ui.toggleDuty = function()
        LogDebug('[ui] toggleDuty called')
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            TriggerServerEvent("QBCore:ToggleDuty")
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerServerEvent("esx:toggleDuty")
        elseif sharedConfig.Framework == 'ND_Core' then
            exports["ND_Core"]:toggleDuty()
        end
    end

    ---@param params table
    ui.progressbar = function(params)
        params = params or {}
        local framework = sharedConfig.Framework
        local name = params.name or 'progress'
        local label = params.label or 'Action'
        local duration = params.duration or 5000
        local useWhileDead = params.useWhileDead or false
        local canCancel = params.canCancel or false
        local disableControls = params.disableControls or {}
        local animation = params.animation or {}
        local prop = params.prop or {}
        local onFinish = params.onFinish or function() end
        local onCancel = params.onCancel or function() end

        if lib and lib.progressBar then
            LogDebug(('[ui] progressbar(%s) using ox_lib'):format(tostring(label)))
            local options = {
                duration = duration,
                label = label,
                useWhileDead = useWhileDead,
                canCancel = canCancel,
                disable = disableControls,
                anim = animation,
                prop = prop,
            }
            if lib.progressBar(options) then onFinish() else onCancel() end
        elseif framework == 'qb-core' then
            LogDebug(('[ui] progressbar(%s) using framework Progressbar'):format(tostring(label)))
            local core = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()
            if core and core.Functions and core.Functions.Progressbar then
                core.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, nil, onFinish, onCancel)
            else
                Wait(duration)
                onFinish()
            end
        else
            LogDebug(('[ui] progressbar(%s) timed fallback (no progress system)'):format(tostring(label)))
            ui.notify(label .. '...', 'info', duration)
            Wait(duration)
            onFinish()
        end
    end
end

return ui
