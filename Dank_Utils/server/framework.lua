--- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx-core, qb-core, and es_extended.
local sharedConfig = require 'config.shared'
local Framework = {}

Framework.Status = {
    Framework = nil,
    Inventory = nil,
    Banking = nil
}

if sharedConfig.Framework == 'qbx-core' then
    --- Retrieves a player object by their source identifier.
    --- @param source number|string The player's source identifier.
    --- @return table|nil GetPlayer The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return exports.qbx_core:GetPlayer(source)
    end

    --- Removes a specified amount of an item from a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to remove.
    --- @param amount number The quantity of the item to remove.
    --- @return boolean RemoveItem True if the item was successfully removed, false otherwise.
    Framework.RemoveItem = function(source, item, amount)
        return exports.qbx_core:RemoveItem(item, amount)
    end

    --- Adds a specified amount of an item to a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to add.
    --- @param amount number The quantity of the item to add.
    --- @return boolean AddItem True if the item was successfully added, false otherwise.
    Framework.AddItem = function(source, item, amount)
        return exports.qbx_core:AddItem(item, amount)
    end

    --- Adds money to a player's account.
    --- @param source number|string The player's source identifier.
    --- @param moneyType string The type of money (e.g., 'cash', 'bank').
    --- @param payment number The amount of money to add.
    --- @param message string|nil An optional message to display to the player.
    Framework.AddMoney = function(source, moneyType, payment, message)
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.Functions.AddMoney(moneyType, payment, message)
    end

        --- Sends a notification to a player.
    --- @param source number|string The player's source identifier.
    --- @param message string The message to be displayed in the notification.
    --- @param messageType string The type of notification (e.g., 'success', 'error').
    Framework.Notify = function(source, message, messageType)
        exports.qbx_core:Notify(source, message, messageType)
    end

    --- Retrieves an item by name from a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to retrieve.
    --- @return table|nil GetItemByName The item object if found, otherwise nil.
    Framework.GetItemByName = function(source, item)
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        return Player.Functions.GetItemByName(item)
    end

    --- Registers a callback for when a specific item is used.
    --- @param item string The name of the item that triggers the callback.
    --- @param callback function The function to call when the item is used, receiving the player's source as an argument.
    Framework.CreateUseableItem = function(item, callback)
        exports.qbx_core:CreateUseableItem(item, function(source)
            callback(source)
        end)
    end

    --- Checks if a player has a specified item in their inventory with ox_inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to check for.
    --- @param amount number The minimum amount of the item required.
    --- @return boolean HasItem True if the player has at least the specified amount of the item, false otherwise.
    Framework.HasItem = function(source, item, amount)
        local inventory = exports.ox_inventory:GetInventory(source)
        if inventory and inventory[item] and inventory[item].count >= amount then
            return true
        end
        return false
    end

    Framework.Status.Framework = sharedConfig.Framework

