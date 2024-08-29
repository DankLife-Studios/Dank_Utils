--- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
local sharedConfig = require 'config.shared'
Framework = Framework or {}

Framework.Status = {
    Framework = nil,
    Inventory = nil,
    Banking = nil
}

if sharedConfig.Framework == 'qbx_core' then
    local ox_inventory = exports.ox_inventory

    --- Retrieves the player data from the QBX core.
    --- @return table PlayerData The player data table.
    Framework.PlayerData = function()
        return QBX.PlayerData
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

    Framework.Status.Framework = sharedConfig.Framework

elseif sharedConfig.Framework == 'qb-core' then
    -- Initialize QBCore framework
    local QBCore = exports['qb-core']:GetCoreObject()

    --- Retrieves the player data from the QBCore core.
    --- @return table PlayerData The player data table.
    Framework.PlayerData = function()
        return QBCore.Functions.GetPlayerData()
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

    Framework.Status.Framework = sharedConfig.Framework

elseif sharedConfig.Framework == 'es_extended' then
    local ESX = exports['es_extended']:getSharedObject()

    --- Retrieves the player data from the ESX core.
    --- @return table PlayerData The player data table.
    Framework.PlayerData = function()
        return ESX.GetPlayerData()
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

    Framework.Status.Framework = sharedConfig.Framework

else
    error("Unsupported framework: " .. (sharedConfig.Framework or "nil"))
end

Framework.Inventory = {}

if sharedConfig.Banking == 'qb-management' or sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' or sharedConfig.Banking == 'Renewed-Banking' then
    Framework.Status.Banking = sharedConfig.Banking
end

Framework.Inventory = {}

if sharedConfig.Inventory == 'qb-inventory' then

    --- Opens a stash using the qb-inventory system.
    --- @param stashName string The name or identifier of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        local data = { label = stashName, maxweight = sharedConfig.InventorySpace.maxweight, slots = sharedConfig.InventorySpace.slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
    end

    Framework.Status.Inventory = sharedConfig.Inventory

elseif sharedConfig.Inventory == 'ps-inventory' then

    --- Opens a stash using the ps-inventory system.
    --- @param stashName string The name or identifier of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
        TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
            maxweight = sharedConfig.InventorySpace.maxweight,
            slots = sharedConfig.InventorySpace.slots,
        })
    end

    Framework.Status.Inventory = sharedConfig.Inventory

elseif sharedConfig.Inventory == 'ox_inventory' then
    local ox_inventory = exports.ox_inventory

    --- Opens a stash using the ox_inventory system.
    --- @param stashName string The identifier for the stash to be opened.
    Framework.Inventory.OpenStash = function(stashName)
        ox_inventory:openInventory('stash', { id = stashName })
    end

    Framework.Status.Inventory = sharedConfig.Inventory

elseif sharedConfig.Inventory == 'qs-inventory' or sharedConfig.Inventory == 'qb-old-inventory' then
    --- Opens a stash for either qs-inventory or qb-old-inventory systems.
    --- @param stashName string The name of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        local other = {}
        other.maxweight = sharedConfig.InventorySpace.maxweight
        other.slots = sharedConfig.InventorySpace.slots
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    end

    Framework.Status.Inventory = sharedConfig.Inventory

elseif sharedConfig.Inventory == 'esx_inventory' or sharedConfig.Inventory == 'es_extended' then
    local ESX = exports['es_extended']:getSharedObject()

    --- Opens a stash using the ESX inventory system.
    --- @param stashName string The name or identifier of the stash to be opened.
    Framework.Inventory.OpenStash = function(stashName)
        -- Trigger an event or server call specific to ESX inventory handling
        TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
            maxweight = sharedConfig.InventorySpace.maxweight,
            slots = sharedConfig.InventorySpace.slots
        })
    end

    Framework.Status.Inventory = sharedConfig.Inventory

else
    error("Unsupported inventory system: " .. (sharedConfig.Inventory or "nil"))
end


-- Print status message once all components are initialized
CreateThread(function()
    if Framework.Status.Framework and Framework.Status.Inventory then
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2Dank Client Utils is Loaded.^0\n" ..
      "^5Framework: ^3" .. tostring(Framework.Status.Framework) .. "^0\n" ..
      "^5Inventory: ^3" .. tostring(Framework.Status.Inventory) .. "^0\n" ..
      "^5Banking: ^3" .. tostring(Framework.Status.Banking) .. "^0")
    else
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^1Dank Utils is not ready. Please check the shared config.^0")
    end
end)

return Framework
