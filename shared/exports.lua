exports('Framework', function()
    return Framework
end)

CreateThread(function()
    local resourceName = GetCurrentResourceName()

    -- Wait briefly to ensure Framework.Status is populated
    Wait(1000)

    local function checkComponents()
        return Framework.Status.Framework ~= 'none' and Framework.Status.Inventory ~= 'none' and Framework.Status.Banking ~= 'none' and Framework.Status.Target ~= 'none' and Framework.Status.Phone ~= 'none' and Framework.Status.Commands ~= 'none'
    end

    local statusMessage = checkComponents() and "^2Dank Utils is Loaded.^0" or "^1Dank Utils is not ready. Check configuration.^0"
    print(string.format("^2[^6DankLife Gaming ^2- ^0%s^2] %s\n^5Framework: ^3%s^0\n^5Inventory: ^3%s^0\n^5Banking: ^3%s^0\n^5Target: ^3%s^0\n^5Phone: ^3%s^0\n^5Commands: ^3%s^0", resourceName, statusMessage, Framework.Status.Framework or 'none', Framework.Status.Inventory or 'none', Framework.Status.Banking or 'none', Framework.Status.Target or 'none', Framework.Status.Phone or 'none', Framework.Status.Commands or 'none'))

    local missingComponents = {}
    for _, component in pairs({{'Framework', Framework.Status.Framework}, {'Inventory', Framework.Status.Inventory}, {'Banking', Framework.Status.Banking}, {'Target', Framework.Status.Target}, {'Phone', Framework.Status.Phone}, {'Commands', Framework.Status.Commands}}) do
        if component[2] == 'none' then
            table.insert(missingComponents, component[1])
        end
    end

    if #missingComponents > 0 then
        local componentList = table.concat(missingComponents, ', ')
        print(string.format("^2[^6DankLife Gaming ^2- ^0%s^2] ^1Missing components: %s^0\n^1Please submit a pull request or open a ticket on our Discord.^0", resourceName, componentList))
    end
end)