local exports = exports
local print = print
local tostring = tostring
local type = type

local sharedConfig = require 'config.dankutils_shared'
local playerModule = require 'modules.player'
local LogDebug = LogDebug or function() end

---@param amount any
---@return number|nil
local function normalizeAmount(amount)
    amount = tonumber(amount)
    if not amount or amount <= 0 then return nil end
    return amount
end

---@class DankBanking
local banking = {}

if IsDuplicityVersion() then
    -- SERVER
    ---Gets the balance of a banking account.
    ---@param account string|number
    ---@return number
    banking.getAccountBalance = function(account)
        local sys = sharedConfig.Banking
        LogDebug(('[banking] getAccountBalance(account=%s) system=%s'):format(tostring(account), tostring(sys)))
        if sys == 'okokBanking' or sys == 'qb-banking' or sys == 'qb-management' or sys == 'fd_banking' then
            local data = exports[sys]:GetAccount(account)
            if type(data) == 'table' then
                return data.balance or data.account_balance or data.money or 0
            end
            return tonumber(data) or 0
        elseif sys == 'pefcl' then
            return exports.pefcl:getBankBalanceById(account) or 0
        elseif sys == 'Renewed-Banking' then
            return exports['Renewed-Banking']:getAccountMoney(account) or 0
        elseif sys == 'esx_jobbank' then
            return exports[sharedConfig.Banking]:getJobAccountBalance(account) or 0
        elseif sys == 'qs-banking' then
            return exports['qs-banking']:GetAccountMoney(account) or 0
        else
            -- Fallback: If account is a player source ID or player identifier/bank account
            LogDebug('[banking] getAccountBalance fallback (unsupported system)')
            if type(account) == 'number' then
                LogDebug(('[banking] getAccountBalance routing to player bank for source %s'):format(tostring(account)))
                return playerModule.getMoney(account, 'bank') or 0
            end
            print('^3[Dank_Utils] Banking getAccountBalance fallback applied for: ' .. tostring(sys) .. '^0')
            return 0
        end
    end

    ---@param account string|number
    ---@param amount number
    ---@return any
    banking.addMoney = function(account, amount)
        amount = normalizeAmount(amount)
        if not amount then return false end
        local sys = sharedConfig.Banking
        LogDebug(('[banking] addMoney(account=%s, amount=%s) system=%s'):format(tostring(account), tostring(amount), tostring(sys)))
        if sys == 'okokBanking' or sys == 'qb-banking' or sys == 'qb-management' or sys == 'fd_banking' then
            return exports[sys]:AddMoney(account, amount)
        elseif sys == 'pefcl' then
            return exports.pefcl:addBankBalanceById(account, amount)
        elseif sys == 'Renewed-Banking' then
            pcall(function()
                exports['Renewed-Banking']:handleTransaction(account, 'Society Deposit', amount, 'Society funds deposited', account, account, 'deposit')
            end)
            return exports['Renewed-Banking']:addAccountMoney(account, amount)
        elseif sys == 'esx_jobbank' then
            return exports[sharedConfig.Banking]:addJobAccountMoney(account, amount)
        elseif sys == 'qs-banking' then
            return exports['qs-banking']:AddMoney(account, amount)
        else
            if type(account) == 'number' then
                return playerModule.addMoney(account, 'bank', amount, 'Society / Bank deposit')
            end
            print('^3[Dank_Utils] Banking addMoney unhandled for: ' .. tostring(sys) .. '^0')
            return false
        end
    end

    ---@param account string|number
    ---@param amount number
    ---@return any
    banking.removeMoney = function(account, amount)
        amount = normalizeAmount(amount)
        if not amount then return false end
        local sys = sharedConfig.Banking
        LogDebug(('[banking] removeMoney(account=%s, amount=%s) system=%s'):format(tostring(account), tostring(amount), tostring(sys)))
        if sys == 'okokBanking' or sys == 'qb-banking' or sys == 'qb-management' or sys == 'fd_banking' then
            return exports[sys]:RemoveMoney(account, amount)
        elseif sys == 'pefcl' then
            return exports.pefcl:removeBankBalanceById(account, amount)
        elseif sys == 'Renewed-Banking' then
            pcall(function()
                exports['Renewed-Banking']:handleTransaction(account, 'Society Withdrawal', amount, 'Society funds withdrawn', account, account, 'withdraw')
            end)
            return exports['Renewed-Banking']:removeAccountMoney(account, amount)
        elseif sys == 'esx_jobbank' then
            return exports[sharedConfig.Banking]:removeJobAccountMoney(account, amount)
        elseif sys == 'qs-banking' then
            return exports['qs-banking']:RemoveMoney(account, amount)
        else
            if type(account) == 'number' then
                return playerModule.removeMoney(account, 'bank', amount, 'Society / Bank withdrawal')
            end
            print('^3[Dank_Utils] Banking removeMoney unhandled for: ' .. tostring(sys) .. '^0')
            return false
        end
    end
end

return banking
