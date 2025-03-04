-- @module Banking
-- @desc Server-side banking operations for Dank Utils, supporting multiple banking systems.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

Framework.Banking.GetAccountBalance = function(account)
    if SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking]:GetAccount(account)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:getAccountMoney(account)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:getJobAccountBalance(account)
    else
        LogDebug('[Dank Utils] Unsupported banking system for GetAccountBalance: ' .. tostring(SharedConfig.Banking))
        return nil
    end
end

Framework.Banking.AddMoney = function(account, amount)
    if SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking]:AddMoney(account, amount)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:addAccountMoney(account, amount)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:addJobAccountMoney(account, amount)
    else
        LogDebug('[Dank Utils] Unsupported banking system for AddMoney: ' .. tostring(SharedConfig.Banking))
        return nil
    end
end

Framework.Banking.RemoveMoney = function(account, amount)
    if SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking]:RemoveMoney(account, amount)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:removeAccountMoney(account, amount)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:removeJobAccountMoney(account, amount)
    else
        LogDebug('[Dank Utils] Unsupported banking system for RemoveMoney: ' .. tostring(SharedConfig.Banking))
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
if SharedConfig.Banking and validBanking[SharedConfig.Banking] then
    local state = GetResourceState(SharedConfig.Banking)
    if state == 'started' or state == 'starting' then
        Framework.Status.Banking = SharedConfig.Banking
    else
        LogDebug('[Dank Utils] Banking resource "' .. SharedConfig.Banking .. '" is not active.')
    end
elseif SharedConfig.Banking ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Banking option: ' .. tostring(SharedConfig.Banking))
end

return Framework