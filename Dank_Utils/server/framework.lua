--- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
local sharedConfig = require 'config.shared'
Framework = Framework or {}
Framework.Status = {}

if sharedConfig.Framework == 'qbx_core' then
    --- Retrieves a player object by their source identifier.
    --- @param source number|string The player's source identifier.
    --- @return table|nil GetPlayer The player object if found, otherwise nil.
    Framework.GetPlayer = function(source)
        return exports.qbx_core:GetPlayer(source)
    end

    --- Retrieves all player data from the QBX Core.
    --- @return table GetQBPlayers A table of player data where the keys are player IDs and the values are player objects.
    Framework.GetAllPlayers = function()
        return exports.qbx_core:GetQBPlayers() or {} -- Return all players or an empty table
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

    --- Retrieves all player data from QB-Core.
    --- @return table GetQBPlayers A table of player data where the keys are player IDs and the values are player objects.
    Framework.GetAllPlayers = function()
        return QBCore.Functions.GetQBPlayers() or {} -- Return all players or an empty table
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

    Framework.Status.Framework = sharedConfig.Framework

elseif sharedConfig.Framework == 'es_extended' then
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

    --- Adds money to an account.
    --- @param account string The name of the account to add money to.
    --- @param amount number The amount of money to add.
    --- @return boolean AddMoney True if money was added successfully, false otherwise.
    Framework.Banking.AddMoney = function(account, amount)
        return exports[sharedConfig.Banking].AddMoney(account, amount)
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

    --- Adds money to an account for Renewed-Banking.
    --- @param account string The name of the account to add money to.
    --- @param amount number The amount of money to add.
    --- @return boolean AddMoney True if money was added successfully, false otherwise.
    Framework.Banking.AddMoney = function(account, amount)
        return exports['Renewed-Banking']:addAccountMoney(account, amount)
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

    --- Adds money to a job account for esx_jobbank.
    --- @param job string The job to add money to.
    --- @param amount number The amount of money to add.
    --- @return boolean AddMoney True if money was added successfully, false otherwise.
    Framework.Banking.AddMoney = function(job, amount)
        return exports['esx_jobbank']:addJobAccountMoney(job, amount)
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
    --- Retrieves the balance of an account for unsupported banking systems.
    --- @param account string The name of the account to check.
    --- @return nil nil Always returns nil as unsupported.
    Framework.Banking.GetAccountBalance = function(account)
        print("Unsupported banking system configured.")
        return nil
    end

    --- Adds money to an account for unsupported banking systems.
    --- @param account string The name of the account to add money to.
    --- @param amount number The amount of money to add.
    --- @return boolean AddMoney Always returns false as unsupported.
    Framework.Banking.AddMoney = function(account, amount)
        print("Unsupported banking system configured.")
        return false
    end

    --- Removes money from an account for unsupported banking systems.
    --- @param account string The name of the account to remove money from.
    --- @param amount number The amount of money to remove.
    --- @return boolean RemoveMoney Always returns false as unsupported.
    Framework.Banking.RemoveMoney = function(account, amount)
        print("Unsupported banking system configured. Cannot remove money.")
        return false
    end
end


Framework.Inventory = {}

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

Framework.Commands = {}

if sharedConfig.Framework == 'qbx_core' then
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

elseif sharedConfig.Framework == 'qb-core' then
    --- Adds a command for the QB-Core framework.
    --- @param name string The name of the command.
    --- @param description string The description of the command.
    --- @param args table List of command parameters.
    --- @param restricted boolean If true, restricts command usage to certain groups.
    --- @param callback function The function to execute when the command is invoked.
    --- @param group string The user group required to use the command.
    Framework.Commands.Add = function(name, description, args, restricted, callback, group)
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Commands.Add(name, description, args, restricted, function(source, _)
            callback(source, _)
        end, group)
    end

elseif sharedConfig.Framework == 'es_extended' then
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
end

Framework.Phone = {}

if sharedConfig.phone == 'qs-smartphone' then
    --- Retrieves the phone number for the 'qs-smartphone' system.
    --- @param source number The player's server ID.
    --- @return string|nil phoneNumber The phone number of the player or nil if not found.
    Framework.Phone.GetPhoneNumber = function(source)
        local Player = Framework.GetPlayer(source)
        local citizenid = Player.PlayerData.citizenid
        local mustBePhoneOwner = true
        return exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(citizenid, mustBePhoneOwner)
    end

    Framework.Status.Phone = sharedConfig.phone

elseif sharedConfig.phone == 'qb-phone' then
    --- Retrieves the phone number for the 'qb-phone' system.
    --- @param source number The player's server ID.
    --- @return string|nil phoneNumber The phone number of the player or nil if not found.
    Framework.Phone.GetPhoneNumber = function(source)
        local Player = Framework.GetPlayer(source)
        return Player.PlayerData.charinfo.phone
    end

elseif sharedConfig.phone == 'npwd' then
    --- Retrieves the phone number for the 'npwd' system.
    --- @param source number The player's server ID.
    --- @return string|nil phoneNumber The phone number of the player or nil if not found.
    Framework.Phone.GetPhoneNumber = function(source)
        return exports['npwd']:GetPhoneNumber(source)
    end

    Framework.Status.Phone = sharedConfig.phone

elseif sharedConfig.phone == 'esx_phone' then
    --- Retrieves the phone number for the 'esx_phone' system.
    --- @param source number The player's server ID.
    --- @return string|nil phoneNumber The phone number of the player or nil if not found.
    Framework.Phone.GetPhoneNumber = function(source)
        local Player = Framework.GetPlayer(source)
        local identifier = Player.PlayerData.identifier
        local phoneNumber = nil
        MySQL.Async.fetchAll('SELECT phone_number FROM users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(result)
            if result[1] then
                phoneNumber = result[1].phone_number
            end
        end)
        return phoneNumber
    end

    Framework.Status.Phone = sharedConfig.phone

else
    --- Placeholder function for unsupported phone systems.
    --- @param source number The player's server ID.
    --- @return string|nil phoneNumber Always returns nil as the phone system is unsupported.
    Framework.Phone.GetPhoneNumber = function(source)
        print("Unsupported phone system configured.")
        return nil
    end
end

return Framework
