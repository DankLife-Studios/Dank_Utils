-- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

local callbacks = {}

-- Framework function to create a callback
Framework.CreateCallback = function(name, cb)
    callbacks[name] = cb
end

-- Event to handle client requests for callbacks
RegisterServerEvent('Dank_Utils:ClientRequest')
AddEventHandler('Dank_Utils:ClientRequest', function(name, requestId, ...)
    local src = source
    if callbacks[name] then
        local result = callbacks[name](src, ...)
        TriggerClientEvent('Dank_Utils:ClientResponse', src, requestId, result)
    else
        TriggerClientEvent('Dank_Utils:ClientResponse', src, requestId, nil, "Unknown callback")
    end
end)

if SharedConfig.Framework == 'qbx_core' then
    --- Retrieves a player object by their source identifier.
    --- @param source number|string The player's source identifier.
    --- @return table|nil GetPlayer The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return exports.qbx_core:GetPlayer(source)
    end

    --- Retrieves all player data from the QBX Core.
    --- @return table GetQBPlayers A table of player data where the keys are player IDs and the values are player objects.
    Framework.GetAllPlayers = function()
        return exports.qbx_core:GetQBPlayers() -- Return all players or an empty table
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

    --- Retrieves all jobs for the 'qbx_core' framework.
    --- @return table jobs A table containing all jobs for the 'qbx_core' framework.
    Framework.GetAllJobs = function()
        return exports.qbx_core:GetJobs()
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

    --- Adds a command for the QBX Core framework.
    --- @param name string The name of the command.
    --- @param description string The description of the command.
    --- @param args table List of command parameters.
    --- @param restricted boolean If true, restricts command usage to certain groups.
    --- @param callback function The function to execute when the command is invoked.
    --- @param group string The user group required to use the command.
    Framework.Commands.Add = function(name, description, args, restricted, callback, group)
        lib.addCommand(name, {
            help = description,
            params = args,
            permission = group or "user",
        }, function(source, args)
            callback(source, args)
        end)
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

elseif SharedConfig.Framework == 'qb-core' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local src = source

    --- Retrieves a player object by their source identifier.
    --- @param source number|string The player's source identifier.
    --- @return table|nil GetPlayer The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return QBCore.Functions.GetPlayer(source)
    end

    --- Retrieves all player data from QB-Core.
    --- @return table GetQBPlayers A table of player data where the keys are player IDs and the values are player objects.
    Framework.GetAllPlayers = function()
        return QBCore.Functions.GetQBPlayers() -- Return all players or an empty table
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

    --- Retrieves all jobs for the 'qb-core' framework.
    --- @return table jobs A table containing all jobs for the 'qb-core' framework.
    Framework.GetAllJobs = function()
        return QBCore.Shared.Jobs or {}
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

    --- Adds a command for the QB-Core framework.
    --- @param name string The name of the command.
    --- @param description string The description of the command.
    --- @param args table List of command parameters.
    --- @param restricted boolean If true, restricts command usage to certain groups.
    --- @param callback function The function to execute when the command is invoked.
    --- @param group string The user group required to use the command.
    Framework.Commands.Add = function(name, description, args, restricted, callback, group)
        QBCore.Commands.Add(name, description, args, restricted, function(source, _)
            callback(source, _)
        end, group)
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

elseif SharedConfig.Framework == 'es_extended' then
    local ESX = exports['es_extended']:getSharedObject()

    --- Retrieves a player object by their source identifier.
    --- @param source number The player's source identifier.
    --- @return table|nil GetPlayerFromId The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return ESX.GetPlayerFromId(source)
    end

    --- Retrieves all player data from ESX.
    --- @return table playerMap A table of player data where the keys are player IDs and the values are player objects.
    Framework.GetAllPlayers = function()
        local playerIds = ESX.GetPlayers() -- Get a list of player IDs
        local playerMap = {}

        for _, playerId in ipairs(playerIds) do
            local player = ESX.GetPlayerFromId(playerId) -- Get player object by ID
            if player then
                playerMap[playerId] = player -- Map player ID to player object
            end
        end

        return playerMap
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

    --- Retrieves all jobs for the 'es_extended' framework.
    --- @return table jobs A table containing all jobs for the 'es_extended' framework.
    Framework.GetAllJobs = function()
        if ESX and ESX.GetJobList then
            return ESX.GetJobList() or {}
        end
        return {}
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

    --- Adds a command for the ESX Extended framework.
    --- @param name string The name of the command.
    --- @param description string The description of the command.
    --- @param args table List of command parameters.
    --- @param restricted boolean If true, restricts command usage to certain groups.
    --- @param callback function The function to execute when the command is invoked.
    --- @param group string The user group required to use the command.
    Framework.Commands.Add = function(name, description, args, restricted, callback, group)
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterCommand(name, function(source, args, user)
            if restricted and (not user or user.getGroup() ~= group) then return end
            callback(source, args)
        end, false, { help = description })
    end

    Framework.Status.Framework = SharedConfig.Framework
    Framework.Status.Commands = SharedConfig.Framework

else
    error("Unsupported framework: " .. (SharedConfig.Framework or "nil"))
end

return Framework