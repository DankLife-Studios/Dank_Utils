local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local exports = exports
local print = print
local Wait = Wait

local sharedConfig = require 'config.dankutils_shared'
local ui = {}

if IsDuplicityVersion() then
    -- SERVER
    ui.notify = function(source, message, messageType, timeLength)
        local time = timeLength or 5000
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:Notify(source, message, messageType, time)
        elseif sharedConfig.Framework == 'qb-core' then
            TriggerClientEvent('QBCore:Notify', source, message, messageType, time)
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerClientEvent('esx:showNotification', source, message, messageType, time)
        elseif sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            TriggerClientEvent('ox_lib:notify', source, { description = message, type = messageType })
        else
            TriggerClientEvent('chat:addMessage', source, { args = {message} })
        end
    end
else
    -- CLIENT
    ui.notify = function(message, type, timeLength)
        local time = timeLength or 5000
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:Notify(message, type, time)
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            if core then core.Functions.Notify(message, type, time) end
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerEvent('esx:showNotification', message, type, time)
        elseif sharedConfig.Framework == 'ND_Core' or sharedConfig.Framework == 'ox_core' then
            if lib then
                lib.notify({ description = message, type = type })
            else
                TriggerEvent('chat:addMessage', { args = {message} })
            end
        else
            TriggerEvent('chat:addMessage', { args = {message} })
        end
    end

    ui.toggleDuty = function()
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            TriggerServerEvent("QBCore:ToggleDuty")
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerServerEvent("esx:toggleDuty")
        elseif sharedConfig.Framework == 'ND_Core' then
            exports["ND_Core"]:toggleDuty()
        end
    end

    ui.progressbar = function(params)
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

        if framework == 'qbx_core' or framework == 'ND_Core' or framework == 'ox_core' then
            if not lib then print('^3[Dank_Utils] Progressbar: ox_lib not found.^0') return end
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
            local core = exports['qb-core']:GetCoreObject()
            if core then
                core.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, nil, onFinish, onCancel)
            end
        elseif framework == 'es_extended' then
            print('^3[Dank_Utils] Progressbar: ESX progress bar not natively supported, using chat fallback.^0')
            ui.notify(label .. ' in progress...', 'info', duration)
            Wait(duration)
            onFinish()
        else
            print('^3[Dank_Utils] Progressbar: No framework detected.^0')
        end
    end
end

return ui
