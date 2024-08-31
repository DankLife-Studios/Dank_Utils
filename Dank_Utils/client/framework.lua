-- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

local pendingCallbacks = {}

-- Framework function to trigger a server callback
Framework.TriggerServerCallback = function(name, cb, ...)
    local requestId = "CB_" .. math.random(100000, 999999)
    pendingCallbacks[requestId] = cb
    TriggerServerEvent('Dank_Utils:ClientRequest', name, requestId, ...)
end

-- Event to handle server responses
RegisterNetEvent('Dank_Utils:ClientResponse')
AddEventHandler('Dank_Utils:ClientResponse', function(requestId, ...)
    local cb = pendingCallbacks[requestId]
    if cb then
        cb(...)
        pendingCallbacks[requestId] = nil
    end
end)

if SharedConfig.Framework == 'qbx_core' then
    local ox_inventory = exports.ox_inventory

    --- Retrieves the player data from the QBX core.
    --- @return table PlayerData The player data table.
    Framework.GetPlayerData = function()
        return QBX.PlayerData
    end

    --- Retrieves the player data from the QBX core.
    --- @param citizenid string The citizen ID of the player.
    --- @return table PlayerData The player data table, or nil if not found.
    Framework.GetPlayerByCitizenId = function(citizenid)
        return exports.qbx_core:GetPlayerByCitizenId(citizenid)
    end

    --- Notify function to display notifications to the player.
    --- @param message string The message to be displayed.
    --- @param type string The notification type (e.g., 'success', 'error').
    Framework.Notify = function(message, type)
        exports.qbx_core:Notify(message, type)
    end

    --- Retrieves the label of an item from the inventory system.
    --- @param itemName string The name of the item to look up.
    --- @return string getItem The item's label or "Unknown Item" if not found.
    Framework.GetItemLabel = function(itemName)
        local itemNames = {}

        -- Retrieve all items and their labels from ox_inventory
        for item, data in pairs(ox_inventory:Items()) do
            itemNames[item] = data.label
        end

        -- Check if the item exists and has a label
        if itemNames[itemName] then
            return itemNames[itemName]
        else
            return "Unknown Item" -- Return fallback if item is not found
        end
    end

    --- Toggles the player's duty status.
    Framework.ToggleDuty = function()
        TriggerServerEvent("QBCore:ToggleDuty")
    end

    --- Checks if the player has a certain amount of an item in their inventory.
    --- @param item string The item name to check for.
    --- @param amount number The amount of the item required.
    --- @return boolean HasItem True if the player has enough of the item, false otherwise.
    Framework.HasItem = function(item, amount)
        local count = ox_inventory:Search('count', item)
        return count >= amount
    end

    --- Initiates a progress bar with various options for customization.
    --- @param name string The identifier for this progress bar.
    --- @param label string The text displayed on the progress bar.
    --- @param duration number How long the progress bar lasts in milliseconds.
    --- @param useWhileDead boolean If the progress can continue after player death.
    --- @param canCancel boolean Whether the player can cancel this progress.
    --- @param disableControls table A table with booleans to disable controls during progress.
    --- @param animation table Contains the animation dictionary, clip, and flags.
    --- @param prop table Details of the prop to be used during the animation.
    --- @param propTwo table Details for an optional second prop.
    --- @param onFinish function Function to call when progress completes.
    --- @param onCancel function Function to call when progress is cancelled.
    Framework.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        local options = {
            duration = duration,
            label = label,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            disable = {
                move = disableControls.disableMovement,
                car = disableControls.disableCarMovement,
                combat = disableControls.disableCombat,
                mouse = disableControls.disableMouse,
            },
            anim = {
                dict = animation.animDict,
                clip = animation.anim,
                flag = animation.flags,
                -- Add other animation options if needed, default values can be set here or left out if ox_lib provides defaults
            },
            prop = prop, -- Assuming prop structure matches ox_lib's expectations
            -- If you need propTwo, you might need to handle it differently or adjust ox_lib's expectations
        }

        -- Call the progress bar and handle the result
        if lib.progressBar(options) then
            onFinish() -- Success callback
        else
            onCancel() -- Cancellation callback
        end
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

