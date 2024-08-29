--- This section simply exports the Framework table for use in other resources.
-- @script shared/exports.lua

--- Exports a function to get a deep copy of the Framework object.
-- This exported function allows other scripts to safely access and manipulate their own copy of the Framework object without affecting the original global state.
-- This is particularly useful in multi-threaded or complex applications where maintaining isolated state is crucial.
-- @function get_object
-- @usage local Framework = exports['Dank_Utils'].Framework()
-- @return table: A deep copy of the Framework object, ensuring isolated state and no side effects on the original Framework object.
exports('Framework', function()
    return Framework
end)

--- Print status message once all components are initialized
CreateThread(function()
    if Framework.Status.Framework and Framework.Status.Inventory and Framework.Status.Banking then
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^2Dank Utils is Loaded.^0\n" ..
        "^5Framework: ^3" .. tostring(Framework.Status.Framework) .. "^0\n" ..
        "^5Inventory: ^3" .. tostring(Framework.Status.Inventory) .. "^0\n" ..
        "^5Banking: ^3" .. tostring(Framework.Status.Banking) .. "^0\n" ..
        "^5Commands: ^3" .. tostring(Framework.Status.Commands) .. "^0")
    else
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^1Dank Utils is not ready. Please check the shared config.^0")
    end
end)
