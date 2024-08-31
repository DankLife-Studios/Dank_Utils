-- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Banking = Framework.Banking or {}

if SharedConfig.Banking == 'qb-management' or SharedConfig.Banking == 'okokBanking' or SharedConfig.Banking == 'qb-banking' then
    --- Retrieves the balance of an account.
    --- @param account string The name of the account to check.
    --- @return number|nil GetAccountBalance The balance of the account or nil if the operation fails.
    Framework.Banking.GetAccountBalance = function(account)
        return exports[SharedConfig.Banking]:GetAccount(account)
    end

    --- Adds money to an account.
    --- @param account string The name of the account to add money to.
    --- @param amount number The amount of money to add.
    --- @return boolean AddMoney True if money was added successfully, false otherwise.
    Framework.Banking.AddMoney = function(account, amount)
        return exports[SharedConfig.Banking].AddMoney(account, amount)
    end

    --- Removes money from an account.
    --- @param account string The name of the account to remove money from.
    --- @param amount number The amount of money to remove.
    --- @return boolean RemoveMoney True if money was removed successfully, false otherwise.
    Framework.Banking.RemoveMoney = function(account, amount)
        return exports[SharedConfig.Banking].RemoveMoney(account, amount)
    end

    Framework.Status.Banking = SharedConfig.Banking

elseif SharedConfig.Banking == 'Renewed-Banking' then
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

    Framework.Status.Banking = SharedConfig.Banking

elseif SharedConfig.Banking == 'esx_jobbank' then
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

    Framework.Status.Banking = SharedConfig.Banking

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

return Framework