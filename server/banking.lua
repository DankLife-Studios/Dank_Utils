-- @module Banking
-- @desc Server-side banking operations for Dank Utils, supporting multiple banking systems.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

local sharedConfig = require 'config.shared'

Framework.Banking.GetAccountBalance = function(account)
    if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' then
        return exports[sharedConfig.Banking]:GetAccount(account)
    elseif sharedConfig.Banking == 'Renewed-Banking' then
        return exports[sharedConfig.Banking]:getAccountMoney(account)
    elseif sharedConfig.Banking == 'esx_jobbank' then
        return exports[sharedConfig.Banking]:getJobAccountBalance(account)
    else
        LogDebug('[Dank Utils] Unsupported banking system for GetAccountBalance: ' .. tostring(sharedConfig.Banking))
        return nil
    end
end

Framework.Banking.AddMoney = function(account, amount)
    if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' then
        return exports[sharedConfig.Banking]:AddMoney(account, amount)
    elseif sharedConfig.Banking == 'Renewed-Banking' then
        return exports['Renewed-Banking']:addAccountMoney(account, amount)
    elseif sharedConfig.Banking == 'esx_jobbank' then
        return exports[sharedConfig.Banking]:addJobAccountMoney(account, amount)
    else
        LogDebug('[Dank Utils] Unsupported banking system for AddMoney: ' .. tostring(sharedConfig.Banking))
        return nil
    end
end

Framework.Banking.RemoveMoney = function(account, amount)
    print('account:', account)
    print('total_cost:', amount)
    if sharedConfig.Banking == 'okokBanking' or sharedConfig.Banking == 'qb-banking' then
        return exports[sharedConfig.Banking]:RemoveMoney(account, amount)
    elseif sharedConfig.Banking == 'Renewed-Banking' then
        return exports['Renewed-Banking']:removeAccountMoney(account, amount)
    elseif sharedConfig.Banking == 'esx_jobbank' then
        return exports[sharedConfig.Banking]:removeJobAccountMoney(account, amount)
    else
        LogDebug('[Dank Utils] Unsupported banking system for RemoveMoney: ' .. tostring(sharedConfig.Banking))
        return nil
    end
end

-- Set banking status if valid and active
local validBanking = {
    ['okokBanking'] = true,
    ['qb-banking'] = true,
    ['Renewed-Banking'] = true,
    ['esx_jobbank'] = true
}
if sharedConfig.Banking and validBanking[sharedConfig.Banking] then
    local state = GetResourceState(sharedConfig.Banking)
    if state == 'started' or state == 'starting' then
        Framework.Status.Banking = sharedConfig.Banking
    else
        LogDebug('[Dank Utils] Banking resource "' .. sharedConfig.Banking .. '" is not active.')
    end
elseif sharedConfig.Banking ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Banking option: ' .. tostring(sharedConfig.Banking))
end

return Framework