elseif SharedConfig.Framework == 'qb-core' then
    -- Initialize QBCore framework
    local QBCore = exports['qb-core']:GetCoreObject()

    --- Retrieves the player data from the QBCore core.
    --- @return table PlayerData The player data table.
    Framework.GetPlayerData = function()
        return QBCore.Functions.GetPlayerData()
    end

    --- Retrieves the player data from the QBX core.
    --- @param citizenid string The citizen ID of the player.
    --- @return table PlayerData The player data table, or nil if not found.
    Framework.GetPlayerByCitizenId = function(citizenid)
        return QBCore.Functions.GetPlayerByCitizenId(citizenid)
    end

    --- Notify function to display notifications to the player.
    --- @param message string The message to be displayed.
    --- @param type string The notification type (e.g., 'success', 'error').
    Framework.Notify = function(message, type)
        QBCore.Functions.Notify(message, type)
    end

    --- Retrieves the label of an item from the inventory system.
    --- @param itemName string The name of the item to look up.
    --- @return string GetItemLabel The item's label or "Unknown Item" if not found.
    Framework.GetItemLabel = function(itemName)
        local item = QBCore.Shared.Items[itemName]
        if item and item.label then
            return item.label
        else
            return "Unknown Item" -- Return fallback if item is not found
        end
    end

    --- Toggles the player's duty status.
    Framework.ToggleDuty = function()
        TriggerServerEvent("QBCore:ToggleDuty")
    end

    --- Checks if the player has a certain amount of an item in their inventory.
    --- @param item string The item name to check for.
    --- @param amount number The amount of the item required.
    --- @return boolean HasItem True if the player has enough of the item, false otherwise.
    Framework.HasItem = function(item, amount)
        return QBCore.Functions.HasItem(item, amount)
    end

    --- Initiates a progress bar with various options for customization.
    --- @param name string The identifier for this progress bar.
    --- @param label string The text displayed on the progress bar.
    --- @param duration number How long the progress bar lasts in milliseconds.
    --- @param useWhileDead boolean If the progress can continue after player death.
    --- @param canCancel boolean Whether the player can cancel this progress.
    --- @param disableControls table A table with booleans to disable controls during progress.
    --- @param animation table Contains the animation dictionary, clip, and flags.
    --- @param prop table Details of the prop to be used during the animation.
    --- @param propTwo table Details for an optional second prop.
    --- @param onFinish function Function to call when progress completes.
    --- @param onCancel function Function to call when progress is cancelled.
    Framework.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, {
            disableMovement = disableControls.disableMovement,
            disableCarMovement = disableControls.disableCarMovement,
            disableMouse = disableControls.disableMouse,
            disableCombat = disableControls.disableCombat,
        }, animation, prop, propTwo, onFinish, onCancel)
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

elseif SharedConfig.Framework == 'es_extended' then
    local ESX = exports['es_extended']:getSharedObject()

    --- Retrieves the player data from the ESX core.
    --- @return table PlayerData The player data table.
    Framework.GetPlayerData = function()
        return ESX.GetPlayerData()
    end

    --- Retrieves the player data from ESX by their citizen ID.
    --- @param citizenid string The citizen ID of the player.
    --- @return table|nil PlayerData The player data table, or nil if not found.
    Framework.GetPlayerByCitizenId = function(citizenid)
        local identifier = "license:" .. citizenid -- Adjust if ESX uses a different identifier scheme
        local player = ESX.GetPlayerFromIdentifier(identifier)

        -- Check if player is found and return their data
        if player then
            return player.get('playerData') -- or the appropriate method to get player data
        else
            return nil
        end
    end

    --- Notify function to display notifications to the player.
    --- @param message string The message to be displayed.
    --- @param type string The notification type (e.g., 'success', 'error').
    Framework.Notify = function(message, type)
        TriggerEvent('esx:showNotification', message)
    end

    --- Retrieves the label of an item from the inventory system.
    --- @param itemName string The name of the item to look up.
    --- @return string GetItemLabel The item's label or "Unknown Item" if not found.
    Framework.GetItemLabel = function(itemName)
        local item = ESX.GetItems()[itemName]
        if item and item.label then
            return item.label
        else
            return "Unknown Item" -- Return fallback if item is not found
        end
    end

    --- Toggles the player's duty status.
    Framework.ToggleDuty = function()
        TriggerServerEvent("esx:toggleDuty")  -- Adjust event name if necessary
    end

    --- Checks if the player has a certain amount of an item in their inventory.
    --- @param item string The item name to check for.
    --- @param amount number The amount of the item required.
    --- @return boolean HasItem True if the player has enough of the item, false otherwise.
    Framework.HasItem = function(item, amount)
        local xPlayer = ESX.GetPlayerData()
        local count = xPlayer.getInventoryItem(item).count
        return count >= amount
    end

    --- Initiates a progress bar with various options for customization.
    --- @param name string The identifier for this progress bar.
    --- @param label string The text displayed on the progress bar.
    --- @param duration number How long the progress bar lasts in milliseconds.
    --- @param useWhileDead boolean If the progress can continue after player death.
    --- @param canCancel boolean Whether the player can cancel this progress.
    --- @param disableControls table A table with booleans to disable controls during progress.
    --- @param animation table Contains the animation dictionary, clip, and flags.
    --- @param prop table Details of the prop to be used during the animation.
    --- @param propTwo table Details for an optional second prop.
    --- @param onFinish function Function to call when progress completes.
    --- @param onCancel function Function to call when progress is cancelled.
    Framework.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        TriggerEvent('esx_progressbar:start', {
            name = name,
            label = label,
            duration = duration,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            disableControls = disableControls,
            animation = animation,
            prop = prop,
            propTwo = propTwo,
            onFinish = onFinish,
            onCancel = onCancel
        })
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

else
    error("Unsupported framework: " .. (SharedConfig.Framework or "nil"))
end

return Framework