--- This section simply exports the Framework table for use in other resources.
-- @script shared/exports.lua

--- Exports a function to get a deep copy of the Framework object.
-- This exported function allows other scripts to safely access and manipulate their own copy of the Framework object without affecting the original global state.
-- This is particularly useful in multi-threaded or complex applications where maintaining isolated state is crucial.
--- @function get_object
--- @usage local Framework = exports['Dank_Utils'].Framework()
--- @return table: A deep copy of the Framework object, ensuring isolated state and no side effects on the original Framework object.
exports('Framework', function()
    return Framework
end)

CreateThread(function()
    local resourceName = GetCurrentResourceName()
    local statusMessage

    -- Check if all components are correctly detected or initialized
    if Framework.Status.Framework and Framework.Status.Inventory and Framework.Status.Banking and Framework.Status.Target and Framework.Status.Commands then
        statusMessage = "^2Dank Utils is Loaded.^0"
    else
        statusMessage = "^1Dank Utils is not ready. Please check the shared config.^0"
    end

    -- Print status messages
    print(string.format(
        "^2[^6DankLife Gaming ^2- ^0%s^2] %s\n" ..
        "^5Framework: ^3%s^0\n" ..
        "^5Inventory: ^3%s^0\n" ..
        "^5Banking: ^3%s^0\n" ..
        "^5Target: ^3%s^0\n" ..
        "^5Commands: ^3%s^0",
        resourceName,
        statusMessage,
        Framework.Status.Framework,
        Framework.Status.Inventory,
        Framework.Status.Banking,
        Framework.Status.Target,
        Framework.Status.Commands
    ))

    -- Only print the professional message if any components are missing
    local missingComponents = {}
    if Framework.Status.Framework == 'none' then
        table.insert(missingComponents, 'Frameworks')
    end
    if Framework.Status.Inventory == 'none' then
        table.insert(missingComponents, 'Inventory systems')
    end
    if Framework.Status.Banking == 'none' then
        table.insert(missingComponents, 'Banking systems')
    end
    if Framework.Status.Target == 'none' then
        table.insert(missingComponents, 'Target systems')
    end
    if Framework.Status.Commands == 'none' then
        table.insert(missingComponents, 'Commands')
    end

    if #missingComponents > 0 then
        local componentList = table.concat(missingComponents, '\n')
        local message = string.format(
            "^2[^6DankLife Gaming ^2- ^0%s^2] ^1The following supported components are missing:^0\n" ..
            "^1%s^0\n" ..
            "^1Please submit a pull request with the necessary support or open a ticket on our Discord server, and we will work to add the support promptly.^0",
            resourceName, componentList
        )
        print(message)
    end
end)