elseif sharedConfig.Framework == 'qb-core' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local src = source

    --- Retrieves a player object by their source identifier.
    --- @param source number|string The player's source identifier.
    --- @return table|nil GetPlayer The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end

    --- Removes a specified amount of an item from a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to remove.
    --- @param amount number The quantity of the item to remove.
    --- @return boolean RemoveItem True if the item was successfully removed, false otherwise.
    Framework.RemoveItem = function(source, item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
        return QBCore.Functions.RemoveItem(item, amount)
    end

    --- Adds a specified amount of an item to a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to add.
    --- @param amount number The quantity of the item to add.
    --- @return boolean AddItem True if the item was successfully added, false otherwise.
    Framework.AddItem = function(source, item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
        return QBCore.Functions.AddItem(item, amount)
    end

    --- Adds money to a player's account.
    --- @param source number|string The player's source identifier.
    --- @param moneyType string The type of money (e.g., 'cash', 'bank').
    --- @param payment number The amount of money to add.
    --- @param message string|nil An optional message to display to the player.
    Framework.AddMoney = function(source, moneyType, payment, message)
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.Functions.AddMoney(moneyType, payment, message)
    end

    --- Sends a notification to a player.
    --- @param source number|string The player's source identifier.
    --- @param message string The message to be displayed in the notification.
    --- @param messageType string The type of notification (e.g., 'success', 'error').
    Framework.Notify = function(source, message, messageType)
        TriggerClientEvent('QBCore:Notify', source, message, messageType)
    end

    --- Retrieves an item by name from a player's inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to retrieve.
    --- @return table|nil GetItemByName The item object if found, otherwise nil.
    Framework.GetItemByName = function(source, item)
        local Player = Framework.GetPlayer(source)
        if Player then
            return Player.Functions.GetItemByName(item)
        else return nil end
    end
    --- Registers a callback for when a specific item is used.
    --- @param item string The name of the item that triggers the callback.
    --- @param callback function The function to call when the item is used, receiving the player's source as an argument.
    Framework.CreateUseableItem = function(item, callback)
        QBCore.Functions.CreateUseableItem(item, function(source)
            callback(source)
        end)
    end

    --- Checks if a player has a specified item in their inventory.
    --- @param source number|string The player's source identifier.
    --- @param item string The name of the item to check for.
    --- @param amount number The minimum amount of the item required.
    --- @return boolean HasItem True if the player has at least the specified amount of the item, false otherwise.
    Framework.HasItem = function(source, item, amount)
        local Player = Framework.GetPlayer(source)
        if Player then
            return Player.Functions.HasItem(item, amount)
        else
            return false
        end
    end

    Framework.Status.Framework = sharedConfig.Framework

elseif sharedConfig.Framework == 'es_extended' then
    local ESX = exports['es_extended']:getSharedObject()

    --- Retrieves a player object by their source identifier.
    --- @param source number The player's source identifier.
    --- @return table|nil GetPlayerFromId The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return ESX.GetPlayerFromId(source)
    end

    --- Removes a specified amount of an item from a player's inventory.
    --- @param source number The player's source identifier.
    --- @param item string The name of the item to remove.
    --- @param amount number The quantity of the item to remove.
    Framework.RemoveItem = function(source, item, amount)
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            xPlayer.removeInventoryItem(item, amount)
            TriggerClientEvent('esx_inventory:client:ItemBox', source, item, 'remove')
        else
            return false
        end
    end

    --- Adds a specified amount of an item to a player's inventory.
    --- @param source number The player's source identifier.
    --- @param item string The name of the item to add.
    --- @param amount number The quantity of the item to add.
    Framework.AddItem = function(source, item, amount)
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            xPlayer.addInventoryItem(item, amount)
            TriggerClientEvent('esx_inventory:client:ItemBox', source, item, 'add')
        else
            return false
        end
    end

    --- Adds money to a player's account.
    --- @param source number The player's source identifier.
    --- @param moneyType string The type of money ('money', 'bank', or 'black').
    --- @param amount number The amount of money to add.
    --- @param message string|nil An optional message to display to the player.
    Framework.AddMoney = function(source, moneyType, amount, message)
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            if moneyType == 'money' then
                xPlayer.addMoney(amount)
            elseif moneyType == 'bank' then
                xPlayer.addAccountMoney('bank', amount)
            elseif moneyType == 'black' then
                xPlayer.addAccountMoney('black_money', amount)
            end
        end
        if message then
            TriggerClientEvent('esx:showNotification', source, message)
        end
    end

    --- Sends a notification to a player.
    --- @param source number The player's source identifier.
    --- @param message string The message to be displayed in the notification.
    --- @param messageType string|nil Currently not used in es_extended, but included for consistency.
    Framework.Notify = function(source, message, messageType)
        TriggerClientEvent('esx:showNotification', source, message)
    end

    --- Retrieves an item by name from a player's inventory.
    --- @param source number The player's source identifier.
    --- @param item string The name of the item to retrieve.
    --- @return table getInventoryItem The item object.
    Framework.GetItemByName = function(source, item)
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            return xPlayer.getInventoryItem(item)
        else
            return {}
        end
    end

    --- Registers a callback for when a specific item is used.
    --- @param item string The name of the item that triggers the callback.
    --- @param callback function The function to call when the item is used, receiving the player's source as an argument.
    Framework.CreateUseableItem = function(item, callback)
        ESX.RegisterUsableItem(item, function(source)
            callback(source)
        end)
    end

    --- Checks if a player has a specified item in their inventory.
    --- @param source number The player's source identifier.
    --- @param item string The name of the item to check for.
    --- @param amount number The minimum amount of the item required.
    Framework.HasItem = function(source, item, amount)
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            return xPlayer.getInventoryItem(item).count >= amount
        else
            return false
        end
    end

    Framework.Status.Framework = sharedConfig.Framework
else
    error("Unsupported framework: " .. (sharedConfig.Framework or "nil"))
end

Framework.Banking = {}

if sharedConfig.Banking == 'qb-management' or sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' then
    --- Retrieves the balance of an account.
    --- @param account string The name of the account to check.
    --- @return number|nil GetAccountBalance The balance of the account or nil if the operation fails.
    Framework.Banking.GetAccountBalance = function(account)
        return exports[sharedConfig.Banking]:GetAccount(account)
    end

    --- Removes money from an account.
    --- @param account string The name of the account to remove money from.
    --- @param amount number The amount of money to remove.
    --- @return boolean RemoveMoney True if money was removed successfully, false otherwise.
    Framework.Banking.RemoveMoney = function(account, amount)
        return exports[sharedConfig.Banking].RemoveMoney(account, amount)
    end

    Framework.Status.Banking = sharedConfig.Banking

elseif sharedConfig.Banking == 'Renewed-Banking' then
    --- Retrieves the balance of an account for Renewed-Banking.
    --- @param account string The name of the account to check.
    --- @return number|nil GetAccountBalance The balance of the account or nil if the operation fails.
    Framework.Banking.GetAccountBalance = function(account)
        return exports['Renewed-Banking']:getAccountMoney(account)
    end

    --- Removes money from an account for Renewed-Banking.
    --- @param account string The name of the account to remove money from.
    --- @param amount number The amount of money to remove.
    --- @return boolean RemoveMoney True if money was removed successfully, false otherwise.
    Framework.Banking.RemoveMoney = function(account, amount)
        return exports['Renewed-Banking']:removeAccountMoney(account, amount)
    end

    Framework.Status.Banking = sharedConfig.Banking

elseif sharedConfig.Banking == 'esx_jobbank' then
    --- Retrieves the balance of a job account for esx_jobbank.
    --- @param job string The job to check.
    --- @return number|nil GetAccountBalance The balance of the job account or nil if the operation fails.
    Framework.Banking.GetAccountBalance = function(job)
        return exports['esx_jobbank']:getJobAccountBalance(job)
    end

    --- Removes money from a job account for esx_jobbank.
    --- @param job string The job to remove money from.
    --- @param amount number The amount of money to remove.
    --- @return boolean RemoveMoney True if money was removed successfully, false otherwise.
    Framework.Banking.RemoveMoney = function(job, amount)
        return exports['esx_jobbank']:removeJobAccountMoney(job, amount)
    end

    Framework.Status.Banking = sharedConfig.Banking

else
    --- Placeholder functions for unsupported banking systems
    Framework.Banking.GetAccountBalance = function()
        print("Unsupported banking system configured.")
        return nil
    end

    Framework.Banking.RemoveMoney = function()
        print("Unsupported banking system configured. Cannot remove money.")
        return false
    end
end

-- Initialize Inventory
if sharedConfig.Inventory == 'ox_inventory' then

    --- Function to register a stash with ox_inventory
    --- @param stashId string The unique identifier for the stash.
    --- @param stashData table The data associated with the stash.
    Framework.Inventory.RegisterStash = function(stashId, stashData)
        local stashLabel = stashData.label or 'Default Stash' -- Default label if not provided
        local stashSlots = stashData.slots or 50 -- Default slots if not provided
        local stashWeight = stashData.weight or 100000 -- Default weight if not provided

        -- Register stash with ox_inventory
        exports.ox_inventory:RegisterStash(stashId, stashLabel, stashSlots, stashWeight, false)
    end

    Framework.Status.Inventory = sharedConfig.Inventory

end

--- Print status message once all components are initialized
CreateThread(function()
    Wait(500) -- Delay to ensure all components are properly initialized
    if Framework.Status.Framework and Framework.Status.Inventory and Framework.Status.Banking then
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2Dank Server Utils is Loaded. ^5Framework: ^3" .. tostring(Framework.Status.Framework) .. " ^5Inventory: ^3" .. tostring(Framework.Status.Inventory) .. " ^5Banking: ^3" .. tostring(Framework.Status.Banking) .. "^0")
    else
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^1Dank Utils is not ready. Please check the shared config.^0")
    end
end)


return Framework