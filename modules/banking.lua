local exports = exports
local print = print
local tostring = tostring

local sharedConfig = require 'config.shared'
local banking = {}

if IsDuplicityVersion() then
    -- SERVER
    banking.getAccountBalance = function(account)
        if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' or sharedConfig.Banking == 'qb-management' or sharedConfig.Banking == 'fd_banking' then
            local balance = exports[sharedConfig.Banking]:GetAccount(account)
            return balance
        elseif sharedConfig.Banking == 'pefcl' then
            return exports.pefcl:getBankBalanceById(account)
        elseif sharedConfig.Banking == 'Renewed-Banking' then
            local balance = exports['Renewed-Banking']:getAccountMoney(account)
            return balance
        elseif sharedConfig.Banking == 'esx_jobbank' then
            local balance = exports[sharedConfig.Banking]:getJobAccountBalance(account)
            return balance
        else
            print('^3[Dank_Utils] Unsupported banking system for getAccountBalance: ' .. tostring(sharedConfig.Banking) .. '^0')
            return nil
        end
    end

    banking.addMoney = function(account, amount)
        if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' or sharedConfig.Banking == 'qb-management' or sharedConfig.Banking == 'fd_banking' then
            return exports[sharedConfig.Banking]:AddMoney(account, amount)
        elseif sharedConfig.Banking == 'pefcl' then
            return exports.pefcl:addBankBalanceById(account, amount)
        elseif sharedConfig.Banking == 'Renewed-Banking' then
            exports['Renewed-Banking']:handleTransaction(account, 'Society Deposit', amount, 'Society funds deposited', account, account, 'deposit')
            return exports['Renewed-Banking']:addAccountMoney(account, amount)
        elseif sharedConfig.Banking == 'esx_jobbank' then
            return exports[sharedConfig.Banking]:addJobAccountMoney(account, amount)
        else
            print('^3[Dank_Utils] Unsupported banking system for addMoney: ' .. tostring(sharedConfig.Banking) .. '^0')
            return nil
        end
    end

    banking.removeMoney = function(account, amount)
        if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' or sharedConfig.Banking == 'qb-management' or sharedConfig.Banking == 'fd_banking' then
            return exports[sharedConfig.Banking]:RemoveMoney(account, amount)
        elseif sharedConfig.Banking == 'pefcl' then
            return exports.pefcl:removeBankBalanceById(account, amount)
        elseif sharedConfig.Banking == 'Renewed-Banking' then
            exports['Renewed-Banking']:handleTransaction(account, 'Society Withdrawal', amount, 'Society funds withdrawn', account, account, 'withdraw')
            return exports['Renewed-Banking']:removeAccountMoney(account, amount)
        elseif sharedConfig.Banking == 'esx_jobbank' then
            return exports[sharedConfig.Banking]:removeJobAccountMoney(account, amount)
        else
            print('^3[Dank_Utils] Unsupported banking system for removeMoney: ' .. tostring(sharedConfig.Banking) .. '^0')
            return nil
        end
    end
end

return banking
