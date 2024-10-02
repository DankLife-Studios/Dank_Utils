Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

Framework.Banking.GetAccountBalance = function(account)
    if SharedConfig.Banking == 'qb-management' or SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking]:GetAccount(account)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:getAccountMoney(account)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:getJobAccountBalance(account)
    else
        return 0
    end
end

Framework.Banking.GetAccount = function(account)
    if SharedConfig.Banking == 'qb-management' or SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking]:GetAccount(account)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:getAccountMoney(account)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:getJobAccountBalance(account)
    end
end

Framework.Banking.AddMoney = function(account, amount)
    if SharedConfig.Banking == 'qb-management' or SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking].AddMoney(account, amount)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:addAccountMoney(account, amount)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:addJobAccountMoney(account, amount)
    end
end

Framework.Banking.RemoveMoney = function(account, amount)
    if SharedConfig.Banking == 'qb-management' or SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
        return exports[SharedConfig.Banking].RemoveMoney(account, amount)
    elseif SharedConfig.Banking == 'Renewed-Banking' then
        return exports[SharedConfig.Banking]:removeAccountMoney(account, amount)
    elseif SharedConfig.Banking == 'esx_jobbank' then
        return exports[SharedConfig.Banking]:removeJobAccountMoney(account, amount)
    end
end

if SharedConfig.Banking then
    Framework.Status.Banking = SharedConfig.Banking
end

return Framework